# AZ-500 Exam Information & Strategy Guide

## 🎓 Exam Overview

| Field | Details |
|-------|---------|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Certification** | Microsoft Certified: Azure Security Engineer Associate |
| **Cost** | $165 USD |
| **Passing Score** | 700 / 1000 |
| **Total Questions** | 40–60 questions |
| **Performance-Based Lab** | May include 1 lab with ~12 sub-tasks |
| **Duration** | 150 minutes |
| **Proctoring** | Pearson VUE |
| **Renewal** | Annual (free renewal assessment via Microsoft Learn) |

---

## 📋 Question Types

| Type | Description |
|------|-------------|
| **Multiple Choice** | Single best answer from 4–5 options |
| **Multi-Select** | Select 2 or more correct answers |
| **Drag-and-Drop** | Match or order items correctly |
| **Case Studies** | A scenario followed by multiple questions sharing the same context |
| **Performance-Based Labs** | Live Azure portal tasks (or simulated) — no Ctrl+Z! |

> ⚠️ **Important:** Performance-based lab questions cannot be reviewed or changed once submitted.

---

## 📊 Domain Weightage

| Domain | Topic | Weight | Recommended Study Time |
|--------|-------|--------|------------------------|
| 1 | Secure Identity and Access | 15–20% | ~2–3 days |
| 2 | Secure Networking | 20–25% | ~3–4 days |
| 3 | Secure Compute, Storage, and Databases | 20–25% | ~3–4 days |
| 4 | Secure Azure using Microsoft Defender for Cloud and Sentinel | 30–35% | ~4–5 days |

---

## 🗓️ Recommended Study Plan (4-Week)

### Week 1 — Identity and Access (Domain 1)
- Day 1–2: Microsoft Entra ID, users, groups, RBAC
- Day 3–4: Conditional Access, MFA, SSPR
- Day 5–6: PIM, Identity Protection, Managed Identities
- Day 7: B2B/B2C, review, practice questions

### Week 2 — Secure Networking (Domain 2)
- Day 1–2: NSGs, Azure Firewall, WAF
- Day 3–4: DDoS Protection, Private Link, Bastion
- Day 5–6: VPN Gateway, ExpressRoute, Front Door
- Day 7: Network Watcher, review, practice questions

### Week 3 — Compute, Storage, Databases (Domain 3)
- Day 1–2: Azure Key Vault, disk encryption, VM security
- Day 3–4: Storage account security, SAS tokens, RBAC for storage
- Day 5–6: Azure SQL security, Always Encrypted, TDE
- Day 7: Container security (AKS, ACR), review, practice questions

### Week 4 — Defender for Cloud and Sentinel (Domain 4)
- Day 1–2: Microsoft Defender for Cloud, Secure Score, recommendations
- Day 3–4: Defender plans (servers, storage, SQL, Kubernetes)
- Day 5: Microsoft Sentinel — workspaces, connectors, analytics rules
- Day 6: Sentinel playbooks, hunting, MITRE ATT&CK
- Day 7: Full review, timed practice exam

---

## 💡 Exam Tips and Strategies

