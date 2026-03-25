# Lab 03 — Configure Microsoft Sentinel

## Objective

By the end of this lab you will be able to:
- Create a Log Analytics workspace and enable Microsoft Sentinel
- Connect an Azure AD data source
- Create a scheduled analytics rule using KQL
- Investigate an incident
- Create a playbook (Logic App) to automate a response

---

## Prerequisites

- An Azure subscription
- Global Administrator or Security Administrator role in Azure AD
- Contributor role on the target subscription

---

## Part 1 — Create Log Analytics Workspace and Enable Sentinel

### Using the Azure Portal

1. Navigate to [portal.azure.com](https://portal.azure.com).
2. Search for **Microsoft Sentinel** and click **Create Microsoft Sentinel**.
3. Click **+ Create a new workspace**.
4. Fill in:
   - **Subscription**: your subscription
   - **Resource group**: Create new → `rg-sentinel-lab`
   - **Name**: `law-sentinel-lab` (must be globally unique)
   - **Region**: East US (or nearest to you)
5. Click **Review + Create** → **Create**.
6. Once the workspace is created, select it and click **Add** to enable Sentinel.

### Using Azure CLI

```bash
RESOURCE_GROUP="rg-sentinel-lab"
LOCATION="eastus"
WORKSPACE="law-sentinel-lab-$RANDOM"

az group create --name $RESOURCE_GROUP --location $LOCATION

az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE \
  --location $LOCATION

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE \
  --query id -o tsv)

# Enable Sentinel on the workspace
az sentinel onboarding-state create \
  --workspace-name $WORKSPACE \
  --resource-group $RESOURCE_GROUP \
  --name default
```

---

## Part 2 — Connect Data Sources

### Connect Azure Active Directory

1. In Microsoft Sentinel, go to **Configuration** → **Data connectors**.
2. Search for **Azure Active Directory**.
3. Click **Open connector page**.
4. Under **Configuration**, check:
   - ✅ **Sign-in logs**
   - ✅ **Audit logs**
   - ✅ (Optional) **Risky sign-ins** (requires Azure AD P2)
5. Click **Apply changes**.

> **Note**: Logs start appearing in 5–15 minutes.

### Connect Azure Activity

1. In Data connectors, search for **Azure Activity**.
2. Click **Open connector page** → **Launch Azure Policy Assignment Wizard**.
3. On the **Parameters** tab, select your Log Analytics workspace.
4. Click **Review and create** → **Create**.

---

## Part 3 — Create a Scheduled Analytics Rule

This rule detects when a user account is disabled and re-enabled within a short window (a common account manipulation technique).

1. Microsoft Sentinel → **Configuration** → **Analytics** → **+ Create** → **Scheduled query rule**.

### General Tab
- **Name**: `Account Disabled Then Re-Enabled`
- **Description**: `Detects an account that was disabled and then re-enabled within 1 hour`
- **Severity**: Medium
- **Tactics**: Persistence
- **Techniques**: T1098 (Account Manipulation)

### Set Rule Logic Tab

```kql
let lookback = 1h;
AuditLogs
| where TimeGenerated > ago(lookback)
| where OperationName == "Disable account"
| extend DisabledUser = tostring(TargetResources[0].userPrincipalName)
| join kind=inner (
    AuditLogs
    | where TimeGenerated > ago(lookback)
    | where OperationName == "Enable account"
    | extend ReEnabledUser = tostring(TargetResources[0].userPrincipalName)
) on $left.DisabledUser == $right.ReEnabledUser
| project TimeGenerated, DisabledUser, InitiatedBy=tostring(InitiatedBy.user.userPrincipalName)
```

- **Query scheduling**: Every **5 minutes**, look back **1 hour**
- **Alert threshold**: Generate alert when number of results is **greater than 0**
- **Event grouping**: Group all events into a single alert

### Incident settings Tab
- Enable **Create incidents from alerts triggered by this analytics rule** ✅

### Automated response Tab
- Leave blank for now (we'll add automation in Part 5)

Click **Review and create** → **Save**.

---

## Part 4 — Investigate a Sentinel Incident

*(Simulate an alert or wait for a real one from connected data sources)*

### Simulate a Sign-in Failure (optional)

1. Open a new InPrivate/Incognito browser.
2. Navigate to [portal.azure.com](https://portal.azure.com).
3. Attempt to sign in with an invalid password multiple times.
4. Within ~15 minutes, the failed sign-in logs will appear in Sentinel.

### Investigate the Incident

1. Microsoft Sentinel → **Threat management** → **Incidents**.
2. Click on an incident to open the details panel.
3. Click **View full details**.
4. Explore:
   - **Timeline** — chronological events
   - **Entities** — extracted users, IPs, hosts
   - **Evidence** — raw alert data
   - **Investigation graph** — visual entity relationships
5. Click an entity (e.g., a user) → **Go hunt** → see related events.
6. Set **Status** to **Active** and assign to yourself.
7. Add a **Comment**: `Investigated — testing lab activity. Benign.`
8. Close the incident: **Status** → **Closed** → **Reason**: `False Positive`.

---

## Part 5 — Create a Playbook (Logic App)

This playbook will send a Teams message when a Sentinel incident is created.

### Create the Logic App

1. Azure Portal → **Logic Apps** → **+ Add**.
2. Fill in:
   - **Resource group**: `rg-sentinel-lab`
   - **Logic App name**: `playbook-teams-notify`
   - **Region**: East US
   - **Plan type**: Consumption
3. Click **Review + create** → **Create**.
4. Once deployed, open the Logic App → **Logic app designer**.

### Build the Playbook

1. Select the template: **When a Microsoft Sentinel incident creation rule was triggered**.
   - This adds the Sentinel trigger automatically.
2. Click **+ New step** → search for **Microsoft Teams** → **Post a message in a chat or channel**.
3. Sign in to your Microsoft 365 account.
4. Configure:
   - **Post in**: Channel
   - **Team**: Your team
   - **Channel**: General
   - **Message**: 
     ```
     🚨 New Sentinel Incident: @{triggerBody()?['object']?['properties']?['title']}
     Severity: @{triggerBody()?['object']?['properties']?['severity']}
     Status: @{triggerBody()?['object']?['properties']?['status']}
     ```
5. Click **Save**.

### Attach Playbook to Analytics Rule

1. Microsoft Sentinel → **Configuration** → **Analytics**.
2. Edit your `Account Disabled Then Re-Enabled` rule.
3. Go to **Automated response** tab → **+ Add new**.
4. Select `playbook-teams-notify`.
5. Click **Review and create** → **Save**.

---

## Part 6 — Enable UEBA

1. Microsoft Sentinel → **Configuration** → **Settings** → **Entity behavior settings**.
2. Under **User and Entity Behavior Analytics**, enable UEBA.
3. Select data sources: **Azure Active Directory** ✅
4. Click **Apply**.

> UEBA builds baselines over 7 days before generating useful anomaly insights.

---

## Cleanup

```bash
az group delete --name rg-sentinel-lab --yes --no-wait
echo "Cleanup initiated"
```

> **Note**: Deleting the Log Analytics workspace will also remove all ingested logs.

---

## Key Takeaways

- Microsoft Sentinel is built on **Log Analytics** — all data is stored in and queried from a workspace.
- **Data connectors** bring logs in; **Analytics rules** find threats; **Playbooks** automate responses.
- **KQL** (Kusto Query Language) is essential for writing custom detection rules.
- **Incidents** are the primary unit of investigation in Sentinel — they aggregate correlated alerts.
- **UEBA** requires at least 7 days of data to establish behavioural baselines.
