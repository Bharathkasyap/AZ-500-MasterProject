# AZ-500 Quick Reference / Cheat Sheet

> **Back to:** [README](../README.md)

> Use this as a last-minute review the day before your exam.

---

## Exam At a Glance

| Item | Detail |
|------|--------|
| **Exam Code** | AZ-500 |
| **Exam Name** | Microsoft Azure Security Technologies |
| **Certification** | Microsoft Certified: Azure Security Engineer Associate |
| **Questions** | 40–60 (multiple choice, case study, drag-and-drop, hot area) |
| **Duration** | 120 minutes |
| **Passing Score** | 700 / 1000 |
| **Domains** | Identity (25–30%), Networking (20–25%), Compute/Storage/DB (20–25%), Security Ops (25–30%) |

---

## Domain 1: Identity Quick Reference

### MFA Method Security Ranking (strongest → weakest)
```
FIDO2 Security Key ≥ Windows Hello for Business > Microsoft Authenticator (push) > OATH hardware token > OATH software token > SMS/Voice (AVOID)
```

### Conditional Access — Policy Anatomy
```
IF [Users/Groups] access [Cloud Apps]
AND [Conditions: risk, location, device, client app]
THEN [Grant: allow/block/require MFA/require compliant device]
     [Session: sign-in frequency, persistent session, CAE]
```

### PIM Key Concepts
| Term | Meaning |
|------|---------|
| Eligible | Can activate the role (JIT) |
| Active | Role is always active (avoid for privileged roles) |
| Activation | Request to use an eligible role |
| Activation duration | Max hours role stays active (1–24h) |
| Access Review | Periodic certification of role assignments |

### RBAC Scope Hierarchy
```
Management Group > Subscription > Resource Group > Resource
(Higher scope = inherited by all children)
```

### Critical Built-in Roles
| Role | Can Assign Roles? | Can Delete Resources? | Can Read Secrets? |
|------|------------------|----------------------|------------------|
| Owner | ✅ | ✅ | ❌ (need KV role) |
| Contributor | ❌ | ✅ | ❌ |
| Reader | ❌ | ❌ | ❌ |
| User Access Administrator | ✅ (RBAC only) | ❌ | ❌ |
| Key Vault Secrets User | ❌ | ❌ | ✅ (read only) |
| Key Vault Secrets Officer | ❌ | ❌ | ✅ (CRUD) |

### B2B vs. B2C
| | B2B | B2C |
|-|-----|-----|
| Who | External partners / vendors | Customers / end-users |
| Identity in | Their tenant / home IdP | Your B2C tenant |
| Setup | Invite to your tenant as guest | Separate tenant + user flows |
| License | Guest = 1/5 of P1 MAU ratio | Consumption-based (MAU) |

---

## Domain 2: Networking Quick Reference

### NSG Rule Processing
```
Rules evaluated: lowest priority number first (100 = first)
Default deny all (65500) catches anything not explicitly allowed
Both subnet NSG AND NIC NSG must allow traffic (AND logic)
```

### Azure Firewall Rule Priority
```
Processing order: DNAT → Network Rules → Application Rules
First match within a collection wins
```

### Key Service Tags for NSG Rules
| Tag | Use When |
|-----|---------|
| `Internet` | Block/allow all public internet |
| `AzureLoadBalancer` | Allow load balancer health probes |
| `VirtualNetwork` | Allow VNet-to-VNet traffic |
| `Storage` | Allow Azure Storage service traffic |
| `Sql` | Allow Azure SQL service traffic |
| `AzureCloud` | Allow all Azure datacenters |

