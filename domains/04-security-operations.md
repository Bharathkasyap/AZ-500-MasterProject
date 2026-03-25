# Domain 4 — Manage Security Operations (25–30%)

## Overview

This domain covers how to monitor, detect, and respond to security threats in Azure using Microsoft Defender for Cloud, Microsoft Sentinel, Azure Monitor, and related automation tools.

---

## 4.1 Microsoft Defender for Cloud

Microsoft Defender for Cloud (formerly Azure Security Center + Azure Defender) is the central security posture management (CSPM) and threat protection platform for Azure (and multi-cloud).

### Two Core Pillars

| Pillar | Description |
|--------|-------------|
| **CSPM** (Cloud Security Posture Management) | Assess misconfigurations; generate recommendations; calculate Secure Score |
| **CWPP** (Cloud Workload Protection Platform) | Threat detection; alerts for specific workloads |

### Secure Score
- Measures the security posture of your environment
- Score = (Completed controls / Total controls) × 100
- Each security control has a **max score** based on its importance
- Recommendations are grouped into **Security Controls**

### Defender Plans (workload-specific)

| Plan | Protects |
|------|---------|
| Defender for Servers | VMs; includes JIT, adaptive application controls, file integrity monitoring |
| Defender for App Service | Azure App Service; detects C2C, data exfiltration, shell commands |
| Defender for SQL | Azure SQL, SQL on VMs, SQL Managed Instance |
| Defender for Storage | Blob/Files storage; malware scanning, anomaly detection |
| Defender for Containers | AKS, container registries; runtime protection |
| Defender for Key Vault | Detect unusual access patterns, suspicious activity |
| Defender for DNS | Detect domain generation algorithms (DGA), DNS tunneling |
| Defender for Resource Manager | Detect lateral movement, suspicious ARM operations |
| Defender CSPM (enhanced) | Attack path analysis, cloud security graph, agentless scanning |

### Security Alerts
- Severity: **High**, **Medium**, **Low**, **Informational**
- Correlation: Individual alerts → **Security Incidents**
- Workflow automation: trigger Logic App on alert/recommendation

### Adaptive Application Controls
- ML-based allowlisting of processes on VMs
- Alerts on processes outside the baseline
- Part of **Defender for Servers**

### File Integrity Monitoring (FIM)
- Monitor changes to Windows registry, OS files, Linux files
- Compare against baseline; alert on unexpected changes
- Part of **Defender for Servers**

### Regulatory Compliance Dashboard
- Map security controls to standards: CIS, NIST, PCI DSS, ISO 27001, Azure Security Benchmark
- Export compliance reports
- Apply industry standards as Defender for Cloud policies

---

## 4.2 Azure Policy for Security

### Policy Concepts

| Concept | Description |
|---------|-------------|
| **Policy Definition** | Rule that evaluates resource properties |
| **Initiative Definition** | Collection of policy definitions (policy set) |
| **Assignment** | Apply a policy/initiative to a scope |
| **Compliance** | Evaluated against all existing + new resources |

### Policy Effects (in evaluation order)

| Effect | Behavior |
|--------|---------|
| **Disabled** | Policy is inactive |
| **Audit** | Log non-compliant resources; do not block |
| **AuditIfNotExists** | Audit if a related resource doesn't exist |
| **Deny** | Block creation/update of non-compliant resources |
| **DeployIfNotExists** | Auto-deploy a related resource if missing |
| **Modify** | Add/update/remove properties (tags, settings) |
| **Append** | Add fields to existing resources |

### Azure Security Benchmark (ASB)
- Microsoft's default initiative in Defender for Cloud
- Maps to CIS Controls and NIST SP 800-53
- Provides prioritized security recommendations

### Management Groups
- Hierarchical container for subscriptions (up to 6 levels deep)
- Policies assigned at a management group apply to all child subscriptions
- Limit of **10,000 management groups** in a single directory

---

## 4.3 Microsoft Sentinel

Microsoft Sentinel is Azure's cloud-native **SIEM** (Security Information and Event Management) and **SOAR** (Security Orchestration, Automation, and Response) platform.

### Core Components

```
Data Connectors → Log Analytics Workspace
                        ↓
                   Analytics Rules
                        ↓
                    Incidents
                        ↓
          Investigation → Playbooks (SOAR)
```

### Data Connectors
- **Microsoft 1st party**: Azure AD, Defender for Cloud, Office 365, Microsoft 365 Defender
- **Third-party**: Fortinet, Palo Alto, Cisco, AWS CloudTrail
- **CEF/Syslog**: Generic Linux-based connectors via Log Analytics agent
- **Codeless Connectors**: API-based (no infrastructure needed)

### Analytics Rules

| Rule Type | Description |
|-----------|-------------|
| **Scheduled** | KQL query on a defined schedule; creates incidents |
| **NRT (Near Real-Time)** | Low-latency scheduled rules (every ~1 min) |
| **Microsoft Security** | Import alerts from Defender products as incidents |
| **Fusion** | ML-based correlation of low-fidelity signals into high-fidelity incidents |
| **Anomaly** | Behavioral analytics (UEBA — User and Entity Behavior Analytics) |
| **Threat Intelligence** | Auto-generate alerts from threat intel indicators |

