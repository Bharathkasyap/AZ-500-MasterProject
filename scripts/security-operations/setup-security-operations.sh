#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script — Domain 4: Security Operations
# Provisions: Log Analytics workspace (90-day retention), Microsoft Sentinel
#             onboarding, Activity Log diagnostic settings, Key Vault with
#             RBAC mode + purge protection + audit logging, Defender plan
#             enablement for VMs / SQL / Storage / KeyVaults
#
# Usage:
#   chmod +x setup-security-operations.sh
#   ./setup-security-operations.sh
#
# Cleanup:
#   az group delete --name az500-secops-rg --yes --no-wait
#   # Disable Defender plans to avoid charges:
#   for p in VirtualMachines SqlServers StorageAccounts KeyVaults; do
#     az security pricing create --name $p --tier Free
#   done
# =============================================================================
set -euo pipefail

# ---------- Configuration ----------------------------------------------------
RESOURCE_GROUP="az500-secops-rg"
LOCATION="${LOCATION:-eastus}"
TIMESTAMP=$(date +%s | tail -c 8)
WS_NAME="az500-sentinel-ws"
KV_NAME="az500-secops-kv-${TIMESTAMP}"

# ---------- Helper ------------------------------------------------------------
log() { echo "[$(date '+%H:%M:%S')] $*"; }

# ---------- Resource Group ---------------------------------------------------
log "Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

SUB_ID=$(az account show --query id -o tsv)

# ---------- Log Analytics Workspace (90-day retention) -----------------------
log "Creating Log Analytics Workspace: $WS_NAME (90-day retention)"
az monitor log-analytics workspace create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WS_NAME" \
  --location "$LOCATION" \
  --retention-time 90 \
  --output none

WS_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WS_NAME" \
  --query id -o tsv)

log "Workspace ID: $WS_ID"

# ---------- Microsoft Sentinel Onboarding ------------------------------------
log "Onboarding Microsoft Sentinel to workspace"
az sentinel onboarding-state create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WS_NAME" \
  --name default \
  --output none

# ---------- Activity Log Diagnostic Settings ---------------------------------
log "Configuring Activity Log → Log Analytics (all security-relevant categories)"
az monitor diagnostic-settings create \
  --name "activity-logs-to-sentinel" \
  --subscription "$SUB_ID" \
  --logs '[
    {"category":"Administrative","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Security","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"ServiceHealth","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Alert","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Recommendation","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Policy","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"Autoscale","enabled":true,"retentionPolicy":{"enabled":false,"days":0}},
    {"category":"ResourceHealth","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}
  ]' \
  --workspace "$WS_ID" \
  --output none

log "Activity Log diagnostic settings configured"

# ---------- Key Vault (RBAC mode + purge protection) -------------------------
log "Creating Key Vault: $KV_NAME (RBAC mode, purge protection)"
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

KV_ID=$(az keyvault show --name "$KV_NAME" --query id -o tsv)

# Assign current user as Secrets Officer
MY_OID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --assignee-object-id "$MY_OID" \
  --assignee-principal-type User \
  --role "Key Vault Secrets Officer" \
  --scope "$KV_ID" \
  --output none

# Store sample secrets with expiry
log "Storing sample secrets in Key Vault"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "sentinel-api-key" \
  --value "SampleApiKey@2024!" \
  --output none

az keyvault secret set-attributes \
  --vault-name "$KV_NAME" \
  --name "sentinel-api-key" \
  --expires "$(date -u -d '+90 days' +%Y-%m-%dT%H:%MZ 2>/dev/null || \
               date -u -v+90d +%Y-%m-%dT%H:%MZ)" \
  --output none

