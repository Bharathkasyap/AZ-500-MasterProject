# AZ-500 — 8-Week Study Plan

> **Goal:** Pass the AZ-500 exam with a score ≥ 700/1000.  
> **Daily commitment:** ~1.5–2 hours on weekdays, 3–4 hours on weekends.

---

## Prerequisites Checklist

Before starting, ensure you are comfortable with:

- [ ] Azure fundamentals (AZ-900 level) — VMs, storage, networking basics
- [ ] Basic identity concepts (users, groups, roles)
- [ ] Azure portal and Azure CLI navigation
- [ ] Basic PowerShell or Bash scripting

---

## Week-by-Week Plan

### Week 1 — Identity Foundations

| Day | Task | Resource |
|-----|------|----------|
| Mon | Read Domain 1 intro; Microsoft Entra ID overview | [Domain 1 notes](domains/01-identity-access.md) |
| Tue | Users, groups, and dynamic membership rules | Microsoft Learn |
| Wed | App registrations, service principals, managed identities | Microsoft Learn |
| Thu | Role-Based Access Control (RBAC) deep dive | Azure docs |
| Fri | **Lab:** Create users, assign RBAC, test access | [Lab 01](labs/lab-01-azure-ad-mfa.md) |
| Sat | Conditional Access policies and named locations | Microsoft Learn |
| Sun | Review + quiz yourself on Week 1 concepts | [Mock exam Qs 1–15](practice-questions/mock-exam.md) |

---

### Week 2 — Advanced Identity & PIM

| Day | Task | Resource |
|-----|------|----------|
| Mon | Privileged Identity Management (PIM) — concepts | Microsoft Learn |
| Tue | PIM — eligible vs. active assignments, activation workflow | Azure docs |
| Wed | Azure AD Identity Protection, risk policies | Microsoft Learn |
| Thu | Access reviews, entitlement management | Microsoft Learn |
| Fri | **Lab:** Configure PIM eligible role + MFA requirement | [Lab 01](labs/lab-01-azure-ad-mfa.md) |
| Sat | External identities: B2B collaboration, cross-tenant access | Microsoft Learn |
| Sun | Review + quiz yourself on Week 2 concepts | [Mock exam Qs 16–30](practice-questions/mock-exam.md) |

---

### Week 3 — Secure Networking

| Day | Task | Resource |
|-----|------|----------|
| Mon | Read Domain 2; Virtual Network fundamentals refresher | [Domain 2 notes](domains/02-secure-networking.md) |
| Tue | NSGs — inbound/outbound rules, service tags, ASGs | Azure docs |
| Wed | Azure Firewall — DNAT, network, application rules | Microsoft Learn |
| Thu | Azure DDoS Protection Standard vs. Basic | Microsoft Learn |
| Fri | **Lab:** Create NSG + Azure Firewall in hub-spoke | [Lab 03](labs/lab-03-nsg-firewall.md) |
| Sat | Private Endpoints, Private Link, service endpoints | Microsoft Learn |
| Sun | Azure Bastion, Just-in-Time VM access, VPN Gateway | Microsoft Learn |

---

### Week 4 — Secure Networking (continued) & WAF

| Day | Task | Resource |
|-----|------|----------|
| Mon | Application Gateway WAF — OWASP rules, custom rules | Microsoft Learn |
| Tue | Azure Front Door WAF vs. Application Gateway WAF | Azure docs |
| Wed | Network Watcher — flow logs, connection troubleshoot | Microsoft Learn |
| Thu | Forced tunneling, User-Defined Routes (UDRs) | Microsoft Learn |
| Fri | **Lab:** Enable DDoS Standard + WAF on App Gateway | [Lab 03](labs/lab-03-nsg-firewall.md) |
| Sat | Review + quiz yourself on Weeks 3–4 concepts | [Mock exam Qs 31–45](practice-questions/mock-exam.md) |
| Sun | Catch-up / weak spots | — |

---

### Week 5 — Compute, Storage & Database Security

| Day | Task | Resource |
|-----|------|----------|
| Mon | Read Domain 3; Azure Key Vault concepts | [Domain 3 notes](domains/03-compute-storage-db.md) |
| Tue | Key Vault — access policies vs. RBAC, soft-delete, purge protection | Microsoft Learn |
| Wed | **Lab:** Deploy Key Vault, store secret, retrieve via managed identity | [Lab 02](labs/lab-02-key-vault.md) |
| Thu | Disk encryption — Azure Disk Encryption (ADE) with Key Vault | Microsoft Learn |
| Fri | Storage security — SSE, SAS tokens, access keys, Azure AD auth | Azure docs |
| Sat | Container security — Azure Container Registry, AKS RBAC, pod identity | Microsoft Learn |
| Sun | Database security — Defender for SQL, Transparent Data Encryption, auditing | Microsoft Learn |

---

### Week 6 — Security Operations

| Day | Task | Resource |
|-----|------|----------|
| Mon | Read Domain 4; Microsoft Defender for Cloud overview | [Domain 4 notes](domains/04-security-operations.md) |
| Tue | Defender for Cloud — Secure Score, recommendations, remediation | Microsoft Learn |
| Wed | Defender for Cloud — Defender plans (VMs, SQL, Storage, etc.) | Microsoft Learn |
| Thu | **Lab:** Enable Defender for Cloud, remediate recommendations | [Lab 04](labs/lab-04-defender.md) |
| Fri | Azure Policy — built-in policies, custom policies, initiatives | Microsoft Learn |
| Sat | Azure Blueprints, Management Groups, policy compliance | Microsoft Learn |
| Sun | Review + quiz yourself on Weeks 5–6 concepts | [Mock exam Qs 46–60](practice-questions/mock-exam.md) |

---

### Week 7 — Microsoft Sentinel & Monitoring

| Day | Task | Resource |
|-----|------|----------|
| Mon | Microsoft Sentinel — architecture, workspaces | Microsoft Learn |
| Tue | Sentinel data connectors — Entra ID, Office 365, CEF/Syslog | Microsoft Learn |
| Wed | Sentinel analytics rules, incidents, playbooks | Microsoft Learn |
| Thu | **Lab:** Deploy Sentinel, connect Entra ID, create analytics rule | [Lab 05](labs/lab-05-sentinel.md) |
| Fri | KQL fundamentals — common queries for security investigations | Microsoft Learn |
| Sat | Azure Monitor, Log Analytics, Diagnostic Settings | Microsoft Learn |
| Sun | Catch-up / deep dive on weak areas | — |

---

### Week 8 — Review & Exam Prep

| Day | Task | Resource |
|-----|------|----------|
| Mon | Full mock exam (all 60 questions, timed) | [Mock exam](practice-questions/mock-exam.md) |
| Tue | Review incorrect answers; revisit weak domain notes | Domain files |
| Wed | Second full mock exam on a paid platform (Whizlabs / MeasureUp) | External |
| Thu | Review all [cheat sheets](cheatsheets/quick-reference.md) | Cheat sheets |
| Fri | Light review only — no new content; rest well | — |
| Sat | **EXAM DAY** 🎯 | — |
| Sun | Celebrate! 🎉 | — |

---

## Daily Study Tips

- **Active recall** beats passive reading — quiz yourself after each section.
- **Hands-on labs** are the fastest way to understand Azure services — don't skip them.
- **Explain it out loud** — if you can't explain a concept simply, you don't know it yet.
- **Use Microsoft Learn** — the official sandbox labs are free and require no Azure subscription.
- **Track Secure Score changes** in a real or free-tier subscription to build intuition.
