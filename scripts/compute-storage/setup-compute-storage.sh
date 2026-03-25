#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script — Domain 3: Secure Compute, Storage, and Databases
# Provisions: VM with system-assigned identity, secure storage account,
#             SQL Server with AD admin + ATP + auditing + private endpoint,
#             Azure Disk Encryption
#
# Usage:
#   export TENANT_DOMAIN="<your-tenant>.onmicrosoft.com"
#   chmod +x setup-compute-storage.sh
#   ./setup-compute-storage.sh
#
# Cleanup:
#   az group delete --name az500-compute-rg --yes --no-wait
#
# ⚠️  COST WARNING: This script provisions a VM (~$0.10/hr), SQL (~$0.36/hr).
#                  Clean up after lab.
# =============================================================================
set -euo pipefail

# ---------- Configuration ----------------------------------------------------
RESOURCE_GROUP="az500-compute-rg"
LOCATION="${LOCATION:-eastus}"
TIMESTAMP=$(date +%s | tail -c 8)
VM_NAME="lab-vm"
SA_NAME="az500store${TIMESTAMP}"
SQL_SERVER="az500sql${TIMESTAMP}"
SQL_DB="labsecdb"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="SqlAdmin@Lab2024!"
KV_ADE_NAME="az500-ade-kv-${TIMESTAMP}"
: "${TENANT_DOMAIN:?Set TENANT_DOMAIN env variable}"

# ---------- Helper ------------------------------------------------------------
log() { echo "[$(date '+%H:%M:%S')] $*"; }

# ---------- Resource Group ---------------------------------------------------
log "Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

SUB_ID=$(az account show --query id -o tsv)

# ---------- VM with System-Assigned Managed Identity -------------------------
log "Creating VNet for VM"
az network vnet create \
  --name lab-vnet \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --address-prefix 10.100.0.0/16 \
  --subnet-name vm-subnet \
  --subnet-prefix 10.100.1.0/24 \
  --output none

log "Deploying Linux VM with system-assigned managed identity"
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name lab-vnet \
  --subnet vm-subnet \
  --public-ip-sku Standard \
  --assign-identity \
  --nsg "" \
  --output none

VM_PRINCIPAL=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --query identity.principalId -o tsv)

log "VM system-assigned managed identity principal: $VM_PRINCIPAL"

# ---------- Key Vault for ADE ------------------------------------------------
log "Creating Key Vault for Azure Disk Encryption: $KV_ADE_NAME"
az keyvault create \
  --name "$KV_ADE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --enabled-for-disk-encryption true \
  --enable-soft-delete true \
  --sku standard \
  --output none

# ---------- Azure Disk Encryption --------------------------------------------
log "Enabling Azure Disk Encryption on VM (this takes 5–10 minutes...)"
az vm encryption enable \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --disk-encryption-keyvault "$KV_ADE_NAME" \
  --volume-type All \
  --output none

# ---------- Secure Storage Account -------------------------------------------
log "Creating secure storage account: $SA_NAME"
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --https-only true \
  --min-tls-version TLS1_2 \
  --default-action Deny \
  --allow-blob-public-access false \
  --output none

SA_ID=$(az storage account show --name "$SA_NAME" --resource-group "$RESOURCE_GROUP" --query id -o tsv)

log "Adding service endpoint to VM subnet for storage"
az network vnet subnet update \
  --name vm-subnet \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name lab-vnet \
  --service-endpoints Microsoft.Storage \
  --output none

log "Adding VNet rule to storage account for vm-subnet"
az storage account network-rule add \
  --account-name "$SA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name lab-vnet \
  --subnet vm-subnet \
  --output none

log "Assigning Storage Blob Data Reader to VM managed identity"
az role assignment create \
  --assignee-object-id "$VM_PRINCIPAL" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Reader" \
  --scope "$SA_ID" \
  --output none

# Create a container and upload a test blob
log "Creating storage container and test blob"
az storage container create \
  --name labdata \
  --account-name "$SA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --auth-mode login \
  --output none 2>/dev/null || log "Container creation skipped (may already exist)"

# ---------- Azure SQL Server -------------------------------------------------
log "Creating Azure SQL Server: $SQL_SERVER"
az sql server create \
  --name "$SQL_SERVER" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --admin-user "$SQL_ADMIN" \
  --admin-password "$SQL_PASSWORD" \
  --output none

