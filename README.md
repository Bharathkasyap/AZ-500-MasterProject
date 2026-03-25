# AZ-500 Master Project — Microsoft Azure Security Technologies

> **The ultimate self-contained study guide for the AZ-500 certification exam.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Exam: AZ-500](https://img.shields.io/badge/Exam-AZ--500-blue)](https://learn.microsoft.com/en-us/certifications/exams/az-500)
[![Certification: Azure Security Engineer Associate](https://img.shields.io/badge/Certification-Azure%20Security%20Engineer%20Associate-0078D4)](https://learn.microsoft.com/en-us/certifications/azure-security-engineer)

---

## 📋 Certification At a Glance

| Field | Details |
|---|---|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Certification Earned** | Microsoft Certified: Azure Security Engineer Associate |
| **Cost** | $165 USD |
| **Passing Score** | 700 out of 1000 |
| **Total Questions** | 40–60 questions |
| **Performance-Based Lab** | May include 1 lab with ~12 sub-tasks |
| **Exam Duration** | 150 minutes |
| **Question Types** | Multiple-choice, multi-select, drag-and-drop, case studies, performance-based labs |
| **Proctoring** | Pearson VUE (online or test center) |
| **Renewal** | Annually — FREE online renewal assessment on Microsoft Learn |
| **Official Prerequisites** | None (AZ-104 knowledge strongly recommended) |

---

## 🎯 What This Project Covers

This repository is organized around the **four official exam skill domains** as published in the [AZ-500 exam skills outline](https://learn.microsoft.com/en-us/certifications/exams/az-500):

| # | Domain | Exam Weight |
|---|---|---|
| 1 | [Manage Identity and Access](docs/01-identity-and-access/README.md) | 25–30% |
| 2 | [Secure Networking](docs/02-secure-networking/README.md) | 20–25% |
| 3 | [Secure Compute, Storage, and Databases](docs/03-secure-compute-storage-databases/README.md) | 20–25% |
| 4 | [Manage Security Operations](docs/04-security-operations/README.md) | 25–30% |

---

## 📁 Repository Structure

```
AZ-500-MasterProject/
├── README.md                          ← You are here (exam overview & roadmap)
│
├── docs/
│   ├── 01-identity-and-access/
│   │   └── README.md                  ← Azure AD, RBAC, MFA, PIM, Conditional Access
│   ├── 02-secure-networking/
│   │   └── README.md                  ← NSGs, Azure Firewall, VPN, DDoS, Private Endpoints
│   ├── 03-secure-compute-storage-databases/
│   │   └── README.md                  ← Defender for Cloud, encryption, Key Vault, ACR
│   └── 04-security-operations/
│       └── README.md                  ← Microsoft Sentinel, Defender, monitoring, incident response
│
├── practice-questions/
│   └── README.md                      ← 100+ practice questions with answers & explanations
│
├── labs/
│   └── README.md                      ← Step-by-step hands-on labs mapped to exam objectives
│
└── cheatsheets/
    └── README.md                      ← Quick-reference cards for exam day
```

---

## 🗺️ Recommended Study Roadmap

### Phase 1 — Foundation (Week 1–2)
- [ ] Review Azure fundamentals (AZ-900 level): subscriptions, resource groups, RBAC basics
- [ ] Study **Domain 1**: Identity and Access Management
- [ ] Complete Lab 1: Configure Azure AD and Privileged Identity Management
- [ ] Complete Lab 2: Implement Conditional Access Policies

### Phase 2 — Networking & Infrastructure (Week 3–4)
- [ ] Study **Domain 2**: Secure Networking
- [ ] Complete Lab 3: Configure Network Security Groups and Azure Firewall
- [ ] Complete Lab 4: Implement DDoS Protection and Private Endpoints

### Phase 3 — Compute, Storage & Data (Week 5–6)
- [ ] Study **Domain 3**: Secure Compute, Storage, and Databases
- [ ] Complete Lab 5: Configure Microsoft Defender for Cloud
- [ ] Complete Lab 6: Implement Key Vault and Storage Encryption

### Phase 4 — Security Operations (Week 7–8)
- [ ] Study **Domain 4**: Manage Security Operations
- [ ] Complete Lab 7: Deploy Microsoft Sentinel and Create Analytics Rules
- [ ] Complete Lab 8: Configure Security Monitoring and Alerts

### Phase 5 — Practice & Review (Week 9)
- [ ] Complete all practice questions
- [ ] Review cheat sheets
- [ ] Take at least 2 full mock exams

---

## 📖 Study Resources

### Official Microsoft Resources
- [AZ-500 Exam Page](https://learn.microsoft.com/en-us/certifications/exams/az-500) — Skills outline and registration
- [Microsoft Learn: AZ-500 Learning Path](https://learn.microsoft.com/en-us/training/paths/manage-identity-access/) — Free official training
- [Microsoft Security Documentation](https://learn.microsoft.com/en-us/azure/security/) — Full technical reference

### Recommended Books & Courses
- *Exam Ref AZ-500 Microsoft Azure Security Technologies* (Microsoft Press)
- [John Savill's AZ-500 Study Cram](https://www.youtube.com/watch?v=6vISzj-z8k4) — YouTube deep dive
- Pluralsight / Udemy AZ-500 courses (various authors)

### Practice Exams
- [MeasureUp AZ-500 Practice Test](https://www.measureup.com/microsoft-practice-test-az-500.html) (official Microsoft learning partner)
- [Whizlabs AZ-500](https://www.whizlabs.com/microsoft-azure-certification-az-500/) — Community-rated practice tests

---

## 🔑 Key Azure Security Services — Quick Index

| Service | Domain | Purpose |
|---|---|---|
| Azure Active Directory (Entra ID) | Identity | Identity platform, SSO, MFA |
| Azure AD Privileged Identity Management (PIM) | Identity | Just-in-time privileged access |
| Conditional Access | Identity | Policy-based access control |
| Azure RBAC | Identity | Role-based resource authorization |
| Network Security Groups (NSG) | Networking | Layer 4 traffic filtering |
| Azure Firewall | Networking | Managed, stateful firewall |
| Azure DDoS Protection | Networking | Volumetric attack mitigation |
| Azure Private Link / Private Endpoints | Networking | Private connectivity to PaaS |
| Microsoft Defender for Cloud | Compute/Ops | CSPM + workload protection |
| Azure Key Vault | Compute | Secrets, keys, and certificates |
| Microsoft Sentinel | Operations | Cloud-native SIEM/SOAR |
| Microsoft Defender for Endpoint | Operations | EDR for servers/VMs |
| Azure Monitor / Log Analytics | Operations | Centralized logging & monitoring |
| Azure Security Center Secure Score | Operations | Security posture measurement |

---

## ⚡ Exam Tips

1. **Understand the trust model**: Know the difference between authentication (proving identity) and authorization (granting access).
2. **PIM is critical**: Privileged Identity Management questions appear frequently — know activation, approval workflows, and access reviews.
3. **Defender for Cloud tiers**: Know the difference between Free (CSPM) and Paid (Defender plans) tiers.
4. **Sentinel vs Defender**: Sentinel is SIEM/SOAR; Defender products protect individual workloads. They integrate but are distinct.
5. **Key Vault access policies vs RBAC**: Both methods exist — know when to use each and how permissions differ.
6. **NSG + ASG combinations**: Application Security Groups simplify rule management — understand how they work with NSGs.
7. **Performance-based labs**: Practice in the Azure portal. Labs test actual task completion, not just knowledge.
8. **Read question stems carefully**: Many questions include a constraint like "minimum permissions" or "without additional cost."

---

## 🏗️ Performance-Based Lab Tips

The exam may include one performance-based lab with approximately 12 sub-tasks. These tasks:
- Are completed in a **live or simulated Azure portal environment**
- Typically cover: configuring Conditional Access, enabling Defender plans, setting Key Vault policies, configuring Sentinel, etc.
- Are **NOT reviewed in sequence** — you can skip and return
- Are **timed separately** from the rest of the exam

**Practice Tip**: Complete all labs in this repository in the actual Azure portal (use the free trial or a pay-as-you-go subscription).

---

## 💰 Cost & Exam Logistics

- **Exam Fee**: $165 USD (discounts available for Microsoft employees, students, and exam vouchers from events)
- **Reschedule**: Free if done 6+ business days before the exam
- **Cancellation**: Free if done 6+ business days before the exam; $100 fee if within 5 business days
- **Score Report**: Delivered immediately after exam completion
- **Retake Policy**: If you fail, you must wait 24 hours before retaking; after the second fail, wait 14 days (maximum 5 attempts per year)

---

## 🔄 Certification Renewal

- **Renewal Period**: Annually
- **Renewal Method**: FREE online assessment on [Microsoft Learn](https://learn.microsoft.com/en-us/certifications/renew-your-microsoft-certification)
- **No Re-exam Required**: The renewal assessment is shorter and taken online without a proctor
- **Grace Period**: You can renew starting 6 months before expiry

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or PR if you find:
- Incorrect or outdated information
- Missing topics from the official skills outline
- Typos or formatting issues
- Additional practice questions or lab ideas

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

*Last updated: 2026-03-25 | Based on the AZ-500 exam skills outline published by Microsoft*
