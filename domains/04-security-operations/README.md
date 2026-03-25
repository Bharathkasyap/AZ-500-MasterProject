# Domain 4 — Manage Security Operations

> **Weight: 25–30% of the AZ-500 Exam**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Microsoft Defender for Cloud](#microsoft-defender-for-cloud)
- [Secure Score & Recommendations](#secure-score--recommendations)
- [Azure Policy & Regulatory Compliance](#azure-policy--regulatory-compliance)
- [Microsoft Sentinel](#microsoft-sentinel)
- [Log Analytics Workspace](#log-analytics-workspace)
- [Azure Monitor](#azure-monitor)
- [Incident Response](#incident-response)
- [Key Exam Points](#key-exam-points)

---

## Overview

Domain 4 covers monitoring, detecting, and responding to security threats across Azure. Key tools are Microsoft Defender for Cloud (CSPM + workload protection) and Microsoft Sentinel (SIEM/SOAR).

**Key Theme:** *Visibility + Detection + Response = Defense in Depth for Operations*

---

## Microsoft Defender for Cloud

Microsoft Defender for Cloud is a **Cloud Security Posture Management (CSPM)** and **Cloud Workload Protection Platform (CWPP)** solution.

### Two Core Pillars
| Pillar | Description | Plan |
|--------|-------------|------|
| **CSPM (Posture Management)** | Identify misconfigurations; Secure Score; compliance | Foundational CSPM (Free) or Defender CSPM (Paid) |
| **CWPP (Workload Protection)** | Runtime threat detection for specific workloads | Defender plans (per workload) |

### CSPM Tiers
| Tier | Features |
|------|---------|
| **Foundational CSPM** (Free) | Secure Score, recommendations, Azure Security Benchmark |
| **Defender CSPM** (Paid) | + Attack path analysis, cloud security graph, agentless scanning, governance |

### Onboarding Scope
- **Azure subscriptions**: Natively supported
- **AWS accounts**: Via Defender CSPM connector
- **GCP projects**: Via Defender CSPM connector
- **On-premises**: Via Azure Arc-enabled servers
- **GitHub/Azure DevOps**: Via Defender for DevOps

### Key Features
| Feature | Description |
|---------|-------------|
| **Secure Score** | Percentage score based on security posture; 0–100% |
| **Recommendations** | Actionable guidance to improve security |
| **Security alerts** | Threat detection alerts per resource |
| **Compliance dashboard** | Map to regulatory frameworks (CIS, PCI-DSS, NIST, SOC 2) |
| **Workbooks** | Visual security reports |
| **Inventory** | All resources across connected environments |
| **Attack path analysis** | Visualize potential attack paths (Defender CSPM) |

---

## Secure Score & Recommendations

### Secure Score
- Measures overall security posture across all recommendations
- **Range**: 0% (worst) to 100% (best)
- Each security control has a max points value
- Unhealthy resources reduce points

### Recommendation Types
| Type | Description |
|------|-------------|
| **Built-in** | Aligned to Azure Security Benchmark / Microsoft Cloud Security Benchmark |
| **Custom** | Based on custom Azure Policy definitions |

### Recommendation Status
| Status | Description |
|--------|-------------|
| **Unhealthy** | Resource does not comply with recommendation |
| **Healthy** | Resource complies |
| **Not applicable** | Exempted or not relevant |
| **Exempt** | Admin has acknowledged risk and exempted |

### Governance Rules
- Assign ownership of recommendations to specific users/teams
- Set due dates for remediation
- Track compliance in governance report

### Exemptions
- Mark a resource as exempt from a recommendation
- Types: **Waiver** (accept risk), **Mitigated** (compensating control exists)
- Exemptions have an expiry date (max 365 days)

---

## Azure Policy & Regulatory Compliance

### Azure Policy
- Enforce organizational governance rules on Azure resources
- **Policy definition**: Rule with condition and effect
- **Initiative**: Group of policy definitions (also called policy set)
- **Assignment**: Apply policy/initiative to a scope (management group, subscription, RG, resource)

### Policy Effects (in evaluation order)
| Effect | Description |
|--------|-------------|
| **Disabled** | Policy disabled; no enforcement |
| **Audit** | Log non-compliant resources; do NOT block |
| **AuditIfNotExists** | Audit if a related resource doesn't exist |
| **Deny** | Block non-compliant resource creation/modification |
| **DeployIfNotExists** | Auto-deploy a related resource if not present |
| **Modify** | Add/update/remove tags or properties |
| **Append** | Add field values (e.g., add a tag) |

> **Exam tip:** `DeployIfNotExists` and `Modify` require a **managed identity** for the policy assignment to make changes.

### Regulatory Compliance in Defender for Cloud
| Framework | Description |
|-----------|-------------|
| **Microsoft Cloud Security Benchmark (MCSB)** | Default baseline in Defender for Cloud |
| **CIS Microsoft Azure Foundations Benchmark** | Center for Internet Security |
| **PCI DSS** | Payment Card Industry Data Security Standard |
| **NIST SP 800-53** | US federal government standard |
| **SOC 2 Type 2** | Service organization controls |
| **ISO 27001** | International information security management |
| **HIPAA/HITRUST** | US healthcare |

### Management Groups
```
Root Management Group
    ├── Platform MG
    │   ├── Identity Subscription
    │   ├── Management Subscription
    │   └── Connectivity Subscription
    └── Landing Zones MG
        ├── Corp Subscription 1
        ├── Corp Subscription 2
        └── Online Subscription 1
```
- Policies at parent MG are **inherited** by all child subscriptions
- RBAC at parent MG is **inherited** by all child subscriptions
- Up to 6 levels of management group hierarchy

---

## Microsoft Sentinel

Microsoft Sentinel is a **cloud-native SIEM** (Security Information and Event Management) and **SOAR** (Security Orchestration, Automation, and Response) solution.

### Architecture
```
Data Sources → Data Connectors → Log Analytics Workspace
                                        ↓
                              Analytics Rules (detect threats)
                                        ↓
                              Incidents (aggregated alerts)
                                        ↓
                         Playbooks (SOAR - automated response)
                                        ↓
                              Investigation/Hunting
```

### Data Connectors
| Category | Examples |
|----------|---------|
| **Microsoft services** | Microsoft Entra ID, Defender for Cloud, Microsoft 365, Defender for Endpoint |
| **Azure services** | Azure Activity, Azure Firewall, Azure WAF, NSG Flow Logs |
| **Partner connectors** | Palo Alto, Fortinet, Cisco, Check Point |
| **Custom** | Syslog, CEF (Common Event Format), REST API, Azure Functions |

### Data Connector Methods
| Method | Description |
|--------|-------------|
| **Direct connectors** | Native Microsoft connectors (single-click setup) |
| **Syslog** | Linux-based sources via OMS agent |
| **CEF** | Firewall/security devices via Syslog agent |
| **Logstash** | Custom pipeline using Logstash plugin |
| **REST API** | Pull data using custom Function App |

### Analytics Rules (Detection)
| Rule Type | Description |
|-----------|-------------|
| **Scheduled** | Run KQL query on schedule; create alert if results found |
| **Near Real-time (NRT)** | Run every 1 minute; low-latency detection |
| **Microsoft Security** | Auto-create incidents from other Defender products |
| **Machine Learning** | Built-in ML models for anomaly detection |
| **Fusion** | Multi-stage attack detection using ML correlation |
| **Threat intelligence** | Match logs against Threat Intelligence indicators |
| **Anomaly** | ML-based behavioral anomaly detection (UEBA) |

### Analytics Rule Components
- **Query**: KQL query against workspace tables
- **Schedule**: How often to run (5 minutes to 14 days)
- **Lookback period**: How far back to query (5 minutes to 14 days)
- **Alert threshold**: Create alert when results count > X
- **Event grouping**: Group results into single alert or separate alerts
- **Incident creation**: Create incident from each alert or group alerts
- **Entity mapping**: Extract entities (user, IP, host, URL) from query results
- **Alert enrichment**: Tactics, techniques, severity, custom details

### Incidents
- An incident is a **group of related alerts** (correlated by Sentinel)
- Incident properties: Severity, status, owner, tactics, entities
- Status: New → Active → Closed
- Close reasons: True Positive, False Positive, Benign Positive, Undetermined

### Entities
| Entity Type | Examples |
|-------------|---------|
| **Account** | User accounts, service accounts |
| **Host** | Server name, IP |
| **IP** | Public/private IP addresses |
| **URL** | Web URLs |
| **File hash** | MD5/SHA256 of malware files |
| **Malware** | Known malware families |
| **DNS** | DNS queries |
| **Azure resource** | Subscription, resource group, resource |

### Threat Hunting
- Manual or automated search for threats not detected by analytics rules
- **Hunting queries**: KQL queries for proactive threat search
- **Livestream**: Real-time query as events arrive
- **Bookmarks**: Save interesting events during hunting for investigation
- **MITRE ATT&CK mapping**: Map hunting queries to ATT&CK techniques

### Workbooks
- Interactive dashboards for security data visualization
- Built-in templates for common scenarios (Azure AD, Defender, Firewall, etc.)
- Custom workbooks using KQL + visualizations
- Shared across workspace

---

## Playbooks (SOAR Automation)

### What are Playbooks?
- Automated response workflows triggered by Sentinel alerts/incidents
- Built on **Azure Logic Apps**
- Can send notifications, create tickets, block users/IPs, enrich incidents

### Trigger Types
| Trigger | When to Use |
|---------|------------|
| **Incident trigger** | Actions on the whole incident (recommended) |
| **Alert trigger** | Actions on a specific alert |
| **Entity trigger** | Actions on a specific entity (user, IP, host) |

### Common Playbook Actions
| Action | Example |
|--------|---------|
| **Notification** | Send Teams/email alert on new incident |
| **Enrichment** | Query threat intel for IP; add comment to incident |
| **Containment** | Disable user in Entra ID; block IP in firewall |
| **Ticketing** | Create ServiceNow/JIRA ticket |
| **Investigation** | Auto-run entity investigation; query related events |

### Automation Rules
- Lightweight automation WITHOUT Logic Apps
- Trigger: Incident created or updated
- Actions: Assign owner, change severity/status, add tags, run playbook, suppress similar incidents
- Use for: Initial triage, routing, deduplication

---

## Log Analytics Workspace

### Architecture
- Central repository for all log data
- Receives data from: Azure resources, VMs (agents), Sentinel, Defender for Cloud
- Data organized in **tables** (one per data type)
- Retention: Default 30 days interactive; configurable 1–730 days; archival up to 12 years

### Key Tables for Security
| Table | Data |
|-------|------|
| `SecurityAlert` | Security alerts from Defender products |
| `SecurityIncident` | Sentinel incidents |
| `SecurityEvent` | Windows Security event log (VMs) |
| `Syslog` | Linux syslog events (VMs) |
| `AzureActivity` | Azure subscription-level operations |
| `SignInLogs` | Entra ID sign-in events |
| `AuditLogs` | Entra ID audit events |
| `AzureDiagnostics` | Azure resource diagnostic logs |
| `CommonSecurityLog` | CEF format logs (firewalls, etc.) |
| `OfficeActivity` | Microsoft 365 activity |
| `NetworkSecurityGroupFlowEvent` | NSG flow logs |

### KQL (Kusto Query Language) Essentials

```kusto
// Basic query structure
TableName
| where TimeGenerated > ago(24h)
| where column == "value"
| project column1, column2, column3
| order by TimeGenerated desc
| take 100

// Count by
SecurityAlert
| where TimeGenerated > ago(7d)
| summarize count() by AlertSeverity
| order by count_ desc

// Join tables
SignInLogs
| where ResultType != 0  // failed sign-ins
| join kind=leftouter (
    AuditLogs
    | where OperationName == "Disable account"
) on $left.UserId == $right.InitiatedBy
| project TimeGenerated, UserPrincipalName, ResultDescription

// Detect brute force
SecurityEvent
| where EventID == 4625  // Failed logon
| where TimeGenerated > ago(1h)
| summarize FailedAttempts = count() by IpAddress, TargetAccount
| where FailedAttempts > 10
| order by FailedAttempts desc

// Geo-location (uses built-in function)
SignInLogs
| where ResultType == 0
| extend city = tostring(LocationDetails.city)
| extend countryOrRegion = tostring(LocationDetails.countryOrRegion)
| summarize SignIns = count() by countryOrRegion
| order by SignIns desc
```

---

## Azure Monitor

### Components
| Component | Description |
|-----------|-------------|
| **Metrics** | Numerical time-series data (CPU %, requests/sec) |
| **Logs** | Semi-structured data in Log Analytics |
| **Alerts** | Rules that trigger on metric/log conditions |
| **Action Groups** | Define response actions for alerts |
| **Diagnostic Settings** | Configure where resource logs go |

### Diagnostic Settings
Configure on each Azure resource to send logs/metrics to:
- Log Analytics Workspace (query with KQL)
- Azure Storage Account (archival)
- Azure Event Hubs (streaming to external SIEM)
- Azure Monitor / Partner solutions

### Alert Rules
```
Signal (Metric, Log, Activity Log)
    + Condition (threshold, KQL query)
    + Action Group (email, SMS, webhook, ITSM, Logic App)
    = Alert Rule
```

### Action Groups
| Action Type | Description |
|-------------|-------------|
| **Email/SMS/Push/Voice** | Notification to people |
| **Azure Function** | Trigger a function for automation |
| **Logic App** | Trigger a Logic App workflow |
| **Webhook** | HTTP POST to any URL |
| **ITSM** | Create ticket in ServiceNow, etc. |
| **Runbook** | Azure Automation runbook |

---

## Incident Response

### Incident Response Process
```
Detection (Sentinel alert / Defender alert)
    → Triage (severity assessment, assign owner)
    → Investigation (entity investigation, hunting)
    → Containment (block user/IP, isolate host)
    → Eradication (remove malware, fix vulnerability)
    → Recovery (restore service, verify clean)
    → Lessons Learned (update playbooks, detection rules)
```

### Microsoft Sentinel Investigation
- **Investigation graph**: Visual map of entities and their relationships
- **Entity pages**: Timeline of activity for specific user/IP/host
- **Bookmarks**: Save important findings during investigation
- **Incident timeline**: Chronological view of all alerts in incident

### Microsoft Defender for Endpoint (MDE) Response
- **Isolate device**: Block all network traffic except Defender communication
- **Restrict app execution**: Only Microsoft-signed executables allowed
- **Run AV scan**: Trigger antivirus scan remotely
- **Collect investigation package**: Collect forensic data
- **Live response**: Remote shell for forensic investigation

---

## Microsoft Defender XDR

Extended Detection and Response platform integrating:
- **Defender for Endpoint** (devices)
- **Defender for Identity** (on-prem AD)
- **Defender for Office 365** (email, collaboration)
- **Defender for Cloud Apps** (SaaS apps)
- **Defender for Cloud** (Azure workloads)

Cross-product correlation in Microsoft Defender portal (security.microsoft.com)

---

## Key Exam Points

### Tool Selection Guide
| Need | Tool |
|------|------|
| Posture management + Secure Score | Defender for Cloud |
| Workload threat detection (VMs, SQL, etc.) | Defender plans in Defender for Cloud |
| SIEM (collect + analyze all logs) | Microsoft Sentinel |
| SOAR (automated response) | Sentinel Playbooks (Logic Apps) |
| Compliance dashboard | Defender for Cloud Regulatory Compliance |
| Enforce governance | Azure Policy |
| Centralized log storage | Log Analytics Workspace |
| KQL queries for threat hunting | Microsoft Sentinel / Log Analytics |
| Incident investigation | Microsoft Sentinel |

### Common Exam Scenarios
- **"Automatically block users when high-severity incident detected"** → Sentinel Automation Rule → Playbook → Disable user in Entra ID
- **"Ensure all subscriptions follow NIST 800-53"** → Defender for Cloud → Regulatory Compliance → Add NIST initiative
- **"Monitor changes to Azure RBAC assignments"** → Azure Activity Log → Alert on "Write RoleAssignments" operation
- **"Detect impossible travel sign-ins"** → Entra ID Identity Protection + Sentinel analytic rule on SignInLogs
- **"Collect logs from on-premises Cisco firewall"** → Sentinel → CEF connector → Syslog forwarder VM

### KQL Cheat Sheet
```kusto
// Last 24 hours
| where TimeGenerated > ago(24h)

// Filter by value
| where Severity == "High"

// Multiple conditions
| where ResultType != 0 and UserPrincipalName endswith "@contoso.com"

// Count per category
| summarize count() by Category

// Top 10
| top 10 by TimeGenerated desc

// Join two tables
| join kind=inner (OtherTable | where ...) on CommonField

// Render chart
| render timechart
```

---

📖 [Detailed Study Notes →](study-notes.md) | [Practice Questions →](../../practice-questions/domain4-security-ops.md)
