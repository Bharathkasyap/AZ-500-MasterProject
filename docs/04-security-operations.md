# Domain 4: Manage Security Operations (25–30%)

> **Back to:** [README](../README.md) | **Previous:** [Domain 3 — Compute, Storage, and Databases](03-compute-storage-databases.md)

---

## Table of Contents

1. [Microsoft Defender for Cloud](#1-microsoft-defender-for-cloud)
2. [Microsoft Sentinel (SIEM + SOAR)](#2-microsoft-sentinel-siem--soar)
3. [Azure Monitor and Log Analytics](#3-azure-monitor-and-log-analytics)
4. [Azure Policy and Regulatory Compliance](#4-azure-policy-and-regulatory-compliance)
5. [Incident Response and Investigation](#5-incident-response-and-investigation)
6. [Security Posture and Vulnerability Management](#6-security-posture-and-vulnerability-management)
7. [Key Exam Tips](#key-exam-tips)

---

## 1. Microsoft Defender for Cloud

### Overview
Microsoft Defender for Cloud (formerly Azure Security Center + Azure Defender) is a Cloud Security Posture Management (CSPM) and Cloud Workload Protection Platform (CWPP) for Azure, hybrid, and multi-cloud environments.

**Two core capabilities:**
| Capability | Description |
|-----------|-------------|
| **CSPM (Posture Management)** | Assess and improve security posture; secure score; recommendations; compliance |
| **CWPP (Workload Protection)** | Threat detection and protection for specific workload types (Defender plans) |

### Defender Plans
| Plan | Workload Protected |
|------|--------------------|
| Defender for Servers | VMs, VMSS, Arc-enabled servers |
| Defender for App Service | Azure App Service plans |
| Defender for Storage | Azure Storage accounts |
| Defender for SQL | Azure SQL, SQL on VMs, SQL Arc |
| Defender for Containers | ACR, AKS, Arc-enabled Kubernetes |
| Defender for Key Vault | Azure Key Vault |
| Defender for Resource Manager | ARM API layer |
| Defender for DNS | Azure DNS |
| Defender for APIs | Azure API Management APIs |
| Defender CSPM (enhanced) | Attack path analysis, CIEM, data security posture, agentless scanning |

**Foundational CSPM** (free): Basic recommendations, secure score, compliance dashboard

### Secure Score
- Score from 0–100%; higher = better posture
- Calculated: (points scored) / (maximum points) × 100
- Each security control has a max score; fixing all recommendations in a control awards its full points
- Tracked over time; exportable to Log Analytics for trending

### Security Recommendations
Actionable guidance to remediate security risks:
- **Severity:** High, Medium, Low
- **Quick Fix:** One-click remediation (supported recommendations)
- **Exemption:** Exclude a specific resource with justification (e.g., known risk accepted)
- **Enforce:** Apply recommendation via Azure Policy to enforce on new resources

### Security Alerts
Real-time threat detection notifications:
- **Severity:** High, Medium, Low, Informational
- **MITRE ATT&CK mapping:** Alerts tagged with MITRE tactics and techniques
- **Alert suppression rules:** Suppress false-positive alerts automatically
- **Export:** To Event Hub, Log Analytics, or Logic App for SOAR workflows

### Attack Path Analysis (Defender CSPM)
- Visualizes how an attacker could traverse from an internet-exposed entry point to a critical resource
- Uses graph-based analysis of the entire cloud environment
- Helps prioritize remediations that block the most attack paths

### Defender for Cloud — Multi-Cloud and Hybrid
- **AWS:** via Defender for Cloud AWS connector (requires CSPM/workload plans)
- **GCP:** via GCP connector
- **On-premises:** via Azure Arc (Arc-enabled servers, Kubernetes, SQL)

---

## 2. Microsoft Sentinel (SIEM + SOAR)

### What is Microsoft Sentinel?
A cloud-native **SIEM** (Security Information and Event Management) and **SOAR** (Security Orchestration, Automation, and Response) solution built on Azure Monitor / Log Analytics.

**SIEM:** Collects, correlates, and analyzes security data from across your environment  
**SOAR:** Automates response to security incidents via playbooks (Logic Apps)

### Architecture
```
Data Sources → Data Connectors → Log Analytics Workspace
                                           ↓
                                   Analytics Rules (detection)
                                           ↓
                                   Incidents (investigation)
                                           ↓
                                   Automation (SOAR / Playbooks)
```

### Data Connectors
Connect data sources to send logs to Sentinel:

| Connector Category | Examples |
|-------------------|---------|
| **Microsoft 1st party** | Defender for Cloud, Entra ID, Microsoft 365, Defender for Endpoint, Azure Activity |
| **Azure services** | Azure Firewall, NSG Flow Logs, Azure DDoS, WAF, AKS |
| **Third-party (CEF/Syslog)** | Cisco ASA, Palo Alto, F5, Fortinet via Log Analytics agent |
| **Third-party API** | AWS CloudTrail, Okta, Salesforce via REST API connectors |
| **Microsoft Sentinel solutions** | Pre-packaged data connectors + analytics rules + workbooks for specific products |

### Analytics Rules
Rules that detect suspicious activity in collected logs:

| Rule Type | Description |
|-----------|-------------|
| **Scheduled** | KQL query runs on a schedule; creates incidents from matching events |
| **Near real-time (NRT)** | KQL query runs almost in real-time (1-minute intervals) |
| **Microsoft security** | Auto-import incidents from other Microsoft security products (Defender for Cloud, MDE) |
| **Anomaly** | ML-based detection of unusual patterns |
| **Fusion** | ML-based multi-stage attack detection (correlates alerts from multiple products) |
| **Threat Intelligence** | Match IoCs from TI feeds against log data |

**KQL example — detect multiple failed logins:**
```kql
SigninLogs
| where ResultType != "0"
| summarize FailedAttempts = count() by UserPrincipalName, bin(TimeGenerated, 1h)
| where FailedAttempts > 10
| project TimeGenerated, UserPrincipalName, FailedAttempts
```

### Incidents
Incidents group related alerts into a single investigation unit:
- Created by analytics rules or imported from connected products
- **Severity:** High, Medium, Low, Informational
- **Status:** New → Active → Closed
- **Assignment:** Assign to an analyst
- **Investigation graph:** Visual map of related entities (users, IPs, hosts, URLs)

### Entity Behavior Analytics (UEBA)
- Builds a behavioral baseline for users, devices, and applications
- Detects anomalies against the baseline (UEBA)
- Assigns risk scores to users and entities
- Requires: Entra ID and/or Active Directory data connectors

### Threat Intelligence
- Import IoCs (IPs, domains, URLs, file hashes) from TAXII feeds, Microsoft TI, or custom TI platforms
- Automatically correlate IoCs against logs via threat intelligence analytics rules
- Visualize TI in the Threat Intelligence blade

### Playbooks (SOAR)
Logic Apps that automate response to Sentinel incidents or alerts:

**Common playbook actions:**
- Block user in Entra ID (disable account)
- Isolate VM via Defender for Endpoint
- Send Teams/email notification
- Create ServiceNow/Jira ticket
- Enrich alert with VirusTotal or threat intelligence
- Block IP in Azure Firewall or NSG

**Trigger types:**
- Incident trigger (recommended): run when an incident is created/updated
- Alert trigger: run on alert before incident creation
- Entity trigger: run ad-hoc from entity page

### Workbooks
Interactive dashboards built on Azure Monitor Workbooks framework:
- Pre-built workbooks for connectors (Azure Activity, Entra ID Sign-ins, AWS, etc.)
- Custom workbooks using KQL queries
- Use for SOC reporting and investigation dashboards

### Watchlists
Custom lookup lists for use in KQL queries and analytics rules:
- Upload CSV files (e.g., VIP user list, known bad IPs, service accounts)
- Reference in KQL: `_GetWatchlist('VIPUsers')`
- Use to correlate incoming alerts against context

### Sentinel Pricing
- Based on data ingestion volume (GB/day)
- Commitment tiers (reserved capacity) for cost optimization
- Data retention: 90 days free; longer retention charged
- Free data sources: Microsoft 365 Defender, Entra ID P1/P2, Azure Activity

---

## 3. Azure Monitor and Log Analytics

### Azure Monitor Components
```
Azure Monitor
├── Metrics (numerical time-series data; 93-day retention)
├── Logs (structured/unstructured log data in Log Analytics workspace)
├── Alerts
│   ├── Metric alerts
│   ├── Log alerts (KQL queries)
│   └── Activity log alerts
├── Insights (VM Insights, Container Insights, Application Insights, Network Insights)
└── Diagnostic Settings (route resource logs to storage, LA workspace, Event Hub)
```

### Log Analytics Workspace
- Central repository for log data
- Query with KQL (Kusto Query Language)
- Multiple Azure resources can send logs to a single workspace
- Sentinel is built on top of a Log Analytics workspace

### Important Log Tables (for Security)
| Table | Contents |
|-------|---------|
| `AzureActivity` | ARM operations (create, delete, update, start, stop) |
| `SigninLogs` | Entra ID interactive sign-ins |
| `AuditLogs` | Entra ID admin operations (user creation, role assignment, etc.) |
| `AzureFirewallNetworkRule` | Azure Firewall network rule matches |
| `AzureFirewallApplicationRule` | Azure Firewall application rule matches |
| `SecurityEvent` | Windows Security Event Log from VMs with MMA/AMA agent |
| `Syslog` | Linux syslog from VMs with MMA/AMA agent |
| `StorageBlobLogs` | Azure Storage access logs |
| `AzureDiagnostics` | Diagnostic logs from many Azure services |
| `SecurityAlert` | Security alerts from Defender for Cloud and Sentinel |
| `SecurityIncident` | Sentinel incidents |
| `KeyVaultLogs` / `AzureDiagnostics` | Key Vault audit events |

### Diagnostic Settings
Configure where resource logs are sent:
- **Log Analytics workspace:** For querying and Sentinel integration
- **Storage account:** Long-term archival/compliance
- **Event Hub:** Stream to SIEM, Splunk, or custom applications

**What can be configured with diagnostic settings:**
- Azure Firewall logs
- Key Vault audit events
- NSG flow logs (via Network Watcher)
- Azure SQL audit logs
- Activity Log (subscription-level)
- App Service HTTP access logs

### Azure Monitor Alerts
| Alert Type | Trigger |
|------------|---------|
| **Metric alerts** | When a metric crosses a threshold (CPU > 90%, request count, etc.) |
| **Log alerts** | KQL query returns results above a threshold |
| **Activity log alerts** | Specific operations in the Azure Activity Log |
| **Service health alerts** | Azure service outages/maintenance affecting your subscription |

**Action groups:** Define what happens when an alert fires:
- Email / SMS / voice call
- Webhook (call an HTTP endpoint)
- Logic App (trigger a workflow)
- Azure Function
- IT Service Management (ITSM) connector

### Azure Activity Log
- Records all **control plane** operations in your subscription
- Retention: 90 days (export to Log Analytics for longer retention)
- Critical events: role assignments, resource deletions, policy changes, resource lock changes
- Alert on: role assignment changes, resource deletions, VM start/stop/deallocate

---

## 4. Azure Policy and Regulatory Compliance

### Azure Policy
Azure Policy evaluates resources against rules and enforces compliance.

**Key concepts:**
| Concept | Description |
|---------|-------------|
| **Policy definition** | A single rule (e.g., "Storage accounts must use HTTPS only") |
| **Initiative (policy set)** | A collection of policy definitions for a common goal |
| **Assignment** | Apply a policy/initiative to a scope (management group, subscription, RG) |
| **Compliance** | Percentage of resources compliant with assigned policies |
| **Remediation task** | Fix non-compliant resources automatically (for `deployIfNotExists` / `modify` policies) |

### Policy Effects (in priority order)
| Effect | When Applied | Description |
|--------|-------------|-------------|
| `Disabled` | N/A | Policy is turned off |
| `Append` | Before resource creation/update | Add fields to resource request |
| `Modify` | Before resource creation/update | Add/update/remove resource tags |
| `Audit` | After resource creation | Log non-compliant resources; no blocking |
| `AuditIfNotExists` | After resource creation | Audit if a related resource is missing |
| `Deny` | Before resource creation/update | Block non-compliant resource operations |
| `DeployIfNotExists` | After resource creation | Deploy a related resource if it doesn't exist |
| `DenyAction` | During specific actions | Block specific action types (e.g., delete) |

### Built-in Initiatives (Regulatory Compliance)
| Initiative | Standard |
|-----------|---------|
| Microsoft Cloud Security Benchmark | Azure best practices (replaces Azure Security Benchmark) |
| CIS Microsoft Azure Foundations Benchmark | Center for Internet Security |
| NIST SP 800-53 | US federal government standard |
| ISO 27001:2013 | International security management standard |
| PCI DSS | Payment Card Industry standard |
| HIPAA/HITRUST | Healthcare data protection |
| FedRAMP | US federal cloud security |

### Regulatory Compliance Dashboard (Defender for Cloud)
- Maps Defender for Cloud recommendations to compliance controls
- Shows compliance score per standard
- Generates audit-ready compliance reports
- Tracks remediation progress

### Azure Blueprints (Legacy — now Deployment Environments)
- Package policy assignments, RBAC assignments, ARM templates into a deployable unit
- Applied to subscriptions; creates deny assignments (enforced RBAC)
- **Note:** Azure Blueprints is being deprecated in favor of Azure Deployment Environments and template specs

### Resource Locks
Prevent accidental deletion or modification of resources:
| Lock Level | Effect |
|-----------|--------|
| **CanNotDelete** | Read and modify are allowed; delete is blocked |
| **ReadOnly** | Only read operations allowed; all write and delete blocked |

Locks apply to ALL principals including Owner role (cannot be overridden by role assignment).

---

## 5. Incident Response and Investigation

### Incident Response Process (NIST SP 800-61)
```
Preparation → Detection & Analysis → Containment, Eradication & Recovery → Post-Incident Activity
```

### Sentinel Investigation Workflow
1. **Triage:** Review new incident; assess severity, assign to analyst
2. **Enrich:** Add context — run playbooks to enrich entities (user, IP, host info)
3. **Investigate:** Use investigation graph; query related logs in Log Analytics
4. **Contain:** Isolate affected systems, block users/IPs
5. **Eradicate:** Remove malicious artifacts, remediate vulnerabilities exploited
6. **Recover:** Restore systems from clean backups, verify normal operations
7. **Close:** Document findings, update playbooks, tune analytics rules

### Containment Actions via Sentinel Playbooks
| Threat | Automated Response |
|--------|-------------------|
| Compromised user account | Disable Entra ID account; revoke sessions via `revokeSignInSessions` |
| Compromised VM | Isolate VM via MDE: `restrictCodeExecution` |
| Malicious IP | Add to Azure Firewall deny rule or NSG deny rule |
| Malicious email | Soft-delete email via Microsoft 365 Defender |
| Risky sign-in | Force MFA via Identity Protection; require password change |

### Evidence Collection and Chain of Custody
- **Disk snapshot:** Create a snapshot of the OS disk before remediation
- **Memory dump:** Use Azure VM Run Command or Defender for Endpoint live response
- **Log preservation:** Export relevant logs to a dedicated storage account
- **Audit trail:** All Defender for Cloud and Sentinel actions logged in Azure Activity

### Threat Hunting
Proactive search for threats not yet detected by automated rules:
- Use **Sentinel Hunting** queries (KQL) across all data sources
- Create bookmarks on suspicious findings for tracking
- Convert bookmarks to incidents for formal investigation
- Use MITRE ATT&CK matrix as hunting framework

**Example hunting query — detect PowerShell encoded commands:**
```kql
SecurityEvent
| where EventID == 4688
| where CommandLine contains "-EncodedCommand" or CommandLine contains "-enc "
| project TimeGenerated, Computer, Account, CommandLine, ParentProcessName
| order by TimeGenerated desc
```

### Live Response (Defender for Endpoint)
Allows analysts to connect to a compromised machine remotely for investigation:
- Run scripts and commands on the machine
- Upload/download files
- Collect forensic data
- Isolate the machine from the network

---

## 6. Security Posture and Vulnerability Management

### Vulnerability Assessment Options (Defender for Servers)
| Option | Description |
|--------|-------------|
| **Microsoft Defender Vulnerability Management (MDVM)** | Integrated with Defender for Endpoint; no agent needed |
| **Qualys** | Third-party scanner deployed via Defender for Servers Plan 2 |
| **Custom vulnerability scanner** | Bring your own Qualys or Rapid7 license |

### Agentless Scanning (Defender CSPM / Defender for Servers Plan 2)
- Scans VMs without installing an agent
- Takes disk snapshots and analyzes them
- Finds: OS vulnerabilities, installed software, sensitive data, misconfigurations

### Cloud Security Explorer (Defender CSPM)
- Graph-based query interface for the security knowledge graph
- Run queries like: "Show me all internet-exposed VMs with high severity vulnerabilities AND running as admin"
- Helps identify complex attack paths

### Security Benchmark and Baseline
- **Microsoft Cloud Security Benchmark (MCSB):** Replaces Azure Security Benchmark
- Mapped to CIS, NIST, PCI standards
- 12 security domains: Network Security, Identity Management, Privileged Access, Data Protection, etc.

### Microsoft Secure Score (Microsoft 365 Defender)
Similar to Defender for Cloud's Secure Score but focused on Microsoft 365 security:
- Microsoft 365, Entra ID, Defender for Endpoint, Defender for Identity
- Compare with industry and organization size peers
- Improvement actions tied to specific security controls

---

## Key Exam Tips

1. **Sentinel vs. Defender for Cloud:** Defender for Cloud is CSPM/CWPP (recommendations + alerts). Sentinel is SIEM/SOAR (collect all logs, detect, investigate, respond). They are complementary — Defender for Cloud feeds alerts into Sentinel.

2. **KQL is essential for the exam.** Know basic syntax: `where`, `summarize`, `project`, `extend`, `join`, `bin()`. Common tables: `SigninLogs`, `AzureActivity`, `SecurityEvent`, `AuditLogs`.

3. **Analytics rule types:** Scheduled (KQL on schedule), NRT (near-real-time), Fusion (ML multi-stage), Anomaly (ML baseline). Know which to use in which scenario.

4. **Playbooks use Logic Apps.** When the exam asks "automate response to a Sentinel incident," the answer is a Logic App triggered by a Sentinel automation rule.

5. **Diagnostic settings ≠ Data connectors.** Diagnostic settings route Azure resource logs to a Log Analytics workspace. Sentinel Data Connectors configure Sentinel to use that workspace AND enable additional parsing/analytics for specific services.

6. **Azure Policy `Deny` effect** blocks resource creation. `Audit` effect logs non-compliance but doesn't block. `DeployIfNotExists` automatically remediates (deploys a related resource).

7. **Resource locks** override even the Owner role — no one can delete a resource with a CanNotDelete lock unless they first remove the lock. Removing a lock requires `Microsoft.Authorization/locks/delete` permission.

8. **Activity Log = control plane operations.** For data plane (who read which secret, who accessed which file), you need resource-specific diagnostic logs (Key Vault diagnostics, Storage access logs, etc.).

9. **UEBA requires data connectors.** Entity behavior analytics in Sentinel needs Entra ID sign-in logs and/or Windows Security Events to build behavioral baselines. Just enabling UEBA without connectors provides limited value.

10. **Threat hunting bookmarks** — when you find something suspicious during hunting, bookmark it. Bookmarks can be converted to incidents for formal tracking without creating an automated rule.

---

> **Previous:** [Domain 3 — Compute, Storage, and Databases](03-compute-storage-databases.md) | **Next:** [Practice Questions →](practice-questions.md)
