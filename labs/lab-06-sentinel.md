# Lab 06: Microsoft Sentinel SIEM/SOAR

> **Domain**: Security Operations | **Difficulty**: Advanced | **Time**: ~45 minutes

---

## Prerequisites

- Azure subscription with Security Admin or Owner access
- Microsoft Sentinel workspace (or we will create one in this lab)
- At least one data source to connect (Entra ID, Azure Activity)

---

## Objectives

By the end of this lab, you will be able to:
- Deploy Microsoft Sentinel on a Log Analytics Workspace
- Connect data connectors (Azure Activity, Entra ID)
- Create a Scheduled Analytics Rule with KQL
- Create an Automation Rule and Playbook
- Perform threat hunting with KQL

---

## Part 1: Deploy Microsoft Sentinel

### Step 1.1 — Create Log Analytics Workspace

```bash
RG="SentinelLabRG"
LOCATION="eastus"
WORKSPACE="SentinelWorkspace$RANDOM"

# Create resource group
az group create --name $RG --location $LOCATION

# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name $WORKSPACE \
  --location $LOCATION \
  --sku PerGB2018 \
  --retention-time 90

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name $WORKSPACE \
  --query id --output tsv)
echo "Workspace ID: $WORKSPACE_ID"
```

### Step 1.2 — Enable Microsoft Sentinel

```bash
# Enable Sentinel on the workspace
az sentinel workspace create \
  --resource-group $RG \
  --workspace-name $WORKSPACE

echo "Microsoft Sentinel enabled on workspace: $WORKSPACE"
```

---

## Part 2: Connect Data Connectors

### Step 2.1 — Connect Azure Activity Logs

Azure Activity logs record all subscription-level operations.

```
Azure Portal → Microsoft Sentinel → Configuration → Data connectors
  → Search for "Azure Activity"
  → Open connector page → Launch Azure Policy Assignment Wizard
  → Assign policy to your subscription
  → Review + create → Create
```

Or via Policy:

```bash
# Assign Azure Activity log connector policy
az policy assignment create \
  --name "sentinel-activity-$(az account show --query id --output tsv | cut -c1-8)" \
  --policy "2465583e-4e78-4c15-b6be-a36cbc7c8b0f" \
  --scope "/subscriptions/$(az account show --query id --output tsv)" \
  --params "{\"logAnalytics\": {\"value\": \"$WORKSPACE_ID\"}}"
```

### Step 2.2 — Connect Entra ID (Azure AD) Logs

```
Sentinel → Data connectors → Microsoft Entra ID → Open connector page
  → Select log types:
    ✅ Sign-in Logs
    ✅ Audit Logs
    ✅ Non-Interactive User Sign-in Log
    ✅ Service Principal Sign-in Log
  → Apply Changes
```

> **Note**: Requires Entra ID P1 or P2 for sign-in logs. Global Administrator or Security Administrator role required.

### Step 2.3 — Verify Data is Flowing

```bash
# After 10-15 minutes, verify data is ingesting:
az monitor log-analytics query \
  --workspace $WORKSPACE_ID \
  --analytics-query "AzureActivity | summarize count() by CategoryValue | top 5 by count_" \
  --output table
```

---

## Part 3: Create Analytics Rules

### Step 3.1 — Create Scheduled Analytics Rule (Portal)

```
Sentinel → Configuration → Analytics → + Create → Scheduled query rule
```

Configure the rule:

**General**:
- Name: `Multiple Failed Sign-ins from Same IP`
- Description: Detects potential password spray attacks
- Tactics: Credential Access
- Severity: Medium

**Rule Logic**:
```kql
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != 0
| summarize FailureCount = count(), 
            DistinctUsers = dcount(UserPrincipalName),
            Users = make_set(UserPrincipalName, 10)
  by IPAddress, bin(TimeGenerated, 5m)
| where FailureCount >= 10 and DistinctUsers >= 3
| project TimeGenerated, IPAddress, FailureCount, DistinctUsers, Users
| order by FailureCount desc
```

**Query Scheduling**:
- Run query every: 5 minutes
- Lookup data from last: 1 hour

**Alert Threshold**:
- Generate alert when number of results > 0

**Entity Mapping**:
- IP Address → IPAddress

Click **Review + create** → **Create**.

### Step 3.2 — Create Analytics Rule via ARM Template

```bash
# Create rule via REST API/CLI (advanced)
cat > /tmp/sentinel-rule.json << 'EOF'
{
  "kind": "Scheduled",
  "properties": {
    "displayName": "Admin Account Created Outside Business Hours",
    "description": "Detects admin account creation outside 8am-6pm weekdays",
    "severity": "High",
    "enabled": true,
    "query": "AuditLogs\n| where TimeGenerated > ago(1d)\n| where OperationName == 'Add user'\n| where Result == 'success'\n| extend Hour = hourofday(TimeGenerated)\n| extend DayOfWeek = dayofweek(TimeGenerated)\n| where Hour < 8 or Hour > 18 or DayOfWeek == 0 or DayOfWeek == 6\n| project TimeGenerated, OperationName, InitiatedBy, TargetResources",
    "queryFrequency": "PT1H",
    "queryPeriod": "P1D",
    "triggerOperator": "GreaterThan",
    "triggerThreshold": 0,
    "suppressionEnabled": false,
    "tactics": ["Persistence"],
    "techniques": ["T1136"],
    "alertRuleTemplateName": null
  }
}
EOF
```