### Before the Exam
- ✅ Register at [Pearson VUE](https://home.pearsonvue.com/microsoft) at least 1 week in advance.
- ✅ Complete all Microsoft Learn learning paths for AZ-500.
- ✅ Perform hands-on labs in a free Azure subscription (Azure Free Account).
- ✅ Take at least 3 full practice exams.
- ✅ Review Microsoft documentation for services you're weakest on.

### During the Exam
- ✅ **Read questions twice** — Azure questions often include important qualifiers like "least privilege," "most secure," or "without increasing cost."
- ✅ **Flag and skip** difficult questions — come back at the end.
- ✅ **For multi-select** — all correct answers must be selected for full credit.
- ✅ **Time management**: ~2 minutes per question. For 60 questions = 120 minutes, leaving 30 minutes for review.
- ✅ **Performance labs first**: Microsoft often places labs near the start; complete them before case studies.
- ✅ **Eliminate obviously wrong answers** to improve odds on unknowns.

### Key Words to Watch For
| Keyword | Implication |
|---------|-------------|
| "Least privilege" | Use minimum permissions / RBAC over Owner |
| "Without downtime" | Consider blue-green, availability zones |
| "At rest" | Encryption (TDE, SSE, BitLocker) |
| "In transit" | TLS, HTTPS, VPN |
| "Prevent" | Deny/block (Firewall rules, NSG deny) |
| "Detect" | Monitor/alert (Defender, Sentinel) |
| "Respond" | Playbooks, automation, SOAR |
| "Zero-trust" | Verify explicitly, least privilege, assume breach |

---

## 🔑 High-Priority Topics (by Exam Weight)

### Must-Know Services
1. **Microsoft Defender for Cloud** — Secure Score, recommendations, Defender plans
2. **Microsoft Sentinel** — SIEM/SOAR, analytics rules, workbooks, playbooks
3. **Microsoft Entra ID** — Conditional Access, PIM, Identity Protection
4. **Azure Key Vault** — Secrets, keys, certificates, access policies vs RBAC
5. **Network Security Groups** — Rules, priority, default rules, ASGs
6. **Azure Firewall** — DNAT, network rules, application rules, Premium features
7. **Private Endpoints** — DNS configuration, network isolation
8. **Azure Policy** — Definitions, initiatives, compliance, remediation

### Common Exam Traps
- **Azure AD vs Entra ID**: Microsoft rebranded Azure Active Directory to Microsoft Entra ID in 2023. Both names may appear.
- **NSG vs Azure Firewall**: NSGs are for subnet/NIC level; Azure Firewall is for entire VNet or cross-VNet.
- **Defender for Cloud Secure Score**: Increasing it requires implementing security recommendations, not just enabling plans.
- **PIM activation vs assignment**: Just-in-time vs permanent assignment distinction.
- **Managed Identity vs Service Principal**: Managed identities don't require credential management.

---

## 🔗 Official Resources

| Resource | URL |
|----------|-----|
| Exam Page | https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/ |
| Official Study Guide | https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-500 |
| Microsoft Learn Path | https://learn.microsoft.com/en-us/training/courses/az-500t00 |
| Azure Security Docs | https://learn.microsoft.com/en-us/azure/security/ |
| Pearson VUE Registration | https://home.pearsonvue.com/microsoft |
| Microsoft Renewal Assessments | https://learn.microsoft.com/en-us/credentials/certifications/renewal/ |

---

## 📝 Practice Exam Resources

- **Microsoft Learn** — Free practice assessments available on the exam page
- **MeasureUp** — Official Microsoft practice tests (paid)
- **Whizlabs** — AZ-500 practice tests (paid, highly rated)
- **ExamTopics** — Community-shared questions (free, use for familiarization only)
- **A Cloud Guru / Pluralsight** — Video courses with labs

---

## ✅ Day-Before Checklist

- [ ] Confirm exam appointment time and location (or online proctoring setup)
- [ ] Test your system if taking online: camera, microphone, stable internet
- [ ] Have a valid government-issued photo ID ready
- [ ] Review your notes on Defender for Cloud and Sentinel (highest weight domain)
- [ ] Review your notes on Conditional Access and PIM
- [ ] Review Azure Key Vault (access policies vs RBAC model)
- [ ] Get 8 hours of sleep — don't cram the night before
- [ ] Arrive or log in 15 minutes early

---

## 🏆 After Passing

- You will receive **Microsoft Certified: Azure Security Engineer Associate** badge.
- The certification is valid for **1 year**.
- To renew: Complete the **free online renewal assessment** at Microsoft Learn.
- No re-exam required for renewal.
- Badge can be shared on LinkedIn, Credly, and Microsoft Learn profile.
