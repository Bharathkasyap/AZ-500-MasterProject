# AZ-500 Master Project — Ultimate Study Guide

> **Microsoft Azure Security Technologies** — Complete, self-contained study resource for the AZ-500 certification exam.

---

## 📋 Certification Details

| Field | Details |
|---|---|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Publisher** | Microsoft |
| **Certification** | Microsoft Certified: Azure Security Engineer Associate |
| **Passing Score** | 700 / 1000 |
| **Duration** | 120 minutes |
| **Languages** | English, Japanese, Chinese (Simplified), Korean, German, French, Spanish, Portuguese (Brazil), Russian, Arabic (Saudi Arabia), Chinese (Traditional), Italian |
| **Exam Format** | Multiple choice, case studies, drag-and-drop, build-list, hot-area |
| **Official Page** | [Microsoft Learn — AZ-500](https://learn.microsoft.com/en-us/certifications/exams/az-500/) |

---

## 🎯 Who Should Take This Exam?

The AZ-500 exam is targeted at **Azure Security Engineers** who:

- Implement, manage, and monitor security for resources in Azure, multi-cloud, and hybrid environments
- Are part of a larger team dedicated to cloud-based management and security
- Have hands-on experience with Azure administration and Azure development, and are familiar with Microsoft 365 workloads

**Recommended Prerequisites:**
- AZ-104: Microsoft Azure Administrator (or equivalent experience)
- Familiarity with Microsoft 365 and hybrid identity scenarios

---

## 🗺️ Exam Domains & Weights

The exam covers four skill domains (as of the latest update):

| Domain | Topic | Weight |
|---|---|---|
| 1 | [Manage Identity and Access](docs/01-manage-identity-access.md) | 25–30% |
| 2 | [Secure Networking](docs/02-secure-networking.md) | 20–25% |
| 3 | [Secure Compute, Storage, and Databases](docs/03-secure-compute-storage-databases.md) | 20–25% |
| 4 | [Manage Security Operations](docs/04-manage-security-operations.md) | 25–30% |

---

## 📂 Project Structure

```
AZ-500-MasterProject/
├── README.md                          # This file — project overview & certification details
├── STUDY_TIPS.md                      # Exam tips, time management, and practice strategies
├── docs/
│   ├── 01-manage-identity-access.md          # Domain 1 study guide
│   ├── 02-secure-networking.md               # Domain 2 study guide
│   ├── 03-secure-compute-storage-databases.md # Domain 3 study guide
│   └── 04-manage-security-operations.md       # Domain 4 study guide
├── scripts/
│   ├── identity/                      # Azure AD, RBAC, PIM, Conditional Access scripts
│   ├── networking/                    # NSG, Azure Firewall, Private Endpoint scripts
│   ├── compute-storage/               # VM, AKS, Storage, SQL security scripts
│   └── security-operations/           # Defender for Cloud, Sentinel scripts
└── labs/
    ├── lab-01-identity-access.md      # Hands-on lab: Identity & Access
    ├── lab-02-secure-networking.md    # Hands-on lab: Secure Networking
    ├── lab-03-compute-storage.md      # Hands-on lab: Compute, Storage & Databases
    └── lab-04-security-operations.md  # Hands-on lab: Security Operations
```

---

## 🚀 How to Use This Repository

1. **Start with the domain guides** in `docs/` — read them in order (Domains 1–4).
2. **Run the scripts** in `scripts/` to practice configurations against a real Azure subscription (or a free trial).
3. **Complete the hands-on labs** in `labs/` — each lab maps directly to exam objectives.
4. **Review exam tips** in [STUDY_TIPS.md](STUDY_TIPS.md) before scheduling your exam.

> 💡 **Tip:** Use the [Microsoft Learn AZ-500 learning path](https://learn.microsoft.com/en-us/training/courses/az-500t00) alongside this guide for free, official video and interactive content.

---

## 🛡️ Domain Summaries

### Domain 1 — Manage Identity and Access (25–30%)
Covers Azure Active Directory (Entra ID), Conditional Access, Privileged Identity Management (PIM), managed identities, and role-based access control (RBAC). → [Full guide](docs/01-manage-identity-access.md)

### Domain 2 — Secure Networking (20–25%)
Covers Virtual Network security, Network Security Groups (NSGs), Azure Firewall, Azure DDoS Protection, Private Endpoints, and VPN/ExpressRoute security. → [Full guide](docs/02-secure-networking.md)

### Domain 3 — Secure Compute, Storage, and Databases (20–25%)
Covers VM security (Endpoint Protection, Just-in-Time access), AKS and container security, Azure Storage security (SAS, encryption), and Azure SQL / Cosmos DB security. → [Full guide](docs/03-secure-compute-storage-databases.md)

### Domain 4 — Manage Security Operations (25–30%)
Covers Microsoft Defender for Cloud, Microsoft Sentinel (SIEM/SOAR), Key Vault, monitoring, incident response, and security baselines. → [Full guide](docs/04-manage-security-operations.md)

---

## 📚 Official & Recommended Resources

| Resource | Link |
|---|---|
| Microsoft Learn — AZ-500 | https://learn.microsoft.com/en-us/certifications/exams/az-500/ |
| AZ-500 Study Guide (PDF) | https://learn.microsoft.com/en-us/certifications/resources/study-guides/az-500 |
| Microsoft Defender for Cloud Docs | https://learn.microsoft.com/en-us/azure/defender-for-cloud/ |
| Microsoft Sentinel Docs | https://learn.microsoft.com/en-us/azure/sentinel/ |
| Azure Key Vault Docs | https://learn.microsoft.com/en-us/azure/key-vault/ |
| Azure AD (Entra ID) Docs | https://learn.microsoft.com/en-us/azure/active-directory/ |
| Azure Network Security Docs | https://learn.microsoft.com/en-us/azure/networking/security/ |
| Microsoft Security Blog | https://www.microsoft.com/en-us/security/blog/ |

---

## 🤝 Contributing

Pull requests are welcome! If you find an error or want to add practice questions, improved examples, or updated content:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improve-domain-3`)
3. Commit your changes
4. Open a pull request

---

## ⚖️ License

This project is licensed under the [MIT License](LICENSE). Content is for educational purposes and is not affiliated with or endorsed by Microsoft.

---

*Last updated: March 2026 | Based on the AZ-500 exam skills outline published by Microsoft.*
