# 🔐 AZ-500: Microsoft Azure Security Technologies
## Complete Study Guide & Master Project

[![Exam Code](https://img.shields.io/badge/Exam-AZ--500-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://learn.microsoft.com/en-us/certifications/exams/az-500/)
[![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate%2FAdvanced-orange?style=for-the-badge)](https://learn.microsoft.com/en-us/certifications/exams/az-500/)
[![Certification](https://img.shields.io/badge/Certification-Azure%20Security%20Engineer%20Associate-blue?style=for-the-badge&logo=microsoft)](https://learn.microsoft.com/en-us/certifications/azure-security-engineer/)
[![Cost](https://img.shields.io/badge/Exam%20Cost-$165%20USD-green?style=for-the-badge)](https://learn.microsoft.com/en-us/certifications/exams/az-500/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)

> 📘 **A comprehensive, community-driven study guide** for the Microsoft AZ-500 certification exam. Covers all four exam domains with in-depth documentation, hands-on labs, practice questions, and curated study resources.

---

## 📋 Table of Contents

- [🎯 Certification Details](#-certification-details)
- [📊 Exam Domain Breakdown](#-exam-domain-breakdown)
- [📁 Project Structure](#-project-structure)
- [🚀 How to Use This Study Guide](#-how-to-use-this-study-guide)
- [🗓️ Study Timeline Recommendations](#️-study-timeline-recommendations)
- [☁️ Key Azure Security Services Covered](#️-key-azure-security-services-covered)
- [✅ Prerequisites](#-prerequisites)
- [🔗 Official Resources & Links](#-official-resources--links)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🎯 Certification Details

| Property | Details |
|---|---|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Certification Earned** | Microsoft Certified: Azure Security Engineer Associate |
| **Exam Cost** | $165 USD |
| **Passing Score** | 700 out of 1000 |
| **Total Questions** | 40–60 questions (may include 1 performance-based lab with ~12 sub-tasks) |
| **Exam Duration** | 150 minutes |
| **Question Types** | Multiple-choice, multi-select, drag-and-drop, case studies, performance-based labs |
| **Proctoring** | Pearson VUE |
| **Languages Available** | English, Japanese, Chinese (Simplified), Korean, German, French, Spanish, Portuguese (Brazil), Arabic (Saudi Arabia), Russian, Indonesian (Indonesia), Italian, Chinese (Traditional) |
| **Renewal** | Every 1 year via free online assessment |

> 💡 **Tip:** Schedule your exam through [Pearson VUE](https://home.pearsonvue.com/microsoft) or directly via the [Microsoft Certification portal](https://learn.microsoft.com/en-us/certifications/exams/az-500/).

---

## 📊 Exam Domain Breakdown

The AZ-500 exam is organized into **four key domains**. Understanding the weight of each domain helps you prioritize your study efforts.

| Domain | Topic | Weight |
|---|---|---|
| **Domain 1** | Manage Identity and Access | 25–30% |
| **Domain 2** | Secure Networking | 20–25% |
| **Domain 3** | Secure Compute, Storage, and Databases | 20–25% |
| **Domain 4** | Manage Security Operations | 25–30% |

```
Domain Weight Distribution
────────────────────────────────────────
Domain 1 - Identity & Access    ████████  25–30%
Domain 2 - Secure Networking    ██████    20–25%
Domain 3 - Compute/Storage/DB   ██████    20–25%
Domain 4 - Security Operations  ████████  25–30%
────────────────────────────────────────
```

### Domain 1 – Manage Identity and Access (25–30%)
- Microsoft Entra ID (Azure AD) — users, groups, roles, and MFA
- Conditional Access policies
- Privileged Identity Management (PIM)
- Managed Identities and Service Principals
- Azure AD B2B and B2C

### Domain 2 – Secure Networking (20–25%)
- Network Security Groups (NSGs) and Application Security Groups (ASGs)
- Azure Firewall and Azure Firewall Manager
- Azure DDoS Protection
- Azure Bastion and Just-in-Time (JIT) VM Access
- Web Application Firewall (WAF) and Azure Front Door

### Domain 3 – Secure Compute, Storage, and Databases (20–25%)
- Azure Key Vault — secrets, keys, and certificates
- Disk encryption and Azure Backup security
- Azure Container Instances and AKS security
- Storage account security — SAS tokens, access policies, encryption
- Azure SQL and Cosmos DB security

### Domain 4 – Manage Security Operations (25–30%)
- Microsoft Defender for Cloud
- Microsoft Sentinel — SIEM/SOAR capabilities
- Security policies, initiatives, and compliance
- Log Analytics and Azure Monitor
- Incident response and threat intelligence

---

## 📁 Project Structure

```
AZ-500-MasterProject/
│
├── 📄 README.md                          # This file — project overview & guide
│
├── 📂 docs/                              # In-depth domain documentation
│   ├── 01-identity-and-access.md         # Domain 1: Identity & Access Management
│   ├── 02-secure-networking.md           # Domain 2: Secure Networking
│   ├── 03-compute-storage-databases.md   # Domain 3: Compute, Storage & Databases
│   └── 04-security-operations.md         # Domain 4: Security Operations
│
├── 📂 practice-questions/                # Domain-specific and full practice exams
│   ├── domain1-questions.md              # Identity & Access practice questions
│   ├── domain2-questions.md              # Secure Networking practice questions
│   ├── domain3-questions.md              # Compute/Storage/DB practice questions
│   ├── domain4-questions.md              # Security Operations practice questions
│   └── full-practice-exam.md            # Simulated full-length practice exam
│
├── 📂 labs/                              # Hands-on Azure lab exercises
│   ├── lab01-azure-ad-security.md        # Lab 1: Microsoft Entra ID Security
│   ├── lab02-network-security.md         # Lab 2: Network Security Groups & Firewall
│   ├── lab03-key-vault-encryption.md     # Lab 3: Azure Key Vault & Encryption
│   ├── lab04-defender-for-cloud.md       # Lab 4: Microsoft Defender for Cloud
│   └── lab05-microsoft-sentinel.md       # Lab 5: Microsoft Sentinel SIEM/SOAR
│
└── 📂 study-resources/                   # Supplementary study materials
    ├── exam-tips.md                      # Proven exam tips and strategies
    ├── cheat-sheet.md                    # Quick-reference cheat sheet
    └── study-plan.md                     # Structured weekly study plan
```

---

## 🚀 How to Use This Study Guide

### Step 1 — Clone the Repository
```bash
git clone https://github.com/your-username/AZ-500-MasterProject.git
cd AZ-500-MasterProject
```

### Step 2 — Review the Exam Domains
Start with the `/docs` folder. Each file maps to one exam domain:
```bash
# Read domain documentation in order
docs/01-identity-and-access.md
docs/02-secure-networking.md
docs/03-compute-storage-databases.md
docs/04-security-operations.md
```

### Step 3 — Complete the Hands-On Labs
The `/labs` folder contains step-by-step Azure lab exercises. You will need an active Azure subscription (a free trial works for most labs).
```bash
labs/lab01-azure-ad-security.md     # Start here
labs/lab02-network-security.md
labs/lab03-key-vault-encryption.md
labs/lab04-defender-for-cloud.md
labs/lab05-microsoft-sentinel.md    # Finish here
```

> ⚠️ **Note:** Some labs may incur small Azure costs. Review the lab prerequisites before starting. Always clean up resources after completing a lab.

### Step 4 — Test Your Knowledge
Use the practice questions to assess your understanding after each domain:
```bash
practice-questions/domain1-questions.md   # After studying Domain 1
practice-questions/domain2-questions.md   # After studying Domain 2
practice-questions/domain3-questions.md   # After studying Domain 3
practice-questions/domain4-questions.md   # After studying Domain 4
practice-questions/full-practice-exam.md  # When ready — simulate the real exam
```

### Step 5 — Review Supplementary Resources
```bash
study-resources/cheat-sheet.md   # Quick service reference
study-resources/exam-tips.md     # Final exam preparation tips
study-resources/study-plan.md    # Adjust to your target date
```

---

## 🗓️ Study Timeline Recommendations

Choose a plan based on your existing Azure experience and available study time.

### ⚡ 4-Week Accelerated Plan
*Recommended for: Experienced Azure professionals or those with prior security knowledge.*

| Week | Focus | Resources |
|---|---|---|
| **Week 1** | Domain 1 — Identity & Access + Lab 1 | `docs/01-identity-and-access.md`, `labs/lab01-azure-ad-security.md` |
| **Week 2** | Domain 2 — Secure Networking + Lab 2 | `docs/02-secure-networking.md`, `labs/lab02-network-security.md` |
| **Week 3** | Domain 3 — Compute/Storage/DB + Lab 3 | `docs/03-compute-storage-databases.md`, `labs/lab03-key-vault-encryption.md` |
| **Week 4** | Domain 4 — Security Ops + Labs 4 & 5 + Full Practice Exam | `docs/04-security-operations.md`, `labs/lab04-defender-for-cloud.md`, `labs/lab05-microsoft-sentinel.md`, `practice-questions/full-practice-exam.md` |

**Daily commitment:** ~3–4 hours/day

---

### 📅 8-Week Comprehensive Plan
*Recommended for: Those new to Azure security or wanting a deeper understanding.*

| Week | Focus | Resources |
|---|---|---|
| **Week 1** | Prerequisites & Azure Fundamentals Review | Azure docs, Microsoft Learn fundamentals paths |
| **Week 2** | Domain 1 — Identity & Access (Part 1: Entra ID, MFA, Conditional Access) | `docs/01-identity-and-access.md` (sections 1–3) |
| **Week 3** | Domain 1 — Identity & Access (Part 2: PIM, Managed Identities) + Lab 1 | `docs/01-identity-and-access.md` (sections 4–6), `labs/lab01-azure-ad-security.md` |
| **Week 4** | Domain 2 — Secure Networking + Lab 2 | `docs/02-secure-networking.md`, `labs/lab02-network-security.md` |
| **Week 5** | Domain 3 — Compute, Storage & Databases + Lab 3 | `docs/03-compute-storage-databases.md`, `labs/lab03-key-vault-encryption.md` |
| **Week 6** | Domain 4 — Security Operations + Labs 4 & 5 | `docs/04-security-operations.md`, `labs/lab04-defender-for-cloud.md`, `labs/lab05-microsoft-sentinel.md` |
| **Week 7** | Domain-specific practice questions + review weak areas | `practice-questions/domain1–4-questions.md` |
| **Week 8** | Full practice exam + cheat sheet review + exam-day prep | `practice-questions/full-practice-exam.md`, `study-resources/exam-tips.md`, `study-resources/cheat-sheet.md` |

**Daily commitment:** ~1.5–2 hours/day

> 💡 **Recommended Score Before Booking:** Consistently score **80%+ on practice exams** before scheduling your real exam.

---

## ☁️ Key Azure Security Services Covered

| Service | Domain | Purpose |
|---|---|---|
| **Microsoft Entra ID** (Azure AD) | Identity & Access | Cloud identity and access management |
| **Privileged Identity Management (PIM)** | Identity & Access | Just-in-time privileged access |
| **Conditional Access** | Identity & Access | Risk-based access policies |
| **Azure Key Vault** | Compute/Storage/DB | Secrets, keys, and certificate management |
| **Azure Firewall** | Secure Networking | Cloud-native stateful network firewall |
| **Network Security Groups (NSGs)** | Secure Networking | Layer 4 traffic filtering |
| **Azure DDoS Protection** | Secure Networking | Distributed Denial of Service mitigation |
| **Azure Bastion** | Secure Networking | Secure RDP/SSH without public IP exposure |
| **Web Application Firewall (WAF)** | Secure Networking | Layer 7 application protection |
| **Microsoft Defender for Cloud** | Security Operations | Cloud security posture management (CSPM) |
| **Microsoft Sentinel** | Security Operations | Cloud-native SIEM and SOAR |
| **Azure Policy** | Security Operations | Governance and compliance enforcement |
| **Log Analytics / Azure Monitor** | Security Operations | Centralized logging and monitoring |
| **Azure Security Center** | Security Operations | Unified security management |
| **Just-in-Time (JIT) VM Access** | Secure Networking | Reduce attack surface for VMs |
| **Azure Disk Encryption** | Compute/Storage/DB | VM disk encryption at rest |
| **Storage Account Security** | Compute/Storage/DB | SAS tokens, private endpoints, RBAC |
| **Azure Container Registry Security** | Compute/Storage/DB | Container image scanning and policies |

---

## ✅ Prerequisites

Before diving into AZ-500 content, ensure you have the following foundational knowledge:

### Required Knowledge
- ✔️ **Azure Fundamentals (AZ-900 level)** — core Azure concepts, services, and pricing
- ✔️ **Azure Administration (AZ-104 level)** — managing VMs, storage, networking, and identity
- ✔️ **Basic networking concepts** — TCP/IP, DNS, firewalls, VPNs, subnets
- ✔️ **Security fundamentals** — authentication, authorization, encryption, PKI

### Recommended Experience
- 🔹 6–12 months of hands-on Azure experience
- 🔹 Familiarity with the Azure Portal, Azure CLI, and PowerShell
- 🔹 Understanding of Active Directory concepts
- 🔹 Basic understanding of cloud security principles (Zero Trust, defense in depth)

### Recommended Pre-Study (Free)
| Resource | Link |
|---|---|
| AZ-900: Azure Fundamentals | [Microsoft Learn Path](https://learn.microsoft.com/en-us/training/paths/azure-fundamentals/) |
| AZ-104: Azure Administrator | [Microsoft Learn Path](https://learn.microsoft.com/en-us/training/paths/az-104-administrator-prerequisites/) |
| Microsoft Security Fundamentals | [SC-900 Learn Path](https://learn.microsoft.com/en-us/training/paths/describe-concepts-of-security-compliance-identity/) |

---

## 🔗 Official Resources & Links

### Microsoft Official Resources
| Resource | URL |
|---|---|
| 📋 Exam AZ-500 Official Page | [learn.microsoft.com/certifications/exams/az-500](https://learn.microsoft.com/en-us/certifications/exams/az-500/) |
| 📖 Exam Skills Outline (PDF) | [Download Study Guide](https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE3VC70) |
| 🎓 Official Microsoft Learn Path | [AZ-500 Learning Path](https://learn.microsoft.com/en-us/training/courses/az-500t00) |
| 🧪 Microsoft Learn Sandbox (Free Labs) | [learn.microsoft.com/training](https://learn.microsoft.com/en-us/training/) |
| 📝 Schedule Exam (Pearson VUE) | [home.pearsonvue.com/microsoft](https://home.pearsonvue.com/microsoft) |
| 🔄 Certification Renewal | [Renew Azure Security Engineer Associate](https://learn.microsoft.com/en-us/certifications/azure-security-engineer/renew/) |

### Practice & Assessment Tools
| Resource | Description |
|---|---|
| [Microsoft Official Practice Assessment](https://learn.microsoft.com/en-us/certifications/practice-assessments-for-microsoft-certifications) | Free official practice questions |
| [MeasureUp AZ-500](https://www.measureup.com/az-500-microsoft-azure-security-technologies.html) | Paid premium practice exams |
| [Whizlabs AZ-500](https://www.whizlabs.com/microsoft-azure-certification-az-500/) | Paid practice exams and labs |

### Community & Forums
| Resource | URL |
|---|---|
| Microsoft Tech Community | [techcommunity.microsoft.com](https://techcommunity.microsoft.com/) |
| Reddit r/AzureCertification | [reddit.com/r/AzureCertification](https://www.reddit.com/r/AzureCertification/) |
| Azure Security Blog | [microsoft.com/security/blog](https://www.microsoft.com/en-us/security/blog/) |

---

## 🤝 Contributing

Contributions are warmly welcomed! This project grows stronger with community input.

### How to Contribute

1. **Fork** the repository
2. **Create** a new branch for your changes:
   ```bash
   git checkout -b feature/add-domain1-notes
   ```
3. **Make** your changes following the style guide below
4. **Commit** your changes with a descriptive message:
   ```bash
   git commit -m "Add Conditional Access policy notes to Domain 1"
   ```
5. **Push** your branch and open a **Pull Request**:
   ```bash
   git push origin feature/add-domain1-notes
   ```

### Contribution Guidelines
- 📝 Keep documentation **accurate and up-to-date** with the latest exam objectives
- 🔗 Always cite **official Microsoft documentation** where possible
- ✅ Ensure practice questions include **clear explanations** for correct and incorrect answers
- 🧪 Lab exercises should include **setup, steps, validation, and cleanup** instructions
- 🚫 Do **not** share actual exam questions (this violates Microsoft's NDA)

### What We Need Help With
- [ ] Expanding domain documentation with real-world scenarios
- [ ] Adding more practice questions per domain
- [ ] Creating additional hands-on labs
- [ ] Translating content into other languages
- [ ] Keeping service names and features current with Azure updates

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 AZ-500-MasterProject Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
```

> ⚠️ **Disclaimer:** This project is a **community-created study guide** and is not affiliated with, endorsed by, or sponsored by Microsoft. All Microsoft product names, logos, and trademarks are the property of Microsoft Corporation. Exam content and objectives may change — always refer to the [official exam page](https://learn.microsoft.com/en-us/certifications/exams/az-500/) for the most current information.

---

<div align="center">

**⭐ If this study guide helped you pass the AZ-500, please give it a star! ⭐**

Made with ❤️ by the Azure security community

[![Microsoft Certified](https://img.shields.io/badge/Microsoft-Certified-0078D4?style=flat-square&logo=microsoft)](https://learn.microsoft.com/en-us/certifications/azure-security-engineer/)
[![Azure Security](https://img.shields.io/badge/Azure-Security%20Engineer-blue?style=flat-square&logo=microsoft-azure)](https://learn.microsoft.com/en-us/certifications/exams/az-500/)

</div>
