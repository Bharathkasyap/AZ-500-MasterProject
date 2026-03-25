# Domain 4: Manage Security Operations (25–30%)

← [Back to README](../README.md) | [← Domain 3](./03-compute-storage-databases.md)

---

## Table of Contents

1. [Microsoft Sentinel](#1-microsoft-sentinel)
2. [Microsoft Defender for Cloud — Security Operations](#2-microsoft-defender-for-cloud--security-operations)
3. [Azure Monitor & Log Analytics](#3-azure-monitor--log-analytics)
4. [Azure Security Benchmark & Azure Policy](#4-azure-security-benchmark--azure-policy)
5. [Incident Response in Azure](#5-incident-response-in-azure)
6. [Key Exam Facts & Practice Questions](#6-key-exam-facts--practice-questions)

---

## 1. Microsoft Sentinel

**Microsoft Sentinel** is a cloud-native **SIEM (Security Information and Event Management)** and **SOAR (Security Orchestration, Automation, and Response)** solution built on Azure.

### Core Components

| Component | Description |
|-----------|-------------|
| **Workspace** | Log Analytics workspace backing Sentinel; all data stored here |
| **Data Connectors** | Ingest data from Microsoft services, Azure, third-party (Syslog, CEF, REST API) |
| **Analytics Rules** | Detect threats by querying ingested data; generate incidents |
| **Incidents** | Grouped security alerts + evidence; assigned to analysts for investigation |
| **Threat Intelligence** | IOC feeds (IP addresses, domains, hashes) used in detection |
| **Workbooks** | Dashboards and visualizations built on Log Analytics queries |
| **Playbooks** | Azure Logic Apps automating response to incidents/alerts |
| **Hunting** | Proactive threat hunting using KQL queries |
| **UEBA (User/Entity Behavior Analytics)** | Baseline normal behavior; detect anomalies |
| **Watchlists** | CSV-based reference data used in analytics rules (e.g., VIP users, asset lists) |
| **Notebooks** | Jupyter notebooks for deep investigation and advanced hunting |

### Data Connectors

Common connectors:
- **Microsoft connectors**: Entra ID, Microsoft 365 Defender, Defender for Cloud, Azure Activity, Azure AD Identity Protection
- **Azure services**: Azure Firewall, NSG Flow Logs, Key Vault, Storage, SQL
- **Non-Microsoft**: Syslog/CEF agents (Linux), REST API, Logstash
- **Threat Intelligence**: TAXII feeds, Microsoft Threat Intelligence

### Analytics Rules

| Rule Type | Description |
|-----------|-------------|
| **Scheduled** | KQL query runs on schedule (every N minutes/hours); creates incidents if results found |
| **NRT (Near Real-Time)** | Low-latency scheduled rule (runs every minute) |
| **Microsoft Security** | Create incidents from Microsoft 365 Defender alerts |
| **Fusion** | ML-based multi-stage attack detection (combines signals across tables) |
| **Anomaly** | ML-based behavioral anomaly detection (UEBA) |
| **Threat Intelligence** | Match indicators (IOCs) against logs |

### Incidents

- Created from analytics rule alerts
- Contain: title, severity (High/Medium/Low/Informational), status (New/Active/Closed), owner, evidence (related alerts, entities, bookmarks)
- **Entities**: Extracted artifacts (accounts, IPs, hosts, URLs, files) linked to incident
- **MITRE ATT&CK**: Incidents can be tagged with ATT&CK tactics and techniques

### Playbooks (SOAR)

Playbooks are **Azure Logic Apps** triggered by Sentinel analytics rules or incidents:

```
Trigger: When a Microsoft Sentinel incident is created
    │
    ├── Condition: Severity = High?
    │       ├── Yes → Send Teams message to SOC channel
    │       │       → Create ServiceNow ticket
    │       │       → Block IP in Azure Firewall (via API)
    │       └── No  → Send email notification
    │
    └── Update incident status to Active
```

**Automation rules**: Lightweight rules for incident management (assign owner, change status, suppress false positives, trigger playbooks) — run before playbooks, no code needed.

### Kusto Query Language (KQL) Essentials

```kql
// Find failed sign-ins from specific country
SigninLogs
| where TimeGenerated > ago(1d)
| where ResultType != 0  // Non-zero = failure
| where Location == "RU"
| summarize FailCount = count() by UserPrincipalName, IPAddress
| order by FailCount desc

// Detect impossible travel (sign-ins from two different countries within 1 hour)
SigninLogs
| where TimeGenerated > ago(1d)
| where ResultType == 0  // Success only
| summarize Locations = make_set(Location), Count = count() by UserPrincipalName, bin(TimeGenerated, 1h)
| where array_length(Locations) > 1

// Find process execution on endpoint
SecurityEvent
| where EventID == 4688  // Process creation
| where ProcessName endswith "powershell.exe"
| where CommandLine contains "-EncodedCommand"
| project TimeGenerated, Computer, Account, CommandLine
```

### Threat Hunting

- Proactive search for threats not yet detected by analytics rules
- Use **Hunting queries** (pre-built or custom KQL)
- **Bookmarks**: Save interesting query results for later investigation
- **Livestream**: Real-time query execution on incoming data

### UEBA (User and Entity Behavior Analytics)

- Establishes behavioral baseline for users and entities
- Generates **User/Entity Insights** shown on incidents and entity pages
- **Anomaly tables** (BehaviorAnalytics): Scored anomalies per user/entity
- Requires: Entra ID sign-in logs + audit logs enabled

### Sentinel Pricing

- Based on **data ingestion** into the Log Analytics workspace
- **Commitment tiers**: Per-GB pricing (Pay-as-you-go) or commitment tiers (fixed GB/day at discount)
- Microsoft 365 Defender data (UEBA, Threat Intelligence) may be free under certain plans

---

## 2. Microsoft Defender for Cloud — Security Operations

> *Note: Defender for Cloud is covered in Domain 3 (CSPM and workload protection). This section focuses on the security operations aspects relevant to Domain 4.*

### Continuous Export

Stream Defender for Cloud security alerts and recommendations to:
- **Log Analytics workspace** (for Sentinel integration or direct querying)
- **Azure Event Hub** (for third-party SIEM integration)

```bash
# Enable continuous export to Log Analytics
az security auto-provisioning-setting update \
  --name "mma" \
  --auto-provision "On"
```

### Workflow Automation

Trigger Logic Apps (playbooks) based on:
- Security alerts (Defender for Cloud alerts)
- Recommendations (specific recommendations becoming unhealthy)
- Regulatory compliance assessment changes

### Security Alerts in Defender for Cloud

Alert types include:
- **Compute alerts**: Suspicious process on VM, fileless attack, crypto mining
- **Storage alerts**: Unusual access, malware detected, data exfiltration
- **SQL alerts**: SQL injection attempt, unusual location access
- **Network alerts**: Suspicious outbound traffic, malicious IP communication

**Alert suppression rules**: Suppress known false positives to reduce noise.

---

## 3. Azure Monitor & Log Analytics

### Azure Monitor Components

```
Azure Monitor
    ├── Metrics (real-time, time-series numerical data)
    │       └── Metrics Explorer, Metric Alerts
    ├── Logs (Log Analytics Workspace — structured/semi-structured logs)
    │       └── KQL queries, Log Search Alerts, Workbooks
    ├── Alerts
    │       ├── Metric alerts
    │       ├── Log search alerts
    │       ├── Activity log alerts
    │       └── Service health alerts
    ├── Diagnostic Settings (route logs/metrics to destinations)
    ├── Action Groups (notifications + actions for alerts)
    └── Insights (VM Insights, Container Insights, Application Insights, etc.)
```

### Log Analytics Workspace

All Azure Monitor Logs are stored in a **Log Analytics workspace**. Key tables for security:

| Table | Content |
|-------|---------|
| `AzureActivity` | Azure Resource Manager operations (who did what, when) |
| `SigninLogs` | Entra ID sign-in logs |
| `AuditLogs` | Entra ID audit logs (user/group changes, app changes) |
| `SecurityEvent` | Windows Security event log from VMs |
| `Syslog` | Linux system logs from VMs |
| `AzureFirewallApplicationRule` | Azure Firewall application rule logs |
| `AzureFirewallNetworkRule` | Azure Firewall network rule logs |
| `AzureDiagnostics` | Various Azure resource diagnostic logs |
| `SecurityAlert` | Defender for Cloud alerts |
| `SecurityRecommendation` | Defender for Cloud recommendations |
| `KeyVaultLogs` | Key Vault audit events |
| `StorageBlobLogs` | Azure Storage Blob access logs |
| `SQLSecurityAuditEvents` | Azure SQL audit events |

### Diagnostic Settings

Configure which logs and metrics to collect from Azure resources and where to send them:

**Sources:**
- Azure resources (Key Vault, SQL, Storage, Firewall, NSG, etc.)
- Activity Log (subscription-level ARM operations)
- Entra ID (sign-in, audit logs)

**Destinations:**
- Log Analytics workspace
- Azure Storage (archive)
- Azure Event Hub (stream to SIEM)
- Partner solutions

```bash
# Enable diagnostic settings for a Key Vault
az monitor diagnostic-settings create \
  --resource "/subscriptions/<sub>/resourceGroups/MyRG/providers/Microsoft.KeyVault/vaults/MyKeyVault" \
  --name "KVDiagnostics" \
  --workspace "/subscriptions/<sub>/resourceGroups/MyRG/providers/Microsoft.OperationalInsights/workspaces/MyWorkspace" \
  --logs '[{"category":"AuditEvent","enabled":true,"retentionPolicy":{"enabled":true,"days":90}}]'
```

### Azure Monitor Alerts

**Alert components:**
- **Condition**: Metric threshold, log search result, activity log event
- **Action Group**: Email, SMS, webhook, ITSM, Logic App, Azure Function, Automation Runbook
- **Alert rule**: Combines signal + condition + action group + severity

**Common security alert scenarios:**
- Alert when anyone is added to Global Administrator role (Activity Log alert)
- Alert when Key Vault secret is accessed by an unexpected application
- Alert when VM process matching ransomware pattern is detected (Defender for Cloud)
- Alert on Entra ID sign-in failure spike (Log Search alert on SigninLogs)

```kql
// Log search alert: Multiple failed sign-ins followed by success (potential password spray)
let FailThreshold = 10;
let TimeWindow = 1h;
SigninLogs
| where TimeGenerated > ago(TimeWindow)
| where ResultType != 0
| summarize FailCount = countif(ResultType != 0), SuccessCount = countif(ResultType == 0) by UserPrincipalName
| where FailCount >= FailThreshold and SuccessCount >= 1
```

### Azure Activity Log

Records all **control plane** operations (ARM API calls) in a subscription:
- Who: Caller identity
- What: Operation name (e.g., `Microsoft.KeyVault/vaults/delete`)
- When: Timestamp
- Result: Succeeded, Failed, Accepted

**Retention**: 90 days built-in; export to Log Analytics for longer retention.

**Key security uses:**
- Detect unauthorized resource deletions
- Monitor policy changes
- Track role assignment changes
- Alert on subscription-level operations

---

## 4. Azure Security Benchmark & Azure Policy

### Microsoft Cloud Security Benchmark (MCSB)

Formerly **Azure Security Benchmark (ASB)**. A set of best-practice security recommendations for Azure (mapped to CIS, NIST, PCI DSS).

Control families:
- Network security (NS)
- Identity management (IM)
- Privileged access (PA)
- Data protection (DP)
- Asset management (AM)
- Logging and threat detection (LT)
- Incident response (IR)
- Posture and vulnerability management (PV)
- Endpoint security (ES)
- Backup and recovery (BR)
- DevOps security (DS)
- Governance and strategy (GS)

### Azure Policy

**Azure Policy** evaluates Azure resources against business rules (policies) and enforces compliance.

#### Policy Components

| Component | Description |
|-----------|-------------|
| **Policy definition** | A single rule (e.g., "Storage accounts must use HTTPS") |
| **Initiative (policy set)** | A collection of related policy definitions |
| **Assignment** | Apply a definition or initiative to a scope (MG, subscription, RG) |
| **Effect** | What happens when evaluated |

#### Policy Effects

| Effect | Description |
|--------|-------------|
| `Deny` | Block non-compliant resource creation/update |
| `Audit` | Log non-compliant resources; no blocking |
| `AuditIfNotExists` | Audit if a related resource doesn't exist (e.g., VM without antimalware extension) |
| `DeployIfNotExists` | Deploy a related resource if missing (remediation) |
| `Modify` | Add/update/remove resource properties or tags |
| `Append` | Append additional fields to a resource (e.g., add a tag) |
| `Disabled` | Policy defined but not enforced |

> **Exam Tip:** `DeployIfNotExists` and `Modify` require a **managed identity** on the policy assignment for the remediation task to execute.

```bash
# Assign the built-in "Require HTTPS" policy to a resource group
az policy assignment create \
  --name "RequireHTTPS" \
  --display-name "Storage accounts should use HTTPS" \
  --scope "/subscriptions/<sub>/resourceGroups/MyRG" \
  --policy "404c3081-a854-4457-ae30-26a93ef643f9"
```

#### Compliance

- Policy compliance shows % compliant resources per assignment
- Non-compliant resources listed with reasons
- **Remediation tasks**: For DeployIfNotExists/Modify policies — fix existing non-compliant resources
- Compliance data exported to Log Analytics for trend analysis

### Azure Blueprints

> *Note: Azure Blueprints is being deprecated in favor of Azure Deployment Environments and Template Specs, but may still appear on the AZ-500 exam.*

Blueprints package together:
- Role assignments
- Policy assignments
- ARM templates
- Resource groups

Key features:
- **Locked assignments**: Prevent modification of blueprint-deployed resources (DoNotDelete or ReadOnly)
- Blueprints create **deny assignments** to enforce locks (explains why deny assignments exist)

---

## 5. Incident Response in Azure

### Incident Response Lifecycle

```
1. PREPARATION  →  2. DETECTION  →  3. CONTAINMENT  →  4. ERADICATION  →  5. RECOVERY  →  6. LESSONS LEARNED
```

### Detection Tools

| Signal | Tool |
|--------|------|
| Identity threats | Entra ID Identity Protection, Sentinel |
| VM/server threats | Defender for Servers, Sentinel |
| Network threats | Azure Firewall logs, NSG Flow Logs, Sentinel |
| Application threats | WAF logs, Application Insights |
| Storage/DB threats | Defender for Storage, Defender for SQL |
| Overall posture | Defender for Cloud |

### Containment Actions in Azure

| Threat | Containment Action |
|--------|-------------------|
| Compromised user account | Disable user, revoke sessions, reset password, confirm compromised in Identity Protection |
| Compromised VM | Isolate (move to quarantine NSG), snapshot disk for forensics, trigger JIT lockdown |
| Data exfiltration | Revoke SAS tokens, rotate storage keys, block IP in NSG/Firewall |
| Malware on VM | Isolate VM, enable Defender for Endpoint, quarantine using Defender |
| Suspicious app | Disable app registration, revoke service principal credentials |

```bash
# Revoke all sign-in sessions for a user (containment action)
az ad user revoke-sign-in-sessions --id alice@contoso.com

# Disable a user account
az ad user update --id alice@contoso.com --account-enabled false

# Rotate storage account keys
az storage account keys renew \
  --account-name mystorageacct \
  --resource-group MyRG \
  --key primary
```

### Sentinel Incident Investigation

Investigation workflow:
1. **Triage**: Review incident title, severity, entities, evidence
2. **Investigate**: Use Investigation Graph (entity relationships), timeline
3. **Hunt**: Run hunting queries for related activity
4. **Contain**: Use playbooks to block IPs, disable users, isolate VMs
5. **Close**: Document findings, close incident with classification (True Positive, False Positive, Benign Positive)

### Microsoft Sentinel MITRE ATT&CK Coverage

Use the **MITRE ATT&CK** matrix in Sentinel to:
- See which tactics/techniques are covered by your active analytics rules
- Identify gaps in detection coverage
- Plan improvements to detection rules

---

## 6. Key Exam Facts & Practice Questions

### Must-Know Facts

1. **Microsoft Sentinel** is Azure's SIEM + SOAR solution; uses Log Analytics workspace as its data store
2. **Analytics rules** in Sentinel create **incidents** (not just alerts) — incidents group related alerts
3. **Playbooks** = Azure Logic Apps triggered by Sentinel incidents/alerts
4. **Automation rules** are simpler than playbooks — no code, just incident management actions (assign, tag, suppress, trigger playbook)
5. **KQL** is the query language for Sentinel hunting and analytics; know basic operators: `where`, `summarize`, `project`, `join`, `extend`
6. **Azure Activity Log** retains data for **90 days** by default; export to Log Analytics for longer retention
7. **Diagnostic Settings** route resource logs/metrics to Log Analytics, Storage, or Event Hub
8. **Azure Policy `DeployIfNotExists`** requires a managed identity on the assignment for remediation
9. **Sentinel UEBA** requires Entra ID sign-in logs and audit logs enabled; establishes behavioral baselines
10. **Threat Intelligence** in Sentinel: IOC (Indicator of Compromise) feeds matched against logs

### Practice Questions

**Q1.** Your SOC team needs to automatically create a ServiceNow ticket whenever Microsoft Sentinel creates a High severity incident. Which Sentinel feature should you configure?

- A) An Analytics rule with a scheduled query
- B) A Playbook (Logic App) triggered by the incident creation trigger
- C) A Workbook with automated export
- D) A Hunting query with bookmark automation

<details><summary>Answer</summary>
**B** — Playbooks are Azure Logic Apps that can be triggered by Sentinel incident creation events. The Logic App can then call the ServiceNow API to create a ticket. Analytics rules (A) create incidents but don't take response actions. Workbooks (C) are dashboards. Hunting queries (D) are for proactive threat detection.
</details>

---

**Q2.** You need to ensure that all Azure resources in your subscription use HTTPS for data in transit. Some non-compliant resources already exist. You want to auto-remediate non-compliant resources without blocking future deployments. Which Azure Policy effect should you use?

- A) `Deny`
- B) `Audit`
- C) `DeployIfNotExists`
- D) `Modify`

