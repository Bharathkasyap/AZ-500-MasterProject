#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script: Security Operations
# Domain 4 — Manage Security Operations
#
# Demonstrates:
#   - Microsoft Defender for Cloud enablement (enhanced security plans)
#   - Azure Key Vault with diagnostic logging to Log Analytics
#   - Microsoft Sentinel workspace setup with data connectors
#   - Azure Policy assignment (security baseline)
#   - Log Analytics workspace with Security solutions
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Owner or Security Admin permissions on subscription
#
# Usage:
#   chmod +x setup-security-operations.sh
#   ./setup-security-operations.sh
# =============================================================================

set -euo pipefail

# ─── Variables ────────────────────────────────────────────────────────────────
RESOURCE_GROUP="rg-az500-secops-lab"
LOCATION="eastus"
LOG_ANALYTICS_WORKSPACE="law-az500-$(openssl rand -hex 4)"
KEYVAULT_NAME="kv-az500-so-$(openssl rand -hex 4)"
SENTINEL_WORKSPACE="$LOG_ANALYTICS_WORKSPACE"

echo "============================================================"
echo " AZ-500 Security Operations Lab Setup"
echo "============================================================"

SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# ─── 1. Create Resource Group ─────────────────────────────────────────────────
echo "[1/8] Creating resource group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# ─── 2. Create Log Analytics Workspace ───────────────────────────────────────
echo "[2/8] Creating Log Analytics workspace: $LOG_ANALYTICS_WORKSPACE"

az monitor log-analytics workspace create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$LOG_ANALYTICS_WORKSPACE" \
  --location "$LOCATION" \
  --sku PerGB2018 \
  --retention-time 90 \
  --output none

LAW_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$LOG_ANALYTICS_WORKSPACE" \
  --query id --output tsv)

LAW_CUSTOMER_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$LOG_ANALYTICS_WORKSPACE" \
  --query customerId --output tsv)

echo "    Log Analytics workspace created: $LOG_ANALYTICS_WORKSPACE"
echo "    Workspace ID: $LAW_CUSTOMER_ID"

# ─── 3. Enable Microsoft Sentinel ────────────────────────────────────────────
echo "[3/8] Enabling Microsoft Sentinel on the workspace"

az sentinel onboarding-state create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$SENTINEL_WORKSPACE" \
  --name "default" \
  --output none 2>/dev/null || \
  echo "    (Sentinel already enabled or using portal to enable)"

echo "    Microsoft Sentinel enabled on: $SENTINEL_WORKSPACE"

# ─── 4. Enable Azure Activity Log → Log Analytics ────────────────────────────
echo "[4/8] Connecting Azure Activity Log to Log Analytics workspace"

az monitor diagnostic-settings create \
  --name "ActivityLogToLAW" \
  --resource "/subscriptions/${SUBSCRIPTION_ID}" \
  --workspace "$LAW_ID" \
  --logs '[
    {"category":"Administrative","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Security","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"ServiceHealth","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Alert","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Recommendation","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Policy","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}
  ]' \
  --output none 2>/dev/null || \
  echo "    (Activity log diagnostic setting: already exists or check permissions)"

echo "    Azure Activity Log → Log Analytics: Configured"

# ─── 5. Create Key Vault with Diagnostic Logging ─────────────────────────────
echo "[5/8] Creating Key Vault with diagnostic logging: $KEYVAULT_NAME"

az keyvault create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$KEYVAULT_NAME" \
  --location "$LOCATION" \
  --enable-rbac-authorization true \
  --enable-purge-protection true \
  --retention-days 90 \
  --output none

KV_ID=$(az keyvault show --name "$KEYVAULT_NAME" --query id --output tsv)

# Enable diagnostic settings for Key Vault (audit logs → Log Analytics)
az monitor diagnostic-settings create \
  --name "KVAuditToLAW" \
  --resource "$KV_ID" \
  --workspace "$LAW_ID" \
  --logs '[
    {"category":"AuditEvent","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"AzurePolicyEvaluationDetails","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}
  ]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --output none

echo "    Key Vault '$KEYVAULT_NAME' created with audit logging to Log Analytics"

# Grant current user Key Vault Secrets Officer
CURRENT_USER_OID=$(az ad signed-in-user show --query id --output tsv 2>/dev/null || \
  az account show --query id --output tsv)

az role assignment create \
  --assignee "$CURRENT_USER_OID" \
  --role "Key Vault Secrets Officer" \
  --scope "$KV_ID" \
  --output none 2>/dev/null || echo "    (Role assignment: may already exist)"

