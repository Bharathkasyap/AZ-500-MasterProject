# AZ-500 Master Project — Ultimate Study Guide

> **Microsoft Azure Security Technologies** | Exam Code: AZ-500  
> Certification: **Microsoft Certified: Azure Security Engineer Associate**

---

## 📋 Certification Details

| Field | Details |
|-------|---------|
| **Exam Name** | Microsoft Azure Security Technologies |
| **Exam Code** | AZ-500 |
| **Certification** | Microsoft Certified: Azure Security Engineer Associate |
| **Cost** | $165 USD |
| **Passing Score** | 700 out of 1000 |
| **Total Questions** | 40–60 questions (may include 1 performance-based lab with ~12 sub-tasks) |
| **Exam Duration** | 150 minutes |
| **Question Types** | Multiple-choice, multi-select, drag-and-drop, case studies, performance-based labs |
| **Proctoring** | Pearson VUE |
| **Renewal** | Required annually via FREE online renewal assessment on Microsoft Learn |
| **Prerequisites** | None official, but AZ-104 knowledge strongly recommended |
| **Registration** | [Register Here](https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/) |
| **Study Guide** | [Official Study Guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-500) |

---

## 📊 Domain Weightage Table

| Domain | Topic | Weight |
|--------|-------|--------|
| 1 | Secure Identity and Access | 15–20% |
| 2 | Secure Networking | 20–25% |
| 3 | Secure Compute, Storage, and Databases | 20–25% |
| 4 | Secure Azure using Microsoft Defender for Cloud and Sentinel | 30–35% |

---

## 📁 Project Structure

```
AZ-500-MasterProject/
├── README.md                          ← You are here
├── EXAM-INFO.md                       ← Detailed exam tips, strategies, and resources
│
├── Domain-1-Identity-and-Access/
│   ├── 01-EntraID-Overview.md
│   ├── 02-Conditional-Access.md
│   ├── 03-MFA-and-SSPR.md
│   ├── 04-Privileged-Identity-Management.md
│   ├── 05-Identity-Protection.md
│   ├── 06-Managed-Identities.md
│   ├── 07-Azure-AD-B2B-and-B2C.md
│   └── 08-RBAC-and-Custom-Roles.md
│
└── Domain-2-Secure-Networking/
    ├── 01-Network-Security-Groups.md
    ├── 02-Azure-Firewall.md
    ├── 03-Web-Application-Firewall.md
    ├── 04-DDoS-Protection.md
    ├── 05-Private-Endpoints-and-Private-Link.md
    ├── 06-Azure-Bastion.md
    ├── 07-VPN-Gateway-and-ExpressRoute.md
    ├── 08-Front-Door-and-CDN-Security.md
    └── 09-Network-Watcher-and-Flow-Logs.md
```

---

## 🗂️ Domain Overview

### Domain 1 — Secure Identity and Access (15–20%)

| File | Topic |
|------|-------|
| [01-EntraID-Overview.md](Domain-1-Identity-and-Access/01-EntraID-Overview.md) | Microsoft Entra ID fundamentals, tenants, users, groups |
| [02-Conditional-Access.md](Domain-1-Identity-and-Access/02-Conditional-Access.md) | Conditional Access policies, named locations, controls |
| [03-MFA-and-SSPR.md](Domain-1-Identity-and-Access/03-MFA-and-SSPR.md) | Multi-Factor Authentication and Self-Service Password Reset |
| [04-Privileged-Identity-Management.md](Domain-1-Identity-and-Access/04-Privileged-Identity-Management.md) | PIM, just-in-time access, access reviews |
| [05-Identity-Protection.md](Domain-1-Identity-and-Access/05-Identity-Protection.md) | Risk policies, sign-in risk, user risk |
| [06-Managed-Identities.md](Domain-1-Identity-and-Access/06-Managed-Identities.md) | System-assigned vs user-assigned managed identities |
| [07-Azure-AD-B2B-and-B2C.md](Domain-1-Identity-and-Access/07-Azure-AD-B2B-and-B2C.md) | External identities, guest access, B2C custom policies |
| [08-RBAC-and-Custom-Roles.md](Domain-1-Identity-and-Access/08-RBAC-and-Custom-Roles.md) | Built-in roles, custom roles, scope, assignments |

### Domain 2 — Secure Networking (20–25%)

| File | Topic |
|------|-------|
| [01-Network-Security-Groups.md](Domain-2-Secure-Networking/01-Network-Security-Groups.md) | NSG rules, flow logs, application security groups |
| [02-Azure-Firewall.md](Domain-2-Secure-Networking/02-Azure-Firewall.md) | Azure Firewall, Firewall Manager, Premium SKU |
| [03-Web-Application-Firewall.md](Domain-2-Secure-Networking/03-Web-Application-Firewall.md) | WAF on App Gateway and Front Door |
| [04-DDoS-Protection.md](Domain-2-Secure-Networking/04-DDoS-Protection.md) | DDoS Basic vs Standard, mitigation policies |
| [05-Private-Endpoints-and-Private-Link.md](Domain-2-Secure-Networking/05-Private-Endpoints-and-Private-Link.md) | Private Link service, private endpoints, DNS |
| [06-Azure-Bastion.md](Domain-2-Secure-Networking/06-Azure-Bastion.md) | Bastion host, SKUs, secure RDP/SSH |
| [07-VPN-Gateway-and-ExpressRoute.md](Domain-2-Secure-Networking/07-VPN-Gateway-and-ExpressRoute.md) | Site-to-site, P2S VPN, ExpressRoute security |
| [08-Front-Door-and-CDN-Security.md](Domain-2-Secure-Networking/08-Front-Door-and-CDN-Security.md) | Azure Front Door, CDN, security policies |
| [09-Network-Watcher-and-Flow-Logs.md](Domain-2-Secure-Networking/09-Network-Watcher-and-Flow-Logs.md) | Network Watcher, NSG flow logs, traffic analytics |

---

## 🎯 How to Use This Guide

1. **Start with EXAM-INFO.md** — Understand the exam format, scoring, and strategy.
2. **Work through each domain** in order — Each file contains concepts, key services, exam tips, and practice questions.
3. **Focus extra time on Domain 4** — It carries the highest weight (30–35%).
4. **Use the practice questions** at the end of each topic file.
5. **Supplement with Microsoft Learn** labs and sandbox environments.

---

## 📚 Additional Resources

- [Microsoft Learn — AZ-500 Learning Path](https://learn.microsoft.com/en-us/training/courses/az-500t00)
- [Official Exam Page](https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/)
- [Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/)
- [Microsoft Security Blog](https://www.microsoft.com/en-us/security/blog/)
- [Azure Architecture Center — Security](https://learn.microsoft.com/en-us/azure/architecture/framework/security/)

---

*This project is intended for educational purposes to assist with AZ-500 exam preparation.*
