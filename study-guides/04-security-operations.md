# Domain 4: Manage Security Operations (25–30%)

> **Back to [README](../README.md)**

---

## Overview

Security Operations covers Microsoft Defender for Cloud, Microsoft Sentinel, security monitoring, incident response, compliance management, and security posture management. This is the highest-weighted domain in the AZ-500 exam.

---

## 4.1 Plan, Implement, and Manage Microsoft Defender for Cloud

### Overview

Microsoft Defender for Cloud is a **Cloud Security Posture Management (CSPM)** and **Cloud Workload Protection Platform (CWPP)** service that:
- Provides a **Secure Score** to measure security posture
- Detects and responds to threats
- Ensures regulatory compliance
- Protects multicloud and hybrid environments

### Defender for Cloud Plans

| Plan | Description |
|---|---|
| **Foundational CSPM** (Free) | Basic security recommendations, Secure Score |
| **Defender CSPM** (Paid) | AI attack paths, risk prioritization, governance, data security posture |
| **Defender for Servers** | Threat detection, vulnerability management, JIT, FIM |
| **Defender for Storage** | Malware scanning, anomaly detection |
| **Defender for SQL** | Vulnerability assessment, threat detection |
| **Defender for Containers** | Kubernetes threat detection, image scanning |
| **Defender for App Service** | App threat detection |
| **Defender for Key Vault** | Unusual access detection |
| **Defender for DNS** | DNS layer threat detection |
| **Defender for Resource Manager** | ARM-level threat detection |

### Secure Score

Secure Score is a percentage indicating how well your environment aligns with Microsoft's security recommendations.

- Higher score = better security posture
- Calculated as: `(Points achieved / Total potential points) × 100`
- Each recommendation has a **Max Score impact**

```
Defender for Cloud → Overview → Secure Score → Recommendations
  → Filter by category, severity, environment
  → Click recommendation → View affected resources → Remediate
```

### Security Policies and Regulatory Compliance

Defender for Cloud maps recommendations to compliance frameworks:
- **Microsoft Cloud Security Benchmark (MCSB)** — Default initiative
- CIS Microsoft Azure Foundations Benchmark
- PCI DSS 4.0
- ISO 27001:2013
- NIST SP 800-53 Rev 5
- SOC 2 Type 2

```
Defender for Cloud → Regulatory Compliance → Add standards
  → Select framework → Review controls and their compliance status
```

### Enable Defender Plans — Azure CLI

```bash
# Enable Defender for Servers Plan 2
az security pricing create \
  --name VirtualMachines \
  --tier Standard

# Enable Defender for Storage
az security pricing create \
  --name StorageAccounts \
  --tier Standard

# Enable Defender for SQL (Azure SQL)
az security pricing create \
  --name SqlServers \
  --tier Standard

# Enable Defender for Containers
az security pricing create \
  --name Containers \
  --tier Standard
```

### Security Alerts

Security alerts are triggered by Defender for Cloud when threats are detected:

| Alert Category | Example |
|---|---|
| **Virtual Machine** | Unusual process execution, credential dumping |
| **Storage** | Access from Tor IP, unusual data transfer |
| **SQL** | SQL injection attempt, brute force |
| **Key Vault** | High volume of operations, access from suspicious IP |
| **Kubernetes** | Privileged container creation, cryptomining |
| **Network** | Suspicious outbound traffic, port scanning |

```
Defender for Cloud → Security Alerts → Filter by severity/resource
  → Click alert → View affected resources, attack story, evidence
  → Take action: suppress, trigger logic app, export to Sentinel
```

### Workflow Automation

Automate responses to security alerts and recommendations:

```
Defender for Cloud → Workflow automation → Add workflow automation
  → Trigger: Security alert (specific severity) or Recommendation
  → Action: Azure Logic App (e.g., send Teams notification, create ticket)
```

---

## 4.2 Plan and Implement Microsoft Sentinel

### Overview

Microsoft Sentinel is a **cloud-native SIEM (Security Information and Event Management)** and **SOAR (Security Orchestration, Automation, and Response)** solution.

| SIEM Capability | Description |
|---|---|
| **Data Collection** | Connect to Azure, Microsoft 365, and third-party sources |
| **Analytics** | Rules to detect threats in collected data |
| **Incidents** | Group related alerts for investigation |
| **Workbooks** | Visualize security data |
| **Hunting** | Proactively search for threats |

| SOAR Capability | Description |
|---|---|
| **Playbooks** | Logic Apps triggered by alerts/incidents |
| **Automation Rules** | Automatically triage, assign, and close incidents |

### Enable Microsoft Sentinel

```bash
# Create Log Analytics Workspace (Sentinel requires one)
az monitor log-analytics workspace create \
  --resource-group myRG \
  --workspace-name mySentinelWorkspace \
  --location eastus

# Enable Sentinel on the workspace
az sentinel workspace create \
  --resource-group myRG \
  --workspace-name mySentinelWorkspace
```

