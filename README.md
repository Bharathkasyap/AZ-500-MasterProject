# AZ-500 Master Project — Ultimate Study Guide

> **Microsoft Azure Security Technologies | AZ-500 Certification**

[![AZ-500](https://img.shields.io/badge/Exam-AZ--500-blue?style=for-the-badge&logo=microsoft-azure)](https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/)
[![Certification](https://img.shields.io/badge/Certification-Azure%20Security%20Engineer%20Associate-0078D4?style=for-the-badge&logo=microsoft)](https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

---

## 📋 Table of Contents

- [Certification Overview](#-certification-overview)
- [Exam Details](#-exam-details)
- [Domain Weightage](#-domain-weightage)
- [Project Structure](#-project-structure)
- [How to Use This Guide](#-how-to-use-this-guide)
- [Quick Start Learning Path](#-quick-start-learning-path)
- [Domain Summaries](#-domain-summaries)
- [Key Azure Services Reference](#-key-azure-services-reference)
- [Exam Tips & Strategy](#-exam-tips--strategy)
- [Resources](#-resources)

---

## 🎯 Certification Overview

| Field | Details |
|-------|---------|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Certification Earned** | Microsoft Certified: Azure Security Engineer Associate |
| **Cost** | $165 USD |
| **Passing Score** | 700 out of 1000 |
| **Total Questions** | 40–60 questions |
| **Performance-Based Lab** | May include 1 lab with ~12 sub-tasks |
| **Exam Duration** | 150 minutes |
| **Proctoring** | Pearson VUE |
| **Renewal** | Annually via FREE online renewal assessment on Microsoft Learn |
| **Prerequisites** | None official; AZ-104 knowledge strongly recommended |

---

## 📝 Exam Details

### Question Types
- ✅ Multiple-choice (single answer)
- ✅ Multi-select (choose 2 or 3)
- ✅ Drag-and-drop (order steps or match items)
- ✅ Case Studies (scenario-based questions sharing a common environment)
- ✅ Performance-Based Labs (live Azure portal tasks)
- ✅ Hot-area / build-list / yes-no series

### Performance-Based Lab Notes
- The lab is typically the **last section** of the exam
- You have access to a **real Azure portal** with limited resources
- Tasks are graded automatically after the exam
- You **cannot go back** to previous sections once you start the lab
- Focus on completing as many sub-tasks as possible; partial credit is awarded

### Exam Strategy
- Read every question carefully — pay attention to words like *"MOST"*, *"LEAST"*, *"NOT"*, *"ONLY"*
- Flag difficult questions and return to them
- Budget ~2 minutes per question; labs may take 20–30 minutes total
- If unsure, eliminate wrong answers first

### Registration
- 🔗 [Register on Microsoft Learn](https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/)
- 🔗 [Official Study Guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-500)

---

## 📊 Domain Weightage

| # | Domain | Weight |
|---|--------|--------|
| 1 | [Manage Identity and Access](domains/01-identity-access/README.md) | 25–30% |
| 2 | [Secure Networking](domains/02-secure-networking/README.md) | 20–25% |
| 3 | [Secure Compute, Storage, and Databases](domains/03-compute-storage-databases/README.md) | 20–25% |
| 4 | [Manage Security Operations](domains/04-security-operations/README.md) | 25–30% |

> **Note:** Domains 1 and 4 carry the highest weight (~55–60% combined). Prioritize them in your studies.

---

## 📁 Project Structure

```
AZ-500-MasterProject/
│
├── README.md                          ← You are here (main overview)
│
├── domains/
│   ├── 01-identity-access/
│   │   ├── README.md                  ← Domain overview & key concepts
│   │   └── study-notes.md             ← Detailed study notes
│   ├── 02-secure-networking/
│   │   ├── README.md
│   │   └── study-notes.md
│   ├── 03-compute-storage-databases/
│   │   ├── README.md
│   │   └── study-notes.md
│   └── 04-security-operations/
│       ├── README.md
│       └── study-notes.md
│
├── practice-questions/
│   ├── domain1-identity-access.md     ← 20 questions with answers
│   ├── domain2-networking.md          ← 20 questions with answers
│   ├── domain3-compute-storage.md     ← 20 questions with answers
│   ├── domain4-security-ops.md        ← 20 questions with answers
│   └── full-mock-exam.md              ← 50-question timed mock exam
│
├── labs/
│   ├── lab01-azure-ad-rbac.md         ← Identity & RBAC lab
│   ├── lab02-key-vault.md             ← Key Vault configuration lab
│   ├── lab03-network-security.md      ← NSG, Firewall, Bastion lab
│   ├── lab04-defender-for-cloud.md    ← Defender for Cloud lab
│   └── lab05-sentinel-siem.md         ← Microsoft Sentinel lab
│
├── cheatsheets/
│   ├── rbac-cheatsheet.md             ← RBAC roles quick reference
│   ├── key-vault-cheatsheet.md        ← Key Vault policies & commands
│   ├── networking-cheatsheet.md       ← NSG rules, Firewall, routing
│   ├── defender-cheatsheet.md         ← Defender plans & features
│   └── sentinel-cheatsheet.md        ← Sentinel connectors & KQL
│
└── resources.md                       ← Official links & free study resources
```

---

## 🚀 How to Use This Guide

### Recommended Study Order (8-Week Plan)

| Week | Focus | Content |
|------|-------|---------|
| Week 1 | Foundation | Read this README; review AZ-104 prerequisites |
| Week 2 | Domain 1 | [Identity & Access](domains/01-identity-access/README.md) + [Study Notes](domains/01-identity-access/study-notes.md) |
| Week 3 | Domain 4 | [Security Operations](domains/04-security-operations/README.md) + [Study Notes](domains/04-security-operations/study-notes.md) |
| Week 4 | Domain 2 | [Secure Networking](domains/02-secure-networking/README.md) + [Study Notes](domains/02-secure-networking/study-notes.md) |
| Week 5 | Domain 3 | [Compute, Storage & DBs](domains/03-compute-storage-databases/README.md) + [Study Notes](domains/03-compute-storage-databases/study-notes.md) |
| Week 6 | Labs | Complete all [hands-on labs](labs/) |
| Week 7 | Practice | Take all [domain practice questions](practice-questions/) |
| Week 8 | Mock Exam | [Full 50-question mock exam](practice-questions/full-mock-exam.md) + review weak areas |

---

## 🗺️ Quick Start Learning Path

```
[Start Here]
     │
     ▼
[README.md] ──→ [Domain READMEs] ──→ [Study Notes]
                                           │
                                           ▼
                                    [Hands-on Labs]
                                           │
                                           ▼
                               [Domain Practice Questions]
                                           │
                                           ▼
                                  [Full Mock Exam]
                                           │
                                           ▼
                                [Review Cheatsheets]
                                           │
                                           ▼
                                   [Schedule Exam! 🎓]
```

---

## 📚 Domain Summaries

### Domain 1 — Manage Identity and Access (25–30%)

Covers securing identities in Microsoft Entra ID (formerly Azure AD):

| Topic | Key Services |
|-------|-------------|
| Entra ID fundamentals | Microsoft Entra ID, Tenants, Users, Groups |
| Authentication | MFA, SSPR, Passwordless, Certificate-based |
| Authorization | Azure RBAC, Entra ID Roles, PIM |
| External identities | B2B Collaboration, B2C, Guest access |
| Governance | Conditional Access, Identity Protection, Access Reviews |
| Workload identities | Managed Identities, Service Principals, App Registrations |

📖 [Full Domain 1 Guide →](domains/01-identity-access/README.md)

---

### Domain 2 — Secure Networking (20–25%)

Covers protecting Azure network infrastructure:

| Topic | Key Services |
|-------|-------------|
| Perimeter security | Azure Firewall, Azure DDoS Protection |
| Network segmentation | VNets, Subnets, NSGs, ASGs |
| Remote access | Azure Bastion, VPN Gateway, ExpressRoute |
| Private connectivity | Private Link, Private Endpoints, Service Endpoints |
| Web application security | Azure Front Door, Application Gateway, WAF |
| Monitoring | Network Watcher, Traffic Analytics, Flow Logs |

📖 [Full Domain 2 Guide →](domains/02-secure-networking/README.md)

---

### Domain 3 — Secure Compute, Storage, and Databases (20–25%)

Covers securing Azure workloads:

| Topic | Key Services |
|-------|-------------|
| Virtual Machine security | Disk encryption, JIT access, Endpoint protection |
| Container security | AKS security, ACR, Container policies |
| App service security | App Service auth, Managed certificates, TLS |
| Storage security | SAS tokens, Encryption, Firewall rules, Defender |
| Database security | SQL TDE, SQL auditing, Advanced Threat Protection |
| Key management | Azure Key Vault (keys, secrets, certificates) |

📖 [Full Domain 3 Guide →](domains/03-compute-storage-databases/README.md)

---

### Domain 4 — Manage Security Operations (25–30%)

Covers monitoring, detecting, and responding to threats:

| Topic | Key Services |
|-------|-------------|
| Cloud security posture | Microsoft Defender for Cloud, Secure Score |
| Threat protection | Defender plans (VMs, SQL, Storage, Containers…) |
| SIEM/SOAR | Microsoft Sentinel, Workbooks, Analytics rules |
| Log management | Log Analytics, Azure Monitor, Diagnostic settings |
| Incident response | Sentinel incidents, Playbooks, Logic Apps |
| Compliance | Azure Policy, Regulatory Compliance, Blueprints |

📖 [Full Domain 4 Guide →](domains/04-security-operations/README.md)

---

## 🔑 Key Azure Services Reference

| Service | Domain | Purpose |
|---------|--------|---------|
| Microsoft Entra ID | 1 | Cloud identity platform (formerly Azure AD) |
| Privileged Identity Management (PIM) | 1 | Just-in-time privileged access |
| Conditional Access | 1 | Risk-based access policies |
| Identity Protection | 1 | Detect and remediate identity risks |
| Azure Key Vault | 3 | Secrets, keys, and certificates management |
| Azure Firewall | 2 | Stateful, managed network firewall |
| Azure DDoS Protection | 2 | Distributed denial-of-service mitigation |
| Azure Bastion | 2 | Secure RDP/SSH without public IPs |
| NSG (Network Security Groups) | 2 | Layer-4 traffic filtering |
| WAF (Web Application Firewall) | 2 | Layer-7 web attack protection |
| Microsoft Defender for Cloud | 3, 4 | Cloud security posture & workload protection |
| Microsoft Sentinel | 4 | Cloud-native SIEM & SOAR |
| Log Analytics Workspace | 4 | Centralized log aggregation |
| Azure Policy | 4 | Enforce organizational standards |
| Azure RBAC | 1 | Resource-level authorization |

---

## 💡 Exam Tips & Strategy

### Must-Know Concepts
1. **PIM (Privileged Identity Management)** — Understand JIT access, activation, approval workflows
2. **Conditional Access** — Know policy conditions (user/group, location, device, app, risk)
3. **Azure RBAC** — Know built-in roles: Owner, Contributor, Reader, User Access Administrator
4. **Key Vault** — Access policies vs. RBAC; soft-delete; purge protection; HSM
5. **NSG vs. Azure Firewall** — NSG = L4 subnet/NIC filter; Firewall = L3-L7 stateful managed
6. **Defender for Cloud** — Secure Score, recommendations, Defender plans
7. **Microsoft Sentinel** — Data connectors, Analytics rules, Incidents, Playbooks
8. **Managed Identities** — System-assigned vs. user-assigned; eliminate credential management
9. **Private Endpoints** — Bring service into your VNet via private IP
10. **Azure Policy** — Deny, Audit, DeployIfNotExists effects

### Common Exam Traps
- ❗ **Owner vs. User Access Administrator**: Both can assign RBAC, but Owner has broader permissions
- ❗ **Service Principal vs. Managed Identity**: Managed Identity = automatic credential rotation
- ❗ **NSG priority**: Lower number = higher priority (100 < 200 < 65000)
- ❗ **Key Vault soft-delete**: Enabled by default since 2020; cannot be disabled on new vaults
- ❗ **Conditional Access requires Entra ID P1 or P2**
- ❗ **PIM requires Entra ID P2**
- ❗ **Identity Protection requires Entra ID P2**
- ❗ **Defender for Cloud free tier** = Foundational CSPM only; paid plans needed for Defender features

### Scoring Tips
- There is **no penalty for wrong answers** — always guess if unsure
- Performance-based lab questions are worth significant points; don't skip them
- Case study questions share the same exhibit — read it carefully before answering

---

## 📎 Resources

| Resource | Link |
|----------|------|
| Official Certification Page | [aka.ms/AZ-500](https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/) |
| Official Study Guide | [AZ-500 Study Guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-500) |
| Microsoft Learn Free Path | [AZ-500 Learning Path](https://learn.microsoft.com/en-us/training/paths/manage-identity-access/) |
| Azure Security Documentation | [docs.microsoft.com/azure/security](https://docs.microsoft.com/azure/security/) |
| Microsoft Entra ID Docs | [Entra ID Documentation](https://learn.microsoft.com/en-us/entra/identity/) |
| Microsoft Sentinel Docs | [Sentinel Documentation](https://learn.microsoft.com/en-us/azure/sentinel/) |
| Defender for Cloud Docs | [Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/) |
| Azure Key Vault Docs | [Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/) |
| MeasureUp Practice Tests | [MeasureUp AZ-500](https://www.measureup.com/microsoft-technical-659.html) |
| Whizlabs Practice Tests | [Whizlabs AZ-500](https://www.whizlabs.com/microsoft-azure-certification-az-500/) |

📋 [Full Resources Page →](resources.md)

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

> 💬 **Good luck on your AZ-500 exam!** If this guide helped you, consider starring ⭐ the repository.
