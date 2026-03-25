#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script — Domain 1: Identity and Access
# Provisions: Entra ID user/group, RBAC assignment, Key Vault (RBAC mode),
#             user-assigned managed identity
#
# Usage:
#   export SUBSCRIPTION_ID="<your-subscription-id>"
#   export TENANT_DOMAIN="<your-tenant>.onmicrosoft.com"
#   chmod +x setup-identity.sh
#   ./setup-identity.sh
#
# Cleanup (run after lab):
#   az group delete --name az500-identity-rg --yes --no-wait
#   az ad user delete --id labuser@<TENANT_DOMAIN>
#   az ad group delete --group AZ500-Lab-Group
# =============================================================================
set -euo pipefail

# ---------- Configuration ----------------------------------------------------
RESOURCE_GROUP="az500-identity-rg"
LOCATION="${LOCATION:-eastus}"
TIMESTAMP=$(date +%s | tail -c 8)
KV_NAME="az500-kv-${TIMESTAMP}"
IDENTITY_NAME="az500-managed-id"
GROUP_NAME="AZ500-Lab-Group"
: "${TENANT_DOMAIN:?Set TENANT_DOMAIN env variable (e.g. mytenant.onmicrosoft.com)}"
USER_UPN="labuser@${TENANT_DOMAIN}"

# ---------- Helper ------------------------------------------------------------
log() { echo "[$(date '+%H:%M:%S')] $*"; }

# ---------- Resource Group ---------------------------------------------------
log "Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# ---------- Entra ID User ----------------------------------------------------
log "Creating Entra ID test user: $USER_UPN"
az ad user create \
  --display-name "AZ500 Lab User" \
  --user-principal-name "$USER_UPN" \
  --password "TempLabPass@2024!" \
  --force-change-password-next-sign-in true \
  --output none

USER_OID=$(az ad user show --id "$USER_UPN" --query id -o tsv)
log "User object ID: $USER_OID"

# ---------- Entra ID Security Group ------------------------------------------
log "Creating security group: $GROUP_NAME"
az ad group create \
  --display-name "$GROUP_NAME" \
  --mail-nickname "AZ500LabGroup" \
  --output none

GROUP_OID=$(az ad group show --group "$GROUP_NAME" --query id -o tsv)
log "Group object ID: $GROUP_OID"

log "Adding user to group"
az ad group member add \
  --group "$GROUP_NAME" \
  --member-id "$USER_OID" \
  --output none

# ---------- RBAC Role Assignment (Reader on RG) ------------------------------
log "Assigning Reader role to group on resource group"
SUB_ID=$(az account show --query id -o tsv)
RG_SCOPE="/subscriptions/${SUB_ID}/resourceGroups/${RESOURCE_GROUP}"

az role assignment create \
  --assignee-object-id "$GROUP_OID" \
  --assignee-principal-type Group \
  --role "Reader" \
  --scope "$RG_SCOPE" \
  --output none

log "RBAC assignment: AZ500-Lab-Group → Reader on ${RESOURCE_GROUP}"

# ---------- User-Assigned Managed Identity -----------------------------------
log "Creating user-assigned managed identity: $IDENTITY_NAME"
az identity create \
  --name "$IDENTITY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

MI_PRINCIPAL=$(az identity show \
  --name "$IDENTITY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query principalId -o tsv)

log "Managed Identity principal ID: $MI_PRINCIPAL"

# ---------- Key Vault (RBAC mode) --------------------------------------------
log "Creating Key Vault (RBAC mode): $KV_NAME"
az keyvault create \
  --name "$KV_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --enable-purge-protection true \
  --retention-days 90 \
  --sku standard \
  --output none

KV_SCOPE=$(az keyvault show --name "$KV_NAME" --query id -o tsv)

# Assign current user as Key Vault Secrets Officer
MY_OID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --assignee-object-id "$MY_OID" \
  --assignee-principal-type User \
  --role "Key Vault Secrets Officer" \
  --scope "$KV_SCOPE" \
  --output none

# Assign managed identity as Key Vault Secrets User (read-only)
az role assignment create \
  --assignee-object-id "$MI_PRINCIPAL" \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope "$KV_SCOPE" \
  --output none

log "RBAC assignments on Key Vault $KV_NAME:"
log "  - Current user → Key Vault Secrets Officer"
log "  - Managed Identity → Key Vault Secrets User"

# ---------- Store a test secret ----------------------------------------------
log "Storing test secret: app-db-password"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "app-db-password" \
  --value "InitialValue@2024!" \
  --output none

# ---------- Summary -----------------------------------------------------------
cat <<EOF

=============================================================================
 AZ-500 Identity Lab — Provisioning Complete
=============================================================================
 Resource Group : $RESOURCE_GROUP
 Location       : $LOCATION
 Entra ID User  : $USER_UPN
 Security Group : $GROUP_NAME (Reader on $RESOURCE_GROUP)
 Managed Identity: $IDENTITY_NAME
 Key Vault      : $KV_NAME (RBAC mode, purge protection ON)
 Secret stored  : app-db-password

 💡 Next Step: Configure PIM eligible role assignment in the portal.
 💡 Next Step: Create a Conditional Access policy in the portal.

 ⚠️  COST NOTICE: This lab has minimal cost (Key Vault = ~$0/month for < 10k ops).
 🧹  CLEANUP:
     az group delete --name $RESOURCE_GROUP --yes --no-wait
     az ad user delete --id $USER_UPN
     az ad group delete --group $GROUP_NAME
=============================================================================
EOF
