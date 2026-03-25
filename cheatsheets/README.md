# AZ-500 Quick Reference Cheat Sheets

← [Back to main README](../README.md)

Fast-reference cards for all four exam domains. Print these or keep them open during your final review.

---

## 🔑 Domain 1: Identity and Access — Cheat Sheet

### Azure AD License Requirements

| Feature | Free | P1 | P2 |
|---|---|---|---|
| Basic SSO | ✅ | ✅ | ✅ |
| Self-Service Password Reset | ✅ (cloud only) | ✅ (hybrid) | ✅ |
| Conditional Access | ❌ | ✅ | ✅ |
| Dynamic Groups | ❌ | ✅ | ✅ |
| Identity Protection | ❌ | ❌ | ✅ |
| Privileged Identity Management | ❌ | ❌ | ✅ |
| Access Reviews | ❌ | ❌ | ✅ |

---

### MFA Method Security Levels

```
MOST SECURE
    FIDO2 Security Key / Windows Hello for Business
    Certificate-based Authentication
    Microsoft Authenticator (Passwordless)
    Microsoft Authenticator (Push/TOTP)
    TOTP Hardware Token
    SMS / Voice Call
    Password Alone
LEAST SECURE
```

---

### Conditional Access Policy Components

```
ASSIGNMENTS (WHO + WHAT + WHEN)
├── Users & Groups (who)
├── Cloud Apps / Actions (what)
└── Conditions (when)
    ├── Sign-in risk level
    ├── User risk level
    ├── Device platform
    ├── Location (named location / country)
    ├── Client app type
    └── Device filter

ACCESS CONTROLS (THEN)
├── Grant Access (with requirements)
│   ├── Require MFA
│   ├── Require compliant device
│   ├── Require hybrid Azure AD join
│   └── Require app protection policy
└── Block Access
```

---

### PIM Key Facts

| Setting | Notes |
|---|---|
| Eligible | JIT; must activate; time-limited |
| Active | Permanent; no activation needed |
| Activation max | Configurable; up to 24 hours |
| Require approval | Designated approvers get email notification |
| Require MFA | User must complete MFA during activation |
| Audit logs | All activations and approvals logged |
| Requires | Azure AD P2 |

---

### Azure RBAC Built-in Roles Quick Reference

| Role | Can Manage Resources? | Can Assign RBAC? |
|---|---|---|
| Owner | ✅ | ✅ |
| Contributor | ✅ | ❌ |
| Reader | ❌ (read only) | ❌ |
| User Access Administrator | ❌ | ✅ (RBAC only) |

---

### Key Vault RBAC Roles

| Role | Create/Delete | Read Values | Crypto Ops |
|---|---|---|---|
| KV Administrator | ✅ | ✅ | ✅ |
| KV Secrets Officer | ✅ (secrets only) | ✅ | ❌ |
| **KV Secrets User** | ❌ | **✅** | ❌ |
| KV Crypto Officer | ✅ (keys only) | N/A | ✅ |
| **KV Crypto User** | ❌ | N/A | **✅** |
| KV Reader | ❌ | ❌ | ❌ |

---

### Managed Identity Types

| Type | Lifecycle | Reusable Across Resources? |
|---|---|---|
| System-assigned | Deleted with resource | No |
| User-assigned | Independent resource | Yes |

---

## 🌐 Domain 2: Networking — Cheat Sheet

### NSG Rule Evaluation

```
Priority 100 → Priority 200 → ... → 65000 → 65500
(FIRST MATCH WINS — evaluation stops)

Default rules (cannot delete):
  Inbound:  AllowVnetInBound (65000) → AllowAzureLB (65001) → DenyAll (65500)
  Outbound: AllowVnetOutBound (65000) → AllowInternet (65001) → DenyAll (65500)

When BOTH subnet NSG and NIC NSG exist:
  Inbound:  Subnet NSG → NIC NSG (both must allow)
  Outbound: NIC NSG → Subnet NSG (both must allow)
```

---

### Service Tags Quick Reference

| Tag | Represents |
|---|---|
| `Internet` | All public IPs |
| `VirtualNetwork` | VNet + peered VNets + VPN/ER connected |
| `AzureLoadBalancer` | Load balancer health probe source |
| `Storage` | Azure Storage IPs |
| `Sql` | Azure SQL IPs |
| `AzureCloud` | All Azure datacenter IPs |

---

### Azure Firewall Rule Processing Order

```
1. DNAT rules (inbound → translate to internal IP)
2. Network rules (L3/L4 IP/port matching)
3. Application rules (L7 FQDN matching)

If no rule matches → traffic is DENIED (implicit deny)
```

---

### Service Endpoint vs Private Endpoint

| | Service Endpoint | Private Endpoint |
|---|---|---|
| Cost | Free | Hourly + data fees |
| Private IP for service | ❌ (service keeps public IP) | ✅ |
| Blocks public internet access | ❌ (must configure separately) | ✅ (can disable public endpoint) |
| DNS change required | ❌ | ✅ |
| Works across VNets | ❌ | ✅ |

