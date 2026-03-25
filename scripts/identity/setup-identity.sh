#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script: Identity & Access Management
# Domain 1 — Manage Identity and Access
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Sufficient permissions (Global Admin or equivalent)
#
# Usage:
#   chmod +x setup-identity.sh
#   ./setup-identity.sh
# =============================================================================

set -euo pipefail

# ─── Variables ────────────────────────────────────────────────────────────────
RESOURCE_GROUP="rg-az500-identity-lab"
LOCATION="eastus"
LAB_USER_PREFIX="az500lab"
KEYVAULT_NAME="kv-az500-id-$(openssl rand -hex 4)"

echo "============================================================"
echo " AZ-500 Identity & Access Lab Setup"
echo "============================================================"

# ─── 1. Create Resource Group ─────────────────────────────────────────────────
echo "[1/6] Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# ─── 2. Create Azure AD Test User ─────────────────────────────────────────────
echo "[2/6] Creating Azure AD test user"

# Get the tenant's verified domain
DOMAIN=$(az rest \
  --method get \
  --url "https://graph.microsoft.com/v1.0/domains" \
  --query "value[?isDefault].id" \
  --output tsv)

TEST_USER_UPN="${LAB_USER_PREFIX}-user@${DOMAIN}"
TEST_USER_PASSWORD="Az500Lab!$(openssl rand -hex 4)"

az ad user create \
  --display-name "AZ-500 Lab User" \
  --user-principal-name "$TEST_USER_UPN" \
  --password "$TEST_USER_PASSWORD" \
  --force-change-password-next-sign-in false \
  --output none

echo "    Created user: $TEST_USER_UPN"
echo "    Temporary password: $TEST_USER_PASSWORD"

USER_OBJECT_ID=$(az ad user show \
  --id "$TEST_USER_UPN" \
  --query id \
  --output tsv)

# ─── 3. Create Azure AD Security Group ───────────────────────────────────────
echo "[3/6] Creating Azure AD security group"

GROUP_ID=$(az ad group create \
  --display-name "AZ500-Lab-Readers" \
  --mail-nickname "AZ500-Lab-Readers" \
  --query id \
  --output tsv)

# Add test user to the group
az ad group member add \
  --group "$GROUP_ID" \
  --member-id "$USER_OBJECT_ID" \
  --output none

echo "    Group 'AZ500-Lab-Readers' created (ID: $GROUP_ID)"

# ─── 4. Assign RBAC Role to the Group ────────────────────────────────────────
echo "[4/6] Assigning Reader role to the group on the resource group"

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SCOPE="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

az role assignment create \
  --assignee "$GROUP_ID" \
  --role "Reader" \
  --scope "$SCOPE" \
  --output none

echo "    Reader role assigned on $RESOURCE_GROUP"

# ─── 5. Create Key Vault with Managed Identity Demo ──────────────────────────
echo "[5/6] Creating Key Vault: $KEYVAULT_NAME"

az keyvault create \
  --name "$KEYVAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --enable-rbac-authorization true \
  --enable-purge-protection true \
  --retention-days 7 \
  --output none

# Store a test secret
az keyvault secret set \
  --vault-name "$KEYVAULT_NAME" \
  --name "lab-secret" \
  --value "AZ500-Secret-Value-$(date +%s)" \
  --output none

echo "    Key Vault created: $KEYVAULT_NAME"
echo "    Secret 'lab-secret' stored"

# ─── 6. Create a User-Assigned Managed Identity ───────────────────────────────
echo "[6/6] Creating user-assigned managed identity"

IDENTITY_NAME="id-az500-lab"

az identity create \
  --name "$IDENTITY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

IDENTITY_PRINCIPAL_ID=$(az identity show \
  --name "$IDENTITY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query principalId \
  --output tsv)

# Grant the managed identity access to read secrets from Key Vault
az role assignment create \
  --assignee "$IDENTITY_PRINCIPAL_ID" \
  --role "Key Vault Secrets User" \
  --scope "$(az keyvault show --name "$KEYVAULT_NAME" --query id --output tsv)" \
  --output none

echo "    User-assigned identity '$IDENTITY_NAME' created"
echo "    Granted 'Key Vault Secrets User' on $KEYVAULT_NAME"

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Lab Setup Complete!"
echo "============================================================"
echo " Resource Group:    $RESOURCE_GROUP"
echo " Test User:         $TEST_USER_UPN"
echo " Security Group:    AZ500-Lab-Readers (Reader on RG)"
echo " Key Vault:         $KEYVAULT_NAME"
echo " Managed Identity:  $IDENTITY_NAME"
echo ""
echo " AZ-500 Exam Concepts Demonstrated:"
echo "   ✅ Azure AD user and group creation"
echo "   ✅ Azure RBAC role assignment (Reader on Resource Group)"
echo "   ✅ Azure Key Vault with RBAC authorization mode"
echo "   ✅ Key Vault purge protection"
echo "   ✅ User-assigned managed identity"
echo "   ✅ Key Vault Secrets User role for managed identity"
echo ""
echo " To clean up: az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo "              az ad user delete --id $TEST_USER_UPN"
echo "              az ad group delete --group $GROUP_ID"
echo "              az identity delete --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP"
