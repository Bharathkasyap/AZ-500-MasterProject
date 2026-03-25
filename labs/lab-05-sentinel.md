# Lab 05 — Deploy Microsoft Sentinel SIEM

> **Estimated time:** 60–90 minutes  
> **Prerequisites:** Azure subscription, Log Analytics Contributor + Microsoft Sentinel Contributor roles  
> **Skills practiced:** Domain 4 — Manage Security Operations

---

## Objectives

By the end of this lab you will be able to:

1. Create a Log Analytics workspace and enable Microsoft Sentinel.
2. Connect data connectors (Entra ID, Azure Activity, Defender for Cloud).
3. Create an analytics rule to detect suspicious sign-ins.
4. Understand incidents and investigate the incident graph.
5. Create a playbook (Logic App) to auto-respond to incidents.
6. Write KQL queries to investigate security events.
7. Create a Sentinel workbook dashboard.

---

## Architecture

```
Data Sources
  ├── Microsoft Entra ID (Sign-in logs, Audit logs)
  ├── Azure Activity Log (ARM operations)
  └── Microsoft Defender for Cloud (Security alerts)
          │
          ▼
  Log Analytics Workspace (law-az500-sentinel)
          │
          ▼
  Microsoft Sentinel
    ├── Data Connectors (ingest raw data)
    ├── Analytics Rules (detect threats → create alerts → create incidents)
    ├── Incidents (triaged in the Sentinel queue)
    ├── Playbooks (automated response via Logic Apps)
    └── Workbooks (dashboards)
```

---

## Part 1 — Create Log Analytics Workspace and Enable Sentinel

```bash
# Variables
RG="rg-az500-sentinel"
LOCATION="eastus"
LA_NAME="law-az500-sentinel"

# Create resource group
az group create --name $RG --location $LOCATION

# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name $LA_NAME \
  --location $LOCATION \
  --retention-time 90

# Get workspace resource ID
LA_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name $LA_NAME \
  --query id -o tsv)

# Enable Microsoft Sentinel on the workspace
az sentinel workspace create \
  --resource-group $RG \
  --workspace-name $LA_NAME \
  --location $LOCATION
```

### Via Portal (Alternative)

1. Search for **Microsoft Sentinel** in the portal.
2. Click **+ Create** → **Create a new workspace**.
3. Create a new Log Analytics workspace in your resource group.
4. Click **Add Microsoft Sentinel**.

---

## Part 2 — Connect Data Connectors

### 2a — Connect Microsoft Entra ID

1. In Sentinel → **Data connectors** → Search for **Microsoft Entra ID**.
2. Click **Open connector page**.
3. Under **Configuration**, select:
   - ✅ **Sign-in logs**
   - ✅ **Audit logs**
   - ✅ **Provisioning logs**
   - ✅ **Risky sign-ins** (requires P2)
4. Click **Apply Changes**.

> **Note:** Entra ID logs flow to the `SigninLogs`, `AuditLogs`, and `AADProvisioningLogs` tables.

### 2b — Connect Azure Activity Log

```bash
# Connect Azure Activity Log via diagnostic settings
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az monitor diagnostic-settings create \
  --name "sentinel-activity" \
  --resource "/subscriptions/$SUBSCRIPTION_ID" \
  --workspace $LA_ID \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"Alert","enabled":true},{"category":"Policy","enabled":true}]'
```

### 2c — Connect Microsoft Defender for Cloud

1. In Sentinel → **Data connectors** → **Microsoft Defender for Cloud**.
2. Click **Open connector page**.
3. Select your subscription(s).
4. Click **Connect**.
5. Enable **Bi-directional sync** (Sentinel incidents update Defender alert status).

---

## Part 3 — Create Analytics Rules

### 3a — Enable Built-in Microsoft Security Rules

1. In Sentinel → **Analytics** → **Rule templates** tab.
2. Filter by **Data source**: Microsoft Entra ID.
3. Find **"Suspicious sign-in activity"** → Click **Create rule**.
4. Review the auto-populated settings → Click **Next: Automated response** → **Next: Review** → **Save**.

### 3b — Create a Custom Scheduled Analytics Rule