---

## Part 4: Create Automation (Playbook + Automation Rule)

### Step 4.1 — Create a Sentinel Playbook (Logic App)

```
Azure Portal → Logic Apps → + Add
  → Name: SentinelBlockIPPlaybook
  → Resource Group: SentinelLabRG
  → Plan: Consumption
  → Create
```

Design the Logic App:

1. **Trigger**: `Microsoft Sentinel incident`
2. **Action 1**: Parse incident entities to find IP addresses
   - Action: `Microsoft Sentinel` → `Entities - Get IPs`
   - Input: Incident ARM ID from trigger
3. **Action 2**: For each IP
   - Action: `Azure Resource Manager` → Create/update resource (NSG deny rule)
4. **Action 3**: Add comment to Sentinel incident
   - Action: `Microsoft Sentinel` → `Add comment to incident`
   - Comment: `IP @{items('For_each')?['Address']} has been blocked via NSG rule`

### Step 4.2 — Create Automation Rule

```
Sentinel → Configuration → Automation → + Create → Automation rule
```

Configure:
- Name: `Auto-Assign High Severity Incidents`
- Trigger: When incident is created
- Conditions: 
  - Incident provider = Microsoft Sentinel
  - Severity = High
- Actions:
  1. Assign owner → Select your user
  2. Change severity → (leave as-is)
  3. Add tag → `Needs-Investigation`
  4. Run playbook → SentinelBlockIPPlaybook (if IP entity present)

Click **Apply**.

---

## Part 5: Threat Hunting with KQL

### Step 5.1 — Hunt for Suspicious Activity

Navigate to: `Sentinel → Threat management → Hunting → + New query`

**Hunt 1: Impossible Travel**
```kql
// Detect sign-ins from two geographically distant locations within 1 hour
SigninLogs
| where TimeGenerated > ago(7d)
| where ResultType == 0  // Successful sign-ins only
| project TimeGenerated, UserPrincipalName, Location, 
          IPAddress, Latitude = toreal(LocationDetails.geoCoordinates.latitude),
          Longitude = toreal(LocationDetails.geoCoordinates.longitude)
| summarize Locations = make_list(pack("time", TimeGenerated, "ip", IPAddress, 
                                        "lat", Latitude, "lon", Longitude))
  by UserPrincipalName
| mv-expand Locations
| extend SignInTime = todatetime(Locations.time), Lat = toreal(Locations.lat), Lon = toreal(Locations.lon)
| summarize count() by UserPrincipalName
| where count_ >= 2
```

**Hunt 2: Azure Resource Deletion Spree**
```kql
// Detect multiple resource deletions by a single user in a short time
AzureActivity
| where TimeGenerated > ago(24h)
| where OperationNameValue endswith "delete"
| where ActivityStatusValue == "Success"
| summarize DeletionCount = count(), Resources = make_set(Resource, 20)
  by Caller, bin(TimeGenerated, 1h)
| where DeletionCount >= 5
| order by DeletionCount desc
```

**Hunt 3: New Global Administrator Added**
```kql
// Alert when Global Admin role is assigned
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName == "Add member to role"
| where TargetResources[0].modifiedProperties contains "Global Administrator"
| project TimeGenerated, 
          InitiatedBy = InitiatedBy.user.userPrincipalName,
          TargetUser = TargetResources[0].userPrincipalName,
          Role = TargetResources[0].modifiedProperties[0].newValue
```

**Hunt 4: Key Vault Access from Unusual Location**
```kql
// Detect Key Vault access from an IP that hasn't accessed it before
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet" or OperationName == "KeyGet"
| summarize AccessCount = count(), 
            FirstSeen = min(TimeGenerated),
            LastSeen = max(TimeGenerated)
  by CallerIPAddress, Resource
| where FirstSeen > ago(1d)  // First seen in last 24 hours
| order by AccessCount desc
```

### Step 5.2 — Bookmark Interesting Results

When hunting results show suspicious activity:

```
Sentinel → Hunting → Run query → Select suspicious rows
  → Add bookmark → Fill in notes → Save bookmark
  → Bookmark can be converted to incident: Actions → Create incident
```

---

## Part 6: Review Sentinel Workbooks

### Step 6.1 — Configure a Workbook

```
Sentinel → Threat management → Workbooks → Templates
  → Search for "Azure AD Sign-in logs"
  → Save → View saved workbook
  → Explore: sign-in failures, MFA usage, conditional access results
```

---

## Cleanup

```bash
az group delete --name $RG --yes --no-wait
echo "Resources scheduled for deletion"
```

---

## ✅ Verification Checklist

- [ ] Microsoft Sentinel deployed on Log Analytics Workspace
- [ ] Azure Activity and Entra ID data connectors connected
- [ ] Data verified flowing into workspace (queries returning results)
- [ ] Scheduled analytics rule created for failed sign-in detection
- [ ] Automation rule created to auto-assign high severity incidents
- [ ] Playbook (Logic App) created for incident response
- [ ] At least 2 threat hunting queries executed
- [ ] Suspicious results bookmarked for investigation

---

> ⬅️ [Lab 05: Defender for Cloud](./lab-05-defender-for-cloud.md) | ⬆️ [Back to README](../README.md)
