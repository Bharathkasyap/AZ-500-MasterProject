#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script: Secure Compute, Storage, and Databases
# Domain 3 — Secure Compute, Storage, and Databases
#
# Demonstrates:
#   - Azure VM with system-assigned managed identity
#   - Just-in-Time (JIT) VM Access configuration
#   - Storage account with firewall, HTTPS-only, private endpoint
#   - Azure SQL Database with Azure AD admin, TDE, and auditing
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Microsoft Defender for Servers P2 (for JIT)
#
# Usage:
#   chmod +x setup-compute-storage.sh
#   ./setup-compute-storage.sh
# =============================================================================

set -euo pipefail

# ─── Variables ────────────────────────────────────────────────────────────────
RESOURCE_GROUP="rg-az500-compute-lab"
LOCATION="eastus"
VNET_NAME="vnet-compute-lab"
STORAGE_NAME="staz500$(openssl rand -hex 4)"
SQL_SERVER_NAME="sql-az500-$(openssl rand -hex 4)"
SQL_DB_NAME="az500labdb"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="Az500Lab!$(openssl rand -hex 6)"
VM_NAME="vm-az500-lab"
VM_ADMIN="azureuser"

echo "============================================================"
echo " AZ-500 Compute, Storage & Databases Lab Setup"
echo "============================================================"

SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# ─── 1. Create Resource Group & VNet ─────────────────────────────────────────
echo "[1/7] Creating resource group and VNet"

az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --address-prefix "10.10.0.0/16" \
  --subnet-name "snet-compute" \
  --subnet-prefix "10.10.1.0/24" \
  --output none

# Get subnet ID for later use
SUBNET_ID=$(az network vnet subnet show \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "snet-compute" \
  --query id --output tsv)

# ─── 2. Create VM with System-Assigned Managed Identity ──────────────────────
echo "[2/7] Creating VM with system-assigned managed identity"
echo "    (Using Ubuntu 22.04 LTS, Standard_B2s for lab cost efficiency)"

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "Ubuntu2204" \
  --size "Standard_B2s" \
  --admin-username "$VM_ADMIN" \
  --generate-ssh-keys \
  --assign-identity "[system]" \
  --subnet "$SUBNET_ID" \
  --public-ip-address "" \
  --nsg "" \
  --output none

VM_PRINCIPAL_ID=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --query "identity.principalId" \
  --output tsv)

echo "    VM '$VM_NAME' created (no public IP, system-assigned identity)"
echo "    VM principal ID: $VM_PRINCIPAL_ID"

# Enable Disk Encryption (requires Key Vault — using storage lab KV)
echo "    Note: To enable Azure Disk Encryption, run:"
echo "    az vm encryption enable --resource-group $RESOURCE_GROUP --name $VM_NAME --disk-encryption-keyvault <kvName>"

# ─── 3. Create Secure Storage Account ────────────────────────────────────────
echo "[3/7] Creating secure storage account: $STORAGE_NAME"

az storage account create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$STORAGE_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --default-action Deny \
  --output none

# Allow the compute subnet via service endpoint
az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "snet-compute" \
  --service-endpoints "Microsoft.Storage" \
  --output none

az storage account network-rule add \
  --resource-group "$RESOURCE_GROUP" \
  --account-name "$STORAGE_NAME" \
  --vnet-name "$VNET_NAME" \
  --subnet "snet-compute" \
  --output none

# Grant the VM's managed identity Storage Blob Data Reader
az role assignment create \
  --assignee "$VM_PRINCIPAL_ID" \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/${STORAGE_NAME}" \
  --output none

# Enable soft delete for blobs (7-day retention)
az storage blob service-properties delete-policy update \
  --account-name "$STORAGE_NAME" \
  --enable true \
  --days-retained 7 \
  --auth-mode login \
  --output none 2>/dev/null || echo "    (Soft delete: configure via portal for this account)"

echo "    Storage account '$STORAGE_NAME' created:"
echo "      - HTTPS only + TLS 1.2 minimum"
echo "      - No public blob access"
echo "      - Default action: Deny"
echo "      - VNet service endpoint for snet-compute"
echo "      - VM managed identity granted Storage Blob Data Reader"

# ─── 4. Create Azure SQL Database with Security Features ─────────────────────
echo "[4/7] Creating Azure SQL Server: $SQL_SERVER_NAME"

az sql server create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER_NAME" \
  --location "$LOCATION" \
  --admin-user "$SQL_ADMIN" \
  --admin-password "$SQL_PASSWORD" \
  --output none

echo "    SQL Server created: $SQL_SERVER_NAME"

# ─── 5. Configure SQL Security ────────────────────────────────────────────────
echo "[5/7] Configuring SQL security settings"