**Scenario:** Detect more than 5 failed sign-ins for the same user within 10 minutes.

1. In Sentinel → **Analytics** → **+ Create** → **Scheduled query rule**.
2. Fill in:
   - **Name**: `Brute Force - Multiple Failed Sign-ins`
   - **Severity**: Medium
   - **MITRE ATT&CK tactics**: Credential Access → T1110 (Brute Force)

3. Under **Set rule logic**, paste this KQL:

```kql
SigninLogs
| where TimeGenerated > ago(10m)
| where ResultType != "0"  // Failed sign-ins only
| summarize FailureCount = count(), 
            FailedApps = make_set(AppDisplayName),
            SourceIPs = make_set(IPAddress)
  by UserPrincipalName, bin(TimeGenerated, 10m)
| where FailureCount >= 5
| extend AccountCustomEntity = UserPrincipalName
| extend IPCustomEntity = tostring(SourceIPs[0])
```

4. **Alert enrichment**:
   - Entity mapping:
     - Account → `AccountCustomEntity` (UserPrincipalName)
     - IP → `IPCustomEntity`

5. **Query scheduling**:
   - Run every: 5 minutes
   - Lookup data from last: 10 minutes

6. **Alert threshold**: Generate alert when results > 0.

7. **Incident settings**: Enable incident creation (group alerts).

8. Click **Next: Automated response** → **Save**.

### 3c — Create a Near Real-Time (NRT) Rule

**Scenario:** Alert immediately when someone adds a member to a privileged role.

1. **+ Create** → **NRT query rule**.
2. Name: `Privileged Role Membership Change`
3. Severity: High
4. KQL:

```kql
AuditLogs
| where OperationName in ("Add member to role", "Add eligible member to role")
| where TargetResources[0].displayName in (
    "Global Administrator",
    "Privileged Role Administrator",
    "Security Administrator",
    "User Administrator"
  )
| extend 
    InitiatedBy = tostring(InitiatedBy.user.userPrincipalName),
    TargetUser = tostring(TargetResources[0].userPrincipalName),
    Role = tostring(TargetResources[0].displayName)
| project TimeGenerated, InitiatedBy, TargetUser, Role, OperationName
```

5. Entity mapping:
   - Account → `InitiatedBy`
6. Save.

---

## Part 4 — Create a Playbook for Automated Response

### 4a — Create the Playbook (Logic App)

```bash
# Deploy a pre-built playbook from the Sentinel content hub
# In portal: Sentinel → Content hub → Search "Block Azure AD User"
# Install the solution → Deploy the playbook
```

### Via Portal — Create Custom Playbook

1. Sentinel → **Automation** → **Playbooks** → **+ Add new playbook**.
2. Select **Incident trigger**.
3. Playbook name: `Notify-Security-Team-On-Incident`
4. In the Logic App designer, add:

   **Trigger**: `When a Microsoft Sentinel incident is created`
   
   **Action 1**: Send an email (Office 365 Outlook or SendGrid):
   - To: security-team@yourcompany.com
   - Subject: `[Sentinel Alert] @{triggerBody()?['object']?['properties']?['title']}`
   - Body:
     ```
     Severity: @{triggerBody()?['object']?['properties']?['severity']}
     Status: @{triggerBody()?['object']?['properties']?['status']}
     Description: @{triggerBody()?['object']?['properties']?['description']}
     Incident URL: @{triggerBody()?['object']?['properties']?['incidentUrl']}
     ```

5. Save the Logic App.

### 4b — Attach Playbook to an Analytics Rule

1. Go to your **Brute Force** analytics rule → **Edit**.
2. **Automated response** tab → **Add new**.
3. Select the playbook you just created.
4. Save.

---

## Part 5 — Investigate an Incident

### Trigger a Test Incident

```bash
# Simulate failed sign-ins (will generate brute force alert after ~10 min)
# Use the Azure portal to attempt sign-in with wrong password 6 times for the test user
# OR trigger a test alert from Defender for Cloud:
az security alerts simulate --resource-group <rg>
```

### Investigate via Portal

