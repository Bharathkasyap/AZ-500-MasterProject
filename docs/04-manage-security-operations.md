# Domain 4: Manage Security Operations (25–30%)

> This domain is the highest-weighted area of the AZ-500 exam. Master Microsoft Defender for Cloud, Microsoft Sentinel, Azure Key Vault, and security monitoring.

---

## Objectives Covered

- Plan, implement, and manage governance for security
- Manage security posture by using Microsoft Defender for Cloud
- Configure and manage threat protection by using Microsoft Defender for Cloud
- Configure and manage security monitoring and automation solutions

---

## 4.1 Azure Key Vault

Azure Key Vault is a cloud service for securely storing and accessing secrets, keys, and certificates.

### Key Vault Object Types

| Object Type | Description | Examples |
|---|---|---|
| **Secrets** | Key-value strings | Passwords, connection strings, API keys |
| **Keys** | Cryptographic keys | RSA, EC keys for encryption/signing |
| **Certificates** | X.509 certificates | TLS/SSL certs, managed lifecycle |

### Key Vault SKUs

| Feature | Standard | Premium |
|---|---|---|
| Software-protected keys | ✅ | ✅ |
| HSM-protected keys | ❌ | ✅ (FIPS 140-2 Level 2) |
| Managed HSM | ❌ | Use Azure Managed HSM (dedicated) |

### Access Models

#### Access Policies (Legacy)
- Vault-level permissions granted per principal
- Permissions: Get, List, Set, Delete, Backup, Restore, Purge, Recover (separate for Keys, Secrets, Certificates)
- **Cannot use Deny** — only allow

#### Azure RBAC (Recommended)
| Role | Scope |
|---|---|
| Key Vault Administrator | Manage vault and all objects |
| Key Vault Secrets Officer | Read/write secrets |
| Key Vault Secrets User | Read secrets (e.g., for applications) |
| Key Vault Crypto Officer | Read/write keys |
| Key Vault Crypto User | Use keys for crypto operations |
| Key Vault Certificate Officer | Read/write certificates |
| Key Vault Reader | View metadata (not secret values) |

> ⚠️ **Exam tip:** Azure RBAC is the **recommended** access model. It supports Deny assignments and allows per-object-level access control.

### Soft Delete & Purge Protection

| Feature | Description |
|---|---|
| **Soft delete** | Deleted objects retained for 7–90 days; **enabled by default** (cannot be disabled) |
| **Purge protection** | Prevents permanent deletion during retention period; required for CMK with TDE |

```bash
# Create Key Vault with purge protection
az keyvault create \
  --resource-group myRG \
  --name myKeyVault \
  --location eastus \
  --enable-rbac-authorization true \
  --enable-purge-protection true \
  --retention-days 90
```

### Key Rotation

```bash
# Create a rotation policy for an automatic 1-year rotation
az keyvault key rotation-policy update \
  --vault-name myKeyVault \
  --name myKey \
  --value '{
    "lifetimeActions": [{
      "trigger": {"timeAfterCreate": "P11M"},
      "action": {"type": "Rotate"}
    }],
    "attributes": {"expiryTime": "P1Y"}
  }'
```

### Private Endpoint for Key Vault

```bash
# Disable public network access and use private endpoint
az keyvault update \
  --resource-group myRG \
  --name myKeyVault \
  --public-network-access Disabled

az network private-endpoint create \
  --name myKVPrivateEndpoint \
  --resource-group myRG \
  --vnet-name myVNet \
  --subnet mySubnet \
  --private-connection-resource-id $(az keyvault show --name myKeyVault --query id -o tsv) \
  --group-id vault \
  --connection-name myKVConnection
```

---

## 4.2 Microsoft Defender for Cloud

Microsoft Defender for Cloud is a **cloud security posture management (CSPM)** and **cloud workload protection platform (CWPP)**.

### Core Capabilities

| Capability | Description |
|---|---|
| Secure Score | Measures your security posture (0–100%) |
| Security Recommendations | Actionable guidance to improve posture |
| Regulatory Compliance | Maps controls to standards (CIS, NIST, PCI DSS, ISO 27001) |
| Workload Protections | Runtime threat detection per resource type |
| Cloud Security Graph | Attack path analysis across your environment |
| Defender CSPM | Advanced posture management (paid tier) |

