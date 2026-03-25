# Domain 4 — Study Notes: Manage Security Operations

> Deep-dive reference notes for exam preparation

---

## Microsoft Sentinel — Advanced Configuration

### Sentinel Workspace Design

**Single-workspace architecture:**
- Simpler management
- Best for single team, single region
- All data in one place for correlation

**Multi-workspace architecture:**
- Required for: data residency requirements, multiple SOC teams, different retention needs
- Workspace Manager: Centrally manage multiple workspaces from one Sentinel instance
- Cross-workspace queries: Query data across workspaces in KQL

### Data Retention Strategy
```
Log Type                 | Interactive | Archive
-------------------------|-------------|--------
Security alerts          | 90 days     | 7 years
Sign-in logs             | 30 days     | 2 years
Audit logs               | 30 days     | 2 years
NSG Flow logs            | 30 days     | 1 year
Azure Activity           | 90 days     | 7 years
Custom app logs          | 30 days     | As needed
```

### Pricing Tiers
| Tier | Description |
|------|-------------|
| **Pay-as-you-go** | Per GB ingested |
| **Commitment tiers** | 100–5000 GB/day; lower per-GB cost |

### Sentinel Content Hub
- Pre-built solutions for specific data sources or use cases
- Includes: Data connectors, analytics rules, workbooks, hunting queries, playbooks
- Examples: Azure Activity, Microsoft Entra ID, Microsoft Defender for Endpoint, Cisco ASA

---

## KQL for Security — Deep Dive

### Essential Functions

```kusto
// Parse JSON fields
AzureDiagnostics
| extend parsedData = parse_json(properties_s)
| project TimeGenerated, parsedData.field1

// Extract with regex
SecurityEvent
| where EventID == 4688
| extend Process = extract(@"Process Name:\s+(.+)", 1, EventData)

// String operations
SignInLogs
| where UserPrincipalName has "admin"
| where UserPrincipalName !endswith "@trusted.com"

// Time bucketing
SecurityAlert
| summarize AlertCount = count() by bin(TimeGenerated, 1h), AlertSeverity
| render timechart

// Percentile
Perf
| where CounterName == "% Processor Time"
| summarize p95_cpu = percentile(CounterValue, 95) by Computer
| where p95_cpu > 80

// Dynamic column
SecurityEvent
| where EventID == 4624
| extend LogonType = case(
    LogonType == 2, "Interactive",
    LogonType == 3, "Network",
    LogonType == 10, "RemoteInteractive",
    "Other"
)

// Union multiple tables
union SecurityAlert, SecurityIncident
| where TimeGenerated > ago(7d)
| project TimeGenerated, AlertName, IncidentName, Severity
```

### Common Security KQL Queries

```kusto
// Failed logins followed by success (brute force then success)
let FailedLogins = SecurityEvent
    | where EventID == 4625
    | where TimeGenerated > ago(1h)
    | summarize FailCount = count() by IpAddress, TargetAccount
    | where FailCount > 5;
SecurityEvent
| where EventID == 4624
| join kind=inner FailedLogins on $left.IpAddress == $right.IpAddress
| project TimeGenerated, IpAddress, TargetAccount, FailCount

// New admin account created
AuditLogs
| where OperationName == "Add member to role"
| where TargetResources[0].modifiedProperties[0].newValue contains "Global Administrator"
| project TimeGenerated, InitiatedBy = InitiatedBy.user.userPrincipalName, TargetUser = TargetResources[0].userPrincipalName

// Anomalous resource deletion
AzureActivity
| where OperationNameValue endswith "/delete"
| where ActivityStatusValue == "Success"
| where TimeGenerated > ago(24h)
| summarize DeleteCount = count() by Caller, OperationNameValue
| where DeleteCount > 10
| order by DeleteCount desc

// Key Vault secret access from unknown IP
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet"
| where ResultType == "Success"
| where CallerIPAddress !in (split("10.0.0.0/8,172.16.0.0/12,192.168.0.0/16", ","))
| project TimeGenerated, CallerIPAddress, identity_claim_upn_s, requestUri_s
```