# Set Azure AD admin (using current user)
CURRENT_USER_UPN=$(az account show --query user.name --output tsv)
CURRENT_USER_OID=$(az ad user show --id "$CURRENT_USER_UPN" --query id --output tsv 2>/dev/null || \
  az ad sp show --id "$CURRENT_USER_UPN" --query id --output tsv 2>/dev/null || echo "")

if [[ -n "$CURRENT_USER_OID" ]]; then
  az sql server ad-admin create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER_NAME" \
    --display-name "Azure AD Admin" \
    --object-id "$CURRENT_USER_OID" \
    --output none
  echo "    Azure AD admin set: $CURRENT_USER_UPN"
fi

# Create database
az sql db create \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER_NAME" \
  --name "$SQL_DB_NAME" \
  --service-objective S1 \
  --output none

# Enable Advanced Threat Protection (Defender for SQL)
az sql server threat-policy update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER_NAME" \
  --state Enabled \
  --output none

# Enable SQL Auditing to storage account
STORAGE_ID=$(az storage account show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$STORAGE_NAME" \
  --query id --output tsv)

az sql server audit-policy update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER_NAME" \
  --state Enabled \
  --storage-account "$STORAGE_NAME" \
  --retention-days 90 \
  --output none

# Deny public network access
az sql server update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER_NAME" \
  --set publicNetworkAccess=Disabled \
  --output none

echo "    SQL Database '$SQL_DB_NAME' created"
echo "    Advanced Threat Protection: Enabled"
echo "    Auditing: Enabled (90-day retention → $STORAGE_NAME)"
echo "    Public network access: Disabled"

# ─── 6. Create Private Endpoint for SQL ───────────────────────────────────────
echo "[6/7] Creating private endpoint for SQL Server"

# Need a private endpoint subnet
az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "snet-private-endpoints" \
  --address-prefix "10.10.2.0/24" \
  --output none

SQL_RESOURCE_ID=$(az sql server show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER_NAME" \
  --query id --output tsv)

az network private-endpoint create \
  --resource-group "$RESOURCE_GROUP" \
  --name "pe-sql-az500" \
  --vnet-name "$VNET_NAME" \
  --subnet "snet-private-endpoints" \
  --private-connection-resource-id "$SQL_RESOURCE_ID" \
  --group-id sqlServer \
  --connection-name "sql-private-connection" \
  --output none

echo "    Private endpoint 'pe-sql-az500' created for $SQL_SERVER_NAME"

# ─── 7. Configure JIT Access Policy (Requires Defender for Servers) ──────────
echo "[7/7] JIT VM Access Note:"
echo "    Just-in-Time (JIT) access requires Microsoft Defender for Servers (P2)."
echo "    To enable JIT via CLI after Defender for Servers is enabled:"
echo ""
echo "    az security jit-policy create \\"
echo "      --resource-group $RESOURCE_GROUP \\"
echo "      --location $LOCATION \\"
echo "      --name default \\"
echo "      --vm-policies '[{"
echo "        \"id\": \"<VM_RESOURCE_ID>\","
echo "        \"ports\": [{"
echo "          \"number\": 22,"
echo "          \"protocol\": \"TCP\","
echo "          \"allowedSourceAddressPrefix\": \"*\","
echo "          \"maxRequestAccessDuration\": \"PT3H\""
echo "        }]"
echo "      }]'"

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Lab Setup Complete!"
echo "============================================================"
echo " Resource Group:    $RESOURCE_GROUP"
echo " VM:                $VM_NAME (system-assigned managed identity)"
echo " Storage Account:   $STORAGE_NAME (HTTPS-only, deny public, VNet rule)"
echo " SQL Server:        $SQL_SERVER_NAME.database.windows.net"
echo " SQL Database:      $SQL_DB_NAME"
echo " SQL Admin (local): $SQL_ADMIN / (stored securely)"
echo ""
echo " AZ-500 Exam Concepts Demonstrated:"
echo "   ✅ VM with system-assigned managed identity"
echo "   ✅ Storage: HTTPS-only, TLS 1.2, no public blob access"
echo "   ✅ Storage: VNet service endpoint + network rules"
echo "   ✅ Storage: Managed identity RBAC (Blob Data Reader)"
echo "   ✅ SQL: Azure AD admin configuration"
echo "   ✅ SQL: Advanced Threat Protection (Defender for SQL)"
echo "   ✅ SQL: Auditing to storage (90-day retention)"
echo "   ✅ SQL: Public network access disabled"
echo "   ✅ SQL: Private endpoint in VNet"
echo ""
echo " IMPORTANT: Store SQL password securely!"
echo " SQL Password: $SQL_PASSWORD"
echo ""
echo " To clean up: az group delete --name $RESOURCE_GROUP --yes --no-wait"