### Data Connectors

Sentinel collects data through **Data Connectors**:

| Connector Category | Examples |
|---|---|
| **Microsoft Services** | Entra ID, Microsoft Defender XDR, Office 365, Defender for Cloud |
| **Azure Platform** | Azure Activity, Azure Firewall, NSG Flow Logs |
| **Third-party SIEM/Firewall** | Palo Alto, Fortinet, Check Point, Cisco |
| **Custom** | Syslog, CEF, REST API, Azure Event Hub |

```
Sentinel → Configuration → Data connectors → Search → Connect
```

### Analytics Rules

Sentinel analytics rules create incidents from data:

| Rule Type | Description |
|---|---|
| **Scheduled** | KQL query runs on a schedule; triggers alert when results found |
| **NRT (Near Real Time)** | Query runs every minute with minimal delay |
| **Fusion** | ML-based multi-stage attack detection (auto-enabled) |
| **Anomaly** | ML-based behavioral anomaly detection |
| **Threat Intelligence** | Match logs against TI feeds |
| **Microsoft Security** | Import alerts from Defender products |

#### Example KQL — Scheduled Analytics Rule

```kql
// Detect multiple failed sign-ins followed by success (password spray)
let failureThreshold = 10;
let successWindow = 10m;
SigninLogs
| where ResultType != "0"  // Failed sign-ins
| summarize FailureCount = count() by UserPrincipalName, bin(TimeGenerated, 1h)
| where FailureCount >= failureThreshold
| join kind=inner (
    SigninLogs
    | where ResultType == "0"  // Successful sign-ins
) on UserPrincipalName
| where TimeGenerated1 > TimeGenerated and TimeGenerated1 < TimeGenerated + successWindow
| project UserPrincipalName, FailureCount, SuccessTime = TimeGenerated1
```

### KQL (Kusto Query Language) Essentials

```kql
// Basic structure
TableName
| where TimeGenerated > ago(24h)
| where column == "value"
| project column1, column2, column3
| summarize count() by column1
| order by count_ desc
| take 10

// Key operators
// where    — filter rows
// project  — select columns
// extend   — add computed columns
// summarize — aggregate
// join     — join tables
// union    — combine tables
// parse    — extract fields from strings
// mv-expand — expand multi-value fields
// render   — visualize (barchart, timechart, piechart)

// Common tables
// SigninLogs — Entra ID sign-in logs
// AuditLogs — Entra ID audit logs
// SecurityAlert — Defender alerts
// SecurityIncident — Sentinel incidents
// AzureActivity — Azure subscription activity
// CommonSecurityLog — CEF format logs
// Syslog — Linux syslog
// OfficeActivity — Microsoft 365 activity
// AzureNetworkAnalytics_CL — NSG flow logs
```

### Workbooks

Sentinel workbooks provide interactive visualizations:

```
Sentinel → Threat management → Workbooks → Templates → Save → View saved workbook
```

Popular template workbooks:
- **Azure AD Sign-in logs** — Authentication patterns
- **Azure Activity** — Subscription-level activity
- **Insecure Protocols** — Legacy authentication usage
- **Microsoft Defender for Cloud Alerts** — Threat dashboard

### Hunting

Proactive threat hunting using KQL queries:

```
Sentinel → Threat management → Hunting → + New query
  → Write KQL query → Run → Bookmark interesting results
  → Create incident from bookmarks
```

### Playbooks (SOAR)

Playbooks are Logic Apps triggered by Sentinel incidents:

```
Sentinel → Configuration → Automation → Create → Playbook
  → Use Logic App designer
  → Trigger: "When a Microsoft Sentinel incident is created"
  → Actions: Send email / Post Teams message / Block IP in NSG / Create ServiceNow ticket
```

#### Automation Rules

```
Sentinel → Configuration → Automation → Automation rules → + Create
  → Trigger: Incident created / Incident updated
  → Conditions: Analytic rule name, severity, tactics
  → Actions: Assign owner, change severity, close incident, run playbook
```

---

## 4.3 Configure and Manage Security Monitoring and Automation

### Azure Monitor

Azure Monitor is the core platform for collecting, analyzing, and acting on telemetry data from Azure and on-premises environments.

| Component | Description |
|---|---|
| **Metrics** | Numerical time-series data (CPU %, requests/sec) |
| **Logs** | Structured/unstructured event data in Log Analytics |
| **Alerts** | Notify when conditions are met |
| **Action Groups** | Define notification/automation actions for alerts |
| **Diagnostic Settings** | Route resource logs to Storage, Event Hub, or Log Analytics |

#### Create a Security Alert — Azure CLI

```bash
# Create action group
az monitor action-group create \
  --name mySecurityActionGroup \
  --resource-group myRG \
  --short-name SecAlerts \
  --email-receivers name=SecurityTeam email=security@contoso.com

# Create alert rule (example: detect deletion of Key Vault)
az monitor activity-log alert create \
  --name KeyVaultDeletionAlert \
  --resource-group myRG \
  --scope /subscriptions/<sub-id> \
  --condition "category=Administrative and operationName=Microsoft.KeyVault/vaults/delete" \
  --action-group mySecurityActionGroup
```

