# AZ-500 Master Project — Azure Security Technologies

> **The ultimate self-contained study guide for the AZ-500 Microsoft Azure Security Technologies certification exam.**

---

## 📋 Certification Metadata

| Field | Detail |
|---|---|
| **Exam Code** | AZ-500 |
| **Full Name** | Microsoft Azure Security Technologies |
| **Passing Score** | 700 / 1000 |
| **Duration** | 120 minutes |
| **Question Format** | Multiple choice, case studies, drag-and-drop, hot area, build-list |
| **Languages** | English, Japanese, Korean, Simplified Chinese, Traditional Chinese, French, German, Indonesian, Portuguese (Brazil), Russian, Spanish, Arabic |
| **Renewal** | Annual (free online assessment) |
| **Prerequisites** | Recommended: AZ-104 or equivalent hands-on experience |

---

## 📊 Exam Domain Weights

| # | Domain | Weight |
|---|---|---|
| 1 | Manage Identity and Access | 25–30% |
| 2 | Secure Networking | 20–25% |
| 3 | Secure Compute, Storage, and Databases | 20–25% |
| 4 | Manage Security Operations | 25–30% |

---

## 🗂️ Project Map

```
AZ-500-MasterProject/
├── README.md                          ← You are here — exam metadata & navigation
├── STUDY_TIPS.md                      ← Exam strategy, comparisons, 8-week plan
│
├── docs/                              ← Deep-dive study guides per domain
│   ├── 01-manage-identity-access.md
│   ├── 02-secure-networking.md
│   ├── 03-secure-compute-storage-databases.md
│   └── 04-manage-security-operations.md
│
├── labs/                              ← Hands-on lab walkthroughs per domain
│   ├── 01-identity-access-lab.md
│   ├── 02-secure-networking-lab.md
│   ├── 03-compute-storage-databases-lab.md
│   └── 04-security-operations-lab.md
│
└── scripts/                           ← Runnable Azure CLI provisioning scripts
    ├── identity/
    │   └── setup-identity.sh
    ├── networking/
    │   └── setup-networking.sh
    ├── compute-storage/
    │   └── setup-compute-storage.sh
    └── security-operations/
        └── setup-security-operations.sh
```

---

## 📚 Study Guides

| File | Topics Covered |
|---|---|
| [01 — Identity & Access](docs/01-manage-identity-access.md) | Entra ID, Conditional Access, PIM, Identity Protection, Managed Identities, RBAC |
| [02 — Secure Networking](docs/02-secure-networking.md) | NSG/ASG/Service Tags, Azure Firewall, DDoS Protection, WAF, Private Link, VPN/ER |
| [03 — Compute, Storage & Databases](docs/03-secure-compute-storage-databases.md) | ADE/SSE, JIT VM, Bastion, AKS, SAS tokens, Always Encrypted, DDM |
| [04 — Security Operations](docs/04-manage-security-operations.md) | Key Vault, Defender for Cloud, Sentinel, Azure Policy |

---

## 🧪 Hands-on Labs

| File | What You Build |
|---|---|
| [Lab 01 — Identity & Access](labs/01-identity-access-lab.md) | Entra ID users, PIM role activation, Conditional Access policy |
| [Lab 02 — Secure Networking](labs/02-secure-networking-lab.md) | Hub-spoke VNet, Azure Firewall, NSG deny rules, forced tunneling |
| [Lab 03 — Compute, Storage & DB](labs/03-compute-storage-databases-lab.md) | JIT VM access, disk encryption, storage SAS, SQL ATP |
| [Lab 04 — Security Operations](labs/04-security-operations-lab.md) | Sentinel workspace, Key Vault rotation, Defender plans |

---

## ⚙️ Lab Scripts

| Script | What It Provisions |
|---|---|
| [setup-identity.sh](scripts/identity/setup-identity.sh) | Entra ID user/group, RBAC, Key Vault (RBAC mode), user-assigned managed identity |
| [setup-networking.sh](scripts/networking/setup-networking.sh) | Hub-spoke VNet, Azure Firewall + policy, NSG deny rules, UDR forced tunneling |
| [setup-compute-storage.sh](scripts/compute-storage/setup-compute-storage.sh) | VM with system-assigned identity, secure storage account, SQL with ATP/auditing |
| [setup-security-operations.sh](scripts/security-operations/setup-security-operations.sh) | Log Analytics, Sentinel, diagnostic settings, Key Vault logging, Defender plans |

---

## 🌐 Official Resources

| Resource | URL |
|---|---|
| Exam AZ-500 Study Guide (Microsoft) | https://learn.microsoft.com/certifications/exams/az-500 |
| Microsoft Learn — AZ-500 Learning Path | https://learn.microsoft.com/training/paths/manage-identity-access/ |
| Azure Security Documentation | https://learn.microsoft.com/azure/security/ |
| Microsoft Defender for Cloud Docs | https://learn.microsoft.com/azure/defender-for-cloud/ |
| Microsoft Sentinel Docs | https://learn.microsoft.com/azure/sentinel/ |
| Azure Key Vault Docs | https://learn.microsoft.com/azure/key-vault/ |
| Azure AD / Entra ID Docs | https://learn.microsoft.com/entra/identity/ |
| AZ-500 Practice Assessment (free) | https://learn.microsoft.com/certifications/practice-assessments-for-microsoft-certifications |
| John Savill AZ-500 Study Cram (YouTube) | https://www.youtube.com/watch?v=6vISzj-z8k4 |

---

## 💡 Quick-Start Checklist

- [ ] Read [STUDY_TIPS.md](STUDY_TIPS.md) and build your 8-week schedule
- [ ] Work through each `docs/` guide in order
- [ ] Complete the matching `labs/` walkthrough after each guide
- [ ] Run the `scripts/` to build a live Azure sandbox environment
- [ ] Take the free Microsoft Practice Assessment and review weak areas
- [ ] Schedule your exam at least 2 weeks out once scoring ≥ 80% on practice sets

---

> ⚠️ **Cost Notice** — The lab scripts provision real Azure resources. Always run the cleanup commands printed at the end of each script to avoid unexpected charges. Estimated cost for all labs: **< $5 USD** if cleaned up within 24 hours.
