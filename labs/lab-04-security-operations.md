# Lab 04: Security Operations

> **Estimated Time:** 60–90 minutes  
> **Domain:** 4 — Manage Security Operations  
> **Prerequisites:** Azure subscription, Azure CLI, Owner/Security Admin permissions, Log Analytics workspace

---

## Lab Overview

In this lab, you will:
1. Set up a Log Analytics workspace and onboard Microsoft Sentinel
2. Connect data sources (Azure Activity Log, Azure AD Sign-in Logs)
3. Create an analytics rule to detect suspicious activity
4. Configure an automation playbook (Logic App) for alert response
5. Review Microsoft Defender for Cloud Secure Score and recommendations
6. Configure Azure Key Vault with diagnostic logging and alerts

---

## Exercise 1: Log Analytics Workspace and Microsoft Sentinel

### Task 1.1: Create a Log Analytics workspace

```bash
RESOURCE_GROUP="rg-az500-secops-lab"
LOCATION="eastus"
WORKSPACE_NAME="law-az500-sentinel"

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

az monitor log-analytics workspace create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --location "$LOCATION" \
  --sku PerGB2018 \
  --retention-time 90

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  -g "$RESOURCE_GROUP" -n "$WORKSPACE_NAME" \
  --query id -o tsv)

echo "Workspace created: $WORKSPACE_ID"
```

### Task 1.2: Enable Microsoft Sentinel

```bash
# Enable Sentinel on the workspace
az sentinel onboarding-state create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --name "default"
```

Alternatively, via portal:
1. Search for **Microsoft Sentinel** in the Azure Portal
2. Click **+ Create**
3. Select your Log Analytics workspace → **Add**
4. Wait for Sentinel to initialize (~1 minute)

✅ **Validation:** Microsoft Sentinel overview page loads without errors.

---

## Exercise 2: Data Connectors

### Task 2.1: Connect Azure Activity Log via diagnostic settings

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az monitor diagnostic-settings create \
  --name "ActivityLog-To-Sentinel" \
  --resource "/subscriptions/${SUBSCRIPTION_ID}" \
  --workspace "$WORKSPACE_ID" \
  --logs '[
    {"category":"Administrative","enabled":true},
    {"category":"Security","enabled":true},
    {"category":"ServiceHealth","enabled":true},
    {"category":"Alert","enabled":true},
    {"category":"Recommendation","enabled":true},
    {"category":"Policy","enabled":true}
  ]'
```

### Task 2.2: Connect Azure AD Sign-in and Audit Logs (via portal)

1. In Microsoft Sentinel → **Data connectors**
2. Search for **Azure Active Directory**
3. Click **Open connector page**
4. Under **Configuration**, connect:
   - ✅ Sign-in logs
   - ✅ Audit logs
   - ✅ Non-interactive user sign-in logs (if available)
5. Click **Apply changes**

> 💡 Azure AD connectors require **Azure AD Diagnostic Settings** to point to the Sentinel Log Analytics workspace.

### Task 2.3: Connect Microsoft Defender for Cloud

1. In Sentinel → **Data connectors** → search **Microsoft Defender for Cloud**
2. Click **Open connector page**
3. Select your subscription → click **Connect**
4. Enable **Bi-directional sync** (Sentinel incidents ↔ Defender alerts)

✅ **Validation:** In Sentinel → **Logs**, run:
```kql
AzureActivity
| take 10
```
Data should appear within 5–15 minutes of configuring the connector.

---

## Exercise 3: Analytics Rules

### Task 3.1: Enable built-in rule templates

1. In Microsoft Sentinel → **Analytics**
2. Click **Rule templates** tab
3. Search for **"brute force"** — find **"Failed login attempts"** or similar
4. Click on the rule → **Create rule**
5. Review and accept default settings → **Create**

### Task 3.2: Create a custom Scheduled analytics rule

1. In Sentinel → **Analytics** → **+ Create** → **Scheduled query rule**
2. **General:**
   - Name: `Detect Multiple Failed Logins from Same IP`
   - Severity: Medium
   - MITRE ATT&CK: **Credential Access** → **Brute Force**

3. **Set rule logic** — paste this KQL:
```kql
SecurityEvent
| where EventID == 4625  // Failed logon
| where TimeGenerated > ago(1h)
| summarize 
    FailCount = count(),
    Accounts = make_set(TargetAccount),
    LastAttempt = max(TimeGenerated)
  by IpAddress
