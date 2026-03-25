# AZ-500 Master Project — Ultimate Study Guide

> **Microsoft Certified: Azure Security Engineer Associate**

[![Azure](https://img.shields.io/badge/Microsoft%20Azure-AZ--500-0078D4?style=for-the-badge&logo=microsoft-azure)](https://learn.microsoft.com/en-us/certifications/azure-security-engineer/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

## 📋 Certification Details

| Field | Value |
|---|---|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Certification Earned** | Microsoft Certified: Azure Security Engineer Associate |
| **Cost** | $165 USD |
| **Passing Score** | 700 out of 1000 |
| **Exam Duration** | 120 minutes |
| **Question Types** | Multiple choice, case studies, drag-and-drop, hot area |
| **Renewal** | Every year via free online assessment |
| **Official Page** | [Microsoft Learn](https://learn.microsoft.com/en-us/certifications/exams/az-500/) |

---

## 🗺️ Repository Structure

```
AZ-500-MasterProject/
├── README.md                        ← This file — project overview & certification details
├── study-plan.md                    ← 8-week study plan with daily tasks
├── domains/
│   ├── 01-identity-access.md        ← Domain 1: Manage Identity and Access (25–30%)
│   ├── 02-secure-networking.md      ← Domain 2: Secure Networking (20–25%)
│   ├── 03-compute-storage-db.md     ← Domain 3: Secure Compute, Storage & Databases (20–25%)
│   └── 04-security-operations.md   ← Domain 4: Manage Security Operations (25–30%)
├── labs/
│   ├── lab-01-azure-ad-mfa.md       ← Lab: Configure MFA and Conditional Access
│   ├── lab-02-key-vault.md          ← Lab: Deploy and Secure Azure Key Vault
│   ├── lab-03-nsg-firewall.md       ← Lab: Network Security Groups and Azure Firewall
│   ├── lab-04-defender.md           ← Lab: Enable Microsoft Defender for Cloud
│   └── lab-05-sentinel.md           ← Lab: Deploy Microsoft Sentinel SIEM
├── practice-questions/
│   └── mock-exam.md                 ← 60-question mock exam with explanations
└── cheatsheets/
    └── quick-reference.md           ← Concise command & portal reference cards
```

---

## 🎯 Exam Domains & Weights

| # | Domain | Weight |
|---|--------|--------|
| 1 | [Manage Identity and Access](domains/01-identity-access.md) | 25–30% |
| 2 | [Secure Networking](domains/02-secure-networking.md) | 20–25% |
| 3 | [Secure Compute, Storage, and Databases](domains/03-compute-storage-db.md) | 20–25% |
| 4 | [Manage Security Operations](domains/04-security-operations.md) | 25–30% |

---

## 🚀 Quick Start

1. **Read** this README for the big picture.
2. **Follow** the [8-week study plan](study-plan.md) to pace your preparation.
3. **Deep-dive** into each [domain guide](domains/) for detailed notes and key concepts.
4. **Practice** with hands-on [labs](labs/) to build muscle memory in the Azure portal and CLI.
5. **Test yourself** with the [mock exam](practice-questions/mock-exam.md) (aim for ≥80% before booking).
6. **Review** the [quick-reference cheat sheets](cheatsheets/quick-reference.md) the night before the exam.

---

## 📚 Recommended Learning Resources

| Resource | Type | Cost |
|---|---|---|
| [Microsoft Learn AZ-500 path](https://learn.microsoft.com/en-us/training/paths/manage-identity-access/) | Official | Free |
| [Microsoft Official Study Guide (Exam Ref AZ-500)](https://www.microsoftpressstore.com/) | Book | ~$40 |
| [John Savill's AZ-500 Study Cram (YouTube)](https://www.youtube.com/c/NTFAQGuy) | Video | Free |
| [Pluralsight AZ-500 path](https://www.pluralsight.com/) | Video | Subscription |
| [Whizlabs AZ-500 Practice Tests](https://www.whizlabs.com/) | Practice tests | ~$20 |
| [MeasureUp AZ-500](https://www.measureup.com/) | Practice tests | ~$99 |
| [Azure Free Account (labs)](https://azure.microsoft.com/en-us/free/) | Hands-on | Free |

---

## ⚡ Key Services to Know Cold

### Identity & Access
- **Microsoft Entra ID** (formerly Azure AD) — users, groups, roles, app registrations
- **Privileged Identity Management (PIM)** — just-in-time privileged access
- **Conditional Access** — signal-based access policies
- **Identity Protection** — risk-based sign-in policies

### Networking
- **Network Security Groups (NSGs)** — layer-4 traffic filtering
- **Azure Firewall** — stateful layer-7 firewall
- **Azure DDoS Protection** — volumetric attack mitigation
- **Azure Bastion** — browser-based RDP/SSH without public IPs
- **Private Endpoints / Private Link** — private connectivity to PaaS services
- **Azure Web Application Firewall (WAF)** — OWASP rule-set protection

### Compute, Storage & Databases
- **Azure Key Vault** — secrets, keys, and certificate management
- **Disk Encryption (ADE)** — BitLocker/DM-Crypt via Key Vault
- **Storage Service Encryption (SSE)** — at-rest encryption for blobs
- **Shared Access Signatures (SAS)** — time-limited, scoped storage tokens
- **Microsoft Defender for SQL / Storage** — threat detection for data services

### Security Operations
- **Microsoft Defender for Cloud** — CSPM + workload protection (Secure Score)
- **Microsoft Sentinel** — cloud-native SIEM/SOAR
- **Azure Monitor / Log Analytics** — telemetry collection and KQL queries
- **Azure Policy** — governance and compliance enforcement
- **Security Center Recommendations** — guided remediation

---

## 🔑 Exam Tips

1. **Know role boundaries**: Understand the difference between Owner, Contributor, Security Admin, Security Reader, and Security Operator.
2. **PIM is a favourite topic**: Know how to configure eligible assignments, activation settings, and access reviews.
3. **Defender for Cloud Secure Score**: Understand how recommendations affect the score and how to remediate them.
4. **Sentinel data connectors**: Know which connector to use for common sources (Entra ID, Office 365, CEF, Syslog).
5. **Key Vault access models**: Both RBAC and access-policy models appear in questions — know both.
6. **NSG vs. Azure Firewall vs. WAF**: Know *when* to use each and the OSI layer each operates at.
7. **Conditional Access vs. MFA per-user**: Conditional Access is the modern, recommended approach.
8. **Read every answer carefully**: Microsoft often includes distractors that are almost correct.

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

*Good luck on your AZ-500 exam! 🎉*