---

## Defender for Cloud — Advanced Configuration

### Auto-Provisioning
Defender for Cloud can automatically install agents/extensions:
- **Log Analytics agent** (MMA): Collect security events from VMs
- **Azure Monitor agent (AMA)**: Next-gen agent (replacing MMA)
- **Dependency agent**: For service map
- **Microsoft Defender for Endpoint**: For Defender for Servers

### Security Contact
- Configure email/phone for security notifications
- Receives alerts of High/Medium severity
- Receives weekly security digest

### Continuous Export
Export Defender for Cloud data to:
- **Log Analytics Workspace**: For KQL analysis in Sentinel
- **Azure Event Hubs**: For external SIEM (Splunk, QRadar, etc.)

Data types:
- Security recommendations
- Security alerts
- Regulatory compliance data
- Secure score data

### Workflow Automation
- Trigger Logic Apps on security alerts or recommendations
- Use cases: Notification, ticketing, auto-remediation
- Similar to Sentinel playbooks but scoped to Defender for Cloud

---

## Azure Policy — Advanced

### Custom Policy Definition
```json
{
  "properties": {
    "displayName": "Require Key Vault to use RBAC authorization",
    "description": "Key Vault should use RBAC for access control",
    "mode": "Indexed",
    "parameters": {
      "effect": {
        "type": "String",
        "allowedValues": ["Audit", "Deny", "Disabled"],
        "defaultValue": "Audit"
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.KeyVault/vaults"
          },
          {
            "field": "Microsoft.KeyVault/vaults/enableRbacAuthorization",
            "notEquals": true
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  }
}
```

### DeployIfNotExists Policy
```json
{
  "then": {
    "effect": "DeployIfNotExists",
    "details": {
      "type": "Microsoft.Insights/diagnosticSettings",
      "roleDefinitionIds": [
        "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      ],
      "deployment": {
        "properties": {
          "mode": "incremental",
          "template": {
            "$schema": "...",
            "resources": [{
              "type": "Microsoft.Insights/diagnosticSettings",
              "name": "setByPolicy",
              "properties": {
                "logs": [{ "category": "AuditEvent", "enabled": true }]
              }
            }]
          }
        }
      }
    }
  }
}
```

### Policy Evaluation Order
1. `Disabled` → skip
2. `Append` / `Modify` → applied before other effects
3. `Deny` → block if condition matches
4. `Audit` → log non-compliant; allow operation
5. `AuditIfNotExists` / `DeployIfNotExists` → check for related resource after deployment

### Non-Compliance Evaluation
- **On-demand scan**: `az policy state trigger-scan`
- **On new/updated resources**: Evaluated within 30 minutes
- **Scheduled**: Every 24 hours for existing resources

---

## Sentinel — Threat Intelligence

### Threat Intelligence Integration
- Import IoCs (Indicators of Compromise): IPs, domains, URLs, file hashes
- Sources: TAXII feeds, threat intel platforms, manual import
- **Threat Intelligence Matching Analytics**: Auto-match logs against IoCs

### STIX/TAXII
- **STIX** (Structured Threat Information Expression): Format for threat intel
- **TAXII** (Trusted Automated eXchange of Indicator Information): Protocol for sharing
- Connect TAXII server in Sentinel: Threat Intelligence → Add new → TAXII server

### Fusion (MSTIC ML Model)
- Detects multi-stage attacks (kill chain) by correlating signals from:
  - Anomalous sign-ins
  - Malicious apps
  - Suspicious Azure activity
  - Malware
  - Phishing attempts
- Creates high-fidelity, low-noise incidents
- Based on ML + Microsoft threat research

---

## UEBA (User and Entity Behavior Analytics)

