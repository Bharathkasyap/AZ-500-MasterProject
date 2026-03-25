# Domain 4: Manage Security Operations (25–30%)

← [Back to main README](../../README.md)

This domain covers **Microsoft Sentinel, Defender for Cloud monitoring, security alerts, incident response, and compliance management**. It accounts for **25–30%** of the AZ-500 exam.

---

## Table of Contents

1. [Microsoft Sentinel — Overview](#1-microsoft-sentinel--overview)
2. [Microsoft Sentinel — Data Connectors](#2-microsoft-sentinel--data-connectors)
3. [Microsoft Sentinel — Analytics Rules](#3-microsoft-sentinel--analytics-rules)
4. [Microsoft Sentinel — Incidents and Investigation](#4-microsoft-sentinel--incidents-and-investigation)
5. [Microsoft Sentinel — Playbooks and SOAR](#5-microsoft-sentinel--playbooks-and-soar)
6. [Microsoft Sentinel — Workbooks and Dashboards](#6-microsoft-sentinel--workbooks-and-dashboards)
7. [Azure Monitor and Log Analytics](#7-azure-monitor-and-log-analytics)
8. [Diagnostic Settings and Audit Logs](#8-diagnostic-settings-and-audit-logs)
9. [Microsoft Defender for Cloud — Alerts and Recommendations](#9-microsoft-defender-for-cloud--alerts-and-recommendations)
10. [Security Baselines and Benchmarks](#10-security-baselines-and-benchmarks)
11. [Azure Policy](#11-azure-policy)
12. [Key Exam Tips for Domain 4](#key-exam-tips-for-domain-4)

---

## 1. Microsoft Sentinel — Overview

### What Microsoft Sentinel Is

Microsoft Sentinel is a **cloud-native SIEM (Security Information and Event Management) and SOAR (Security Orchestration, Automation, and Response)** platform built on Azure.

### SIEM vs SOAR

| Capability | Description |
|---|---|
| **SIEM** | Collects, correlates, and analyzes security data from many sources; detects threats |
| **SOAR** | Automates security response workflows; orchestrates tools; reduces manual effort |

### Sentinel Architecture

```
Data Sources (connectors)
    ↓
Log Analytics Workspace (Sentinel data store)
    ↓
Analytics Rules (threat detection)
    ↓
Incidents (grouped alerts)
    ↓
Investigation (entity mapping, timeline, threat hunting)
    ↓
Playbooks / Automation (SOAR response)
```

### Sentinel Prerequisites

1. **Log Analytics Workspace** — Sentinel workspace is built on top of a Log Analytics workspace
2. **Sentinel contributor** or higher role — To configure and manage Sentinel
3. **Data connector permissions** — Reader/Contributor on the data sources

### Pricing

- Based on **data ingestion volume** (GB/day)
- **Commitment tiers**: Pre-commit to daily GB volume for lower per-GB rates
- **Pay-as-you-go**: No commitment; higher per-GB rate
- **Microsoft 365 Defender data**: Ingested free (within included M365 Defender data)
- **Azure Activity logs**: First 5 GB/month free per workspace

---

## 2. Microsoft Sentinel — Data Connectors

### Connector Categories

| Category | Examples |
|---|---|
| **Microsoft services** | Azure Active Directory, Microsoft 365 Defender, Defender for Cloud, Azure Activity, Office 365 |
| **Microsoft partner** | Palo Alto, Fortinet, Check Point, Cisco, Symantec |
| **Community (GitHub)** | Open source connectors maintained by community |
| **Custom (API)** | Syslog, CEF (Common Event Format), REST API via Azure Monitor Agent |

### Key Connector Details

| Connector | What It Ingests |
|---|---|
| **Azure Active Directory** | Sign-in logs, audit logs, risky sign-ins, provisioning logs |
| **Azure Activity** | Azure control plane operations (ARM API calls) |
| **Microsoft 365 Defender** | Alerts from Defender for Endpoint, Defender for Office 365, etc. |
| **Defender for Cloud** | Security alerts from Defender plans |
| **Office 365** | Exchange, SharePoint, Teams activity logs |
| **Microsoft Entra ID Protection** | Risky users and sign-in risk detections |
| **Syslog** | Linux syslogs via AMA (Azure Monitor Agent) |
| **CEF** | Structured logs from security appliances via AMA |

### Common Log Tables in Sentinel

| Table | Data |
|---|---|
| `SigninLogs` | Azure AD sign-in logs |
| `AuditLogs` | Azure AD audit events |
| `AzureActivity` | Azure control plane events |
| `SecurityAlert` | Alerts from connected security products |
| `SecurityIncident` | Sentinel incidents |
| `OfficeActivity` | Microsoft 365 activity |
| `CommonSecurityLog` | CEF-formatted logs from network devices |
| `Syslog` | Linux syslog events |
| `SecurityEvent` | Windows Security Event Log |

---

## 3. Microsoft Sentinel — Analytics Rules

### What Analytics Rules Do
Analytics rules query logs in the workspace on a **schedule** and generate **alerts** (and optionally **incidents**) when conditions are met.

### Analytics Rule Types

| Type | Description | Best For |
|---|---|---|
| **Scheduled** | KQL query runs on a schedule; most flexible | Custom threat detection |
| **NRT (Near Real-Time)** | Runs every minute; low-latency detection | High-priority, time-sensitive threats |
| **Microsoft Security** | Auto-import alerts from Microsoft security products into Sentinel incidents | Quick setup for Microsoft products |
| **Anomaly** | ML-based behavioral baselines; detects deviations | Behavioral anomaly detection |
| **Fusion** | Multi-signal correlation using ML; reduces false positives | Advanced multi-stage attack detection |
| **Threat Intelligence** | Match IOCs from TI feeds against ingested logs | Known threat actor detection |

### Scheduled Rule Components

| Component | Description |
|---|---|
| **KQL Query** | The detection logic (what to look for) |
| **Run frequency** | How often the query runs (e.g., every 5 minutes) |
| **Lookup period** | How far back the query looks (e.g., last 5 hours) |
| **Alert threshold** | Number of results needed to trigger an alert |
| **Entity mapping** | Map query fields to entities (user, IP, host, URL, file hash) |
| **Incident creation** | Group alerts into incidents; configure grouping |
| **MITRE ATT&CK mapping** | Tag the rule with tactics and techniques |

### KQL Basics for AZ-500

```kusto
// Count failed sign-ins per user in last 1 hour
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != "0"
| summarize FailedAttempts = count() by UserPrincipalName
| where FailedAttempts > 5

// Detect sign-ins from multiple countries for same user
SigninLogs
| where TimeGenerated > ago(1d)
| summarize Countries = dcount(Location) by UserPrincipalName
| where Countries > 3

// Detect Azure resource deletion events
AzureActivity
| where OperationNameValue endswith "delete"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, ResourceGroup, Resource, OperationNameValue
```

---

## 4. Microsoft Sentinel — Incidents and Investigation

### Incident Lifecycle

```
Alert generated (by Analytics Rule)
    ↓
Incident created (grouping of related alerts)
    ↓
Incident assigned (to analyst)
    ↓
Investigation (entity exploration, timeline, threat hunting)
    ↓
Incident closed (with classification)
```

### Incident Properties

| Property | Options |
|---|---|
| **Severity** | Informational, Low, Medium, High |
| **Status** | New, Active, Closed |
| **Classification** | True Positive, False Positive, Benign Positive, Undetermined |
| **Owner** | Assigned analyst or team |
| **Tactics** | MITRE ATT&CK tactics associated with the incident |

### Investigation Graph

Visual representation of an incident:
- Shows entities (users, IPs, hosts, URLs) involved
- Shows relationships between entities
- Allows drilling into entity details and related events
- Supports adding bookmarks to notable events

### Threat Hunting

- **Hunting queries**: Pre-built KQL queries for proactive threat hunting
- **Livestream**: Real-time query monitoring
- **Bookmarks**: Mark suspicious events for later investigation; convert to incidents
- **Notebooks**: Jupyter notebooks for advanced analytics

### MITRE ATT&CK Coverage

- Sentinel maps alerts and incidents to MITRE ATT&CK tactics and techniques
- Coverage dashboard shows which tactics have detection coverage
- Helps identify gaps in detection

---

## 5. Microsoft Sentinel — Playbooks and SOAR

### What Playbooks Are

Playbooks are **Logic Apps** workflows triggered by Sentinel alerts or incidents. They automate security response actions.

### Trigger Types

| Trigger | When Used |
|---|---|
| **Alert trigger** | Triggered when a new Sentinel alert is created |
| **Incident trigger** | Triggered when a new Sentinel incident is created or updated |
| **Entity trigger** | Triggered when investigating a specific entity |

### Common Playbook Actions

| Category | Examples |
|---|---|
| **Containment** | Disable user account, block IP in NSG/firewall, isolate VM, revoke sessions |
| **Investigation** | Get user details from Azure AD, get device info from MDE, enrich with threat intel |
| **Notification** | Send Teams/email alert, create ServiceNow ticket, post to Slack |
| **Remediation** | Force MFA registration, reset password, update incident status |

### Example Playbook Flow

```
Trigger: Sentinel Incident (High severity, "Impossible Travel Detected")
    ↓
Action 1: Get user details from Azure AD
    ↓
Action 2: Check if user is a service account (if yes → close incident, add comment)
    ↓
Action 3: Disable user account in Azure AD
    ↓
Action 4: Revoke all active sessions (Azure AD - Revoke sign-in sessions)
    ↓
Action 5: Send Teams notification to SOC team with incident details
    ↓
Action 6: Add comment to Sentinel incident: "Account disabled; sessions revoked"
```

### Automation Rules

Automation rules apply actions to incidents **without needing a playbook** for simple logic:
- Assign incidents to specific owners
- Change incident severity
- Add tags
- Run a playbook
- Close incidents matching certain conditions

Automation rules are evaluated **before** playbooks.

---

## 6. Microsoft Sentinel — Workbooks and Dashboards

### Sentinel Workbooks

Built on **Azure Monitor Workbooks** — interactive dashboards with KQL-powered visualizations.

### Built-in Workbooks Examples

| Workbook | Purpose |
|---|---|
| Azure AD Sign-in logs | Visualize sign-in patterns, failures, MFA usage |
| Azure Activity | Azure control plane activity over time |
| Microsoft Defender for Cloud | Security alerts and recommendations |
| Identity & Access | Privileged access, risky users, PIM activations |
| Azure Network Watcher | Network traffic analytics |

### Custom Workbooks

Create custom workbooks with:
- Time range selectors
- Multiple visualization types (tables, charts, maps, tiles)
- Parameters for filtering by resource, user, time
- Drill-through navigation

---

## 7. Azure Monitor and Log Analytics

### Azure Monitor Components

```
Azure Monitor
├── Metrics (numerical, near real-time, 93-day retention default)
├── Logs (Azure Monitor Logs / Log Analytics)
│   └── Log Analytics Workspace
│       ├── Diagnostic settings → resource logs
│       ├── Agents → VM logs
│       └── Data connectors → Sentinel
├── Alerts
│   ├── Metric alerts
│   ├── Log alerts (KQL-based)
│   ├── Activity log alerts
│   └── Smart detection (Application Insights)
└── Action Groups (define what happens when alert fires)
```

### Log Analytics Workspace

- Central repository for log data
- Uses **KQL (Kusto Query Language)** for querying
- Data retention: 30 days default (free); configurable up to 730 days
- Interactive analytics workspace + Sentinel workspace are both Log Analytics workspaces

### KQL Common Operators

| Operator | Purpose | Example |
|---|---|---|
| `where` | Filter rows | `where Level == "Error"` |
| `project` | Select columns | `project TimeGenerated, Message` |
| `summarize` | Aggregate | `summarize count() by Category` |
| `extend` | Add calculated column | `extend Age = datetime_diff("day", now(), BirthDate)` |
| `join` | Join tables | `T1 \| join T2 on key` |
| `union` | Combine tables | `union T1, T2` |
| `render` | Visualize | `render timechart` |
| `ago()` | Relative time | `where TimeGenerated > ago(7d)` |

### Alerts and Action Groups

**Alert types:**
- **Metric alerts**: Fired when a metric crosses a threshold
- **Log alerts**: Fired when a KQL query returns results
- **Activity log alerts**: Fired on Azure control plane events

**Action groups** define responses:
- Email/SMS notification
- Azure Function trigger
- Logic App (playbook) trigger
- Webhook
- IT Service Management (ITSM) ticket creation
- Voice call

---

## 8. Diagnostic Settings and Audit Logs

### Diagnostic Settings

Every Azure resource can send **diagnostic logs and metrics** to one or more destinations:

| Destination | Use Case |
|---|---|
| **Log Analytics Workspace** | Query with KQL, Sentinel integration |
| **Azure Storage Account** | Long-term archival, compliance |
| **Azure Event Hub** | Stream to SIEM, third-party tools |
| **Partner solutions** | Datadog, Elastic, etc. |

### Azure Activity Log

Records all **management plane (control plane) operations**:
- Creating/deleting/updating resources
- Assigning RBAC roles
- Azure Policy compliance changes
- Azure Service Health events
- 90-day default retention in Azure Monitor (send to Log Analytics for longer retention)

### Azure AD Audit and Sign-in Logs

| Log Type | Contents | Retention |
|---|---|---|
| **Sign-in logs** | Each sign-in attempt; success/failure, location, MFA result | 30 days (P1/P2) / 7 days (Free) |
| **Audit logs** | Changes to Azure AD objects (users, groups, apps, policies) | 30 days |
| **Provisioning logs** | App provisioning/sync events | 30 days |
| **Risky sign-ins** | Identity Protection risk detections | 30 days |

> **Exam Tip**: To retain Azure AD logs longer than 30 days, configure **Diagnostic settings** on the Azure AD tenant and send to Log Analytics or Storage.

---

## 9. Microsoft Defender for Cloud — Alerts and Recommendations

### Alert Severity Levels

| Severity | Description |
|---|---|
| High | Potential breach; immediate action required |
| Medium | Suspicious activity; investigate promptly |
| Low | Informational; monitor |
| Informational | No direct threat; context or informational only |

### Alert Suppression Rules

Create suppression rules to reduce noise for known-good events:
- Suppress by alert name, IP, user, resource
- Set expiration on suppression rules
- Never suppress high-severity alerts without investigation

### Secure Score Recommendations

Recommendations are grouped into **security controls**:

| Control | Examples |
|---|---|
| Protect accounts with MFA | Enable MFA for all subscription owners |
| Apply system updates | Install missing OS patches on VMs |
| Remediate security configurations | Enable disk encryption, enable diagnostic logs |
| Enable endpoint protection | Install antimalware solution |
| Enable encryption at rest | Encrypt VMs, storage accounts |
| Restrict unauthorized network access | Configure NSG rules, disable public IP |

### Workflow Automation

Defender for Cloud supports workflow automation triggered by:
- Security alerts
- Recommendation changes
- Regulatory compliance changes

Actions:
- Send email notification
- Trigger Logic App / playbook
- Create ITSM ticket

---

## 10. Security Baselines and Benchmarks

### Microsoft Cloud Security Benchmark (MCSB)

Formerly **Azure Security Benchmark (ASB)** — a set of security controls mapped to:
- NIST SP 800-53
- CIS Controls
- PCI DSS
- ISO 27001

### Key MCSB Control Domains

| Domain | Example Controls |
|---|---|
| Identity Management | Use Azure AD for authentication, enforce MFA, eliminate legacy auth |
| Privileged Access | Use PIM, minimize permanent admin assignments |
| Network Security | Use private endpoints, NSGs, Azure Firewall |
| Data Protection | Encrypt data at rest and in transit, use Key Vault |
| Asset Management | Tag resources, enable Defender for Cloud |
| Logging and Threat Detection | Enable diagnostic logging, deploy Sentinel |
| Incident Response | Define incident response plans, enable automation |

### CIS Benchmarks

- **Center for Internet Security** benchmarks for Azure
- Available in Defender for Cloud regulatory compliance dashboard
- Maps to specific Azure configuration checks
- CIS Level 1 = minimum security; CIS Level 2 = more restrictive

### NIST SP 800-53

- US government security framework
- Used in FedRAMP compliance for Azure government cloud
- Available in Defender for Cloud regulatory compliance dashboard

---

## 11. Azure Policy

### What Azure Policy Does

Evaluates Azure resources against **business rules** expressed as JSON policy definitions. Can:
- **Audit**: Report non-compliant resources without making changes
- **Deny**: Block resource creation/modification that violates policy
- **DeployIfNotExists**: Automatically deploy a configuration if it doesn't exist
- **Modify**: Add/update tags or properties on resources
- **Append**: Add additional fields to resources during creation/update

### Policy Evaluation

- Policies evaluated when resources are created/updated
- Retroactive compliance scan evaluates existing resources
- Non-compliant resources reported; some effects auto-remediate

### Policy Definitions vs Initiatives

| Concept | Description |
|---|---|
| **Policy Definition** | A single rule (e.g., "Require tags on resources") |
| **Initiative (Policy Set)** | A group of related policy definitions (e.g., "Azure Security Benchmark") |

### Built-in Security Initiatives

- **Azure Security Benchmark**: Mapped to MCSB; broad security coverage
- **Enable Azure Defender**: Policies to enable Defender plans on subscriptions
- **NIST SP 800-53 Rev 5**: US government compliance
- **PCI DSS 3.2.1**: Payment card industry compliance
- **ISO 27001**: Information security standard

### Policy Effects Precedence

```
Disabled → Append → Modify → Deny → Audit → AuditIfNotExists → DeployIfNotExists
```

`Deny` blocks the operation. `DeployIfNotExists` and `AuditIfNotExists` only trigger if the related resource/property doesn't exist.

### Azure Policy vs Azure RBAC

| | Azure Policy | Azure RBAC |
|---|---|---|
| **Controls** | What resources can look like (configuration) | Who can do what (actions) |
| **Deny by default?** | No — allow by default; explicitly deny configurations | Yes — deny by default; explicitly grant access |
| **Scope** | Management group, subscription, resource group, resource | Management group, subscription, resource group, resource |

> **Exam Tip**: Azure Policy and RBAC work together and are complementary. RBAC controls permissions; Policy controls resource configuration.

---

## Key Exam Tips for Domain 4

1. **Sentinel = SIEM + SOAR**: Sentinel collects and detects (SIEM); playbooks automate response (SOAR). Logic Apps power the playbooks.
2. **Analytics rule types**: Know when to use each type. NRT for time-sensitive; Scheduled for custom; Fusion for multi-signal ML correlation.
3. **KQL basics**: Be able to read a KQL query and understand what it detects. `where`, `summarize`, `project`, and `ago()` are critical.
4. **Incident vs Alert**: Alerts are raw detections; Incidents group related alerts and are what analysts work on.
5. **Log Analytics retention**: Default 30 days (interactive); extend for longer retention. Send Azure AD logs to Log Analytics to retain beyond 30 days.
6. **Diagnostic settings destinations**: Log Analytics (query), Storage (archive), Event Hub (stream to external SIEM).
7. **Playbook triggers**: Alert trigger vs Incident trigger — they receive different context objects. Incident trigger is more commonly used.
8. **Azure Policy effects**: Deny blocks operations; DeployIfNotExists auto-deploys configurations; Audit reports without changing.
9. **Defender for Cloud Secure Score**: Completing recommendations increases score. Higher score = better posture.
10. **Automation rules vs Playbooks**: Automation rules are simple if-then logic; playbooks are full Logic Apps with many connector options.
