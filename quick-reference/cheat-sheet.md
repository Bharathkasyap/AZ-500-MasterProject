# AZ-500 Quick Reference Cheat Sheet

> **Back to [README](../README.md)**

---

## 🏆 Exam Overview

| | |
|---|---|
| **Exam Code** | AZ-500 |
| **Passing Score** | 700/1000 |
| **Duration** | 120 minutes |
| **Cost** | $165 USD |
| **Domains** | Identity (25–30%) · Networking (20–25%) · Compute/Storage (20–25%) · Operations (25–30%) |

---

## 🔐 Domain 1: Identity & Access — Quick Reference

### MFA Methods (Strongest → Weakest)

```
FIDO2 Security Key > Windows Hello for Business > Authenticator App (TOTP) > 
Authenticator Push > OATH Hardware Token > SMS / Voice Call (weakest)
```

### PIM — Key Points

| Item | Detail |
|---|---|
| **Eligible vs Active** | Eligible = must activate; Active = standing access |
| **Just-in-Time** | Activates on-demand with time limit |
| **Requires** | Entra ID P2 license |
| **Audit trail** | All activations logged |
| **Access Reviews** | Periodic certification via Identity Governance |

### RBAC Scope Hierarchy

```
Management Group → Subscription → Resource Group → Resource
                   ↑ Roles cascade DOWN
```

### Key RBAC Roles

| Role | Can Manage Resources | Can Assign Roles |
|---|---|---|
| Owner | ✅ | ✅ |
| Contributor | ✅ | ❌ |
| Reader | View only | ❌ |
| User Access Administrator | ❌ | ✅ |

### Managed Identity Types

| Type | Lifecycle | Multiple Resources |
|---|---|---|
| System-assigned | Tied to resource | ❌ One resource only |
| User-assigned | Independent | ✅ Can be shared |

---

## 🌐 Domain 2: Networking — Quick Reference

### NSG Rule Properties

```
Priority (100–4096, lower = higher priority)
Source → Destination | Protocol | Port | Action (Allow/Deny) | Direction
```

### Default NSG Rules

```
65000 AllowVnetInBound   → Allow
65001 AllowAzureLBInBound → Allow  
65500 DenyAllInBound      → Deny   ← All unmatched traffic is denied

65000 AllowVnetOutBound   → Allow
65001 AllowInternetOutBound → Allow
65500 DenyAllOutBound     → Deny
```

### Private Endpoint vs Service Endpoint

| | Private Endpoint | Service Endpoint |
|---|---|---|
| **IP used** | Private IP from VNet | Service's public IP |
| **Isolation** | Stronger (no public IP needed) | Weaker (public IP used) |
| **DNS** | Requires private DNS zone | No DNS changes |
| **Recommended** | ✅ Preferred | For legacy scenarios |

### Azure Firewall Rule Types

| Type | Layer | Example Use |
|---|---|---|
| Application rules | L7 | FQDN filtering (`*.microsoft.com`) |
| Network rules | L3/L4 | IP/port/protocol filtering |
| NAT rules | L3/L4 | DNAT inbound to private VMs |

### Key Azure Networking Commands

```bash
# Force all outbound through firewall
az network route-table route create \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address <firewall-private-ip>

# Test NSG rules
az network watcher test-ip-flow \
  --vm <vm-id> --direction Inbound \
  --local-ip <vm-ip> --local-port <port> \
  --remote-ip <test-ip> --protocol TCP

# Enable NSG flow logs
az network watcher flow-log create \
  --nsg <nsg-name> --storage-account <account> \
  --enabled true --log-version 2
```

---

## 💾 Domain 3: Compute, Storage, Databases — Quick Reference

### Encryption Comparison

| Feature | Scope | Key Owner | Use Case |
|---|---|---|---|
| **SSE (PMK)** | Storage at rest | Microsoft | Default — zero config |
| **SSE (CMK)** | Storage at rest | Customer (Key Vault) | Compliance/revocation |
| **ADE** | VM OS/data disks (OS level) | Customer (Key Vault) | Physical disk protection |
| **Always Encrypted** | DB column | Customer | Protect from DBAs |
| **TDE** | Database at rest | Microsoft or Customer | Default for Azure SQL |
| **DDM** | DB column (display only) | N/A | Non-privileged user access |

### Key Vault SKUs

| SKU | Protection | FIPS Level |
|---|---|---|
| Standard | Software | N/A |
| Premium | HSM-backed | FIPS 140-2 Level 2 |
| Managed HSM | Dedicated HSM | FIPS 140-2 Level 3 |
| Dedicated HSM | Physical dedicated | FIPS 140-2 Level 3 |

### Key Vault Security Checklist

```bash
✅ Enable RBAC authorization (not access policies)
✅ Enable soft delete
✅ Enable purge protection
✅ Restrict network access (firewall rules)
✅ Enable diagnostic logging (AuditEvent → Log Analytics)
✅ Use managed identity for app access
✅ Set key/secret expiration dates
```

### Storage Account Security Checklist

```bash
✅ Require HTTPS (--https-only true)
✅ Minimum TLS 1.2 (--min-tls-version TLS1_2)
✅ Disable public blob access (--allow-blob-public-access false)
✅ Disable shared key access when possible (--allow-shared-key-access false)
✅ Enable Defender for Storage
✅ Use Private Endpoints for sensitive workloads
✅ Use User Delegation SAS (not Account SAS)
✅ Enable soft delete and versioning
```

### SAS Token Types (Best → Worst)

```
User Delegation SAS > Service SAS > Account SAS
(backed by Entra)    (single svc)   (full access)
```

---

## 🛡️ Domain 4: Security Operations — Quick Reference

