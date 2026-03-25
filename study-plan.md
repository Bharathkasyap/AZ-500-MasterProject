# AZ-500 Study Plan — 8-Week Schedule

## Overview

This plan assumes roughly **2–3 hours of study per day**, 5 days a week, with hands-on lab practice on weekends.

---

## Week 1 — Foundation & Domain 1 (Identity and Access — Part 1)

| Day | Topic | Resource |
|-----|-------|----------|
| Mon | Exam overview, scoring, question types | `README.md`, official exam page |
| Tue | Azure Active Directory (Entra ID) concepts: tenants, users, groups | Domain 1 guide |
| Wed | Hybrid identity: Azure AD Connect, PHS, PTA, Federation | Domain 1 guide |
| Thu | Multi-Factor Authentication (MFA) — setup and conditional access | Domain 1 guide, Lab 01 |
| Fri | **Lab**: Enable MFA + Conditional Access Policy | `labs/lab-01-azure-ad-mfa.md` |

**Weekend**: Review practice questions for Domain 1 (Part 1) — `practice-questions/domain-1-questions.md` (Q1–10)

---

## Week 2 — Domain 1 (Identity and Access — Part 2)

| Day | Topic | Resource |
|-----|-------|----------|
| Mon | Privileged Identity Management (PIM) — roles, activation, review | Domain 1 guide |
| Tue | Azure AD Identity Protection — risk policies, SSPR | Domain 1 guide |
| Wed | Role-Based Access Control (RBAC) — built-in roles, custom roles, assignments | Domain 1 guide |
| Thu | Azure AD Application Registrations — service principals, managed identities | Domain 1 guide |
| Fri | **Lab**: Configure PIM + RBAC custom role | Domain 1 guide |

**Weekend**: Domain 1 full practice questions — `practice-questions/domain-1-questions.md` (all)

---

## Week 3 — Domain 2 (Secure Networking — Part 1)

| Day | Topic | Resource |
|-----|-------|----------|
| Mon | Virtual Network security: NSGs, ASGs, service endpoints | Domain 2 guide |
| Tue | Azure Firewall — Standard vs. Premium, policy, DNAT, SNAT | Domain 2 guide |
| Wed | Azure Firewall Manager, Firewall Policy hierarchy | Domain 2 guide |
| Thu | DDoS Protection — Basic vs. Standard, metrics, alerts | Domain 2 guide |
| Fri | **Lab**: Deploy Azure Firewall with threat intelligence | Domain 2 guide |

**Weekend**: Practice questions for Domain 2 (Part 1) — `practice-questions/domain-2-questions.md` (Q1–10)

---

## Week 4 — Domain 2 (Secure Networking — Part 2)

| Day | Topic | Resource |
|-----|-------|----------|
| Mon | Private Link and Private Endpoints | Domain 2 guide |
| Tue | VPN Gateway security, ExpressRoute encryption | Domain 2 guide |
| Wed | Web Application Firewall (WAF) — Application Gateway & Front Door | Domain 2 guide |
| Thu | Azure Bastion — secure RDP/SSH without public IPs | Domain 2 guide |
| Fri | **Lab**: Configure Private Endpoint for Azure Storage | Domain 2 guide |

**Weekend**: Domain 2 full practice questions — `practice-questions/domain-2-questions.md` (all)

---

## Week 5 — Domain 3 (Compute, Storage & Databases)

| Day | Topic | Resource |
|-----|-------|----------|
| Mon | Azure Key Vault — secrets, keys, certificates, RBAC vs. access policies | Domain 3 guide |
| Tue | Key Vault — HSM, soft delete, purge protection, Private Link | Domain 3 guide |
| Wed | VM security: disk encryption, Azure Disk Encryption, Trusted Launch | Domain 3 guide |
| Thu | Container security: AKS policies, image scanning, ACR | Domain 3 guide |
| Fri | **Lab**: Deploy and manage Azure Key Vault with Private Endpoint | `labs/lab-02-key-vault.md` |

**Weekend**: Storage & Database security — `domains/03-compute-storage-databases.md`

---

## Week 6 — Domain 3 continued + Domain 4 (Part 1)

