# Domain 4 — Manage Security Operations (25–30%)

---

## 4.1 Azure Key Vault

### Access Models

#### Access Policies (Legacy)

- Configured at the **vault level**.
- Grant access to all keys, secrets, or certificates of a given type (e.g., Get + List on Secrets).
- Cannot scope to individual secrets.
- Managed independently from Azure RBAC.

#### RBAC Mode (Recommended)

- Azure RBAC controls **both** management plane and data plane.
- Enables per-secret/per-key granularity.
- Unified audit trail in Azure Activity Log.
- Key built-in roles:

| Role | Scope | Permissions |
|---|---|---|
| **Key Vault Administrator** | Vault | All operations on keys, secrets, certs |
| **Key Vault Certificates Officer** | Vault / cert | Manage certificates |
| **Key Vault Crypto Officer** | Vault / key | Manage keys |
| **Key Vault Secrets Officer** | Vault / secret | Read + write secrets |
| **Key Vault Secrets User** | Vault / secret | Read secret value only |
| **Key Vault Reader** | Vault | Read metadata only (no values) |
| **Key Vault Crypto User** | Vault / key | Use key for crypto operations |

> ⚠️ When RBAC mode is enabled, **access policies are completely ignored**.

### Soft Delete and Purge Protection

| Feature | Description | Default |
|---|---|---|
| **Soft delete** | Deleted items retained for 7–90 days (recoverable) | On (forced, cannot be disabled) |
| **Purge protection** | Prevents permanent deletion during retention period even by vault owner | Off (opt-in) |

> 💡 **Exam tip** — For compliance requiring that secrets cannot be permanently deleted for N days, enable **purge protection**.

### Key Rotation

- Azure Key Vault supports **automatic key rotation** (built-in since 2022).
- Configure rotation policy: trigger = time-based (e.g., every 90 days) or expiry-based.
- Storage accounts and SQL support **Key Vault Key auto-rotation** integration.

### Certificates in Key Vault

- Key Vault can act as CA integration (DigiCert, GlobalSign) or issue self-signed certs.
- Certificates include the full chain, private key, and auto-renewal.

### Diagnostic Logging

Enable diagnostic settings → send to Log Analytics:
- **AuditEvent** — Who accessed what secret/key and when
- **AllMetrics** — Vault availability and latency

---

## 4.2 Microsoft Defender for Cloud

### Overview

Defender for Cloud is Azure's **Cloud Security Posture Management (CSPM)** and **Cloud Workload Protection Platform (CWPP)**.

### Secure Score

- A numerical score (0–100%) representing the percentage of security controls satisfied.
- Calculated as: `(Implemented controls points) / (Total max points) × 100`
- Actions to improve score: remediate **recommendations** listed in the Secure Score blade.
- Recommendations have different **points** weights; prioritise high-point items.

### Defender Plans (Workload Protections)

| Plan | Protects | Key Feature |
|---|---|---|
| **Defender for Servers** (P1 / P2) | VMs, Arc servers | P2 adds JIT, adaptive controls, FIM |
| **Defender for Storage** | Azure Storage accounts | Malware scanning, data sensitivity discovery |
| **Defender for SQL** | Azure SQL, SQL MI, SQL on VMs | ATP, vulnerability assessment |
| **Defender for Containers** | AKS, ACR, Arc Kubernetes | Image scanning, runtime protection |
| **Defender for App Service** | Azure App Service | Threat detection |
| **Defender for Key Vault** | Key Vault | Detect unusual access, exfiltration |
| **Defender for DNS** | Azure DNS | Detect DNS-based exfiltration |
| **Defender for Resource Manager** | ARM API | Detect resource enumeration/abuse |
| **Defender CSPM** | All resources | Attack path analysis, governance |

### Security Recommendations

- Defender for Cloud checks resources against the **Microsoft Cloud Security Benchmark (MCSB)**.
- Recommendations have: Description → Affected resources → Remediation steps → Severity.
- **Quick Fix** allows one-click remediation for some recommendations.
- **Exempt** specific resources if they have a documented exception.

### Attack Path Analysis (Defender CSPM)

- Visualises paths an attacker could follow to reach critical assets.
- Helps prioritise what to fix first.

---

## 4.3 Microsoft Sentinel

### Architecture

```
Data Sources → Connectors → Log Analytics Workspace
                                      │
                        ┌─────────────┼─────────────┐
                   Analytics Rules  Workbooks     Incidents
                        │                              │
                   KQL Queries               Automation (Playbooks)
```

### Connectors

