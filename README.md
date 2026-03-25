# AZ-500 Master Project — Ultimate Study Guide

> **Exam Name:** Microsoft Azure Security Technologies  
> **Exam Code:** AZ-500  
> **Certification:** Microsoft Certified: Azure Security Engineer Associate  
> **Format:** 40–60 questions (multiple choice, case studies, drag-and-drop)  
> **Duration:** 120 minutes  
> **Passing Score:** 700 / 1000  
> **Languages:** English, Japanese, Chinese (Simplified), Korean, German, French, Spanish, Portuguese (Brazil), Arabic (Saudi Arabia), Russian, Chinese (Traditional), Italian  

---

## 📋 Table of Contents

1. [About the Exam](#about-the-exam)
2. [Skills Measured](#skills-measured)
3. [Study Domains](#study-domains)
   - [Domain 1 — Manage Identity and Access (25–30%)](#domain-1--manage-identity-and-access-2530)
   - [Domain 2 — Secure Networking (20–25%)](#domain-2--secure-networking-2025)
   - [Domain 3 — Secure Compute, Storage, and Databases (20–25%)](#domain-3--secure-compute-storage-and-databases-2025)
   - [Domain 4 — Manage Security Operations (25–30%)](#domain-4--manage-security-operations-2530)
4. [Quick Reference / Cheat Sheet](#quick-reference--cheat-sheet)
5. [Practice Questions](#practice-questions)
6. [Hands-On Labs](#hands-on-labs)
7. [Official Resources](#official-resources)
8. [Recommended Learning Path](#recommended-learning-path)

---

## About the Exam

The **AZ-500: Microsoft Azure Security Technologies** exam measures your ability to implement security controls, maintain the security posture of an organization, identify and remediate vulnerabilities, perform threat modeling, and implement threat protection.

**Target audience:** Azure Security Engineers who work with architects, administrators, and developers to plan and implement security strategies that satisfy compliance and security requirements.

**Prerequisites:** Familiarity with Microsoft Azure and hybrid environments, plus scripting knowledge (PowerShell, Azure CLI).

---

## Skills Measured

| Domain | Weight |
|--------|--------|
| Manage Identity and Access | 25–30% |
| Secure Networking | 20–25% |
| Secure Compute, Storage, and Databases | 20–25% |
| Manage Security Operations | 25–30% |

---

## Study Domains

### Domain 1 — Manage Identity and Access (25–30%)

📄 **[Full Study Notes → docs/01-identity-and-access.md](docs/01-identity-and-access.md)**

Key topics:
- Microsoft Entra ID (Azure Active Directory) fundamentals
- Multi-Factor Authentication (MFA) and Conditional Access
- Privileged Identity Management (PIM)
- Managed Identities and Service Principals
- Azure RBAC and custom roles
- B2B / B2C collaboration

---

### Domain 2 — Secure Networking (20–25%)

📄 **[Full Study Notes → docs/02-secure-networking.md](docs/02-secure-networking.md)**

Key topics:
- Azure Virtual Network security (NSGs, ASGs, UDRs)
- Azure Firewall and Firewall Manager
- Azure DDoS Protection
- Azure Bastion and Just-in-Time (JIT) VM access
- Azure Private Link and Private Endpoints
- Web Application Firewall (WAF) and Azure Front Door

---

### Domain 3 — Secure Compute, Storage, and Databases (20–25%)

📄 **[Full Study Notes → docs/03-compute-storage-databases.md](docs/03-compute-storage-databases.md)**

Key topics:
- Microsoft Defender for Cloud (compute recommendations)
- VM security: disk encryption, endpoint protection
- Container security: AKS, ACR, Azure Container Instances
- Azure Storage security: SAS tokens, encryption, access keys
- Azure SQL / Cosmos DB security: auditing, TDE, Always Encrypted
- App Service security and authentication

---

### Domain 4 — Manage Security Operations (25–30%)

📄 **[Full Study Notes → docs/04-security-operations.md](docs/04-security-operations.md)**

Key topics:
- Microsoft Defender for Cloud: secure score, recommendations, alerts
- Microsoft Sentinel: workspaces, data connectors, analytics rules, SOAR
- Azure Monitor, Log Analytics, and diagnostic settings
- Key Vault: secrets, keys, certificates, and access policies
- Security policies, initiatives, and compliance (Azure Policy)
- Incident response and security investigations

---

## Quick Reference / Cheat Sheet

📄 **[Cheat Sheet → docs/cheat-sheet.md](docs/cheat-sheet.md)**

Covers service-to-security-goal mappings, port reference, RBAC built-in roles, and exam-day tips.

---

## Practice Questions

📄 **[Practice Questions → docs/practice-questions.md](docs/practice-questions.md)**

120+ scenario-based practice questions covering all four domains with full answer explanations.

---

## Hands-On Labs

📄 **[Lab Exercises → docs/labs.md](docs/labs.md)**

Step-by-step Azure portal / CLI / PowerShell labs aligned to each exam domain.

---

## Official Resources

| Resource | Link |
|----------|------|
| Exam page | https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/ |
| Study guide (Microsoft) | https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-500 |
| Microsoft Learn path | https://learn.microsoft.com/en-us/training/paths/implement-resource-mgmt-security/ |
| Azure security documentation | https://learn.microsoft.com/en-us/azure/security/ |
| Microsoft Defender for Cloud docs | https://learn.microsoft.com/en-us/azure/defender-for-cloud/ |
| Microsoft Sentinel docs | https://learn.microsoft.com/en-us/azure/sentinel/ |
| Azure AD / Entra ID docs | https://learn.microsoft.com/en-us/entra/identity/ |
| Practice Assessment (free) | https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/practice/assessment?assessment-type=practice&assessmentId=57 |

---

## Recommended Learning Path

```
Week 1  → Domain 1: Identity and Access
Week 2  → Domain 2: Secure Networking
Week 3  → Domain 3: Compute, Storage, and Databases
Week 4  → Domain 4: Security Operations
Week 5  → Practice Questions + Labs
Week 6  → Review weak areas + Cheat Sheet + Exam
```

---

## Repository Structure

```
AZ-500-MasterProject/
├── README.md                          ← You are here (overview + navigation)
├── docs/
│   ├── 01-identity-and-access.md     ← Domain 1 study notes
│   ├── 02-secure-networking.md       ← Domain 2 study notes
│   ├── 03-compute-storage-databases.md ← Domain 3 study notes
│   ├── 04-security-operations.md     ← Domain 4 study notes
│   ├── cheat-sheet.md               ← Quick reference card
│   ├── practice-questions.md        ← 120+ practice questions
│   └── labs.md                      ← Hands-on lab exercises
└── .github/
    └── ISSUE_TEMPLATE/
        └── study-feedback.md        ← Template for submitting corrections
```

---

*Last updated: 2026 — aligned to the current AZ-500 exam objectives.*  
*Contributions and corrections are welcome — please open an issue or pull request.*
