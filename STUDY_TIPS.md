# AZ-500 Study Tips & Exam Strategy

---

## 🎯 Exam-Day Tactics

1. **Read the question twice.** Microsoft often asks for the *most* appropriate or *least* privileged solution.
2. **Flag and return.** Mark uncertain questions for review; don't spend > 3 minutes on any single question.
3. **Case studies first.** Case study scenarios share context — read the background once, then answer all linked questions.
4. **Eliminate obviously wrong answers.** On 4-option questions, you can usually drop 1–2 immediately.
5. **Trust keyword anchors.** Words like *"without storing credentials"*, *"least privilege"*, *"without changing existing code"* point directly to specific services (Managed Identities, RBAC, Key Vault references).
6. **Watch for "NOT" and "EXCEPT".** Highlight these in your reading pass.
7. **Pace yourself.** 120 minutes for ~55 questions = ~2 min/question. Leave 15 min for review.

---

## 🔥 High-Priority Topic Matrix

| Topic | Exam Weight | Likely Question Types |
|---|---|---|
| Conditional Access policies | Very High | Scenario: which policy satisfies requirement X |
| Privileged Identity Management (PIM) | Very High | Activation, assignment, Just-in-Time access |
| Azure RBAC vs Entra ID roles | High | Scope, least-privilege assignments |
| Managed Identities (system vs user-assigned) | High | Removing credential storage need |
| NSG rules & flow logs | High | Allow/deny logic, effective rules |
| Azure Firewall (Standard vs Premium) | High | FQDN rules, TLS inspection, IDPS |
| Private Endpoints vs Service Endpoints | High | Data exfiltration prevention |
| Key Vault access models | Very High | RBAC vs Access Policies, soft delete |
| Defender for Cloud Secure Score | High | Recommendations, plans |
| Microsoft Sentinel | High | Connectors, KQL analytics rules, playbooks |
| Azure Disk Encryption vs SSE | Medium | CMK, PMK, encryption at rest |
| JIT VM Access | High | Configuration, approval flow |
| SAS Token types | Medium | Service, Account, User Delegation |
| Always Encrypted | Medium | Column-level, client-side key |
| Dynamic Data Masking | Medium | Rules, privileged users |
| Azure DDoS Protection | Medium | Basic vs Standard tiers |
| Azure Bastion SKUs | Medium | Basic vs Standard features |

---

## 🔑 Key Service Comparisons

### Azure Firewall Standard vs Premium

| Feature | Standard | Premium |
|---|---|---|
| FQDN filtering | ✅ | ✅ |
| Network/App rules | ✅ | ✅ |
| Threat intelligence | ✅ (alert) | ✅ (alert + deny) |
| TLS inspection | ❌ | ✅ |
| IDPS (Intrusion Detection & Prevention) | ❌ | ✅ |
| URL categories | ❌ | ✅ |
| Web categories | ❌ | ✅ |

### NSG vs Azure Firewall

| Characteristic | NSG | Azure Firewall |
|---|---|---|
| Layer | L3/L4 | L3–L7 |
| Scope | Subnet / NIC | Centralised hub |
| FQDN rules | ❌ | ✅ |
| Stateful | ✅ | ✅ |
| Cost | Free | ~$1.25/hr + data processing |
| Use case | Basic allow/deny at subnet | Centralised egress control |

### Private Endpoint vs Service Endpoint

| | Private Endpoint | Service Endpoint |
|---|---|---|
| How | Private IP in your VNet | Optimised route over public IP |
| Data exfiltration prevention | ✅ (traffic stays private) | ❌ (still reaches public IP) |
| On-premises access | ✅ (via VPN/ER) | ❌ |
| DNS requirement | Custom DNS / Private DNS Zone | None |
| Cost | Per endpoint + zone | Free |

### Key Vault: RBAC vs Access Policies

| | RBAC | Access Policies |
|---|---|---|
| Management plane | Azure RBAC | Azure RBAC |
| Data plane | Azure RBAC (Key Vault built-in roles) | Vault-level access policies |
| Granularity | Individual key/secret/cert | Per-object type only |
| Audit | Unified Azure Activity Log | Separate Key Vault diagnostic logs |
| Recommendation | ✅ Preferred (newer) | Legacy |