### Log Analytics Workspace

All security logs flow into Log Analytics Workspace (the foundation for Sentinel and Defender for Cloud).

```bash
# Create workspace
az monitor log-analytics workspace create \
  --resource-group myRG \
  --workspace-name mySecurityWorkspace \
  --location eastus \
  --sku PerGB2018 \
  --retention-time 90

# Connect to Defender for Cloud
az security workspace-setting create \
  --name default \
  --target-workspace /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.OperationalInsights/workspaces/mySecurityWorkspace
```

### Azure Policy for Security Automation

Azure Policy enforces organizational standards and assessments at scale.

| Effect | Description |
|---|---|
| **Deny** | Prevent non-compliant resources from being created |
| **Audit** | Log non-compliant resources (no blocking) |
| **AuditIfNotExists** | Log if a related resource doesn't exist |
| **DeployIfNotExists** | Automatically deploy required configurations |
| **Modify** | Change resource properties to achieve compliance |
| **Append** | Add fields to a resource |

```bash
# Assign a built-in policy to require TLS 1.2 for SQL
az policy assignment create \
  --name RequireTLS12ForSQL \
  --policy "32e6bbec-16b5-49ce-af71-fb03b76c0085" \  # Built-in policy ID
  --scope /subscriptions/<sub-id> \
  --enforcement-mode Default

# Check compliance
az policy state list \
  --resource /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.Sql/servers/mySQLServer \
  --query "[].complianceState"
```

### Microsoft Defender External Attack Surface Management (EASM)

EASM discovers and maps your organization's internet-facing attack surface:
- Discovers unknown assets (shadow IT)
- Identifies vulnerabilities in internet-facing resources
- Monitors for changes in your attack surface

---

## 4.4 Investigate and Respond to Security Incidents

### Incident Response in Sentinel

**Incident Lifecycle in Sentinel:**

```
Data collected → Analytics rule fires → Alert created → Incident created
  → Assigned to analyst → Investigation → Containment → Evidence collected
  → Incident closed (True Positive / False Positive / Benign Positive)
```

#### Investigate an Incident

```
Sentinel → Threat management → Incidents → Open incident
  → Overview: Entity list, severity, tactics (MITRE ATT&CK), timeline
  → Investigation graph: Visualize entity relationships
  → Entities: Users, IPs, hosts, URLs involved
  → Comments: Log investigation notes
  → Tasks: Assign investigation steps
  → Activity log: Audit trail of all actions
```

### MITRE ATT&CK Framework

Sentinel maps detections to **MITRE ATT&CK tactics**:

| Tactic | Description |
|---|---|
| Reconnaissance | Information gathering |
| Resource Development | Setting up attack infrastructure |
| Initial Access | Gaining first foothold (phishing, exploit) |
| Execution | Running malicious code |
| Persistence | Maintaining access across reboots |
| Privilege Escalation | Gaining higher permissions |
| Defense Evasion | Avoiding detection |
| Credential Access | Stealing credentials |
| Discovery | Mapping the environment |
| Lateral Movement | Moving through the network |
| Collection | Gathering data |
| Command and Control | Communication with attacker |
| Exfiltration | Stealing data out |
| Impact | Disrupting availability/integrity |

---

## 📝 Exam Tips — Domain 4

1. **Secure Score**: Higher is better. Focus on high-impact recommendations first. Cannot be manually edited.
2. **Defender for Cloud vs Sentinel**: Defender for Cloud = per-resource threat protection. Sentinel = SIEM/SOAR aggregating all signals.
3. **Analytics rule types**: Scheduled = custom KQL. NRT = near-real-time KQL. Fusion = ML multi-stage. Microsoft Security = import Defender alerts.
4. **Playbooks vs Automation Rules**: Playbooks = Logic Apps with custom complex actions. Automation Rules = built-in triage (assign, change severity, close, run playbook).
5. **KQL must-know operators**: `where`, `project`, `summarize`, `extend`, `join`, `order by`, `take`, `render`.
6. **Policy effects order**: Deny > Append > Audit. DeployIfNotExists/AuditIfNotExists check for related resources.
7. **Log Analytics retention**: Default is 30 days; can be extended to 730 days (2 years) in the workspace. Archive tier for long-term retention.
8. **JIT VM Access requires**: Defender for Servers Plan 2 (or at minimum Plan 1 with some limitations).

---

## 🔗 References

- [Microsoft Defender for Cloud Documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
- [Microsoft Sentinel Documentation](https://learn.microsoft.com/en-us/azure/sentinel/)
- [Azure Monitor Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/)
- [KQL Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)

---

> ⬅️ [Domain 3: Compute, Storage & Databases](./03-compute-storage-databases.md) | ⬆️ [Back to README](../README.md)