### Private Endpoint DNS Zones (Most Common)
| Service | Private DNS Zone |
|---------|-----------------|
| Blob Storage | `privatelink.blob.core.windows.net` |
| Azure SQL | `privatelink.database.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| ACR | `privatelink.azurecr.io` |
| Service Bus | `privatelink.servicebus.windows.net` |
| Event Hub | `privatelink.servicebus.windows.net` (Event Hub namespaces share the Service Bus DNS zone) |

### Service Endpoint vs. Private Endpoint
| | Service Endpoint | Private Endpoint |
|-|-----------------|-----------------|
| Private IP in VNet | ❌ | ✅ |
| Disable public endpoint | ❌ | ✅ |
| Cross-region | ❌ | ✅ |
| DNS change needed | ❌ | ✅ |
| Cost | Free | Paid |

### Bastion Requirements
- Subnet name: **must be `AzureBastionSubnet`**
- Minimum subnet size: **/26**
- SKU: Basic (RDP/SSH), Standard (native client + private-only)

### DDoS Protection Tiers
| Tier | Scope | Use Case |
|------|-------|---------|
| Basic (built-in) | Azure infrastructure | Always on, no user config |
| IP Protection | Per public IP | Cost-optimized |
| Network Protection | Per VNet (all public IPs) | Production; attack analytics + DRR |

---

## Domain 3: Compute/Storage/DB Quick Reference

### Encryption Types Comparison
| Encryption | Protects | Key Owner | Where Applied |
|-----------|---------|-----------|--------------|
| SSE (PMK) | Data at rest | Microsoft | Default; all managed disks |
| SSE (CMK) | Data at rest | Customer (Key Vault) | Managed disk DEK wrapped by Key Vault key |
| ADE (BitLocker/DM-Crypt) | OS/data disk in guest | Customer (Key Vault) | Inside VM OS |
| TDE (SQL) | SQL files + backups | Microsoft or Customer | SQL server layer |
| Always Encrypted | Column data | Customer (Key Vault/cert) | Client driver layer |

### SAS Token Types (Security Ranking)
```
User Delegation SAS (Entra ID signed) > Service SAS (key signed) > Account SAS (key signed)
```
**Always specify: HTTPS only + minimum permissions + shortest expiry**

### Key Vault Access Models
| Model | Recommended? | Notes |
|-------|-------------|-------|
| RBAC | ✅ Yes | Supports PIM; Azure RBAC roles |
| Access Policies | ⚠️ Legacy | Per-principal per object type; no PIM |

### Key Vault Roles
| Role | Secrets | Keys | Certs |
|------|---------|------|-------|
| KV Administrator | CRUD | CRUD | CRUD |
| KV Secrets Officer | CRUD | ❌ | ❌ |
| KV Secrets User | Get | ❌ | ❌ |
| KV Crypto Officer | ❌ | CRUD | ❌ |
| KV Crypto User | ❌ | Use (sign/verify/encrypt/decrypt) | ❌ |

### Defender for Cloud Plans Quick List
| Plan | Key Benefit |
|------|------------|
| Defender for Servers P1 | JIT access, Defender for Endpoint |
| Defender for Servers P2 | + Vuln assessment, FIM, AAC |
| Defender for Storage | Malware scanning, anomaly detection |
| Defender for SQL | ATP for SQL injection, anomalies |
| Defender for Containers | ACR scanning, AKS runtime protection |
| Defender for Key Vault | KV anomalous access detection |
| Defender CSPM | Attack path analysis, CIEM |

---

## Domain 4: Security Operations Quick Reference

### Sentinel Component Map
```
Data Sources
    ↓ (Data Connectors)
Log Analytics Workspace
    ↓ (Analytics Rules: KQL)
Alerts / Incidents
    ↓ (Automation Rules + Playbooks = Logic Apps)
