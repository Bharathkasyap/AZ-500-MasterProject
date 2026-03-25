# Domain 4: Manage Security Operations (25–30%)

> **Exam Weight:** 25–30% — This is one of the two heaviest domains. Expect 10–18 questions. Focus heavily on Microsoft Sentinel, Azure Monitor, and incident response.

---

## Table of Contents

1. [Microsoft Sentinel](#1-microsoft-sentinel)
2. [Azure Monitor and Log Analytics](#2-azure-monitor-and-log-analytics)
3. [Microsoft Defender for Cloud — Security Operations](#3-microsoft-defender-for-cloud--security-operations)
4. [Security Information and Event Management (SIEM)](#4-security-information-and-event-management-siem)
5. [Security Policies and Regulatory Compliance](#5-security-policies-and-regulatory-compliance)
6. [Azure Policy](#6-azure-policy)
7. [Incident Response in Azure](#7-incident-response-in-azure)
8. [Security Automation and Orchestration (SOAR)](#8-security-automation-and-orchestration-soar)
9. [Key Exam Topics Checklist](#9-key-exam-topics-checklist)

---

## 1. Microsoft Sentinel

### What It Is
Microsoft Sentinel is Azure's cloud-native Security Information and Event Management (SIEM) and Security Orchestration, Automation, and Response (SOAR) solution. It collects, detects, investigates, and responds to security threats at cloud scale.

### Sentinel Core Components

| Component | Description |
|---|---|
| **Data Connectors** | Ingest data from Azure services, Microsoft 365, partner solutions, and custom sources |
| **Log Analytics Workspace** | The underlying data store — all data is stored here |
| **Analytics Rules** | Detect threats by running queries on ingested data |
| **Incidents** | Groups of related alerts requiring investigation |
| **Playbooks** | Automated response workflows using Logic Apps |
| **Workbooks** | Interactive dashboards for data visualization |
| **Threat Intelligence** | Feed of known malicious IPs, domains, file hashes |
| **UEBA** | User and Entity Behavior Analytics — baseline normal behavior, detect anomalies |

### Setting Up Microsoft Sentinel

1. Create a Log Analytics workspace
2. Enable Microsoft Sentinel on the workspace
3. Connect data sources using Data Connectors
4. Configure Analytics Rules to detect threats
5. Create Playbooks for automated response

### Data Connectors

| Category | Examples |
|---|---|
| **Microsoft services** | Microsoft Entra ID, Microsoft 365, Defender for Cloud, Azure Activity |
| **Microsoft 365 Defender** | Defender for Endpoint, Defender for Office 365, Defender for Identity |
| **Azure services** | Azure Firewall, NSG flow logs, Azure Key Vault diagnostics |
| **Partner solutions** | Palo Alto, Fortinet, Check Point, Cisco |
| **Custom** | Syslog, CEF (Common Event Format), REST API |

### Analytics Rules

| Rule Type | Description |
|---|---|
| **Microsoft Security** | Auto-create incidents from Microsoft Defender alerts |
| **Scheduled** | KQL query runs on a schedule; triggers alert if condition is met |
| **NRT (Near Real-Time)** | Runs every minute for faster detection |
| **Fusion** | ML-based multi-stage attack detection (correlates alerts across sources) |
| **ML Behavior Analytics** | Anomalous SSH/RDP access detection |
| **Threat Intelligence** | Match indicators against incoming data |

### KQL (Kusto Query Language) Basics

```kql
// Find failed sign-in attempts
SigninLogs
| where ResultType != 0
| where TimeGenerated > ago(1h)
| summarize FailureCount = count() by UserPrincipalName, IPAddress
| where FailureCount > 5
| order by FailureCount desc
```

```kql
// Detect brute force attempts
SecurityEvent
| where EventID == 4625  // Failed logon
| where TimeGenerated > ago(1h)
| summarize Attempts = count() by Account, Computer, IpAddress
| where Attempts > 10
```

### Incidents

| Property | Description |
|---|---|
| **Title** | Descriptive name from the analytics rule |
| **Severity** | High, Medium, Low, Informational |
| **Status** | New, Active, Closed |
| **Owner** | Assigned analyst |
| **Entities** | Accounts, IPs, hosts, URLs, files involved |
| **Alerts** | One or more alerts that triggered the incident |
| **Tactics/Techniques** | MITRE ATT&CK framework mapping |

### Investigating Incidents
1. Open incident from Sentinel dashboard
2. Review alert details and evidence
3. Use Investigation Graph to visualize entity relationships
4. Search related events in Log Analytics
5. Take action (block IP, disable account, isolate host)
6. Close incident with classification and comment

### Hunting
- Proactively search for threats not yet detected by analytics rules
- Use built-in hunting queries (based on MITRE ATT&CK)
- Save interesting results as bookmarks
- Promote bookmarks to incidents

### UEBA (User and Entity Behavior Analytics)
- Builds behavioral baseline for users, hosts, and IPs
- Detects anomalies like:
  - Impossible travel (sign-in from two distant locations in short time)
  - First-time access to sensitive resource
  - Unusual process execution

### Threat Intelligence in Sentinel
- Import threat intelligence feeds (TAXII, STIX)
- Microsoft provides TI through Microsoft Defender Threat Intelligence (MDTI)
- Match indicators (IPs, domains, file hashes) against incoming logs

> **Exam tip:** Understand the difference between Analytics Rules (detect threats), Playbooks (respond), and Workbooks (visualize). Sentinel is built on top of Log Analytics.

---

## 2. Azure Monitor and Log Analytics

### Azure Monitor Architecture

```
Data Sources → Azure Monitor (collection) → Log Analytics / Metrics → Alerts / Dashboards / Workbooks
```

| Data Type | Description | Query Tool |
|---|---|---|
| **Metrics** | Numeric values at regular intervals | Metrics Explorer |
| **Logs** | Structured/unstructured records of events | Log Analytics (KQL) |
| **Distributed traces** | End-to-end request tracing | Application Insights |
| **Changes** | Resource configuration changes | Change Analysis |

### Log Analytics Workspace
- Central repository for log data from Azure and hybrid environments
- Data retention: 30 days default, up to 730 days (longer with Archive tier)
- Query using KQL (Kusto Query Language)

### Key Log Tables in Sentinel/Log Analytics

| Table | Data |
|---|---|
| `SigninLogs` | Azure AD sign-in activity |
| `AuditLogs` | Azure AD audit events |
| `SecurityEvent` | Windows Security Events (from VMs) |
| `Syslog` | Linux system log events |
| `AzureActivity` | Azure Resource Manager operations |
| `AzureFirewallApplicationRule` | Azure Firewall application rule logs |
| `AzureNetworkAnalytics_CL` | NSG flow log analytics (Traffic Analytics) |
| `SecurityAlert` | Security alerts from Defender products |
| `SecurityIncident` | Sentinel incidents |

### Azure Monitor Alerts

| Alert Type | Triggers On |
|---|---|
| **Metric alert** | Metric crosses a threshold (CPU > 90%) |
| **Log alert** | KQL query returns results |
| **Activity log alert** | Specific Azure operation (VM deleted) |
| **Smart detection** | Application Insights automatic anomaly detection |

### Action Groups
Define what happens when an alert fires:
- **Notifications:** Email, SMS, voice call, Azure mobile app
- **Actions:** Webhook, Azure Function, Logic App, ITSM connector, Runbook, Event Hub

### Diagnostic Settings
Configure Azure resources to send logs to:
- Log Analytics workspace (Sentinel/monitoring)
- Azure Storage account (long-term archival)
- Event Hub (stream to external SIEM)

> **Exam tip:** Know the key log tables for common security investigations. Diagnostic settings must be configured per resource.

---

## 3. Microsoft Defender for Cloud — Security Operations

### Security Alerts Workflow

1. **Detect** — Defender detects suspicious activity
2. **Alert** — Alert created with details, severity, MITRE tactic
3. **Investigate** — Analyst reviews alert, related alerts, entities
4. **Respond** — Manual or automated response (Playbook)
5. **Close** — Dismiss, resolve, or escalate to Sentinel

### Alert Suppression Rules
- Suppress recurring false-positive alerts
- Define conditions: alert name, subscription, entity
- Suppressed alerts are still logged but not shown in active alerts

### Workflow Automation
- Trigger Logic App playbooks from Defender for Cloud alerts
- Automated responses: Notify security team, block IP in firewall, isolate VM

### Continuous Export
Export Defender for Cloud data to:
- Log Analytics workspace (for Sentinel integration)
- Event Hub (for external SIEM)

### Defender for Cloud Integration with Sentinel
1. Enable Sentinel data connector: "Microsoft Defender for Cloud"
2. All Defender alerts flow into Sentinel
3. Sentinel correlates Defender alerts with other data sources
4. Incidents created for complex, multi-stage attacks

---

## 4. Security Information and Event Management (SIEM)

### SIEM vs. SOAR

| Aspect | SIEM | SOAR |
|---|---|---|
| **Focus** | Collect, correlate, alert | Automate response workflows |
| **Azure product** | Microsoft Sentinel (SIEM part) | Microsoft Sentinel Playbooks (SOAR part) |
| **Output** | Alerts and reports | Automated actions |

### Log Ingestion Sources for Azure SIEM

| Source | How to Connect |
|---|---|
| Azure AD Sign-ins | Entra ID Diagnostic Settings → Log Analytics |
| Azure Activity Log | Activity Log → Diagnostic Settings → Log Analytics |
| NSG Flow Logs | Network Watcher → NSG Flow Logs → Storage → Log Analytics |
| VM Security Events | Log Analytics Agent / Azure Monitor Agent on VM |
| Azure Firewall | Diagnostic Settings → Log Analytics |
| Office 365 / M365 | Sentinel Data Connector |

### Log Retention Considerations

| Tier | Retention | Cost |
|---|---|---|
| **Hot (Analytics)** | Up to 90 days interactive query | Higher |
| **Warm (Interactive Retention)** | 90 days – 2 years | Medium |
| **Cold (Archive)** | 2 – 7 years | Lower |

---

## 5. Security Policies and Regulatory Compliance

### Microsoft Defender for Cloud Policy Framework

```
Management Group Policy
    └── Subscription Policy
            └── Resource Group Policy
                    └── Resource
```

### Security Initiatives
An initiative is a collection of Azure Policy definitions grouped to achieve a specific goal.

**Default Initiative: Microsoft Cloud Security Benchmark (MCSB)**
- Applied automatically when Defender for Cloud is enabled
- Provides recommendations based on Azure security best practices

### Regulatory Compliance Standards in Defender for Cloud

| Standard | Use Case |
|---|---|
| Azure Security Benchmark | General Azure security best practices |
| CIS Microsoft Azure Foundations Benchmark | Center for Internet Security baseline |
| PCI DSS | Payment Card Industry standard |
| NIST SP 800-53 | US government security standard |
| ISO 27001 | International information security standard |
| SOC TSP | Service Organization Controls |

### Compliance Dashboard
- Shows passing vs. failing controls per standard
- Drill down to specific failing resources
- Download compliance reports for auditors

---

## 6. Azure Policy

### What It Is
Azure Policy evaluates Azure resources for compliance with organizational standards. It can audit, deny, or remediate non-compliant resources.

### Policy Effects (in order of enforcement)

| Effect | Description |
|---|---|
| **Disabled** | Policy is off |
| **Audit** | Log non-compliance but allow the action |
| **AuditIfNotExists** | Audit if a related resource doesn't exist |
| **Deny** | Block the non-compliant action |
| **DeployIfNotExists** | Automatically deploy a related resource if missing |
| **Modify** | Add, update, or remove resource properties |
| **Append** | Add properties to resources |

### Policy Definition Structure

```json
{
  "displayName": "Require HTTPS on storage accounts",
  "policyType": "Custom",
  "mode": "All",
  "parameters": {},
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Storage/storageAccounts"
        },
        {
          "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
          "notEquals": "true"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
}
```

### Policy Scopes
- Management group (applies to all subscriptions in group)
- Subscription
- Resource group
- Individual resource

### Policy Exemptions
- Exclude specific resources from a policy assignment
- Types: Waiver (acknowledge non-compliance) or Mitigated (compliance achieved another way)

### Policy Remediation Tasks
- For `DeployIfNotExists` and `Modify` effects
- Creates a managed identity to perform remediation
- Run remediation task to fix non-compliant existing resources

### Azure Policy vs. Azure RBAC

| Aspect | Azure Policy | Azure RBAC |
|---|---|---|
| **Controls** | What resources look like (compliance) | Who can do what (access) |
| **Default** | Allow all (audit/deny specific things) | Deny all (grant specific permissions) |
| **Scope** | Resource properties and configuration | User actions on resources |

> **Exam tip:** RBAC controls who can perform actions. Azure Policy controls how resources are configured.

---

## 7. Incident Response in Azure

### Incident Response Phases (NIST Framework)

| Phase | Actions |
|---|---|
| **Preparation** | Set up monitoring, playbooks, team roles |
| **Detection & Analysis** | Detect threats, analyze scope and impact |
| **Containment** | Isolate affected resources, stop spreading |
| **Eradication** | Remove threat from environment |
| **Recovery** | Restore systems, validate integrity |
| **Post-Incident** | Document lessons learned, improve controls |

### Containment Actions in Azure

| Threat | Containment Action |
|---|---|
| Compromised VM | Isolate VM from network (NSG deny all), enable JIT |
| Compromised user account | Disable account, revoke sessions, require MFA re-registration |
| Data exfiltration | Revoke SAS tokens, change storage account keys |
| Malware on VM | Snapshot disk for forensics, delete VM, restore from clean backup |
| Suspicious application | Adaptive Application Controls to block |

### Azure Resource Lock
Prevent accidental deletion or modification during incident response:

| Lock Type | Prevents |
|---|---|
| **CanNotDelete** | Resource cannot be deleted but can be modified |
| **ReadOnly** | Resource cannot be deleted or modified |

### Azure Activity Log for Forensics
- All Azure ARM operations logged
- Retention: 90 days in Activity Log (export to Log Analytics for longer)
- Search for: who performed an action, from which IP, at what time

### Key Vault Logging for Forensics
- Enable diagnostic logs on Key Vault
- Logs: Who accessed which secret/key/certificate and when
- Critical for detecting credential theft

---

## 8. Security Automation and Orchestration (SOAR)

### Playbooks in Microsoft Sentinel
Playbooks are automated response workflows built with Azure Logic Apps.

### Playbook Trigger Types

| Trigger | Use Case |
|---|---|
| **Incident trigger** | Runs when a Sentinel incident is created |
| **Alert trigger** | Runs when a Sentinel alert fires |
| **Entity trigger** | Runs on demand for a specific entity (IP, user) |

### Common Playbook Examples

#### Auto-respond to high-severity incidents
```
Trigger: New Sentinel Incident (Severity = High)
→ Send Teams/Slack notification to SOC channel
→ Create ServiceNow/Jira ticket
→ Add incident details to ticket
```

#### Block compromised user on Conditional Access
```
Trigger: New Sentinel Incident (entity = user account)
→ Get user from incident entities
→ Entra ID: Block sign-in for user
→ Entra ID: Revoke all refresh tokens
→ Notify security team via email
```

#### Enrich IP address with threat intelligence
```
Trigger: New Sentinel Alert
→ Extract IP from alert entities
→ Call VirusTotal/Shodan API
→ Add enrichment comment to incident
→ If malicious: Block IP in Azure Firewall
```

### Logic Apps for Security Automation
- Visual workflow designer (no code required)
- 400+ connectors: Entra ID, Azure, Microsoft 365, ServiceNow, Jira, Slack, PagerDuty
- Supports conditional logic, loops, error handling

### Azure Functions for Security Automation
- Code-based automation (Python, C#, JavaScript, PowerShell)
- Triggered by HTTP, Event Grid, Service Bus, Timer
- Used when Logic Apps lack a specific connector or need complex logic

### Event Grid for Security Events
- Route Azure security events to endpoints
- Publish-subscribe model for event-driven security responses
- Sources: Microsoft Defender for Cloud, Key Vault, Policy, Resource changes

> **Exam tip:** Sentinel Playbooks use Logic Apps for automation. Know incident trigger vs. alert trigger.

---

## 9. Key Exam Topics Checklist

Use this checklist to confirm your readiness for Domain 4:

- [ ] Set up Microsoft Sentinel on a Log Analytics workspace
- [ ] Configure Sentinel data connectors (Azure AD, Defender for Cloud, Activity Log)
- [ ] Create and configure Analytics Rules (Scheduled, NRT, Fusion)
- [ ] Write basic KQL queries for security investigation
- [ ] Understand the incident workflow in Sentinel
- [ ] Use UEBA to detect anomalous behavior
- [ ] Configure Azure Monitor diagnostic settings for resources
- [ ] Create metric and log alerts with action groups
- [ ] Configure log retention settings in Log Analytics
- [ ] Understand Defender for Cloud alert workflow
- [ ] Configure continuous export from Defender for Cloud
- [ ] Assign security initiatives and built-in policies
- [ ] Add regulatory compliance standards to Defender for Cloud
- [ ] Create and assign Azure Policy definitions
- [ ] Understand policy effects (Audit, Deny, DeployIfNotExists)
- [ ] Create policy remediation tasks
- [ ] Apply Azure Resource Locks
- [ ] Use Activity Log for incident forensics
- [ ] Create Sentinel Playbooks for automated response
- [ ] Configure incident trigger vs. alert trigger in playbooks
- [ ] Understand incident response phases (NIST framework)

---

*Previous: [Domain 3 — Secure Compute, Storage, and Databases ←](03-compute-storage-db.md)*

*Back to: [README — Project Overview](../README.md)*
