# Lab 04 — Security Operations

**Estimated Time:** 90–120 minutes  
**Prerequisite:** Azure subscription with Owner role; Entra ID P1 or P2 for Sentinel  
**Mapped Exam Domain:** Domain 4 — Manage Security Operations

---

## Learning Objectives

- Deploy a Log Analytics workspace with appropriate retention
- Onboard Microsoft Sentinel and configure data connectors
- Create a Scheduled Analytics Rule with a KQL query
- Configure Key Vault with RBAC mode, soft delete, and purge protection
- Enable multiple Defender for Cloud plans
- Review and remediate Defender for Cloud Secure Score recommendations

---

## Part 1 — Log Analytics Workspace

### Step 1.1 — Create Workspace

```bash
RG="lab-secops-rg"
LOCATION="eastus"
WS_NAME="lab-sentinel-ws"

az group create --name $RG --location $LOCATION

az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name $WS_NAME \
  --location $LOCATION \
  --retention-time 90

WS_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name $WS_NAME \
  --query id -o tsv)

echo "Workspace ID: $WS_ID"
```

### Step 1.2 — Configure Activity Log Diagnostic Settings

```bash
SUB_ID=$(az account show --query id -o tsv)

az monitor diagnostic-settings create \
  --name "activity-to-sentinel" \
  --subscription $SUB_ID \
  --logs '[
    {"category":"Administrative","enabled":true},
    {"category":"Security","enabled":true},
    {"category":"ServiceHealth","enabled":true},
    {"category":"Alert","enabled":true},
    {"category":"Policy","enabled":true}
  ]' \
  --workspace $WS_ID

echo "Activity Log diagnostic settings configured"
```

---

## Part 2 — Microsoft Sentinel

### Step 2.1 — Onboard Sentinel to Workspace

```bash
az sentinel onboarding-state create \
  --resource-group $RG \
  --workspace-name $WS_NAME \
  --name default

echo "Sentinel onboarded to workspace"
```

### Step 2.2 — Enable Data Connectors (Portal Steps)

> Most connectors require portal configuration. Here are the steps for key connectors.

**Azure Active Directory / Entra ID Connector:**
1. In Sentinel, go to **Data connectors** → Search for **Microsoft Entra ID**
2. Click **Open connector page**
3. Check **Sign-in Logs**, **Audit Logs**, **Provisioning Logs**
4. Click **Apply Changes**

**Azure Activity Connector:**
1. In Sentinel, go to **Data connectors** → **Azure Activity**
2. Click **Open connector page**
3. Follow the Azure Policy assignment wizard to configure the subscription
4. Click **Assign**

**Microsoft Defender for Cloud Connector:**
1. In Sentinel → **Data connectors** → **Microsoft Defender for Cloud**
2. Click **Open connector page**
3. Select your subscription → **Connect**

**Validation check:**
Navigate to Sentinel → **Data connectors** and verify the status columns show data flowing.

---

## Part 3 — Analytics Rules

### Step 3.1 — Create a Scheduled Analytics Rule (Portal)

1. In Sentinel, navigate to **Analytics** → **+ Create** → **Scheduled query rule**

2. **General tab:**
   - Name: `Multiple Failed Sign-Ins`
   - Description: `Detect accounts with >10 failed logins in 1 hour`
   - Severity: Medium
   - MITRE ATT&CK Tactics: Credential Access

3. **Set rule logic tab — KQL query:**

```kql
SigninLogs
| where ResultType != "0"                          // Non-successful sign-ins
| where TimeGenerated > ago(1h)
| summarize FailedAttempts = count()
    by UserPrincipalName, IPAddress, AppDisplayName
| where FailedAttempts > 10
| extend AccountCustomEntity = UserPrincipalName
| extend IPCustomEntity = IPAddress
```

4. **Alert enrichment:**
   - Entity mapping: `Account` → `UserPrincipalName`, `IP` → `IPAddress`

5. **Query scheduling:**
   - Run every: 5 minutes
   - Lookup data from last: 1 hour

6. **Incident settings:**
   - Enable incident creation
   - Group alerts into incidents: By `UserPrincipalName`

7. Click **Review + Create** → **Save**

### Step 3.2 — Create a NRT Rule for Key Vault Access

```kql
// Near Real-Time rule for suspicious Key Vault access
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName == "SecretGet"
| where ResultType == "Unauthorized"
| extend VaultName = Resource
| extend CallerIPAddress = CallerIPAddress
| project TimeGenerated, VaultName, CallerIPAddress, identity_claim_upn_s
```

---

## Part 4 — Azure Key Vault

### Step 4.1 — Create Secure Key Vault

```bash
KV_NAME="lab-secops-kv-$(date +%s | tail -c 6)"

az keyvault create \
  --name $KV_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --enable-purge-protection true \
  --retention-days 90 \
  --sku standard

KV_ID=$(az keyvault show --name $KV_NAME --query id -o tsv)

echo "Key Vault created: $KV_NAME"
echo "Key Vault ID: $KV_ID"
```

### Step 4.2 — Assign RBAC Roles

