# Microsoft Defender for Cloud & Sentinel — Quick Reference Cheat Sheet

## Defender for Cloud — Two Pillars

```
┌─────────────────────────────────────────────────────────┐
│              Microsoft Defender for Cloud               │
├────────────────────────┬────────────────────────────────┤
│         CSPM           │           CWPP                 │
│ (Posture Management)   │  (Workload Protection)         │
│                        │                                │
│ • Secure Score         │ • Defender for Servers         │
│ • Recommendations      │ • Defender for Storage         │
│ • Regulatory Compliance│ • Defender for SQL             │
│ • Attack Path Analysis │ • Defender for Containers      │
│ • Cloud Security Graph │ • Defender for Key Vault       │
└────────────────────────┴────────────────────────────────┘
```

---

## Secure Score Formula

```
Secure Score = (Sum of earned points for completed controls)
               ─────────────────────────────────────────────  × 100
               (Sum of max points for all controls)
```

**Increases Secure Score**: Completing security controls (groups of related recommendations).
**Decreases Secure Score**: New non-compliant resources being discovered.

---

## Defender Plans Summary

| Plan | Key Feature |
|------|------------|
| Servers (P2) | JIT VM access, FIM, adaptive app controls, vulnerability assessment |
| Storage | Malware scanning, anomaly detection, sensitive data discovery |
| SQL | Threat detection (injection, anomaly, brute force), vulnerability assessment |
| Containers | Registry scanning, runtime threat detection, AKS behavioral analysis |
| Key Vault | Unusual access, geographic anomaly, suspicious policy changes |
| DNS | DGA detection, DNS tunneling |
| Resource Manager | Suspicious ARM operations, lateral movement |
| App Service | C2C communication, data exfiltration detection |
| CSPM (enhanced) | Agentless scanning, attack path analysis, cloud security graph |

---

## JIT VM Access Flow

```
Default state: Management ports (22, 3389) CLOSED in NSG

User requests access:
    → Specifies: IP address, port, duration (max 3 hours)
    → JIT creates a time-limited NSG rule: ALLOW port from IP for duration
    → At expiry: NSG rule automatically deleted → port CLOSED again
```

---

## Azure Policy Effects (Evaluation Order)

```
Disabled → AuditIfNotExists / DeployIfNotExists → Audit → Deny → Append → Modify
```

| Effect | When to Use |
|--------|------------|
| Audit | Report non-compliance without blocking |
| Deny | Prevent creation/update of non-compliant resources |
| DeployIfNotExists | Auto-deploy a related resource if missing |
| Modify | Automatically add/update resource properties (e.g., tags) |
| AuditIfNotExists | Audit if a related resource doesn't exist |

**Remediation task**: Required to remediate existing non-compliant resources for `DeployIfNotExists`/`Modify` policies.

---

## Microsoft Sentinel — Core Components

```
Data Connectors → Log Analytics Workspace
                        ↓
                 [Raw Log Data]
                        ↓
               Analytics Rules (KQL)
                        ↓
              Alerts → Incidents
                        ↓
          Investigation (Graph, Entities)
                        ↓
           Playbooks (Logic Apps) → Automated Response
```

---

## Sentinel Analytics Rule Types

| Type | Description |
|------|-------------|
| Scheduled | KQL query on schedule; most common; fully customizable |
| NRT (Near Real-Time) | ~1-minute latency scheduled rules |
| Microsoft Security | Import alerts from Defender products |
| Fusion | ML correlation of multiple low-fidelity signals (multi-stage attack) |
| Anomaly | UEBA behavioral baseline deviation |
| Threat Intelligence | Auto-alert on matching threat indicators (IoCs) |

---

## KQL Quick Reference

```kql
// Basic structure
TableName
| where TimeGenerated > ago(24h)
| where ColumnName == "value"
| project Column1, Column2, Column3
| summarize count() by Column1
| sort by count_ desc
| take 10
```

| KQL Operator | Purpose |
|-------------|---------|
| `where` | Filter rows |
| `project` | Select/rename columns |
| `summarize` | Aggregate (count, sum, avg, max) |
| `sort` / `order by` | Sort results |
| `join` | Combine two tables |
| `extend` | Add a computed column |
| `parse` | Extract values from strings |
| `ago(1h)` | Relative time (1 hour ago) |
| `bin()` | Round time to bucket (e.g., `bin(TimeGenerated, 5m)`) |
| `take` / `limit` | Return first N rows |
| `distinct` | Return unique values |
| `render` | Visualize (timechart, barchart, piechart) |

---

## Sentinel Incident Lifecycle

```
Open → Active → In Progress → Closed
                                 ↳ True Positive — Suspicious Activity
                                 ↳ True Positive — Benign Positive
                                 ↳ False Positive
                                 ↳ Undetermined
```

---

## Sentinel Data Tables (Common)

| Table | Contains |
|-------|---------|
| `SigninLogs` | Azure AD sign-in events |
| `AuditLogs` | Azure AD directory operations |
| `AzureActivity` | Azure control-plane operations (ARM) |
| `SecurityEvent` | Windows Security event log |
| `Syslog` | Linux syslog |
| `CommonSecurityLog` | CEF-format firewall/security device logs |
| `SecurityAlert` | Alerts from Defender products |
| `SecurityIncident` | Sentinel incidents |
| `OfficeActivity` | Microsoft 365 operations |
| `AzureFirewall*` | Azure Firewall logs |
| `ThreatIntelligenceIndicator` | Threat intel IoCs |

---

## Defender XDR Integration Points

| Product | Detects | Table in Sentinel |
|---------|---------|-------------------|
| Defender for Endpoint | Endpoint threats, lateral movement | `DeviceEvents`, `AlertEvidence` |
| Defender for Identity | AD attacks (pass-hash, kerberoasting) | `IdentityLogonEvents` |
| Defender for Office 365 | Phishing, BEC, malware | `EmailEvents`, `AlertEvidence` |
| Defender for Cloud Apps | Shadow IT, OAuth abuse | `McasShadowItReporting` |
| Defender for Cloud | Azure workload threats | `SecurityAlert` |

---

## Log Analytics Retention

| Period | Cost |
|--------|------|
| First 31 days | Included in workspace cost |
| 32–730 days | Additional retention cost per GB |
| Interactive retention | Up to 730 days |
| Archive tier | Up to 12 years (low cost, slower queries) |