- Builds baselines of normal behavior for users and entities
- Detects anomalies: unusual access times, impossible travel, data exfiltration patterns
- Available in Microsoft Sentinel
- Requires enabling and onboarding data sources

**UEBA Tables in Sentinel:**
- `BehaviorAnalytics`: Per-user/entity risk scores and anomalies
- `IdentityInfo`: User attributes from Entra ID
- `UserAccessAnalytics`: Access pattern analysis

---

## Security Benchmark & CIS Controls

### Microsoft Cloud Security Benchmark (MCSB)
Default policy initiative assigned in Defender for Cloud. Controls mapped to:
- Identity Management
- Privileged Access
- Network Security
- Data Protection
- Asset Management
- Logging and Threat Detection
- Incident Response
- Posture and Vulnerability Management
- Endpoint Security
- Backup and Recovery
- DevOps Security
- Governance and Strategy

### CIS Benchmark for Azure
Level 1 (basic security):
- Enable MFA for all users
- Ensure no custom role with excessive permissions
- Enable Defender for Cloud
- Enable activity log alerts for critical operations

Level 2 (advanced security):
- Use customer-managed keys
- Enable Azure Defender for all services
- Configure network just-enough-access

---

## Security Logging Best Practices

### What to Log
| Log Source | Enable For |
|-----------|-----------|
| Entra ID Sign-in logs | All authentication events |
| Entra ID Audit logs | All identity management changes |
| Azure Activity logs | All subscription-level operations |
| Resource diagnostic logs | Per-service operational logs |
| NSG Flow logs | Network traffic patterns |
| Azure Firewall logs | All firewall decisions |
| Key Vault diagnostic logs | All secret/key access |
| VM Security events | Windows: EventID 4624,4625,4648,4768,4769; Linux: auth.log |
| SQL Audit logs | All database activities |

### Log Retention Guidelines
| Requirement | Retention |
|------------|----------|
| Azure minimum (interactive) | 30 days |
| Security investigation | 90 days hot |
| Compliance (most standards) | 1 year |
| PCI DSS | 1 year |
| HIPAA | 6 years |
| SOX | 7 years |

---

## Incident Response Playbook Examples

### Playbook 1: Block User on High Risk
```
Trigger: Sentinel Incident (High Severity)
  → Condition: Alert contains entity type = Account
  → Action: Get user details from Entra ID
  → Action: Post message to Teams channel (SOC notification)
  → Condition: Confirm with SOC via adaptive card
    → If Confirmed:
      → Action: Disable user account in Entra ID
      → Action: Revoke all refresh tokens
      → Action: Add comment to Sentinel incident
    → If Rejected:
      → Action: Add comment: "SOC decided no action"
```

### Playbook 2: Enrich IP on Alert
```
Trigger: Sentinel Alert created
  → Get IP address from alert entity
  → Query VirusTotal API for IP reputation
  → Query WHOIS for IP registration info
  → Update alert comment with enrichment data
  → If VirusTotal score > 5:
    → Change incident severity to High
    → Add tag: "Malicious IP Confirmed"
```

---

## Key Management & Operations Checklist

```
Security Operations Daily:
□ Review Sentinel incidents (New status)
□ Review Defender for Cloud high-severity alerts
□ Check Secure Score changes

Security Operations Weekly:
□ Review unanswered PIM requests
□ Review Conditional Access policy report-only mode results
□ Review Identity Protection risky users/sign-ins
□ Check regulatory compliance score changes

Security Operations Monthly:
□ Review and assign Defender for Cloud recommendations
□ Complete access reviews in PIM
□ Review and update named locations
□ Test incident response playbooks
□ Review custom analytics rules for effectiveness

Security Operations Quarterly:
□ Review RBAC assignments for least privilege
□ Complete entitlement management access reviews
□ Review and rotate credentials
□ Penetration testing or red team exercise
□ Review and update security policies
```

---

[← Back to Domain Overview](README.md) | [Practice Questions →](../../practice-questions/domain4-security-ops.md)