Automated Response
```

### Analytics Rule Types
| Type | Detection Method | Best For |
|------|-----------------|---------|
| Scheduled | KQL on a schedule | Known threat patterns |
| NRT | KQL near-real-time | High-urgency detections |
| Microsoft Security | Auto-import from Defender products | Unified incident view |
| Fusion | ML multi-stage | Complex attack chains |
| Anomaly | ML behavioral baseline | Unknown threat patterns |
| Threat Intelligence | IoC matching | Indicator-based detection |

### Azure Policy Effects (Priority Order)
```
Disabled → Append → Modify → Audit → AuditIfNotExists → Deny → DeployIfNotExists → DenyAction
```
| Effect | Blocks resource? | Remediates? |
|--------|-----------------|------------|
| Audit | ❌ | ❌ |
| Deny | ✅ | ❌ |
| DeployIfNotExists | ❌ | ✅ |
| Modify | Conditionally | ✅ |

### Resource Locks
| Lock | Read | Modify | Delete |
|------|------|--------|--------|
| CanNotDelete | ✅ | ✅ | ❌ |
| ReadOnly | ✅ | ❌ | ❌ |

**Locks override Owner role** — must remove lock before deleting (requires `Microsoft.Authorization/locks/delete`)

### Incident Response Steps (Sentinel)
```
1. Triage → 2. Enrich → 3. Investigate → 4. Contain → 5. Eradicate → 6. Recover → 7. Close + Lessons Learned
```

### Key Log Tables for Security Queries
| Table | What It Contains |
|-------|----------------|
| `AzureActivity` | ARM control plane operations (create/delete/update) |
| `SigninLogs` | Entra ID interactive sign-ins |
| `AuditLogs` | Entra ID admin operations (role assignments, user changes) |
| `SecurityEvent` | Windows Security Event Log (from VMs with agent) |
| `Syslog` | Linux logs from VMs |
| `StorageBlobLogs` | Storage access and operations |
| `AzureFirewallNetworkRule` | Firewall network rule matches |
| `KeyVaultLogs` / `AzureDiagnostics` | Key Vault access audit |
| `SecurityAlert` | Defender for Cloud and Sentinel alerts |
| `SecurityIncident` | Sentinel incidents |

---

## Common "What Service Does This?" Questions

| Requirement | Answer |
|-------------|--------|
| Block all traffic to a subnet by default | NSG with deny all rule |
| Inspect outbound internet traffic by FQDN | Azure Firewall (Application Rule) |
| Protect against DDoS volumetric attacks | Azure DDoS Protection Network Protection |
| Protect web app from SQL injection (L7) | WAF on Application Gateway or Front Door |
| Browser-based RDP/SSH without public IP on VM | Azure Bastion |
| Open management ports only on-demand for N hours | JIT VM Access (Defender for Servers) |
| Store secrets/keys/certs centrally with audit trail | Azure Key Vault |
| Encrypt SQL data at rest (default, no config) | Transparent Data Encryption (TDE) |
| Encrypt specific columns from DBAs too | Always Encrypted |
| Auto-detect anomalous storage access/malware | Defender for Storage |
| JIT privileged role assignment with approval | PIM (Privileged Identity Management) |
| Policy-based authentication requiring MFA | Conditional Access |
| Detect risky sign-ins / leaked credentials | Identity Protection (Entra ID P2) |
| Collect all logs, detect threats, SOAR | Microsoft Sentinel |
| CSPM + secure score + recommendations | Defender for Cloud |
| Compliance mapping (PCI, NIST, CIS) | Defender for Cloud Regulatory Compliance |
| Block resource deletion by all principals | Resource Lock (CanNotDelete) |
| Enforce config on all resources automatically | Azure Policy (Deny or DeployIfNotExists) |
| Connect app to Azure services without credentials | Managed Identity |
| Access Azure services via private IP, no public | Private Endpoint |

---

## Frequently Confused Pairs

| Service A | vs. | Service B | Key Difference |
|-----------|-----|-----------|---------------|
| Security Defaults | Conditional Access | Defaults = free but inflexible; CA = P1, fine-grained control |
| Service Endpoint | Private Endpoint | SE = no private IP; PE = private IP + disables public endpoint |
| TDE | Always Encrypted | TDE = server encrypts at rest; AE = client encrypts, server never sees plaintext |
| NSG | Azure Firewall | NSG = L4 (IP/port); Firewall = L3-L7 (FQDN, URL, IDPS) |
| Audit policy effect | Deny policy effect | Audit = logs non-compliance; Deny = blocks resource creation |
| B2B | B2C | B2B = partners in your tenant; B2C = consumers in separate tenant |
| PIM eligible | PIM active | Eligible = must activate; Active = always on |
| Defender for Cloud | Microsoft Sentinel | Defender = CSPM/CWPP (posture + alerts); Sentinel = SIEM/SOAR (collect/detect/respond) |
| System-assigned MI | User-assigned MI | System = tied to 1 resource lifecycle; User = shared across multiple resources |
| Soft delete | Purge protection | Soft delete = recoverable window; Purge protection = cannot force-delete during window |

---

## Exam Day Tips

1. **Read the full question and ALL answer options** before selecting. Many options are partially correct; pick the BEST one.

2. **Pay attention to "LEAST privilege"** — always pick the role/permission with narrowest scope.

3. **"Without requiring..."** phrasing usually points to managed identities or Conditional Access exclusions.

4. **"Automatically"** phrasing usually points to Azure Policy, PIM access reviews, or Sentinel automation rules.

5. **"Prevent"** vs. **"detect"** — Prevent = Deny policy / Conditional Access block / NSG deny; Detect = Audit policy / Defender alerts / Sentinel.

6. **Case studies:** Read the business/technical requirements section carefully. Requirements often specify constraints (e.g., "must not use public IPs") that eliminate answer options.

7. **Flag and return** to questions you're unsure about. Don't spend more than 2 minutes on a single question.

8. **Pace yourself:** 120 minutes ÷ ~50 questions ≈ 2.4 minutes per question.

---

> **Back to:** [README](../README.md) | **Also see:** [Practice Questions →](practice-questions.md) | [Labs →](labs.md)