| Connector Type | Examples |
|---|---|
| **Native (1st party)** | Microsoft Entra ID, Defender for Cloud, Azure Activity, Office 365 |
| **CEF (Common Event Format)** | Third-party firewalls (Palo Alto, Check Point, Fortinet) |
| **Syslog** | Linux systems, network devices |
| **REST API** | Custom data sources |
| **Azure Monitor Agent** | Windows/Linux servers via DCR |

### Analytics Rules

| Rule Type | Description |
|---|---|
| **Scheduled** | KQL query runs on schedule; triggers alert if results returned |
| **NRT (Near Real-Time)** | KQL runs every ~1 minute with low latency |
| **Fusion** | ML-based multi-stage attack detection (built-in) |
| **Microsoft Security** | Imports alerts from other Defender products |
| **Anomaly** | Built-in ML models for unusual behavior |
| **Threat Intelligence** | Matches IOCs from TI feed |

### KQL Example — Detect Multiple Failed Logins

```kql
SecurityEvent
| where EventID == 4625          // Failed logon
| where TimeGenerated > ago(1h)
| summarize FailedAttempts = count() by Account, Computer
| where FailedAttempts > 10
| extend Severity = "Medium"
```

### Incident Management

```
Alert → Incident (auto-grouped by analytics rule) → Investigation Graph
     → Assign analyst → Add comments → Close (True/False positive)
```

### SOAR — Automation Playbooks

- **Playbooks** = Logic Apps triggered by Sentinel incidents or alerts.
- Common automations:
  - Block IP in Azure Firewall
  - Disable compromised Entra ID user
  - Send Teams/email notification
  - Create ServiceNow/Jira ticket
  - Enrich IP with VirusTotal/WHOIS

### Workbooks

- Visualise data from Log Analytics using pre-built or custom dashboards.
- Examples: Azure AD Sign-In, Azure Activity, Security Alerts overview.

---

## 4.4 Azure Policy

### Effects (Enforcement)

| Effect | Behaviour | Use Case |
|---|---|---|
| **Deny** | Prevents non-compliant resource creation/update | Hard enforcement |
| **Audit** | Logs non-compliant resources; does not block | Compliance reporting |
| **AuditIfNotExists** | Audit if a related resource doesn't exist | Check companion resources |
| **DeployIfNotExists** | Automatically deploy missing companion resources | Auto-remediation |
| **Modify** | Change resource properties on create/update | Auto-tag, enforce settings |
| **Append** | Add fields to resource | Add tags, IP restrictions |
| **Disabled** | Policy exists but not evaluated | Testing/staging |

### Initiatives (Policy Sets)

- Group multiple policies into a single assignment.
- Example: **Azure Security Benchmark** initiative contains 200+ policies.
- **Compliance score** = % of resources compliant across all initiative policies.

### Remediation Tasks

- For **DeployIfNotExists** and **Modify** policies: create a remediation task to fix existing non-compliant resources.
- Remediation runs the policy effect on resources that are already deployed.

### Policy Scope

```
Management Group → Subscription → Resource Group → Resource
(Assignment at parent scope applies to all children)
```

### Exclusions

- **Exclude** specific scopes (sub-RGs, individual resources) from a policy assignment.
- Useful for break-glass or legacy resources.

---

## 4.5 Log Analytics and Diagnostic Settings

### Workspace Architecture

- A **Log Analytics Workspace** is the central store for all Azure security logs.
- Multiple services send data to one workspace for centralised analysis.
- **Retention**: Default 30 days; configurable up to 730 days (2 years).
- **Commitment tiers** or **Pay-as-you-go** pricing.

### Diagnostic Settings

Each Azure resource can export:

| Category | Data Type |
|---|---|
| **AuditLogs** | Who did what to the resource |
| **SignInLogs** | Entra ID sign-in events (from Entra ID diagnostic settings) |
| **AllMetrics** | Numeric performance/availability metrics |
| **Resource-specific logs** | e.g., Key Vault `AuditEvent`, SQL `SQLSecurityAuditEvents` |

### Activity Log

- Subscription-level operations (who created/deleted/modified what resource).
- Automatically retained for 90 days.
- Export to Log Analytics for longer retention and KQL analysis.

---

## 4.6 Architecture Decision Guidance