### Defender for Cloud Plans

```
Free tier: Foundational CSPM (Secure Score, basic recommendations)
Paid:      Defender CSPM, Defender for Servers, Storage, SQL, 
           Containers, App Service, Key Vault, DNS, Resource Manager
```

### Sentinel Analytics Rule Types

| Type | Trigger | ML |
|---|---|---|
| Scheduled | KQL runs on schedule | ❌ |
| NRT | Near real-time KQL | ❌ |
| Fusion | Multi-stage attack | ✅ |
| Anomaly | Behavioral baseline | ✅ |
| Threat Intelligence | TI feed matching | ❌ |
| Microsoft Security | Import Defender alerts | ❌ |

### Playbooks vs Automation Rules

| | Automation Rules | Playbooks |
|---|---|---|
| **Complexity** | Simple built-in actions | Complex Logic App workflows |
| **Latency** | ~1 second | Minutes (async) |
| **Use for** | Assign, tag, severity, close | Block IP, send email, create ticket |
| **No-code** | ✅ Yes | Requires Logic App designer |

### KQL Must-Know Operators

```kql
| where          -- Filter rows (like SQL WHERE)
| project        -- Select columns (like SQL SELECT)
| extend         -- Add computed column
| summarize      -- Aggregate (like SQL GROUP BY)
| join           -- Join tables
| union          -- Combine tables (like SQL UNION)
| order by       -- Sort results
| take           -- Limit rows (like SQL TOP)
| distinct       -- Unique values
| parse          -- Extract from string
| mv-expand      -- Expand array/bag column
| render timechart -- Visualize as time chart
| render barchart  -- Visualize as bar chart
```

### Key Log Tables in Sentinel/Log Analytics

| Table | Content |
|---|---|
| `SigninLogs` | Entra ID sign-in events |
| `AuditLogs` | Entra ID directory changes |
| `AzureActivity` | Azure subscription operations (create/delete/update) |
| `SecurityAlert` | Defender for Cloud alerts |
| `SecurityIncident` | Sentinel incidents |
| `AzureDiagnostics` | Azure resource diagnostic logs |
| `CommonSecurityLog` | CEF-formatted logs (firewalls, etc.) |
| `Syslog` | Linux syslog |
| `OfficeActivity` | Microsoft 365 activity |
| `DeviceEvents` | Defender for Endpoint device events |

### Azure Policy Effects (in priority order)

```
Disabled → Append → Deny → Audit → Modify → AuditIfNotExists → DeployIfNotExists
           ↑ Preventive ↑        ↑ Detective ↑          ↑ Remediation ↑
```

---

## ⚡ Critical Services Comparison

### Identity Protection vs Conditional Access vs PIM

| Service | Purpose | When triggered |
|---|---|---|
| **Identity Protection** | Detect risky users/sign-ins using ML | At sign-in or continuously |
| **Conditional Access** | Enforce access policies (MFA, device, location) | At sign-in |
| **PIM** | Just-in-time privileged role activation | When user requests role |

### Defender for Cloud vs Sentinel

| | Defender for Cloud | Sentinel |
|---|---|---|
| **Type** | CSPM + CWPP | SIEM + SOAR |
| **Focus** | Resource-level posture + threats | Enterprise-wide correlation |
| **Input** | Azure resources directly | Data connectors |
| **Output** | Security alerts + recommendations | Incidents |
| **Automation** | Workflow Automation (Logic Apps) | Playbooks + Automation Rules |

---

## 🔢 Important Numbers to Remember

| Item | Value |
|---|---|
| NSG rule priority range | 100 – 4096 |
| NSG default deny rule priority | 65500 |
| Key Vault soft delete range | 7 – 90 days |
| Log Analytics default retention | 30 days |
| Log Analytics max retention | 730 days (2 years) |
| PIM eligible assignment max | Configurable (up to permanent eligible) |
| Azure RBAC max custom roles per tenant | 5,000 |
| Entra ID password protection max custom entries | 1,000 |
| AZ-500 passing score | 700 / 1000 |

---

## 🚨 Common Exam Traps

1. **NSG vs Azure Firewall**: NSGs are L3/L4 stateful; Azure Firewall adds L7 (FQDN, IDPS). Use BOTH.
2. **Private Endpoint needs a private DNS zone** to work correctly.
3. **Soft delete ≠ Purge protection**: Soft delete allows recovery; purge protection prevents purging during soft-delete period.
4. **DDM is not encryption**: Masks display only — privileged users can grant themselves UNMASK.
5. **ADE and SSE are complementary**: SSE is always-on platform encryption; ADE adds OS-level encryption.
6. **MFA fatigue**: Authenticator push is vulnerable; recommend number matching or FIDO2.
7. **User Delegation SAS > Account SAS**: Backed by Entra credentials, revokable per user.
8. **Conditional Access for MFA, not per-user MFA**: Per-user MFA is legacy; CA policies are the modern approach.
9. **JIT requires Defender for Servers** (Plan 1 or 2).
10. **Automation Rule vs Playbook**: Automation rules for simple triage; Playbooks for complex response.

---

## 📚 Last-Minute Study Links

| Resource | URL |
|---|---|
| AZ-500 Exam Skills Outline | https://learn.microsoft.com/credentials/certifications/exams/az-500/ |
| Free Practice Assessment | https://learn.microsoft.com/credentials/certifications/practice-assessments-for-microsoft-certifications |
| Microsoft Learn AZ-500 Path | https://learn.microsoft.com/training/paths/manage-identity-access/ |
| Schedule Exam | https://examregistration.microsoft.com/ |

---

> ⬆️ [Back to README](../README.md)