---

### Azure Bastion Subnet Requirements

```
Subnet name:  AzureBastionSubnet  (EXACT — cannot rename)
Minimum size: /26 (64 addresses)
Public IP:    Standard SKU required
VMs:          No public IP needed; no RDP/SSH ports needed in NSG
Connection:   Browser via TLS 443
```

---

### DDoS Protection Tiers

```
Infrastructure Protection (FREE)
  ├── Automatic; always on
  └── Basic volumetric mitigation only

DDoS IP Protection (PAID - per IP)
  ├── Basic adaptive mitigation
  └── Limited analytics

DDoS Network Protection (PAID - per VNet) ← EXAM FOCUS
  ├── Adaptive tuning (ML-based)
  ├── Attack analytics and telemetry
  ├── DDoS Rapid Response Team
  └── SLA cost protection guarantee
```

---

### WAF Modes

| Mode | Behavior | Default? |
|---|---|---|
| Detection | Logs threats; does NOT block | ✅ YES |
| Prevention | Actively blocks detected attacks | ❌ Must enable |

---

## 💻 Domain 3: Compute, Storage, Databases — Cheat Sheet

### Defender for Cloud Plans

| Plan | What It Protects |
|---|---|
| Defender for Servers P1 | MDE integration |
| **Defender for Servers P2** | **JIT, FIM, vulnerability assessment** |
| Defender for Storage | Blob/File — malware, anomalous access |
| Defender for SQL | Azure SQL + SQL on VM + Arc SQL |
| Defender for Containers | AKS + ACR |
| Defender for Key Vault | Unusual KV access |

---

### JIT VM Access Requirements and Behavior

```
Requires: Defender for Servers Plan 2
Default: Management ports BLOCKED in NSG

Process:
  1. User requests access → specifies IP + duration
  2. NSG rule added: Allow [user IP] on [port] for [duration]
  3. User connects via RDP/SSH/WinRM
  4. Duration expires → NSG rule automatically removed

Ports managed: 3389 (RDP), 22 (SSH), 5985/5986 (WinRM)
```

---

### Azure Key Vault Tiers

| Tier | Hardware | FIPS Level |
|---|---|---|
| Standard | Software | FIPS 140-2 L1 |
| Premium | HSM-backed | FIPS 140-2 L2 |
| Managed HSM | Dedicated HSM | FIPS 140-2 L3 |

### Key Vault Soft Delete + Purge Protection

```
Soft Delete:
  ✅ Always enabled (cannot disable)
  ↳ Deleted objects recoverable for 7–90 days

Purge Protection:
  ✅ Optional (but strongly recommended)
  ↳ Prevents permanent deletion during retention period
  ↳ Even Global Admins cannot purge protected objects
  ↳ Critical for: Databases using BYOK TDE, compliance
```

---

### Storage Security Options

| Method | Security Level | Notes |
|---|---|---|
| Account keys | Low-Medium | Full access; rotate regularly |
| Account SAS | Medium | Scoped; time-limited; uses account key |
| Service SAS | Medium | Single service; uses account key |
| **User Delegation SAS** | **High** | **Uses Azure AD; no account key exposed** |
| Azure AD + RBAC | High | Recommended for Blob/Queue/Table |

---

### Azure SQL Security Features

| Feature | What It Does | Data Changed? |
|---|---|---|
| TDE | Encrypts database files at rest | N/A |
| Always Encrypted | Client-side column encryption | N/A |
| **Dynamic Data Masking** | **Masks values in query results** | **NO** |
| Row-Level Security | Restricts row access | No |
| Advanced Threat Protection | Detects SQL injection, anomalies | No |

---

### Encryption Types for VMs and Disks

| Type | Technology | Keys |
|---|---|---|
| Server-Side Encryption (SSE) | AES-256 at storage layer | Microsoft-managed or CMK |
| **Azure Disk Encryption (ADE)** | **BitLocker (Win) / DM-Crypt (Linux)** | **Keys in Key Vault** |
| Encryption at Host | SSE at VM host | Microsoft-managed or CMK |

---

## 🔍 Domain 4: Security Operations — Cheat Sheet

### Microsoft Sentinel Architecture

```
DATA SOURCES
(connectors: AAD, M365, Defender, Syslog, CEF, etc.)
        ↓
LOG ANALYTICS WORKSPACE
        ↓
ANALYTICS RULES (detect threats → generate alerts)
        ↓
INCIDENTS (groups of related alerts)
        ↓
INVESTIGATION (entity graph, timeline, bookmarks)
        ↓
PLAYBOOKS / AUTOMATION (respond, contain, notify)
```

---

### Sentinel Analytics Rule Types

| Type | How It Works | Best For |
|---|---|---|
| Scheduled | KQL query runs on schedule | Custom detections |
| NRT | Runs every ~1 minute | Time-sensitive threats |
| Microsoft Security | Import Microsoft product alerts | Quick Microsoft integration |
| Anomaly | ML behavioral baseline | Behavioral deviations |
| **Fusion** | **ML multi-signal correlation** | **Multi-stage attack detection** |
| Threat Intelligence | Match IOCs from TI feeds | Known threat actors |