| Requirement | Solution |
|---|---|
| Centralise secrets/keys/certs for all apps | Azure Key Vault (RBAC mode) |
| Prevent permanent deletion of secrets | Key Vault purge protection |
| Automatic certificate renewal | Key Vault + CA integration |
| Get a security posture score across Azure | Defender for Cloud Secure Score |
| Runtime protection for AKS clusters | Defender for Containers |
| Detect SQL injection attacks in real time | Defender for SQL (ATP) |
| Centralise security events for investigation | Microsoft Sentinel |
| Automate incident response | Sentinel Playbooks (Logic Apps) |
| Enforce no unencrypted storage accounts | Azure Policy deny effect |
| Auto-remediate missing Log Analytics agent | Azure Policy DeployIfNotExists |
| Investigate multi-stage attacks | Sentinel Fusion rules + Investigation graph |

---

## 4.7 CLI Quick Reference

```bash
# Create Key Vault with RBAC mode
az keyvault create \
  --name myVault \
  --resource-group myRG \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --enable-purge-protection true \
  --retention-days 90

# Assign Key Vault Secrets User role
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee <object-id> \
  --scope /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.KeyVault/vaults/myVault

# Enable Defender for Cloud plans
az security pricing create --name VirtualMachines --tier Standard
az security pricing create --name SqlServers --tier Standard
az security pricing create --name StorageAccounts --tier Standard

# Create Log Analytics workspace with 90-day retention
az monitor log-analytics workspace create \
  --resource-group myRG \
  --workspace-name mySentinelWS \
  --retention-time 90

# Onboard Sentinel to workspace
az sentinel onboarding-state create \
  --resource-group myRG \
  --workspace-name mySentinelWS \
  --name default

# Set activity log diagnostic settings
az monitor diagnostic-settings create \
  --name activityToSentinel \
  --subscription <sub-id> \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"Alert","enabled":true}]' \
  --workspace /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.OperationalInsights/workspaces/mySentinelWS
```

---

## 4.8 Practice Questions

**Q1.** Azure Key Vault is configured in RBAC authorization mode. A developer has been granted the `Key Vault Secrets User` role at the vault level. An existing access policy grants the developer `Get` and `List` permissions on secrets. Can the developer read a secret value?

- A. No — RBAC and access policies must both allow the action  
- B. Yes — The access policy grants the permission  
- C. Yes — The RBAC role `Key Vault Secrets User` grants read access  
- D. No — `Key Vault Secrets User` role only allows listing secret names  

<details><summary>Answer</summary>
**C** — When RBAC mode is enabled, **access policies are ignored entirely**. The RBAC role `Key Vault Secrets User` grants permission to get secret values.
</details>

---

**Q2.** An organisation needs to ensure that if a Key Vault secret is accidentally deleted, it cannot be permanently destroyed for at least 90 days. Which Key Vault feature must be enabled?

- A. Soft delete with 90-day retention  
- B. Purge protection  
- C. Key rotation policy  
- D. Private endpoint  

<details><summary>Answer</summary>
**B** — Purge protection prevents permanent (purge) deletion of soft-deleted secrets during the retention period. Soft delete alone still allows an admin to purge manually.
</details>

---

**Q3.** A security analyst needs to run a KQL query in Microsoft Sentinel to find all users who had more than 5 failed sign-in attempts in the last 24 hours. Which Sentinel component is used to define an automated alert based on this query?

- A. A Workbook  
- B. A Playbook  
- C. An Analytics Rule (Scheduled)  
- D. A Data Connector  

<details><summary>Answer</summary>
**C** — Scheduled Analytics Rules contain KQL queries that run on a defined schedule and generate alerts/incidents when conditions are met.
</details>

---

**Q4.** An Azure Policy is assigned with a `DeployIfNotExists` effect requiring that all virtual machines have the Log Analytics agent extension installed. A VM already exists without the extension. What must an admin do to enforce compliance on this existing VM?

- A. Delete and recreate the VM  
- B. Assign a new stricter policy  
- C. Create a remediation task for the policy assignment  
- D. Enable Defender for Servers  

<details><summary>Answer</summary>
**C** — `DeployIfNotExists` policies require a **remediation task** to be run against existing non-compliant resources. New resources are automatically remediated at creation time.
</details>

---

**Q5.** Microsoft Defender for Cloud shows a Secure Score of 45%. Which action directly increases the Secure Score?

- A. Enabling Defender for Servers on all VMs  
- B. Adding more VMs to the subscription  
- C. Implementing the security recommendations listed in the Secure Score blade  
- D. Creating Sentinel analytics rules  

<details><summary>Answer</summary>
**C** — The Secure Score increases when security **recommendations** are remediated. Each recommendation is associated with control points; implementing them adds to the score.
</details>