### SAS Token Types

| Type | Signed By | Scope | Revoke Without Key Rotation |
|---|---|---|---|
| Account SAS | Storage account key | Multiple services/resources | ❌ |
| Service SAS | Storage account key | Single service | ❌ |
| User Delegation SAS | Entra ID credentials | Blob/ADLS Gen2 | ✅ (invalidate Entra token) |

### DDoS Protection Tiers

| Tier | Cost | Features |
|---|---|---|
| Network Protection (Basic) | Free | Always-on, automatic volumetric mitigation |
| Network Protection (Standard) | ~$2,944/mo for first 100 public IPs | Adaptive tuning, DDoS Rapid Response, cost protection, attack analytics, SLA guarantee |
| IP Protection | Per-IP pricing | Single public IP, subset of Standard features |

---

## 📅 8-Week Study Plan

| Week | Focus | Goal |
|---|---|---|
| **1** | Entra ID fundamentals, RBAC, Managed Identities | Complete Domain 1 docs + Lab 01 |
| **2** | Conditional Access, PIM, Identity Protection | Practice questions on identity |
| **3** | NSGs, Service Tags, ASGs, Private Link | Complete Domain 2 docs |
| **4** | Azure Firewall, DDoS, WAF, VPN/ExpressRoute | Complete Lab 02 + run networking script |
| **5** | Compute security (JIT, Bastion, ADE), AKS | Complete Domain 3 docs + Lab 03 |
| **6** | Storage (SAS, service endpoints), SQL (ATP, DDM, AE) | Run compute-storage script |
| **7** | Key Vault, Defender for Cloud, Sentinel | Complete Domain 4 docs + Lab 04 |
| **8** | Full review, practice exams, gap analysis | Score ≥ 80% on 3 consecutive practice sets |

### Daily Routine Suggestion (1.5 hrs/day)

- **30 min** — Read/annotate one study guide section
- **30 min** — Hands-on: portal or CLI exercises
- **30 min** — Practice questions (15–20 questions)

---

## ⚠️ Common Failure Modes

| Trap | Clarification |
|---|---|
| Confusing RBAC **Owner** with **User Access Administrator** | Owner can do everything *including* resource management; UAA can *only* manage role assignments |
| Thinking NSG alone stops data exfiltration | NSGs work at IP level; use Private Endpoints to keep storage/SQL off the public internet |
| Mixing up ADE (Azure Disk Encryption) and SSE (Server-Side Encryption) | ADE encrypts inside the VM OS using DM-Crypt/BitLocker; SSE encrypts on the storage backend |
| Applying Key Vault access policies when RBAC mode is enabled | Once RBAC mode is on, access policies are ignored — use data-plane RBAC roles instead |
| Forgetting soft-delete ≠ purge protection | Soft-delete lets you recover deleted keys; purge protection *prevents* permanent deletion during retention period |
| Thinking Sentinel = Defender for Cloud | Defender for Cloud generates *security recommendations*; Sentinel is the *SIEM/SOAR* (incidents + KQL) |
| Assuming PIM is only for Entra ID roles | PIM now covers Azure resource roles (RBAC) too |
| Confusing User Delegation SAS with Service SAS | User Delegation SAS uses Entra ID credentials — the only SAS type that can be revoked without key rotation |
| Mixing up Always Encrypted vs Dynamic Data Masking | Always Encrypted protects data *in motion to client*; DDM masks data in *query results* but data is unencrypted in DB |
| Forgetting JIT requires Defender for Servers Plan 2 | JIT VM Access is a Defender for Servers feature, not available on free tier |

---

## 🧩 Memory Aids

- **PIM = "Praise In Meetings"** → Approve → Activate → Time-bound
- **NSG rule priority** → Lower number = Higher priority (100 beats 200)
- **Secure Score** → Percentage of *implemented* recommendations / total max points
- **Sentinel connectors order** → Connect → Enable analytics rule → Create incident → Run playbook
- **Key Vault roles** → `Key Vault Secrets Officer` (read+write secrets) vs `Key Vault Secrets User` (read only)
- **RBAC scope hierarchy** → Management Group → Subscription → Resource Group → Resource (inherits down)

---

*Good luck on your AZ-500 exam! 🚀*
