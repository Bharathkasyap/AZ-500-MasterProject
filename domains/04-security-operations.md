# Domain 4: Manage Security Operations (25–30%)

> This domain is the second-largest on the AZ-500 exam. It covers Microsoft Defender for Cloud, Microsoft Sentinel, Azure Monitor, and security posture management. Expect 10–18 questions.

---

## Table of Contents

1. [Microsoft Defender for Cloud](#1-microsoft-defender-for-cloud)
2. [Microsoft Sentinel](#2-microsoft-sentinel)
3. [Azure Monitor and Log Analytics](#3-azure-monitor-and-log-analytics)
4. [Azure Security Center Policies and Compliance](#4-azure-security-center-policies-and-compliance)
5. [Microsoft Defender Plans (Workload Protection)](#5-microsoft-defender-plans-workload-protection)
6. [Security Information and Event Management (SIEM)](#6-security-information-and-event-management-siem)
7. [Incident Response in Azure](#7-incident-response-in-azure)
8. [Key Exam Topics Checklist](#8-key-exam-topics-checklist)

---

## 1. Microsoft Defender for Cloud

### Overview
Microsoft Defender for Cloud (formerly Azure Security Center + Azure Defender) is a Cloud Security Posture Management (CSPM) and Cloud Workload Protection Platform (CWPP) solution.

### Two Core Functions

| Function | Description | Tier |
|----------|-------------|------|
| **CSPM (Posture Management)** | Assesses security configuration, provides recommendations, tracks Secure Score | Free (Foundational) |
| **CWPP (Workload Protection)** | Runtime threat detection and protection for specific Azure services | Paid (Defender plans) |

### Secure Score

- Measures overall security posture as a percentage (0–100%)
- Based on security controls (groups of related recommendations)
- Each control has a max score; completing all recommendations in a control earns the full points
- Higher score = stronger security posture

```
Secure Score = (Current score / Max score) × 100
```

### Security Recommendations

- Derived from **security initiatives** (collections of security policies)
- Categorized by severity: High, Medium, Low
- Can be **remediated** (fix the issue), **exempted** (mark as not applicable), or **accepted** (acknowledge risk)
- Some recommendations offer **Quick Fix** for one-click remediation

### Defender for Cloud — Coverage

| Capability | Description |
|-----------|-------------|
| **Azure** | Assess Azure subscriptions and resources |
| **Multicloud** | Connect AWS and GCP for CSPM and some CWPP features |
| **Hybrid** | On-premises servers via Azure Arc |

### Microsoft Cloud Security Benchmark (MCSB)

- Default security initiative in Defender for Cloud
- Based on CIS Controls, NIST CSF, and other frameworks
- Replaces the Azure Security Benchmark (ASB)
- Provides specific recommendations mapped to controls

### Key Exam Points — Defender for Cloud
- Defender for Cloud is enabled on **all subscriptions** with foundational CSPM for free
- Paid Defender plans are required for workload-specific protection (threat detection)
- **Secure Score** is the primary KPI for security posture improvement
- **Security initiatives** bundle policies; the default initiative is MCSB
- Recommendations can be **exempted** (not counted against score) for legitimate exceptions
- Defender for Cloud integrates with **Azure Policy** — many recommendations are backed by policies

---

## 2. Microsoft Sentinel

### Overview
Microsoft Sentinel is a cloud-native SIEM (Security Information and Event Management) and SOAR (Security Orchestration, Automation, and Response) solution.

### Sentinel Architecture

```
Data Sources → Data Connectors → Log Analytics Workspace → Sentinel
                                                                  │
                              ┌───────────────────────────────────┤
                              │               │                   │
                          Analytics        Automation         Threat Intel
                          (Detection)      (SOAR/Playbooks)   (TAXII/STIX)
                              │               │
                          Incidents       Auto-remediation
                          Alerts          Notifications
```

### Data Connectors

| Category | Examples |
|----------|---------|
| **Microsoft 1st party** | Microsoft Entra ID, Microsoft 365, Defender for Cloud, Azure Activity |
| **Partner connectors** | Cisco, Palo Alto, Fortinet, Check Point |
| **CEF (Syslog)** | Any device that sends CEF-formatted syslog |
| **REST API** | Custom connectors using Sentinel Data Collection API |

### Analytics Rules (Detection Rules)

| Rule Type | Description |
|-----------|-------------|
| **Scheduled** | KQL query runs on a schedule; generates alerts if results found |
| **NRT (Near Real-Time)** | Runs every minute; for high-fidelity, time-sensitive detections |
| **Fusion** | ML-based; correlates low-fidelity alerts into high-fidelity incidents |
| **Microsoft Security** | Automatically creates incidents from Microsoft security service alerts |
| **Anomaly** | ML-based; detects behavioral anomalies |
| **Threat Intelligence** | Matches IOCs from threat intelligence against log data |

### KQL (Kusto Query Language)

```kql
// Find failed sign-in attempts
SigninLogs
| where TimeGenerated > ago(1d)
| where ResultType != 0  // 0 = success
| summarize FailedAttempts = count() by UserPrincipalName, IPAddress
| where FailedAttempts > 10
| order by FailedAttempts desc

// Detect suspicious process creation
SecurityEvent
| where EventID == 4688  // Process creation
| where CommandLine has_any ("powershell", "cmd", "wscript", "cscript")
| where NewProcessName !startswith "C:\\Windows\\System32"
| project TimeGenerated, Computer, Account, CommandLine, NewProcessName
```

### Sentinel Automation

| Feature | Description |
|---------|-------------|
| **Automation rules** | Lightweight, rule-based automation triggered by incidents/alerts |
| **Playbooks** | Azure Logic Apps workflows for complex orchestration and response |

**Automation rule actions:**
- Assign incident owner
- Change incident status (Active → Closed)
- Change incident severity
- Add tags to incident
- Run a playbook

**Playbook triggers:**
- When alert is created
- When incident is created
- When incident is updated

```
Incident Created → Automation Rule → Run Playbook (Logic App)
                                            │
                              ┌─────────────┼─────────────┐
                              │             │             │
                         Notify Teams  Block IP in    Create JIRA
                         Channel       NSG/Firewall   Ticket
```

### Threat Intelligence in Sentinel

| Feature | Description |
|---------|-------------|
| **TAXII connector** | Import threat intel from TAXII 2.0/2.1 servers |
| **Threat Intelligence platform** | Upload IOCs via API or UI |
| **MDTI connector** | Microsoft Defender Threat Intelligence (premium) |
| **Threat Intel Matching Analytics** | Auto-detect IOC matches in log data |

### Sentinel Workbooks

- Pre-built or custom dashboards using Azure Monitor Workbooks
- Visualize: Alert trends, geographic distribution, top threats, compliance status
- Built-in workbooks for: Azure Activity, Microsoft Entra ID, Office 365, Defender for Cloud

### Sentinel UEBA (User and Entity Behavior Analytics)

- Builds behavioral profiles for users and entities (hosts, IPs, apps)
- Detects anomalies: unusual access times, access to new resources, impossible travel
- Requires **Entity pages** to see unified view of user/entity activity
- Enriches incidents with behavioral context

### Key Exam Points — Microsoft Sentinel
- Sentinel sits on top of a **Log Analytics workspace** — data is stored in LA
- **KQL** is the query language for all Sentinel queries and detection rules
- **Fusion** rules require no configuration — they automatically correlate alerts using ML
- **Playbooks** are **Azure Logic Apps** — they run on Azure, not on-premises
- **Automation rules** run before playbooks — use them for simple triage and routing
- **TAXII connector** imports threat intelligence from external TI platforms
- Sentinel pricing: **Pay-per-GB ingested** (with capacity reservations for high-volume customers)
- Enable **UEBA** to get behavioral anomaly detection and entity enrichment

---

## 3. Azure Monitor and Log Analytics

### Azure Monitor Overview

```
Data Sources
├── Azure Resources (metrics, diagnostic logs)
├── Guest OS (Windows Event Logs, Syslog via agent)
├── Applications (Application Insights)
├── Custom sources (REST API, agents)
└── Subscriptions/Tenants (Activity Log, Entra ID logs)
          │
          ▼
    Azure Monitor
    ├── Metrics (time-series, 93-day retention, real-time)
    └── Logs (Log Analytics workspace, up to 730-day retention)
          │
          ▼
    Actions/Alerts/Workbooks/Dashboards
```

### Log Analytics Workspace

| Aspect | Details |
|--------|---------|
| **Retention** | 30 days free; up to 730 days (paid); archive up to 7 years |
| **Access model** | Workspace-level access or resource-level access |
| **Data ingestion** | Direct agent, diagnostics settings, API |
| **Pricing** | Pay-per-GB + retention costs |

### Key Security Log Sources

| Log Source | Data |
|-----------|------|
| **Azure Activity Log** | Subscription-level operations (create/update/delete); 90-day retention by default |
| **Entra ID Sign-in Logs** | Authentication events; user and service principal sign-ins |
| **Entra ID Audit Logs** | Directory changes (user creation, role assignments, policy changes) |
| **NSG Flow Logs** | Inbound/outbound traffic through NSGs |
| **Azure Firewall Logs** | Firewall rule matches, IDPS alerts |
| **Key Vault Audit Logs** | Access to secrets, keys, certificates |
| **SQL Audit Logs** | Database operations and access |
| **Security Events** (Windows) | Event IDs 4624 (logon), 4625 (failed logon), 4688 (process creation) |

### Common KQL Security Queries

```kql
// Privileged role assignments in Entra ID
AuditLogs
| where OperationName == "Add member to role"
| where TargetResources[0].modifiedProperties[0].newValue has_any ("Global Administrator", "Privileged Role Administrator")
| project TimeGenerated, InitiatedBy, TargetResources

// Azure Activity: Who deleted resources?
AzureActivity
| where OperationNameValue endswith "/delete"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, Resource

// Key Vault: Who accessed secrets?
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet"
| project TimeGenerated, identity_claim_oid_g, requestUri_s, ResultSignature

// Failed SSH/RDP attempts
SecurityEvent
| where EventID in (4625, 4771)  // Failed logon
| summarize Attempts = count() by IpAddress, Account
| where Attempts > 20
| order by Attempts desc
```

### Azure Monitor Alerts

| Alert Type | Based On | Examples |
|-----------|----------|---------|
| **Metric alert** | Metric threshold | CPU > 90%, DDoS attack detected |
| **Log alert** | KQL query results | Failed logins > threshold, malware detected |
| **Activity log alert** | Azure Activity Log events | Role assignment created, VM deleted |
| **Smart detection** | Application Insights anomalies | Failure rate spike, performance degradation |

### Action Groups

- Define who to notify and what actions to take when an alert fires
- Notification types: Email, SMS, voice call, Azure app push
- Action types: Webhook, Logic App, Azure Function, Event Hub, ITSM connector, Runbook

### Key Exam Points — Azure Monitor/Log Analytics
- Activity Log is **90-day** retention by default — send to Log Analytics for longer retention
- Entra ID logs (sign-in + audit) require a **Log Analytics workspace** or storage account for export
- Log Analytics workspace access control: resource-level vs workspace-level access modes
- **Action groups** are reusable — multiple alerts can share the same action group
- Enable **diagnostic settings** on all critical resources to capture logs in Log Analytics

---

## 4. Azure Security Center Policies and Compliance

### Azure Policy Fundamentals

| Component | Description |
|-----------|-------------|
| **Policy definition** | A rule that evaluates resource configurations |
| **Initiative (Policy Set)** | A group of related policy definitions |
| **Assignment** | Applying a policy/initiative to a scope (MG, subscription, RG) |
| **Compliance state** | Compliant, Non-compliant, Exempt, Conflict |
| **Effect** | What happens when policy evaluates: Deny, Audit, Append, Modify, DeployIfNotExists, AuditIfNotExists |

### Policy Effects (Exam Critical)

| Effect | When Evaluated | Behavior |
|--------|---------------|---------|
| **Deny** | On create/update | Blocks resource creation/update |
| **Audit** | On existing + create/update | Marks as non-compliant; no enforcement |
| **Append** | On create/update | Adds fields to the request |
| **Modify** | On existing + create/update | Modifies resource properties (tags, etc.) |
| **DeployIfNotExists** | On existing resources | Deploys a related resource if it doesn't exist (remediation) |
| **AuditIfNotExists** | On existing resources | Audits if a related resource doesn't exist |

### Remediation Tasks

- For **DeployIfNotExists** and **Modify** policies, you can create **remediation tasks**
- Remediation tasks fix non-compliant existing resources
- Require a **managed identity** with appropriate RBAC permissions

### Regulatory Compliance in Defender for Cloud

- Pre-built compliance dashboards for: NIST SP 800-53, PCI DSS, ISO 27001, SOC 2, CIS Benchmarks, GDPR, HIPAA
- Shows pass/fail status for each control
- Allows downloading compliance reports (PDF)
- Custom initiatives can be added for internal standards

### Key Exam Points — Policy and Compliance
- **Deny** policy prevents non-compliant resources from being created
- **Audit** policy does NOT block anything — it only marks resources as non-compliant
- **DeployIfNotExists** is used for automatically deploying monitoring agents, diagnostic settings
- Policy assignments require an **identity** for DeployIfNotExists/Modify (managed identity)
- **Regulatory compliance** dashboard in Defender for Cloud is for compliance reporting, not real security enforcement

---

## 5. Microsoft Defender Plans (Workload Protection)

### Available Defender Plans

| Plan | Protects | Key Features |
|------|---------|-------------|
| **Defender for Servers P1** | Windows/Linux VMs, Arc servers | Defender for Endpoint integration, JIT VM Access (basic) |
| **Defender for Servers P2** | Windows/Linux VMs, Arc servers | All P1 + JIT VM Access (full), Vulnerability Assessment, File Integrity Monitoring |
| **Defender for Containers** | AKS, ACR, Arc-enabled Kubernetes | Image scanning, runtime protection, Kubernetes data plane hardening |
| **Defender for Storage** | Azure Storage accounts | Threat detection, malware scanning, sensitive data discovery |
| **Defender for SQL** | Azure SQL, SQL on VMs, SQL Managed Instance | Vulnerability assessment, ATP, anomaly detection |
| **Defender for App Service** | Azure App Service | Threat detection, suspicious activity alerts |
| **Defender for Key Vault** | Azure Key Vault | Unusual access pattern detection |
| **Defender for Resource Manager** | Azure Resource Manager | Unusual ARM operations, lateral movement detection |
| **Defender for DNS** | Azure DNS | Unusual DNS queries, DNS tunneling detection |
| **Defender CSPM** | All resources | Advanced posture features, attack path analysis, agentless scanning |
| **Defender for APIs** | Azure API Management | API threat detection, unused/unauthenticated API discovery |

### Defender for Servers Features

| Feature | Plan |
|---------|------|
| MDE integration (Windows/Linux) | P1 + P2 |
| JIT VM Access | P1 (limited) / P2 (full) |
| Adaptive application controls | P2 |
| File Integrity Monitoring (FIM) | P2 |
| Vulnerability assessment | P2 |
| Docker host hardening | P2 |
| Network map | P2 |

### Defender for Cloud — Attack Path Analysis

- Visualizes possible attack paths through your environment
- Shows how an attacker could move from internet-exposed resource to high-value data
- Identifies critical risks that require immediate attention
- Requires **Defender CSPM** plan

### Cloud Security Explorer

- Graphical query tool in Defender for Cloud
- Query relationships between resources (e.g., "VMs with public IPs + high severity vulnerabilities")
- Powered by the **Cloud Security Graph**
- Requires **Defender CSPM** plan

### Key Exam Points — Defender Plans
- Each Defender plan must be **enabled per subscription** — they are not global
- **Defender for Servers P2** includes **JIT VM Access** — P1 has limited JIT
- **Defender for Containers** scans ACR images for vulnerabilities (on push and on schedule)
- **Defender CSPM** plan is distinct from free foundational CSPM — adds attack path analysis
- **File Integrity Monitoring (FIM)** monitors changes to OS files and registry keys

---

## 6. Security Information and Event Management (SIEM)

### SIEM Core Capabilities

| Capability | Description |
|-----------|-------------|
| **Log collection** | Aggregate logs from multiple sources |
| **Normalization** | Parse and normalize log formats |
| **Correlation** | Identify relationships between events from different sources |
| **Detection** | Match events against known attack patterns (rules) |
| **Alerting** | Notify analysts of suspicious activity |
| **Investigation** | Tools to investigate alerts and trace attack paths |
| **Reporting** | Compliance and operational reports |

### SOAR (Security Orchestration, Automation, Response)

| Capability | Sentinel Implementation |
|-----------|------------------------|
| **Orchestration** | Logic Apps (Playbooks) coordinate actions across systems |
| **Automation** | Automation rules run automatically on incident creation |
| **Response** | Block IP, disable user, create ticket, send notification |

### Azure Sentinel vs Traditional SIEM

| Aspect | Traditional SIEM | Microsoft Sentinel |
|--------|-----------------|-------------------|
| **Infrastructure** | On-premises servers | Cloud-native (Azure) |
| **Scaling** | Manual, hardware-limited | Auto-scaling |
| **Cost model** | Large upfront + maintenance | Pay-per-GB ingested |
| **Updates** | Manual | Automatic |
| **ML/AI** | Limited | Built-in (Fusion, UEBA, Anomaly) |

### Key Exam Points — SIEM/SOAR
- Microsoft Sentinel is both a **SIEM** and a **SOAR** platform
- **Playbooks** (Logic Apps) are the SOAR component — they automate response actions
- Sentinel stores all data in **Log Analytics** — KQL is used for all queries
- **Fusion** is ML-based correlation that automatically creates high-fidelity incidents from multiple low-fidelity signals

---

## 7. Incident Response in Azure

### Incident Response Lifecycle

```
Preparation → Identification → Containment → Eradication → Recovery → Lessons Learned
```

### Azure-Native Incident Response Tools

| Tool | Use |
|------|-----|
| **Microsoft Sentinel** | Detection, investigation, response automation |
| **Defender for Cloud** | Alert triage, recommendation remediation |
| **Azure Monitor** | Log analysis, alert management |
| **Azure Activity Log** | Who did what, when, from where |
| **Entra ID Audit Logs** | Identity-related events |
| **Key Vault Audit Logs** | Secret/key access during breach investigation |
| **NSG Flow Logs** | Network traffic analysis |
| **Microsoft Defender for Endpoint** | Endpoint investigation and containment |

### Incident Containment Actions

| Threat Type | Containment Action |
|------------|-------------------|
| **Compromised VM** | Isolate VM (Defender for Endpoint), take snapshot, remove public IP |
| **Compromised account** | Disable account, revoke sessions, reset password, require re-register MFA |
| **Data exfiltration** | Block storage account public access, revoke SAS tokens |
| **Malicious network activity** | Add NSG rule to block source IP, enable Azure Firewall deny rule |
| **Compromised service principal** | Delete or rotate credentials immediately |

### Microsoft Defender for Endpoint Integration

- **Automated investigation and remediation (AIR)**: Automatically investigates alerts and takes remediation actions
- **Live response**: Remote shell access to endpoints for investigation
- **Device isolation**: Cuts off device from network while allowing Defender communication
- **Indicators of Compromise (IOC)**: Block specific file hashes, IPs, URLs at endpoint level

### Key Exam Points — Incident Response
- **Isolate** a compromised VM in Defender for Endpoint — preserves forensic data
- **Revoke all sessions** for a compromised account: `az ad user revoke-sessions`
- Activity Log is the first place to check for "who did what" during an incident
- **Sentinel incidents** aggregate related alerts — work incidents, not individual alerts
- Always **preserve evidence** before remediation (snapshots, memory dumps, log exports)

---

## 8. Key Exam Topics Checklist

### Must-Know for Domain 4

- [ ] Defender for Cloud CSPM (free) vs CWPP (paid Defender plans)
- [ ] Secure Score — what it measures and how it's calculated
- [ ] Microsoft Sentinel as both SIEM and SOAR
- [ ] Sentinel data connectors — types (1st party, CEF, REST API)
- [ ] KQL basics — where, project, summarize, order by
- [ ] Sentinel analytics rule types: Scheduled, NRT, Fusion, Microsoft Security
- [ ] Playbooks = Azure Logic Apps
- [ ] Automation rules vs Playbooks (automation rules are simpler/faster)
- [ ] Azure Monitor: metrics vs logs, action groups, alert types
- [ ] Log Analytics workspace — how to send diagnostic logs
- [ ] Activity Log default retention (90 days) — export to LA for longer
- [ ] Azure Policy effects: Deny, Audit, DeployIfNotExists, Modify
- [ ] Regulatory compliance dashboard — for reporting, not enforcement
- [ ] Defender for Servers P1 vs P2 differences (JIT, vulnerability assessment, FIM)
- [ ] Defender for Containers — image scanning + runtime protection
- [ ] Incident response actions for compromised VMs and accounts
- [ ] File Integrity Monitoring (FIM) — requires Defender for Servers P2
- [ ] UEBA — behavioral anomaly detection in Sentinel
- [ ] Attack Path Analysis — requires Defender CSPM plan

---

## 📖 Microsoft Learn Resources

- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Microsoft Sentinel documentation](https://learn.microsoft.com/en-us/azure/sentinel/overview)
- [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/overview)
- [Azure Policy overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [KQL quick reference](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
- [Microsoft Defender for Endpoint documentation](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/)

---

*← [Domain 3: Compute, Storage & Databases](03-compute-storage-databases.md) | [Practice Questions →](../practice-questions/practice-exam.md)*