### Secure Score

- Score = (Completed controls / Total controls) × 100
- Each recommendation belongs to a **security control**
- Completing all recommendations in a control awards the full control score

### Defender Plans (Workload Protections)

| Plan | Protects |
|---|---|
| Defender for Servers (P1/P2) | Azure, AWS, GCP VMs |
| Defender for Storage | Azure Storage accounts |
| Defender for SQL | Azure SQL, SQL on VMs, SQL Managed Instance |
| Defender for Containers | AKS, container registries |
| Defender for App Service | Azure App Service apps |
| Defender for Key Vault | Key Vault threat detection |
| Defender for Resource Manager | ARM operations |
| Defender for DNS | DNS query threat detection |
| Defender for APIs | Azure API Management |
| Defender CSPM | Advanced CSPM with attack paths, governance |

### Security Policies & Azure Policy
- Defender for Cloud uses **Azure Policy initiatives** to define and evaluate security standards
- Default initiative: **Microsoft Cloud Security Benchmark (MCSB)**
- Add regulatory compliance standards: CIS, NIST SP 800-53, PCI DSS v3.2.1, etc.

```bash
# Assign the NIST SP 800-53 Rev. 5 initiative to a subscription
az policy assignment create \
  --name "NIST-SP-800-53-Rev5" \
  --display-name "NIST SP 800-53 Rev. 5" \
  --policy-set-definition "/providers/Microsoft.Authorization/policySetDefinitions/179d1daa-458f-4e47-8086-2a68d0d6c38f" \
  --scope "/subscriptions/<subscriptionId>"
```

### Workflow Automation
Defender for Cloud can trigger **Logic Apps** automatically when:
- A recommendation state changes
- An alert is generated
- A regulatory compliance assessment changes

---

## 4.3 Microsoft Sentinel

Microsoft Sentinel is a cloud-native **Security Information and Event Management (SIEM)** and **Security Orchestration, Automation, and Response (SOAR)** solution.

### Architecture

```
Data Sources → Data Connectors → Log Analytics Workspace → Sentinel
                                                               ↓
                                              Analytics Rules (KQL)
                                                               ↓
                                                 Incidents / Alerts
                                                               ↓
                                              Playbooks (Logic Apps)
```

### Key Components

| Component | Description |
|---|---|
| **Data Connectors** | Ingest data from 300+ sources (Azure, Microsoft 365, AWS, 3rd party) |
| **Analytics Rules** | KQL queries that trigger alerts (Scheduled, NRT, ML-based, Fusion) |
| **Incidents** | Grouped alerts with investigation workflow |
| **Hunting Queries** | Proactive threat hunting using KQL |
| **Playbooks** | Logic Apps automating response actions |
| **Workbooks** | Interactive dashboards for visualization |
| **UEBA** | User and Entity Behavior Analytics |
| **Threat Intelligence** | IOC matching; integrated TI feeds |

### Analytics Rule Types

| Type | Description |
|---|---|
| Scheduled | KQL query runs on a schedule; generates alerts when threshold met |
| Near Real-Time (NRT) | KQL query runs every minute; low-latency detection |
| Microsoft Security | Auto-create incidents from Microsoft security product alerts |
| ML-Based Behavioral Analytics | Detects anomalies using built-in ML models |
| Fusion | Correlates low-fidelity signals into high-confidence incidents |
| Anomaly | Built-in anomaly detection templates |

### Sample Analytics Rule (KQL)
```kql
// Detect multiple failed login attempts followed by success (password spray)
let threshold = 10;
SecurityEvent
| where EventID == 4625  // Failed logon
| summarize FailCount = count(), LastFail = max(TimeGenerated)
    by TargetAccount, IpAddress
| where FailCount >= threshold
| join kind=inner (
    SecurityEvent
    | where EventID == 4624  // Successful logon
    | project SuccessTime = TimeGenerated, TargetAccount, IpAddress
  ) on TargetAccount, IpAddress
| where SuccessTime > LastFail
| project TargetAccount, IpAddress, FailCount, LastFail, SuccessTime
```