| where FailCount >= 10
| extend AlertDetails = strcat(
    "IP: ", IpAddress,
    " | Failures: ", FailCount,
    " | Accounts targeted: ", array_length(Accounts))
| project TimeGenerated = LastAttempt, IpAddress, FailCount, Accounts, AlertDetails
```

4. **Alert enhancement:**
   - Entity mapping: Add `IpAddress` → type **IP**, identifier **Address**

5. **Query scheduling:**
   - Run query every: **5 minutes**
   - Lookup data from the last: **1 hour**
   - Alert threshold: greater than 0

6. **Incident settings:** Enable → Group related alerts into incidents

7. Click **Review and create** → **Save**

✅ **Validation:** Rule appears in **Analytics** → **Active rules** tab.

---

## Exercise 4: Automation Playbook (Logic App)

### Task 4.1: Create a playbook that sends an email on incident creation

1. In Microsoft Sentinel → **Automation** → **Playbooks** → **+ Create**
2. Select **Incident trigger**
3. Name: `Notify-On-Incident`
4. Click **Create and open Logic App designer**

5. The trigger is pre-set: **When a response to a Microsoft Sentinel incident is triggered**

6. Add a step: **Send an email (V2)** (requires Office 365 Outlook connector)
   - **To:** your email address
   - **Subject:** `[Sentinel Alert] #{triggerBody()?['object']?['properties']?['title']}`
   - **Body:**
     ```
     Incident: @{triggerBody()?['object']?['properties']?['title']}
     Severity: @{triggerBody()?['object']?['properties']?['severity']}
     Status: @{triggerBody()?['object']?['properties']?['status']}
     Description: @{triggerBody()?['object']?['properties']?['description']}
     ```
7. **Save** the Logic App

### Task 4.2: Attach playbook to an analytics rule (automation rule)

1. In Sentinel → **Automation** → **Automation rules** → **+ Create**
2. Name: `Auto-Notify-High-Severity`
3. **Trigger:** When incident is created
4. **Conditions:** Incident severity Equals High
5. **Actions:** Run playbook → Select `Notify-On-Incident`
6. Click **Apply**

✅ **Validation:** When a High severity incident is created in Sentinel, the playbook runs and sends an email.

---

## Exercise 5: Microsoft Defender for Cloud

### Task 5.1: Review Secure Score

1. In Azure Portal → **Microsoft Defender for Cloud** → **Overview**
2. Note the **Secure Score** percentage
3. Click on the score → **Recommendations** sorted by **Potential score increase**

### Task 5.2: Remediate a recommendation

1. Find the recommendation: **"MFA should be enabled on accounts with owner permissions on your subscription"**
2. Click on it → Review affected resources
3. Follow the remediation steps:
   - Navigate to **Azure AD** → **Security** → **Conditional Access**
   - Create a policy requiring MFA for all users with Owner role
4. Return to Defender for Cloud and click **Refresh**

### Task 5.3: Assign a regulatory compliance standard

1. In Defender for Cloud → **Regulatory compliance**
2. Click **Manage compliance policies**
3. Select your subscription → **Security policies** → **Industry & regulatory standards**
4. Add: **CIS Microsoft Azure Foundations Benchmark v2.0.0**
5. Navigate back to **Regulatory compliance** and review:
   - Pass/fail controls
   - Download compliance report (PDF)

✅ **Validation:** CIS benchmark appears in the Regulatory compliance dashboard.

---

## Exercise 6: Azure Key Vault Monitoring

### Task 6.1: Create Key Vault with diagnostic logging

```bash
KV_NAME="kv-secops-$(openssl rand -hex 4)"

az keyvault create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$KV_NAME" \
  --location "$LOCATION" \
  --enable-rbac-authorization true \
  --enable-purge-protection true

# Enable diagnostic logging to Sentinel workspace
az monitor diagnostic-settings create \
  --name "KV-To-Sentinel" \
  --resource "$(az keyvault show --name $KV_NAME --query id -o tsv)" \
  --workspace "$WORKSPACE_ID" \
  --logs '[
    {"category":"AuditEvent","enabled":true},
    {"category":"AzurePolicyEvaluationDetails","enabled":true}
  ]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'

# Store test secret
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "database-password" \
  --value "SuperSecretP@ssw0rd"
```