```bash
MY_OID=$(az ad signed-in-user show --query id -o tsv)

# Assign Key Vault Secrets Officer to current user (for management)
az role assignment create \
  --assignee-object-id $MY_OID \
  --assignee-principal-type User \
  --role "Key Vault Secrets Officer" \
  --scope $KV_ID

echo "RBAC roles assigned"
```

### Step 4.3 — Store Secrets and Configure Rotation

```bash
# Store a secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "app-api-key" \
  --value "initial-value-12345"

# Set an expiry on the secret
az keyvault secret set-attributes \
  --vault-name $KV_NAME \
  --name "app-api-key" \
  --expires "$(date -u -d '+90 days' +%Y-%m-%dT%H:%MZ)"

echo "Secret stored with 90-day expiry"
```

### Step 4.4 — Enable Key Vault Diagnostic Logging

```bash
az monitor diagnostic-settings create \
  --name "kv-audit-to-sentinel" \
  --resource $KV_ID \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --workspace $WS_ID

echo "Key Vault audit logging enabled → Log Analytics"
```

### Step 4.5 — Test Soft Delete and Recovery

```bash
# Delete a secret (soft-delete, not permanent)
az keyvault secret delete \
  --vault-name $KV_NAME \
  --name "app-api-key"

# List deleted secrets (should appear here)
az keyvault secret list-deleted \
  --vault-name $KV_NAME \
  --output table

# Recover the secret
az keyvault secret recover \
  --vault-name $KV_NAME \
  --name "app-api-key"

echo "Secret recovered from soft-delete"
```

> ⚠️ Because purge protection is enabled, you cannot permanently delete secrets during the 90-day retention period.

---

## Part 5 — Defender for Cloud

### Step 5.1 — Enable Defender Plans

```bash
# Enable multiple Defender plans
for plan in VirtualMachines SqlServers StorageAccounts KeyVaults AppServices; do
  az security pricing create \
    --name $plan \
    --tier Standard
  echo "Defender for $plan enabled"
done
```

### Step 5.2 — Review Secure Score (Portal)

1. Navigate to **Microsoft Defender for Cloud** → **Secure posture** (or **Secure Score**)
2. Note your current score percentage
3. Click **View recommendations** 
4. Sort by **Potential score increase** (descending)
5. Click on the top recommendation
6. Review: Affected resources, remediation steps, estimated impact

### Step 5.3 — Remediate a Recommendation (Example)

**"MFA should be enabled on accounts with owner permissions"**

1. Click the recommendation
2. Review the list of non-compliant accounts
3. Click **Quick Fix** if available, or follow the manual remediation steps
4. Verify the recommendation moves to Compliant

### Step 5.4 — Check Defender Alerts

```bash
az security alert list \
  --location $LOCATION \
  --output table
```

---

## Part 6 — Sentinel Playbook (Logic App)

### Step 6.1 — Create an Automation Rule

**Portal:**
1. In Sentinel → **Automation** → **+ Create** → **Automation rule**
2. Name: `Auto-assign-medium-incidents`
3. Conditions: Incident severity = Medium
4. Actions: Assign owner = [your email]
5. Click **Apply**

### Step 6.2 — Create a Simple Notification Playbook

1. In Sentinel → **Automation** → **+ Create** → **Playbook with incident trigger**
2. Follow the Logic App designer to:
   - Trigger: **When a Microsoft Sentinel incident is created**
   - Action: **Send an email** (Office 365 connector) with incident details
3. Authorize connections and save the Logic App
4. Return to Sentinel → Automation → attach the playbook to an analytics rule

---

## Checklist

- [ ] Log Analytics workspace with 90-day retention created
- [ ] Activity Log diagnostic settings configured → workspace
- [ ] Sentinel onboarded to workspace
- [ ] Entra ID and Azure Activity connectors enabled
- [ ] Multiple Failed Sign-Ins analytics rule created (KQL)
- [ ] Key Vault with RBAC mode, soft delete, and purge protection created
- [ ] RBAC roles assigned to Key Vault
- [ ] Secrets stored with expiry dates
- [ ] Key Vault diagnostic logging → Log Analytics enabled
- [ ] Soft delete + recover tested
- [ ] Multiple Defender plans enabled
- [ ] Secure Score reviewed and top recommendation identified
- [ ] Sentinel automation rule created

---

## Cleanup

```bash
az group delete --name lab-secops-rg --yes --no-wait

# Disable Defender plans (to avoid charges)
for plan in VirtualMachines SqlServers StorageAccounts KeyVaults AppServices; do
  az security pricing create --name $plan --tier Free
done

echo "Cleanup initiated"
```

---

## Key Takeaways

1. Log Analytics is the foundation — all Sentinel, Defender for Cloud, and diagnostic data flows here.
2. Key Vault purge protection is the critical setting for compliance — enable it from day one.
3. Sentinel analytics rules + playbooks form the SIEM + SOAR loop: detect → alert → automate.
4. Secure Score is a *prioritisation tool* — focus on high-impact, low-effort recommendations first.
5. Defender for Cloud plans are per-resource-type — enable only what you need to manage cost.
