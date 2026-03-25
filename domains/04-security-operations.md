# Domain 4 — Manage Security Operations (25–30%)

> **Exam weight:** 25–30% of the total score (~15–18 questions out of 60)

---

## Table of Contents

1. [Microsoft Defender for Cloud](#1-microsoft-defender-for-cloud)
2. [Azure Security Benchmark & Secure Score](#2-azure-security-benchmark--secure-score)
3. [Microsoft Defender Plans (Workload Protection)](#3-microsoft-defender-plans-workload-protection)
4. [Microsoft Sentinel](#4-microsoft-sentinel)
5. [Azure Monitor & Log Analytics](#5-azure-monitor--log-analytics)
6. [Azure Policy & Governance](#6-azure-policy--governance)
7. [Security Alerts & Incident Response](#7-security-alerts--incident-response)
8. [Key Exam Points](#key-exam-points)

---

## 1. Microsoft Defender for Cloud

Microsoft Defender for Cloud (formerly Azure Security Center) provides two pillars:

| Pillar | Description |
|--------|-------------|
| **CSPM** (Cloud Security Posture Management) | Assess, visualize, and harden security posture — **Secure Score** |
| **CWP** (Cloud Workload Protection) | Detect and respond to active threats — **Defender plans** |

### Tiers
| Tier | Features | Cost |
|------|---------|------|
| **Foundational CSPM** | Basic recommendations, Secure Score | Free |
| **Defender CSPM** | Attack path analysis, Cloud Security Explorer, governance, agentless scanning | Per resource |
| **Defender Plans** | Threat detection per resource type | Per resource/hour |

### Coverage
- **Azure** resources (native)
- **AWS** and **GCP** (multi-cloud via connectors)
- **On-premises** (via Azure Arc)

---

## 2. Azure Security Benchmark & Secure Score

### Azure Security Benchmark (ASB)
- Microsoft's recommended set of security controls.
- Based on industry standards: CIS Controls, NIST SP 800-53.
- Used as the default compliance standard in Defender for Cloud.
- Organized into control domains (Network Security, Identity Management, Privileged Access, etc.).

### Secure Score

```
Secure Score = (Sum of points earned) / (Sum of max points) × 100
```

- Each recommendation belongs to a **security control**.
- All recommendations in a control must be completed to earn the control's points.
- Higher Secure Score = better security posture.

### Recommendations
Each recommendation includes:
- **Severity**: High, Medium, Low, Informational
- **Affected resources**: Unhealthy, Healthy, Not applicable
- **Quick fix**: One-click remediation for eligible resources
- **Remediation steps**: Manual guidance
- **Policy**: Underlying Azure Policy definition

### Regulatory Compliance Dashboard
- Map your Defender for Cloud controls to compliance standards (PCI DSS, ISO 27001, SOC 2, HIPAA, etc.).
- Add custom compliance standards.

---

## 3. Microsoft Defender Plans (Workload Protection)

### Available Defender Plans
| Plan | Protects | Key Capabilities |
|------|---------|-----------------|
| **Defender for Servers P1** | Azure/Arc VMs | JIT VM access, Adaptive application controls, endpoint integration |
| **Defender for Servers P2** | Azure/Arc VMs | Everything in P1 + Defender for Endpoint, file integrity monitoring, OS baselines, network map |
| **Defender for App Service** | Azure App Service | Detects attacks on web apps, dangling DNS |
| **Defender for Storage** | Blob, Files, ADLS | Detects malware uploads, suspicious access, data exfiltration |
| **Defender for SQL** | Azure SQL, SQL Server on VMs | SQL injection detection, vulnerability assessment |
| **Defender for Cosmos DB** | Azure Cosmos DB | Anomalous access, SQL injection in NoSQL |
| **Defender for Containers** | AKS, ACR, Arc-enabled K8s | Image scanning, runtime threat detection, K8s control plane alerts |
| **Defender for Key Vault** | Azure Key Vault | Unusual access patterns, lateral movement alerts |
| **Defender for Resource Manager** | ARM operations | Detect suspicious ARM API usage, exploitation of automation accounts |
| **Defender for DNS** | Azure DNS resolver | Detect DNS-based attacks, data exfiltration via DNS |
| **Defender CSPM** | All resources | Agentless scanning, attack path analysis, cloud security explorer |

### Adaptive Application Controls
- Machine-learning-based allowlist of processes that should run on VMs.
- Alerts when unlisted processes are detected.
- Operates in **Audit** or **Enforce** mode.

### File Integrity Monitoring (FIM)
- Monitors files, directories, and registry keys for unexpected changes.
- Requires Log Analytics agent.
- Powered by Azure Change Tracking solution.

### Adaptive Network Hardening
- Analyzes actual traffic patterns vs. NSG rules.
- Recommends tighter NSG rules based on real usage.
- Machine-learning powered.

---

## 4. Microsoft Sentinel

Microsoft Sentinel is a cloud-native **SIEM** (Security Information and Event Management) and **SOAR** (Security Orchestration, Automation, and Response) platform.

### Architecture
```
Data Sources (connectors)
     ↓
Log Analytics Workspace (data lake)
     ↓
Analytics Rules (detect threats)
     ↓
Incidents (correlated alerts)
     ↓
Playbooks (automated response via Logic Apps)
```

### Data Connectors
| Category | Examples |
|----------|---------|
| **Microsoft services** | Entra ID (sign-in/audit logs), Office 365, Defender for Cloud, Defender for Endpoint |
| **Azure services** | Azure Activity, Azure Firewall, NSG Flow Logs |
| **Partner connectors** | Palo Alto, Cisco, F5, Fortinet |
| **Generic formats** | CEF (Common Event Format), Syslog, REST API |
| **Threat intelligence** | STIX/TAXII feeds, Microsoft TI |

### Analytics Rule Types
| Type | Description |
|------|-------------|
| **Microsoft Security** | Forward alerts from Defender for Cloud, MDE, etc. as Sentinel incidents |
| **Scheduled** | KQL query run on a schedule; creates alerts on match |
| **ML Behavioral Analytics** | Microsoft ML models detect anomalies (requires P2) |
| **Anomaly** | Detect deviations from baseline (UEBA) |
| **Fusion** | Correlate multiple low-fidelity alerts into high-confidence incidents |
| **Near Real-Time (NRT)** | Run every minute; lower latency than scheduled rules |

### KQL — Key Queries for AZ-500

```kql
// Failed sign-ins
SigninLogs
| where ResultType != "0"
| summarize FailureCount = count() by UserPrincipalName, ResultDescription
| order by FailureCount desc

// Successful sign-ins from risky IPs
SigninLogs
| where RiskLevelDuringSignIn in ("high", "medium")
| project TimeGenerated, UserPrincipalName, IPAddress, Location, RiskDetail

// Azure activity — privilege escalation
AzureActivity
| where OperationNameValue contains "roleAssignments/write"
| project TimeGenerated, Caller, ResourceGroup, Properties

// Key Vault access
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName in ("SecretGet", "KeyDecrypt")
| project TimeGenerated, Resource, CallerIPAddress, identity_claim_oid_g
```

### Playbooks (SOAR)
- Built on **Azure Logic Apps**.
- Triggered by Sentinel incidents or alerts.
- Common actions:
  - Send email or Teams notification.
  - Block IP in NSG or firewall.
  - Disable a user account.
  - Create a ServiceNow/Jira ticket.
  - Run an Azure Automation Runbook.

### Entity Behavior Analytics (UEBA)
- Builds behavioral baselines for users, hosts, and IPs.
- Detects deviations (lateral movement, impossible travel, after-hours access).
- Requires enabling UEBA in Sentinel and connecting Entra ID.

### Threat Intelligence
- Import IoCs (Indicators of Compromise) from:
  - TAXII servers
  - Microsoft Threat Intelligence
  - Flat file upload
- Correlate IoCs against log data using TI analytics rules.

### Workbooks
- Interactive dashboards built on Azure Monitor Workbooks.
- Built-in templates: Overview, Identity & Access, Azure Activity, Microsoft Entra ID.

---

## 5. Azure Monitor & Log Analytics

### Azure Monitor Components
```
Data Sources
  ├── Metrics (time-series numeric data)
  └── Logs (text/structured records in Log Analytics)
        ↓
Analysis & Visualization
  ├── Metrics Explorer (charts)
  ├── Log Analytics (KQL queries)
  ├── Workbooks (dashboards)
  └── Dashboards

Alerts & Actions
  ├── Alert Rules (metric, log, activity log)
  └── Action Groups (email, SMS, webhook, ITSM, Logic App)
```

### Diagnostic Settings
- Configure where to send resource logs and metrics.
- Destinations:
  - **Log Analytics workspace** (queryable; Sentinel source)
  - **Storage Account** (archival; compliance)
  - **Event Hub** (stream to SIEM/SOAR)

> **Exam tip:** To send logs to **Microsoft Sentinel**, configure diagnostic settings to send to the **Log Analytics workspace** connected to Sentinel.

### Activity Log
- Records subscription-level events (management plane operations).
- Who did what, when, from where.
- Retained 90 days by default; send to Log Analytics/Storage for longer retention.
- Key for: detecting role assignment changes, resource deletions, policy changes.

### Azure Monitor Agent (AMA)
- Replacement for Log Analytics agent (MMA) and Diagnostics extension.
- Configured via **Data Collection Rules (DCRs)**.
- Collects: Windows Event Log, Performance counters, Syslog, custom text logs.

---

## 6. Azure Policy & Governance

### Azure Policy
- Enforces organizational standards and assesses compliance at scale.
- Evaluated at resource creation/update and on an ongoing basis.

### Policy Effects (in order of restrictiveness)
| Effect | Description |
|--------|-------------|
| **Disabled** | Policy not evaluated |
| **Audit** | Logs non-compliant resources; no enforcement |
| **AuditIfNotExists** | Audits if a related resource doesn't exist |
| **Modify** | Add or modify resource properties |
| **Append** | Append fields to resources during creation |
| **DeployIfNotExists** | Deploy a related resource if it doesn't exist |
| **Deny** | Block non-compliant resource creation/update |

### Policy Initiatives
- A collection of policies grouped together.
- Also called **Policy Sets**.
- Example: "Enable Azure Monitor for VMs" initiative deploys agents and sets diagnostic settings.
- **ASB initiative** is assigned by default in Defender for Cloud.

### Management Groups
```
Root Management Group (tenant)
  ├── Management Group: Corp
  │     ├── Subscription: Prod
  │     └── Subscription: Dev
  └── Management Group: External
        └── Subscription: Partner
```

- Policies assigned at a management group apply to **all subscriptions** beneath it.
- Up to 6 levels of management group hierarchy.
- A subscription can only be in **one** management group at a time.

### Policy Compliance
- Compliance state is evaluated every 24 hours.
- Trigger on-demand: `az policy state trigger-scan`
- Non-compliant resources appear in Defender for Cloud recommendations.

### Azure Blueprints (being deprecated in favor of Bicep/Policy)
- Package of policies, RBAC, and ARM templates into a repeatable bundle.
- Assigned to subscriptions; locked resources protect governance artifacts.
- Lock modes: **Don't Lock**, **Do Not Delete**, **Read Only**.

---

## 7. Security Alerts & Incident Response

### Defender for Cloud Alerts
- Each alert has: **severity**, **description**, **affected resource**, **recommended steps**.
- Alert severity: **High, Medium, Low, Informational**.
- Suppress alerts: create suppression rules for known false positives.
- Export alerts: to SIEM (Event Hub), SOAR (Logic App), or ITSM.

### Alert Workflow
```
Threat Detected
    ↓
Alert Generated (Defender for Cloud)
    ↓
Alert forwarded to Sentinel (via connector)
    ↓
Analytics rule correlates alerts → Incident created
    ↓
Analyst triages Incident
    ↓
Playbook auto-responds (or analyst manually responds)
    ↓
Incident closed with classification (True Positive / False Positive / etc.)
```

### Incident Classification
| Classification | Sub-Classification | Meaning |
|---------------|-------------------|---------|
| True Positive | — | Real attack; legitimate alert |
| False Positive | Inaccurate data | Alert triggered incorrectly |
| False Positive | Incorrect alert logic | Rule logic is wrong |
| Benign True Positive | — | Real but authorized activity |
| Undetermined | — | Cannot determine |

### Security Incident Response Process (NIST)
1. **Preparation** — policies, playbooks, training.
2. **Detection & Analysis** — identify and confirm the incident.
3. **Containment** — limit the damage scope.
4. **Eradication** — remove the threat.
5. **Recovery** — restore systems; validate.
6. **Post-Incident Activity** — lessons learned, improve defenses.

---

## Key Exam Points

- [ ] **Secure Score** increases when you remediate **entire security controls**, not individual recommendations.
- [ ] **Defender for Servers P2** is required for Defender for Endpoint integration and file integrity monitoring.
- [ ] **JIT VM Access** is in **Defender for Servers P1** (not P2).
- [ ] **Microsoft Security analytics rules** in Sentinel forward alerts from Defender for Cloud — don't confuse with scheduled rules.
- [ ] **Fusion rules** in Sentinel correlate multiple low-fidelity signals into high-confidence incidents.
- [ ] **UEBA** in Sentinel builds behavioral baselines and detects anomalies — requires enabling separately.
- [ ] **Playbooks** are Logic Apps — they can be triggered automatically or run manually.
- [ ] **Activity Log** records management plane events; **Diagnostic Logs** record data/resource plane events.
- [ ] **Azure Policy Deny** effect prevents resource creation; **Audit** only logs non-compliance.
- [ ] **DeployIfNotExists** is the effect used to auto-install agents (e.g., Log Analytics agent on VMs).
- [ ] Know the difference between **Defender for Cloud** (CSPM + CWP) and **Microsoft Sentinel** (SIEM + SOAR).
- [ ] **Export** Defender for Cloud alerts to Sentinel via the Microsoft Defender for Cloud connector.