| Day | Topic | Resource |
|-----|-------|----------|
| Mon | Storage security: SAS, encryption, firewalls, BYOK | Domain 3 guide |
| Tue | Azure SQL security: TDE, Always Encrypted, Dynamic Data Masking, row-level security | Domain 3 guide |
| Wed | **Practice**: Domain 3 questions — `practice-questions/domain-3-questions.md` | |
| Thu | Defender for Cloud — posture management, recommendations, Secure Score | Domain 4 guide |
| Fri | **Lab**: Enable Defender for Cloud, review Secure Score | `labs/lab-04-defender.md` |

**Weekend**: Domain 4 — Defender for Cloud deep-dive

---

## Week 7 — Domain 4 (Security Operations)

| Day | Topic | Resource |
|-----|-------|----------|
| Mon | Microsoft Sentinel — workspace, connectors, analytics rules | Domain 4 guide |
| Tue | Sentinel — Workbooks, playbooks, SOAR automation | Domain 4 guide |
| Wed | Azure Monitor, Log Analytics, diagnostic settings, alerts | Domain 4 guide |
| Thu | Microsoft Defender XDR integration — Defender for Endpoint, Identity, O365 | Domain 4 guide |
| Fri | **Lab**: Configure Microsoft Sentinel with analytics rule + playbook | `labs/lab-03-sentinel.md` |

**Weekend**: Domain 4 full practice questions — `practice-questions/domain-4-questions.md` (all)

---

## Week 8 — Full Review & Final Prep

| Day | Activity |
|-----|----------|
| Mon | Review all cheat sheets (`cheatsheets/` folder) |
| Tue | Take a full mock exam (40–60 questions, timed) |
| Wed | Review weak areas identified in mock exam |
| Thu | Re-do failed lab tasks; review performance-based lab guide |
| Fri | Light review only — cheat sheets + rest |
| Sat | **EXAM DAY** 🎯 |

---

## 📝 Exam-Day Tips

### Before the Exam
- [ ] Schedule your exam at a time when you are most alert (morning is often best)
- [ ] Prepare a **government-issued photo ID** — required for Pearson VUE
- [ ] Test your webcam, microphone, and internet connection the day before
- [ ] Clear your desk of all materials (Pearson VUE will ask you to show your environment)
- [ ] Eat a proper meal and get a full night's sleep

### During the Exam
- [ ] **Read every question carefully** — many distractors use near-identical wording
- [ ] For multi-select questions, the number of required answers is always stated
- [ ] **Mark questions for review** rather than guessing and moving on without flagging
- [ ] Use the **process of elimination** — Microsoft often provides two clearly wrong answers
- [ ] Pay attention to keywords: *"most cost-effective"*, *"least privilege"*, *"without downtime"*
- [ ] **Performance-based lab**: read all sub-tasks before starting; partial credit is awarded
- [ ] Keep an eye on time — aim for ~2 minutes per standard question; budget 30 min for the lab

### Scoring
- The passing score is **700 out of 1000**
- Scores are scaled — not every question has equal weight
- You will receive a **pass/fail result immediately** after completing the exam
- Detailed score report is emailed within 24 hours

### Common Pitfalls
- Confusing **Azure AD roles** (e.g., Global Admin) with **Azure RBAC roles** (e.g., Owner)
- Overlooking **Privileged Identity Management (PIM)** — it's heavily tested
- Missing the difference between **NSG** (layer 4) and **Azure Firewall** (layer 4–7)
- Forgetting that **Azure Policy** enforces compliance but **RBAC** controls who can act
- Mixing up **Key Vault access policies** vs. **Key Vault RBAC** (the newer model)

---

## 📖 Recommended Additional Resources

| Resource | Type | Link |
|----------|------|-------|
| Microsoft Learn AZ-500 Path | Free | [learn.microsoft.com](https://learn.microsoft.com/en-us/training/courses/az-500t00) |
| Microsoft Security Documentation | Free | [docs.microsoft.com/security](https://learn.microsoft.com/en-us/azure/security/) |
| Azure Free Account (labs) | Free tier | [azure.microsoft.com/free](https://azure.microsoft.com/free/) |
| SC-900 Security Fundamentals | Free (background) | [learn.microsoft.com](https://learn.microsoft.com/en-us/credentials/certifications/exams/sc-900/) |
| MeasureUp Practice Tests | Paid | [measureup.com](https://www.measureup.com/) |
| Whizlabs AZ-500 Practice | Paid | [whizlabs.com](https://www.whizlabs.com/) |