<details><summary>Answer</summary>
**D** — `Modify` can add or change resource properties (like enabling HTTPS-only on existing storage accounts) and applies to new and existing resources. `DeployIfNotExists` deploys related companion resources. `Deny` (A) would block non-compliant new resources but not remediate existing ones. `Audit` (B) logs but doesn't remediate.
</details>

---

**Q3.** A security analyst is investigating a suspicious sign-in alert in Microsoft Sentinel. They want to see all other activities performed by the same user and IP address over the past 7 days in a visual timeline. Which Sentinel feature should they use?

- A) Hunting queries with bookmarks
- B) UEBA entity page for the user
- C) Investigation Graph opened from the incident
- D) Workbooks with pre-built sign-in dashboards

<details><summary>Answer</summary>
**C** — The Investigation Graph provides a visual, interactive timeline showing the incident entities (user, IP, host) and their relationships to other alerts and activities over time. UEBA entity pages (B) show behavioral analytics but not the interactive investigation graph. Hunting (A) is for proactive search, not incident investigation.
</details>

---

**Q4.** You need to monitor all Azure Key Vault operations in your subscription and alert when any key vault is deleted. Key Vault deletion is an Azure Resource Manager operation. Which log source and alert type should you configure?

- A) Key Vault diagnostic logs + Log Search Alert
- B) Azure Activity Log + Activity Log Alert
- C) Azure Monitor Metrics + Metric Alert
- D) Defender for Key Vault + Security Alert