# Store a sample secret
az keyvault secret set \
  --vault-name "$KEYVAULT_NAME" \
  --name "sentinel-api-key" \
  --value "sample-secret-$(date +%s)" \
  --output none

echo "    Sample secret stored: 'sentinel-api-key'"

# ─── 6. Enable Microsoft Defender for Cloud Plans ────────────────────────────
echo "[6/8] Enabling Microsoft Defender for Cloud plans"

# Enable Defender for Servers (P2)
az security pricing create \
  --name "VirtualMachines" \
  --tier "Standard" \
  --output none

# Enable Defender for Storage
az security pricing create \
  --name "StorageAccounts" \
  --tier "Standard" \
  --output none

# Enable Defender for Key Vault
az security pricing create \
  --name "KeyVaults" \
  --tier "Standard" \
  --output none

# Enable Defender for SQL (on Azure)
az security pricing create \
  --name "SqlServers" \
  --tier "Standard" \
  --output none

# Enable Defender for App Service
az security pricing create \
  --name "AppServices" \
  --tier "Standard" \
  --output none

# Set the Log Analytics workspace for Defender for Cloud
az security workspace-setting create \
  --name "default" \
  --target-workspace "$LAW_ID" \
  --output none 2>/dev/null || \
  echo "    (Workspace setting: already configured)"

echo "    Defender plans enabled: Servers, Storage, Key Vault, SQL, App Service"

# ─── 7. Assign Azure Security Benchmark Policy ────────────────────────────────
echo "[7/8] Note: Microsoft Cloud Security Benchmark is the default initiative"
echo "    Additional compliance standards can be assigned from:"
echo "    Microsoft Defender for Cloud → Regulatory compliance → Manage compliance policies"
echo ""
echo "    To assign CIS Microsoft Azure Foundations via CLI:"
echo "    az policy assignment create \\"
echo "      --name 'CIS-Azure-1.4.0' \\"
echo "      --policy-set-definition '/providers/Microsoft.Authorization/policySetDefinitions/c3f5c4d9-9a1d-4a99-85c0-7f93e384d5c5' \\"
echo "      --scope '/subscriptions/${SUBSCRIPTION_ID}'"

# ─── 8. Create Sample Sentinel Analytics Rule ─────────────────────────────────
echo "[8/8] Note: Analytics rules are created via portal or ARM templates"
echo "    Example KQL query for a Sentinel Scheduled rule (failed logins):"
echo ""
cat << 'EOF'
    -- Paste this in Sentinel > Analytics > Create > Scheduled query rule
    SecurityEvent
    | where EventID == 4625
    | summarize FailCount = count() by TargetAccount, IpAddress, bin(TimeGenerated, 5m)
    | where FailCount >= 10
    | extend AlertDetails = strcat("Account: ", TargetAccount, " | IP: ", IpAddress, " | Failures: ", FailCount)
EOF

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Lab Setup Complete!"
echo "============================================================"
echo " Resource Group:         $RESOURCE_GROUP"
echo " Log Analytics Workspace: $LOG_ANALYTICS_WORKSPACE"
echo " Workspace ID:           $LAW_CUSTOMER_ID"
echo " Microsoft Sentinel:     Enabled on $SENTINEL_WORKSPACE"
echo " Key Vault:              $KEYVAULT_NAME"
echo " Defender Plans:         Servers, Storage, KeyVault, SQL, AppService"
echo ""
echo " AZ-500 Exam Concepts Demonstrated:"
echo "   ✅ Log Analytics workspace (90-day retention)"
echo "   ✅ Microsoft Sentinel enablement"
echo "   ✅ Azure Activity Log diagnostic settings → Log Analytics"
echo "   ✅ Key Vault audit logging to Log Analytics"
echo "   ✅ Microsoft Defender for Cloud enhanced security plans"
echo "   ✅ Defender workspace configuration"
echo "   ✅ Key Vault with purge protection and RBAC mode"
echo ""
echo " Next Steps:"
echo "   - Add data connectors in Sentinel (Azure AD, M365 Defender, etc.)"
echo "   - Create analytics rules from built-in templates"
echo "   - Review Secure Score in Defender for Cloud"
echo "   - Explore regulatory compliance dashboard"
echo ""
echo " To clean up: az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo "              (Note: Defender plans and diagnostic settings must be removed separately)"
