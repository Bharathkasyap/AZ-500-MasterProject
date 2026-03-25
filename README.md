# AZ-500 Master Project — Ultimate Study Guide

> **The complete, self-contained study guide for the Microsoft AZ-500 certification exam.**

---

## 📋 Certification Details

| Field | Value |
|-------|-------|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Certification Earned** | Microsoft Certified: Azure Security Engineer Associate |
| **Passing Score** | 700 / 1000 |
| **Exam Duration** | 120 minutes |
| **Question Types** | Multiple choice, case studies, drag-and-drop, labs |
| **Languages** | English, Japanese, Chinese (Simplified), Korean, German, French, Spanish, Portuguese (Brazil), Russian, Arabic, Chinese (Traditional), Italian |

---

## 🗺️ What This Guide Covers

The AZ-500 exam measures your ability to implement security controls, maintain an organization's security posture, and identify and remediate security vulnerabilities. This guide is organized by the **four official exam skill domains** measured on the exam:

| # | Domain | Exam Weight |
|---|--------|-------------|
| 1 | [Manage Identity and Access](./study-guides/01-identity-and-access.md) | 25–30% |
| 2 | [Secure Networking](./study-guides/02-secure-networking.md) | 20–25% |
| 3 | [Secure Compute, Storage, and Databases](./study-guides/03-compute-storage-databases.md) | 20–25% |
| 4 | [Manage Security Operations](./study-guides/04-security-operations.md) | 25–30% |

---

## 📁 Repository Structure

```
AZ-500-MasterProject/
├── README.md                          ← You are here (overview & exam details)
├── study-guides/
│   ├── 01-identity-and-access.md      ← Domain 1: Identity & Access (25–30%)
│   ├── 02-secure-networking.md        ← Domain 2: Secure Networking (20–25%)
│   ├── 03-compute-storage-databases.md← Domain 3: Compute, Storage & DBs (20–25%)
│   └── 04-security-operations.md      ← Domain 4: Security Operations (25–30%)
├── practice-questions/
│   └── practice-exam.md               ← 60 practice questions with explanations
├── labs/
│   └── hands-on-labs.md               ← Step-by-step Azure lab exercises
└── reference/
    ├── cheat-sheet.md                  ← Quick-reference for exam day
    └── study-resources.md             ← Books, videos, official docs & links
```

---

## 🚀 How to Use This Guide

1. **Start with the study guides** — read each domain guide in order, taking notes.
2. **Complete the hands-on labs** — real Azure experience is tested on the exam.
3. **Test your knowledge** — attempt all practice questions before reviewing answers.
4. **Review the cheat sheet** — memorize key facts, ports, and CLI commands.
5. **Check study resources** — use Microsoft Learn paths and the official documentation.

---

## 📊 Exam Domain Breakdown

```
Domain 1 — Manage Identity and Access        ████████░░░░  25–30%
Domain 2 — Secure Networking                 ██████░░░░░░  20–25%
Domain 3 — Secure Compute, Storage & DBs    ██████░░░░░░  20–25%
Domain 4 — Manage Security Operations       ████████░░░░  25–30%
```

---

## 🔑 Key Azure Services Covered

| Category | Services |
|----------|----------|
| **Identity** | Microsoft Entra ID, Conditional Access, PIM, Identity Protection, Managed Identities |
| **Networking** | NSG, Azure Firewall, DDoS Protection, VPN Gateway, Private Link, Application Gateway WAF |
| **Compute** | Microsoft Defender for Servers, Azure Disk Encryption, JIT VM Access |
| **Storage** | Storage Account security, SAS tokens, encryption at rest |
| **Databases** | Azure SQL auditing, Transparent Data Encryption, Advanced Threat Protection |
| **Key Management** | Azure Key Vault, HSM, secrets/keys/certificates |
| **Security Ops** | Microsoft Sentinel, Defender for Cloud, Azure Monitor, Log Analytics |

---

## 📚 Quick Links

- [Domain 1: Manage Identity and Access →](./study-guides/01-identity-and-access.md)
- [Domain 2: Secure Networking →](./study-guides/02-secure-networking.md)
- [Domain 3: Secure Compute, Storage, and Databases →](./study-guides/03-compute-storage-databases.md)
- [Domain 4: Manage Security Operations →](./study-guides/04-security-operations.md)
- [Practice Exam Questions (60 Q&A) →](./practice-questions/practice-exam.md)
- [Hands-On Labs →](./labs/hands-on-labs.md)
- [Exam Day Cheat Sheet →](./reference/cheat-sheet.md)
- [Study Resources & Links →](./reference/study-resources.md)

---

## ⚡ Exam Tips

- **Lab questions** count heavily — practice real Azure Portal and CLI tasks.
- **Microsoft Entra ID** (formerly Azure Active Directory) is central to Domain 1 — know it deeply.
- **Microsoft Defender for Cloud** (formerly Azure Security Center) spans multiple domains.
- **Microsoft Sentinel** is the primary SIEM/SOAR — understand its components (workspaces, analytics rules, playbooks).
- **Key Vault** appears in multiple domains — understand access policies vs. RBAC, and soft-delete.
- Pay attention to the difference between **authentication** (who you are) and **authorization** (what you can do).

---

## 📅 Recommended Study Plan (4 Weeks)

| Week | Focus |
|------|-------|
| Week 1 | Domain 1 (Identity & Access) + Labs 1–4 |
| Week 2 | Domain 2 (Networking) + Domain 3 (Compute/Storage/DBs) + Labs 5–9 |
| Week 3 | Domain 4 (Security Ops) + Labs 10–13 |
| Week 4 | Practice exam, review weak areas, cheat sheet review |

---

## 🔗 Official Resources

- [AZ-500 Exam Page (Microsoft)](https://learn.microsoft.com/en-us/certifications/exams/az-500)
- [AZ-500 Study Guide (Microsoft)](https://learn.microsoft.com/en-us/certifications/resources/study-guides/az-500)
- [Microsoft Learn — Azure Security Engineer](https://learn.microsoft.com/en-us/training/paths/manage-identity-access/)
- [Microsoft Entra Documentation](https://learn.microsoft.com/en-us/entra/)
- [Microsoft Defender for Cloud Docs](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
- [Microsoft Sentinel Documentation](https://learn.microsoft.com/en-us/azure/sentinel/)

---

*Last updated: March 2025 · Based on the official AZ-500 exam objectives*