### Playbooks (SOAR Automation)
Playbooks are **Azure Logic Apps** triggered by Sentinel alerts or incidents.

**Common Automation Actions:**
- Send email/Teams notification
- Create a ServiceNow/Jira ticket
- Block an IP in Azure Firewall or NSG
- Disable a compromised user account in Azure AD
- Isolate a VM from the network (Defender for Endpoint integration)

### MITRE ATT&CK Framework Integration
- Analytics rules and hunting queries are mapped to MITRE ATT&CK tactics and techniques
- View your coverage in the **MITRE ATT&CK** workbook in Sentinel

---

## 4.4 Azure Monitor & Security Monitoring

### Diagnostic Settings
Route resource logs and metrics to:
- Log Analytics workspace (query with KQL)
- Storage account (archival)
- Event Hubs (streaming to SIEM)
- Partner solutions

```bash
# Send Activity Log to Log Analytics
az monitor diagnostic-settings create \
  --name "ActivityLogToLA" \
  --subscription <subscriptionId> \
  --workspace /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.OperationalInsights/workspaces/myWorkspace \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"Alert","enabled":true}]'
```

### Azure Activity Log
- Records all **control plane operations** in Azure (create, update, delete resource actions)
- Retained for **90 days** by default; export to Log Analytics for longer retention
- **Key categories:** Administrative, Security, ServiceHealth, Alert, Policy, Recommendation

### Log Analytics & KQL Basics

```kql
// List all resources that have been deleted in the last 7 days
AzureActivity
| where TimeGenerated > ago(7d)
| where OperationNameValue endswith "/delete"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, ResourceGroup, Resource, OperationNameValue
| order by TimeGenerated desc
```

```kql
// Find sign-ins from risky IP addresses
SigninLogs
| where RiskLevelDuringSignIn in ("high", "medium")
| project TimeGenerated, UserPrincipalName, IPAddress, Location, RiskLevelDuringSignIn
| order by TimeGenerated desc
```

---

## 4.5 Azure Policy & Governance

### Policy Effects (Evaluated in Order)

| Effect | Description |
|---|---|
| **Disabled** | Policy rule not evaluated |
| **Audit** | Log non-compliant resources; no enforcement |
| **AuditIfNotExists** | Audit if a related resource doesn't exist |
| **Deny** | Block non-compliant resource operations |
| **DeployIfNotExists** | Deploy a related resource if it doesn't exist |
| **Modify** | Add/replace/remove properties on resource |
| **Append** | Add additional fields to the resource |

### Common Security Policy Examples

```json
// Deny creation of Storage Accounts without HTTPS
{
  "if": {
    "allOf": [
      {"field": "type", "equals": "Microsoft.Storage/storageAccounts"},
      {"field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly", "notEquals": "true"}
    ]
  },
  "then": {"effect": "Deny"}
}
```

```json
// Deploy Log Analytics agent to VMs if missing
{
  "if": {"field": "type", "equals": "Microsoft.Compute/virtualMachines"},
  "then": {"effect": "DeployIfNotExists", ...}
}
```

### Azure Policy Scope
Management Group → Subscription → Resource Group → Resource

### Initiatives (Policy Sets)
An **initiative** is a collection of policies grouped together to achieve a single goal (e.g., CIS compliance).

```bash
# View built-in security initiatives
az policy set-definition list \
  --query "[?policyType=='BuiltIn'] | [?contains(displayName,'Security')].[displayName,name]" \
  --output table
```

---

## 4.6 Microsoft Defender for Cloud — Alerts & Incident Response

### Alert Severity Levels
| Severity | Description |
|---|---|
| High | Attack likely succeeding; immediate action required |
| Medium | Attack possibly succeeding; investigation required |
| Low | Suspicious activity; may need investigation |
| Informational | Normal activity worth noting |