log "Creating database: $SQL_DB"
az sql db create \
  --name "$SQL_DB" \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --edition GeneralPurpose \
  --compute-model Serverless \
  --family Gen5 \
  --capacity 1 \
  --auto-pause-delay 60 \
  --output none

# Set Entra ID admin on SQL
MY_UPN=$(az ad signed-in-user show --query userPrincipalName -o tsv)
MY_OID=$(az ad signed-in-user show --query id -o tsv)

log "Setting Entra ID admin on SQL Server"
az sql server ad-admin create \
  --resource-group "$RESOURCE_GROUP" \
  --server-name "$SQL_SERVER" \
  --display-name "AZ500 SQL Admin" \
  --object-id "$MY_OID" \
  --output none

# Enable Advanced Threat Protection
log "Enabling Advanced Threat Protection (Defender for SQL)"
az sql server threat-policy update \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --state Enabled \
  --storage-account "$SA_NAME" \
  --output none

# Enable SQL Auditing
log "Enabling SQL Auditing → Storage Account"
az sql server audit-policy update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER" \
  --state Enabled \
  --blob-auditing-policy Enabled \
  --storage-account "$SA_NAME" \
  --output none

# ---------- SQL Private Endpoint ---------------------------------------------
log "Disabling public network access on SQL Server"
az sql server update \
  --name "$SQL_SERVER" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-public-network false \
  --output none

log "Creating Private Endpoint for SQL Server"
SQL_SERVER_ID=$(az sql server show \
  --name "$SQL_SERVER" \
  --resource-group "$RESOURCE_GROUP" \
  --query id -o tsv)

az network vnet subnet update \
  --name vm-subnet \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name lab-vnet \
  --disable-private-endpoint-network-policies true \
  --output none

az network private-endpoint create \
  --name sql-pe \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --vnet-name lab-vnet \
  --subnet vm-subnet \
  --private-connection-resource-id "$SQL_SERVER_ID" \
  --group-id sqlServer \
  --connection-name sql-pe-connection \
  --output none

log "Creating Private DNS Zone for SQL"
az network private-dns zone create \
  --resource-group "$RESOURCE_GROUP" \
  --name "privatelink.database.windows.net" \
  --output none

az network private-dns link vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --zone-name "privatelink.database.windows.net" \
  --name lab-vnet-sql-dns-link \
  --virtual-network lab-vnet \
  --registration-enabled false \
  --output none

az network private-endpoint dns-zone-group create \
  --resource-group "$RESOURCE_GROUP" \
  --endpoint-name sql-pe \
  --name sql-dns-group \
  --private-dns-zone "privatelink.database.windows.net" \
  --zone-name "privatelink.database.windows.net" \
  --output none

# ---------- Summary -----------------------------------------------------------
cat <<EOF

=============================================================================
 AZ-500 Compute/Storage/DB Lab — Provisioning Complete
=============================================================================
 Resource Group   : $RESOURCE_GROUP
 Location         : $LOCATION
 VM               : $VM_NAME (Ubuntu 22.04, system-assigned MI)
   - ADE enabled  : Yes (Key Vault: $KV_ADE_NAME)
   - MI Principal : $VM_PRINCIPAL
 Storage Account  : $SA_NAME
   - HTTPS only   : true
   - Default action: Deny
   - Public blobs  : disabled
   - VM identity   : Storage Blob Data Reader
 SQL Server       : $SQL_SERVER.database.windows.net
   - Database      : $SQL_DB (Serverless Gen5)
   - Entra ID admin: $MY_UPN
   - ATP enabled   : Yes
   - Auditing      : Yes (→ $SA_NAME)
   - Public access : Disabled
   - Private EP    : sql-pe

 💡 Next Step: Configure Dynamic Data Masking on a column via the portal.
 💡 Next Step: Set up Always Encrypted using SSMS or Azure Data Studio.

 ⚠️  COST NOTICE: VM + SQL together cost ~$0.50/hr.
 🧹  CLEANUP:
     az group delete --name $RESOURCE_GROUP --yes --no-wait
=============================================================================
EOF