<details><summary>Answer</summary>
**B** — Key Vault deletion is a control plane operation logged in the **Azure Activity Log** (ARM operation: `Microsoft.KeyVault/vaults/delete`). An **Activity Log Alert** can trigger immediately when this operation occurs. Key Vault diagnostic logs (A) record data plane operations (secret access, etc.), not vault deletion.
</details>

---

**Q5.** Microsoft Sentinel is ingesting 50 GB of logs per day. Your organization wants to reduce costs while keeping all security-relevant logs for 12 months. What is the most cost-effective approach?

- A) Set the Log Analytics workspace retention to 12 months (pay for 12 months of hot storage)
- B) Use Sentinel's built-in archive tier: keep 3 months in interactive retention, archive remaining 9 months at lower cost
- C) Delete all logs after 90 days to use only the default retention
- D) Export all logs to Azure Storage every day and delete from Log Analytics after 30 days

<details><summary>Answer</summary>
**B** — Log Analytics workspaces support an **archive tier** (Basic logs and auxiliary logs) at significantly lower cost per GB for data that is still retained but queried infrequently. Set interactive retention to 90 days (or desired period) and archive to 12 months total. Option A is expensive. Option C (delete) means you can't query historical data. Option D is operationally complex and loses the ability to query in Sentinel.
</details>

---

← [Back to README](../README.md) | [← Domain 3](./03-compute-storage-databases.md)