### Incident Management
- **Incidents** = correlated alerts with case management
- Assign to analyst, add comments, link evidence (entities, bookmarks)
- **Entity mapping** — extract users, IPs, hosts from alerts for investigation
- **Investigation graph** — visual relationship between entities

### KQL (Kusto Query Language) Basics

```kql
// Count failed logons in the last 24 hours
SecurityEvent
| where TimeGenerated > ago(24h)
| where EventID == 4625
| summarize count() by Account, Computer
| sort by count_ desc
```

```kql
// Find sign-ins from unfamiliar locations
SigninLogs
| where TimeGenerated > ago(7d)
| where RiskLevelDuringSignIn != "none"
| project TimeGenerated, UserPrincipalName, Location, RiskLevelDuringSignIn, ResultType
```

### Workbooks
- Interactive dashboards built on Azure Monitor Workbooks
- Pre-built workbooks for Azure Activity, Azure AD, Office 365, etc.
- Customizable with KQL queries and visualizations

### Playbooks (SOAR Automation)
- Built on **Azure Logic Apps**
- Triggered by: analytics rule firing, manual trigger from incident
- Common automations:
  - Block IP in NSG / firewall
  - Disable Azure AD user account
  - Isolate VM (network quarantine)
  - Create ServiceNow / Jira ticket
  - Send Teams/Slack notification

### UEBA (User and Entity Behavior Analytics)
- Baseline normal behavior for users and entities
- Alert on deviations: unusual hours, impossible travel, mass downloads
- **Sentinel UEBA** requires Azure AD connector + at least one data source

### Threat Intelligence
- TAXII server connector (STIX 2.x format)
- Microsoft Threat Intelligence feed (built-in)
- Indicator types: IP, domain, URL, file hash

---

## 4.4 Azure Monitor & Log Analytics

### Azure Monitor Components

```
Sources: VMs, App Services, Containers, Azure AD, Activity Log
    ↓
[Metrics]           [Logs]
    ↓                   ↓
Metrics Explorer    Log Analytics Workspace
    ↓                   ↓
Alerts              Workbooks / Dashboards
    ↓
Action Groups (email, SMS, webhook, Logic App, ITSM)
```

### Log Analytics Workspace
- Central repository for logs
- **Security best practice**: Separate workspace for security logs
- **Data retention**: 30 days free; up to 730 days (pay per day beyond 31 days)
- **Commitment tiers**: Reduce cost for high-volume ingestion

### Diagnostic Settings
- Route logs and metrics to: Log Analytics, Storage Account, Event Hubs, or Partner solutions
- Supported log categories vary by resource type (e.g., `AuditLogs`, `SignInLogs`, `AzureFirewallApplicationRule`)

### Azure Monitor Alerts

| Alert Type | Based On |
|-----------|---------|
| **Metric alert** | Threshold on a metric value |
| **Log alert** | KQL query returning rows |
| **Activity log alert** | Azure control-plane events |
| **Smart detection** | Application Insights anomalies |

### Action Groups
- Reusable set of notification and remediation actions
- Actions: email, SMS, push notification, voice call, webhook, Logic App, ITSM connector, Azure Function, Automation Runbook

---

## 4.5 Microsoft Defender XDR Integration

Microsoft Sentinel integrates with the Microsoft Defender XDR suite:

| Product | Detects |
|---------|---------|
| **Defender for Endpoint** | Endpoint threats, lateral movement |
| **Defender for Identity** | On-premises AD attacks (pass-the-hash, kerberoasting) |
| **Defender for Office 365** | Email phishing, malware, BEC |
| **Defender for Cloud Apps** | Shadow IT, OAuth app abuse, cloud app threats |
| **Defender for Cloud** | Azure workload threats |

### Unified SOC Portal
- Microsoft Defender XDR portal (`security.microsoft.com`) now integrates Sentinel
- Unified incident queue across all Defender products + Sentinel
- Single investigation experience

---

## 4.6 Security Governance

### Azure Blueprints *(legacy — migrating to Template Specs)*
- Package of ARM templates + policies + RBAC + resource groups
- Versioned, auditable deployments

### Azure Lighthouse
- Enable **delegated resource management** across customers/tenants
- MSPs manage customer subscriptions without signing in as guest
- Granular RBAC; audit trail of all actions

### Microsoft Defender External Attack Surface Management (EASM)
- Discover and monitor externally exposed assets
- Identify shadow IT, expired certificates, open ports

---

## 🎯 Exam Focus Points — Domain 4

1. **Defender for Cloud Secure Score** — understand what improves it; know the two pillars (CSPM + CWPP).
2. **Defender plans** — which plan protects which workload (VMs, SQL, Storage, Containers).
3. **Azure Policy effects** — `Deny`, `Audit`, `DeployIfNotExists`, `Modify` — know when each is used.
4. **Sentinel components** — connectors, analytics rules, incidents, playbooks, UEBA.
5. **Analytics rule types** — Scheduled, NRT, Fusion, Anomaly, Microsoft Security.
6. **KQL basics** — `where`, `summarize`, `project`, `sort`, `ago()` functions.
7. **JIT VM Access** — how it reduces attack surface; what triggers an access request.
8. **Diagnostic settings** — what can be sent where; importance of routing to Log Analytics.
9. **Adaptive application controls** — ML-based allowlisting; alerts on deviation.
10. **File Integrity Monitoring** — what it monitors; how it alerts; which Defender plan includes it.