1. Sentinel → **Incidents** (wait for an incident to appear or use a sample).
2. Click on the incident to open the investigation pane.
3. Review:
   - **Incident details** (severity, status, assigned to, evidence)
   - **Entities** (users, IPs, hosts involved)
   - **Alerts** (constituent alerts that formed this incident)
4. Click **Investigate** to open the **Investigation Graph**:
   - Shows relationships between entities.
   - Expand entities to see related events.
5. Add a comment: "Investigated by [your name] — appears to be brute force from IP x.x.x.x"
6. Set **Status**: Active → Assign to yourself.

---

## Part 6 — KQL Investigation Queries

### Query the incident's source IP

```kql
// What else did this IP do?
let SuspiciousIP = "1.2.3.4";  // Replace with actual IP from incident

SigninLogs
| where IPAddress == SuspiciousIP
| project TimeGenerated, UserPrincipalName, ResultType, AppDisplayName, Location, 
          DeviceDetail, ConditionalAccessStatus
| order by TimeGenerated desc
```

### Check if the user's account was compromised

```kql
// All activity for a suspicious user in the last 24 hours
let SuspiciousUser = "user@domain.com";

union 
(
    SigninLogs
    | where UserPrincipalName == SuspiciousUser
    | project TimeGenerated, Category = "SignIn", Details = strcat(AppDisplayName, " - ", ResultDescription)
),
(
    AuditLogs
    | where InitiatedBy.user.userPrincipalName == SuspiciousUser
    | project TimeGenerated, Category = "AuditEvent", Details = OperationName
),
(
    AzureActivity
    | where Caller == SuspiciousUser
    | project TimeGenerated, Category = "AzureActivity", Details = OperationNameValue
)
| order by TimeGenerated desc
```

### Identify impossible travel

```kql
// Users who signed in from two different countries within 1 hour
SigninLogs
| where ResultType == "0"
| summarize 
    Locations = make_set(Location.countryOrRegion),
    IPs = make_set(IPAddress),
    Count = count()
  by UserPrincipalName, bin(TimeGenerated, 1h)
| where array_length(Locations) > 1
| project TimeGenerated, UserPrincipalName, Locations, IPs
```

### Detect Azure Resource Manipulation

```kql
// Suspicious ARM operations — deletes and role assignments
AzureActivity
| where OperationNameValue contains "delete" or OperationNameValue contains "roleAssignments/write"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, Resource, Properties
| order by TimeGenerated desc
```

---

## Part 7 — Create a Workbook Dashboard

1. Sentinel → **Workbooks** → **Templates** tab.
2. Find **"Azure AD Sign-in and Audit logs"** → Click **Save** → **View saved workbook**.
3. The workbook shows:
   - Sign-in trends over time
   - Top locations by sign-in count
   - Failed sign-ins by user
   - Audit event trends

### Create Custom Workbook

1. Sentinel → **Workbooks** → **+ Add workbook**.
2. Click **Edit** → **Add** → **Add query**.
3. Paste this KQL:

```kql
SecurityAlert
| summarize Count = count() by AlertSeverity, AlertName
| order by Count desc
```

4. Visualization: **Bar chart**
5. Title: "Security Alerts by Severity and Type"
6. Click **Done editing** → **Save**.

---

## Cleanup

```bash
# Delete the resource group (removes workspace and all Sentinel data)
az group delete --name $RG --yes --no-wait
```

---

## Key Takeaways

- **Microsoft Sentinel** uses a single **Log Analytics workspace** as its data lake — all KQL queries run against this workspace.
- **Data connectors** pull logs from source services; without connectors, there is no data to analyze.
- **Analytics rules** are the detection engine — they run KQL queries on a schedule and create alerts.
- **Incidents** are groups of correlated alerts — triage happens at the incident level, not alert level.
- **Playbooks** (Logic Apps) automate response — they can run automatically or be triggered manually.
- **NRT rules** run every minute — use for high-priority detections where latency matters.
- **Entity mapping** in analytics rules enables the **Investigation Graph** — always map entities.
- **KQL** is the core skill for Sentinel — practice `summarize`, `join`, `union`, `parse`, `extend`.
