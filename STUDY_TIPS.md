# AZ-500 Exam Tips & Study Strategies

> Use this guide in conjunction with the domain study guides to maximize your exam score.

---

## ⏱️ Time Management on Exam Day

- **Total time:** 120 minutes
- **Number of questions:** typically 40–60 (mix of case studies and standalone questions)
- **Pace yourself:** aim for ~2 minutes per standalone question; allocate ~20–25 min for a case study
- **Flag and return:** flag uncertain questions and revisit them rather than spending too long on any single item
- **Case studies first or last:** some candidates prefer answering case studies first while focus is sharp; others prefer warming up with standalone questions — pick what works for you

---

## 📝 Question Strategies

### Multiple-Choice (Single Answer)
- Read the question twice and identify the **key constraint** (e.g., "least privilege", "no additional cost", "without redeploying")
- Eliminate clearly wrong answers first
- Watch for distractor answers that use real Azure service names in the wrong context

### Multiple-Choice (Multiple Answer)
- The number of correct answers is usually stated — "select TWO"
- Choose answers that independently satisfy the requirement; avoid redundant pairs

### Drag-and-Drop / Build-List / Hot-Area
- These test **sequence knowledge** (e.g., steps to enable PIM) or **mapping knowledge** (feature → service)
- Review step-by-step processes in labs before the exam

### Case Studies
- Read the **Requirements** and **Current Environment** sections before reading questions
- Note constraints such as "on-premises AD sync" or "no public IP exposure"
- Answers are often found in the requirements — refer back frequently

---

## 🎓 High-Priority Topics (Most Frequently Tested)

Based on community exam feedback and Microsoft's published skill weighting:

### Must-Know Concepts
| Topic | Why It Matters |
|---|---|
| Azure AD Conditional Access | Policy construction, named locations, sign-in risk |
| Privileged Identity Management (PIM) | Just-in-time, approval workflows, access reviews |
| Azure RBAC vs Azure AD roles | Scope, inheritance, built-in vs custom roles |
| Network Security Groups (NSGs) | Rule priority, default rules, effective security rules |
| Azure Firewall vs NSGs | When to use each, DNAT/SNAT, Threat Intelligence |
| Azure Key Vault | Access policies vs RBAC, soft delete, purge protection |
| Microsoft Defender for Cloud | Secure Score, recommendations, regulatory compliance |
| Microsoft Sentinel | Data connectors, analytics rules, playbooks (Logic Apps) |
| Just-in-Time VM access | How JIT works, required permissions, request flow |
| Storage security | SAS tokens (service vs account vs user delegation), firewall rules, private endpoints |
| Managed identities | System-assigned vs user-assigned, use cases |
| Azure Policy | Deny, Audit, DeployIfNotExists effects |

---

## 🔑 Key Differences to Memorize

### Azure Firewall vs NSG
| Feature | Azure Firewall | NSG |
|---|---|---|
| OSI Layer | 4 + 7 (Application) | 4 (Transport) |
| FQDN filtering | ✅ Yes | ❌ No |
| Threat Intelligence | ✅ Yes | ❌ No |
| Cost | Higher | Lower (included) |
| Scope | VNet-wide / hub | Per subnet or NIC |

### Managed Identity Types
| Type | Lifecycle | Use Case |
|---|---|---|
| System-assigned | Tied to Azure resource | Single-resource scenarios |
| User-assigned | Independent resource | Shared across multiple resources |

### Key Vault Access Models
| Model | Granularity | Notes |
|---|---|---|
| Access Policies | Per principal (vault-level) | Legacy; cannot use Deny |
| Azure RBAC | Per resource (key/secret/cert) | Recommended; supports Deny |

### SAS Token Types
| Type | Signed With | Scope |
|---|---|---|
| Account SAS | Storage account key | Multiple services |
| Service SAS | Storage account key | Single service |
| User Delegation SAS | Azure AD credentials | Blob only (most secure) |

---

## 🗓️ Recommended 8-Week Study Plan

| Week | Focus |
|---|---|
| 1 | Domain 1: Azure AD fundamentals, RBAC, Conditional Access |
| 2 | Domain 1: PIM, Identity Protection, managed identities |
| 3 | Domain 2: VNets, NSGs, Azure Firewall, DDoS |
| 4 | Domain 2: Private Endpoints, VPN Gateway, ExpressRoute security |
| 5 | Domain 3: VM security (JIT, Endpoint Protection), AKS security |
| 6 | Domain 3: Storage security, SQL security, Cosmos DB security |
| 7 | Domain 4: Defender for Cloud, Azure Policy, Key Vault |
| 8 | Domain 4: Microsoft Sentinel; full review + practice exams |

---

## 🧪 Practice & Validation

- **Microsoft Learn practice assessments:** [aka.ms/az500practice](https://learn.microsoft.com/en-us/certifications/practice-assessments-for-microsoft-certifications)
- **MeasureUp:** Official Microsoft exam prep provider
- **Whizlabs / Udemy:** Community exam dumps with explanations (use for practice only — understand each answer, do not memorize dumps)
- **Microsoft Docs:** When unsure, trace every answer back to official documentation

### Lab Environments
- **Azure Free Account:** 30-day $200 credit for hands-on labs
- **Microsoft Learn sandboxes:** Free, time-limited Azure environments inside Learn modules
- **This repo's `scripts/` and `labs/` directories:** Pre-built exercises mapped to exam objectives

---

## ❌ Common Exam Mistakes

1. **Confusing Azure AD roles with Azure RBAC roles** — they are separate control planes
2. **Assuming NSGs block all traffic by default** — they allow all outbound by default
3. **Forgetting that PIM requires Azure AD Premium P2** — note when questions mention licensing
4. **Missing the "least privilege" constraint** — always pick the minimum required permission
5. **Not reading all answer options** — the "best" answer may be the last one listed

---

## 📅 Exam Registration

1. Sign in to [Microsoft Learn](https://learn.microsoft.com/)
2. Navigate to the [AZ-500 certification page](https://learn.microsoft.com/en-us/certifications/exams/az-500/)
3. Click **Schedule exam** — exams are delivered by Pearson VUE (in-person or online proctored)
4. Choose **Online Proctored** for maximum scheduling flexibility
5. Use your **Microsoft Certification dashboard** to track your score and certificate

---

*Good luck on your exam! 🎉 Remember: understand the "why" behind every answer, and you will pass.*