---

### Incident Status and Classification

```
Status:         New → Active → Closed

Classification (on close):
  True Positive  — Real attack, correctly detected
  False Positive — Not an attack; rule needs tuning
  Benign Positive — Real activity but not malicious in context
  Undetermined   — Cannot determine; needs more data
```

---

### KQL Quick Reference

```kusto
// Filter rows
| where TimeGenerated > ago(1h)
| where ResultType != "0"

// Select columns
| project TimeGenerated, UserPrincipalName, Location

// Aggregate
| summarize Count = count() by UserPrincipalName

// Filter aggregate results
| where Count > 5

// Add calculated column
| extend Domain = tostring(split(UserPrincipalName, "@")[1])

// Join tables
| join kind=inner (OtherTable | project key, extraField) on key

// Visualize
| render timechart
| render barchart

// Time helpers
ago(1h)    // 1 hour ago
ago(7d)    // 7 days ago
now()      // current time
bin(TimeGenerated, 5m)  // bucket by 5 minutes
```

---

### Azure Policy Effects (in priority order)

```
1. Disabled     — Policy not evaluated
2. Append       — Adds fields to resource
3. Modify       — Adds/changes tags or properties
4. Deny         — Blocks the operation ← BLOCKS CREATION
5. Audit        — Logs non-compliance; does NOT block
6. AuditIfNotExists  — Audits if related resource missing
7. DeployIfNotExists — Deploys config if it doesn't exist
```

---

### Log Destinations for Diagnostic Settings

| Destination | Best For |
|---|---|
| Log Analytics Workspace | KQL queries, Sentinel, long-term retention (up to 730 days) |
| Azure Storage Account | Long-term archival (> 2 years), compliance, low cost |
| Azure Event Hub | Real-time streaming to external SIEM/tools |
| Partner solution | Datadog, Elastic, etc. |

---

### Azure AD Log Retention

| Log Type | Free | P1/P2 | With Diagnostic Settings |
|---|---|---|---|
| Sign-in logs | 7 days | 30 days | Up to 730 days (Log Analytics) |
| Audit logs | 7 days | 30 days | Up to 730 days |

---

## ⚡ Exam Day Quick Reference

### "Which service do I use for...?" Decision Tree

```
Q: Block management ports by default, open temporarily?
A: Just-in-Time (JIT) VM Access (requires Defender for Servers P2)

Q: RDP/SSH to VM without public IP or open ports?
A: Azure Bastion

Q: Filter HTTP/HTTPS by domain name (L7)?
A: Azure Firewall (application rule) or WAF

Q: Block specific IP ranges from a VM NIC or subnet?
A: NSG

Q: Protect web app from SQL injection and XSS?
A: WAF (Application Gateway or Front Door)

Q: Mitigate volumetric DDoS with ML-based tuning?
A: DDoS Network Protection

Q: Authenticate app to Azure services without credentials?
A: Managed Identity

Q: Store secrets, keys, certificates securely?
A: Azure Key Vault

Q: JIT privileged role activation with approval?
A: Privileged Identity Management (PIM)

Q: Detect and respond to risky sign-ins automatically?
A: Identity Protection + Conditional Access

Q: Collect all security logs, detect threats, automate response?
A: Microsoft Sentinel (SIEM + SOAR)

Q: Monitor security posture, Secure Score, recommendations?
A: Microsoft Defender for Cloud

Q: Periodically review who has access to resources?
A: Access Reviews (Azure AD P2)

Q: Enforce resource configuration across subscription?
A: Azure Policy

Q: Connect VNet to Azure PaaS privately (no public IP for service)?
A: Private Endpoint

Q: Route VNet traffic to Azure service over backbone (service still has public IP)?
A: Service Endpoint
```

---

### Common Exam Traps

| Trap | Correct Answer |
|---|---|
| "Security Reader can dismiss alerts" | ❌ — Needs **Security Admin** |
| "Security defaults + Conditional Access both active" | ❌ — Mutually exclusive; disable security defaults when using CA |
| "WAF blocks attacks by default" | ❌ — Default is **Detection** mode (logging only) |
| "Global Admin bypasses Conditional Access" | ❌ — Global Admins are subject to CA unless excluded |
| "Service endpoint assigns private IP to service" | ❌ — Private Endpoint does this; service endpoint routes traffic |
| "Soft delete prevents permanent deletion" | ❌ — **Purge protection** prevents it; soft delete only delays it |
| "Key Vault Reader can read secret values" | ❌ — Needs **Key Vault Secrets User** role |
| "ADE and SSE are the same thing" | ❌ — ADE = BitLocker/DM-Crypt + KV; SSE = storage-layer AES-256 |
| "Fusion rules are custom KQL queries" | ❌ — Fusion is ML-powered multi-signal correlation; cannot be customized |
| "PIM available on Azure AD P1" | ❌ — PIM requires **P2** |

---

*Good luck on the AZ-500 exam! 🎯*