### Task 6.2: Create a Key Vault alert rule

```bash
# Alert when a secret is accessed (any Get operation on secrets)
az monitor scheduled-query create \
  --resource-group "$RESOURCE_GROUP" \
  --name "KV-Secret-Access-Alert" \
  --scopes "$WORKSPACE_ID" \
  --condition-query "AzureDiagnostics
    | where ResourceType == 'VAULTS'
    | where OperationName == 'SecretGet'
    | where ResultType == 'Success'
    | summarize count() by bin(TimeGenerated, 5m), CallerIPAddress, identity_claim_oid_g" \
  --condition-threshold 0 \
  --condition-operator GreaterThan \
  --evaluation-frequency PT5M \
  --window-size PT5M \
  --severity 2 \
  --description "Alert when Key Vault secrets are accessed"
```

### Task 6.3: Query Key Vault access logs in Log Analytics

```bash
# Access the workspace and run a KQL query
WORKSPACE_CUSTOMER_ID=$(az monitor log-analytics workspace show \
  -g "$RESOURCE_GROUP" -n "$WORKSPACE_NAME" \
  --query customerId -o tsv)

echo "Run this KQL in Sentinel Logs or Log Analytics:"
cat << 'EOF'
// Key Vault operations in the last 24 hours
AzureDiagnostics
| where ResourceType == "VAULTS"
| where TimeGenerated > ago(24h)
| project TimeGenerated, OperationName, ResultType, CallerIPAddress, 
          identity_claim_upn_s, ResourceId
| order by TimeGenerated desc
EOF
```

✅ **Validation:** After accessing a secret in the Key Vault, the `AzureDiagnostics` table should show a `SecretGet` operation.

---

## Bonus: KQL Practice Queries

Run these in Sentinel → **Logs** (or Log Analytics):

```kql
// 1. Find all Azure AD sign-ins from risky IPs (last 7 days)
SigninLogs
| where TimeGenerated > ago(7d)
| where RiskLevelDuringSignIn in ("high", "medium")
| project TimeGenerated, UserPrincipalName, IPAddress, Location, 
          RiskLevelDuringSignIn, AppDisplayName
| order by RiskLevelDuringSignIn asc, TimeGenerated desc
```

```kql
// 2. Resources deleted in the last 24 hours
AzureActivity
| where TimeGenerated > ago(24h)
| where OperationNameValue endswith "/delete"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, ResourceGroup, Resource, OperationNameValue
| order by TimeGenerated desc
```

```kql
// 3. Role assignments created (privilege escalation monitoring)
AzureActivity
| where TimeGenerated > ago(7d)
| where OperationNameValue == "MICROSOFT.AUTHORIZATION/ROLEASSIGNMENTS/WRITE"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, ResourceGroup, Properties
| order by TimeGenerated desc
```

---

## Lab Cleanup

```bash
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

# Disable Defender plans
az security pricing create --name "VirtualMachines" --tier "Free"
az security pricing create --name "SqlServers" --tier "Free"
az security pricing create --name "KeyVaults" --tier "Free"
az security pricing create --name "StorageAccounts" --tier "Free"
az security pricing create --name "AppServices" --tier "Free"
```

---

## Lab Summary

| Concept | What You Practiced |
|---|---|
| Log Analytics workspace | Creation, 90-day retention |
| Microsoft Sentinel | Onboarding, data connectors (Activity Log, Azure AD, Defender) |
| Analytics rules | Built-in templates, custom KQL scheduled rule, MITRE mapping |
| Automation | Playbook (Logic App) for email notifications, automation rules |
| Defender for Cloud | Secure Score review, recommendation remediation, CIS benchmark |
| Key Vault monitoring | Diagnostic logging, KQL queries for access auditing |

---

*Previous: [Lab 03 — Compute, Storage and Databases ←](lab-03-compute-storage.md) | Back to: [README →](../README.md)*