# ---------- Key Vault Audit Logging → Workspace ------------------------------
log "Enabling Key Vault diagnostic logging → Log Analytics"
az monitor diagnostic-settings create \
  --name "kv-audit-to-sentinel" \
  --resource "$KV_ID" \
  --logs '[
    {"category":"AuditEvent","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}
  ]' \
  --metrics '[
    {"category":"AllMetrics","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}
  ]' \
  --workspace "$WS_ID" \
  --output none

log "Key Vault audit logs will appear in: AzureDiagnostics | where ResourceProvider == 'MICROSOFT.KEYVAULT'"

# ---------- Defender Plans ---------------------------------------------------
log "Enabling Defender for Cloud plans"

DEFENDER_PLANS=(
  "VirtualMachines"
  "SqlServers"
  "StorageAccounts"
  "KeyVaults"
  "AppServices"
  "ContainerRegistry"
)

for plan in "${DEFENDER_PLANS[@]}"; do
  log "  Enabling Defender for $plan"
  az security pricing create \
    --name "$plan" \
    --tier Standard \
    --output none 2>/dev/null || log "  ⚠️  Skipped $plan (may require specific resources)"
done

# ---------- Sentinel Analytics Rule (KQL) ------------------------------------
log "Creating Sentinel Scheduled Analytics Rule via REST API"

SENTINEL_RULE_BODY=$(cat <<JSON
{
  "kind": "Scheduled",
  "properties": {
    "displayName": "Multiple Failed Sign-Ins",
    "description": "Detects accounts with more than 10 failed sign-ins in 1 hour",
    "severity": "Medium",
    "enabled": true,
    "query": "SigninLogs | where ResultType != '0' | where TimeGenerated > ago(1h) | summarize FailedAttempts = count() by UserPrincipalName, IPAddress | where FailedAttempts > 10",
    "queryFrequency": "PT5M",
    "queryPeriod": "PT1H",
    "triggerOperator": "GreaterThan",
    "triggerThreshold": 0,
    "suppressionDuration": "PT5H",
    "suppressionEnabled": false,
    "tactics": ["CredentialAccess"],
    "incidentConfiguration": {
      "createIncident": true,
      "groupingConfiguration": {
        "enabled": true,
        "reopenClosedIncident": false,
        "lookbackDuration": "PT5H",
        "matchingMethod": "AllEntities",
        "groupByEntities": [],
        "groupByAlertDetails": [],
        "groupByCustomDetails": []
      }
    }
  }
}
JSON
)

RULE_RESPONSE=$(az rest \
  --method PUT \
  --url "https://management.azure.com/subscriptions/${SUB_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.OperationalInsights/workspaces/${WS_NAME}/providers/Microsoft.SecurityInsights/alertRules/multiple-failed-signins?api-version=2023-02-01" \
  --body "$SENTINEL_RULE_BODY" \
  --output none 2>&1) && \
  log "Sentinel analytics rule created: Multiple Failed Sign-Ins" || \
  log "⚠️  Analytics rule creation skipped (Sentinel may need connector data first)"

# ---------- Summary -----------------------------------------------------------
cat <<EOF

=============================================================================
 AZ-500 Security Operations Lab — Provisioning Complete
=============================================================================
 Resource Group      : $RESOURCE_GROUP
 Location            : $LOCATION
 Log Analytics WS    : $WS_NAME (90-day retention)
 Microsoft Sentinel  : Onboarded ✅
 Activity Log        : → $WS_NAME (all security categories) ✅
 Key Vault           : $KV_NAME
   - RBAC mode       : ✅
   - Soft delete     : ✅ (90 days)
   - Purge protection: ✅
   - Audit logs      : → $WS_NAME ✅
 Defender Plans      : VirtualMachines, SqlServers, StorageAccounts,
                       KeyVaults, AppServices, ContainerRegistry
 Sentinel Rule       : Multiple Failed Sign-Ins (Scheduled, Medium)

 💡 Next Steps (Portal):
    1. Connect Entra ID data connector in Sentinel
    2. Connect Microsoft Defender for Cloud connector
    3. Create a Playbook (Logic App) to auto-notify on incidents
    4. Review Secure Score recommendations in Defender for Cloud

 ⚠️  COST NOTICE: Sentinel + Log Analytics cost based on data ingestion.
    Defender plans cost per resource-hour.
 🧹  CLEANUP:
     az group delete --name $RESOURCE_GROUP --yes --no-wait
     for p in VirtualMachines SqlServers StorageAccounts KeyVaults AppServices ContainerRegistry; do
       az security pricing create --name \$p --tier Free
     done
=============================================================================
EOF