### Incident Response with Defender for Cloud
1. **Detect:** Alert generated by a Defender plan
2. **Triage:** Review alert details, affected resources, MITRE tactic
3. **Investigate:** Attack path analysis, entity mapping, related alerts
4. **Respond:** Run playbook, apply recommendation, isolate resource
5. **Recover:** Validate remediation, update security controls

### Suppression Rules
Create suppression rules to reduce false positives:
```
Alert: "Suspicious process executed"
Condition: Process name = "known_tool.exe" AND machine = "dev-vm-01"
Action: Dismiss + comment
```

---

## 🔬 Practice Questions

**Q1.** Your organization needs to ensure that all Azure Key Vaults are protected from accidental permanent deletion. What two features must be enabled on each Key Vault?

- A) Soft delete and Key Vault Firewall
- B) Key Vault Private Endpoint and Purge Protection
- C) Soft delete and Purge Protection
- D) Key Vault access policies and diagnostic logging

> **Answer:** **C** — **Soft delete** (enabled by default; cannot be disabled) and **Purge protection** (must be explicitly enabled). With both enabled, deleted vaults/objects can only be recovered during the retention period and cannot be permanently deleted until the retention period expires.

**Q2.** A Sentinel analytics rule fires an alert whenever 10 or more failed logins occur for a single account within 5 minutes. You want Sentinel to automatically disable the account in Azure AD when this alert fires. What should you create?

- A) A Sentinel analytics rule with a custom KQL query that directly updates the user object
- B) An Azure Function triggered by a Log Analytics scheduled alert
- C) A Playbook (Azure Logic App) connected to the Sentinel alert trigger, configured to run automatically via an automation rule
- D) A Microsoft Entra Identity Protection risk-based Conditional Access policy

> **Answer:** **C** — A **Playbook** (Azure Logic App) connected to the Sentinel alert trigger. The Logic App would call the Microsoft Graph API to disable the user account. Configure the analytics rule to run the playbook automatically via an **automation rule**.

**Q3.** You need to enforce that all VMs in a subscription must have Endpoint Protection installed. If a VM is found without it, Azure should automatically deploy the extension. Which Azure Policy effect should you use?

- A) Audit
- B) Deny
- C) Append
- D) DeployIfNotExists

> **Answer:** **D** — **DeployIfNotExists** — this effect checks for a related resource (the Endpoint Protection extension) and deploys it if it doesn't exist.

**Q4.** Your Secure Score in Defender for Cloud is 65%. You review the recommendations and find that enabling MFA for all subscription owners would improve the score by 10 points. What does this recommendation belong to?

- A) A compliance initiative
- B) A security control (e.g., "Enable MFA")
- C) A regulatory standard assignment
- D) A resource health alert

> **Answer:** **B** — The recommendation belongs to a **Security Control** called "Enable MFA" (or similar). Secure Score is calculated at the security control level — completing all recommendations within a control awards the full control score.

**Q5.** You need to collect Azure Activity Logs and send them to Microsoft Sentinel. What must you configure?

- A) Install the Log Analytics agent on all VMs to collect subscription activity logs
- B) Enable Microsoft Defender for Cloud standard tier on the subscription
- C) Configure a Diagnostic Setting on the subscription to send Activity Logs to a Log Analytics workspace, connect the workspace to Sentinel, and enable the Azure Activity data connector
- D) Create an Azure Monitor action group and link it directly to Microsoft Sentinel

> **Answer:** **C** —
> 1. Set up a **Diagnostic Setting** on the subscription to send Activity Logs to a **Log Analytics workspace**.
> 2. Connect the Log Analytics workspace to **Microsoft Sentinel**.
> 3. Enable the **Azure Activity** data connector in Sentinel (which queries the `AzureActivity` table).

---

## 📚 Further Reading

- [Azure Key Vault overview](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
- [Microsoft Defender for Cloud docs](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
- [Microsoft Sentinel documentation](https://learn.microsoft.com/en-us/azure/sentinel/)
- [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/overview)
- [Azure Policy documentation](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [KQL quick reference](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)

---

*Previous: [Domain 3 — Secure Compute, Storage, and Databases ←](03-secure-compute-storage-databases.md) | Back to: [README →](../README.md)*
