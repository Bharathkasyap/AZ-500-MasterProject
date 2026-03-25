# AZ-500 Quick Reference Cheat Sheets

> Use this document for last-minute review the night before your exam.

---

## 📋 Table of Contents

1. [Certification at a Glance](#1-certification-at-a-glance)
2. [Identity & Access — Key Facts](#2-identity--access--key-facts)
3. [Networking — Key Facts](#3-networking--key-facts)
4. [Compute, Storage & DB — Key Facts](#4-compute-storage--db--key-facts)
5. [Security Operations — Key Facts](#5-security-operations--key-facts)
6. [Azure CLI Quick Reference](#6-azure-cli-quick-reference)
7. [KQL Quick Reference](#7-kql-quick-reference)
8. [Common Decision Trees](#8-common-decision-trees)

---

## 1. Certification at a Glance

| Field | Value |
|-------|-------|
| Exam | AZ-500: Microsoft Azure Security Technologies |
| Certification | Microsoft Certified: Azure Security Engineer Associate |
| Cost | $165 USD |
| Passing Score | **700 / 1000** |
| Duration | 120 minutes |
| Domains | Identity (25–30%) · Networking (20–25%) · Compute/Storage/DB (20–25%) · Ops (25–30%) |

---

## 2. Identity & Access — Key Facts

### License Requirements
| Feature | License |
|---------|---------|
| Conditional Access | **P1** or higher |
| PIM | **P2** required |
| Identity Protection | **P2** required |
| Access Reviews | P1 (basic) / P2 (PIM reviews) |
| Entitlement Management | P2 |
| SSPR | P1 for hybrid; free for cloud-only |

### RBAC Roles (Critical)
| Role | Can Assign Roles? | Full Resource Access? | Manage Security? |
|------|------------------|-----------------------|-----------------|
| Owner | ✅ | ✅ | ❌ (security-specific) |
| Contributor | ❌ | ✅ | ❌ |
| Reader | ❌ | ❌ (read only) | ❌ |
| User Access Administrator | ✅ (only) | ❌ | ❌ |
| Security Admin | ❌ | ❌ | ✅ |
| Security Reader | ❌ | ❌ | ✅ (read only) |

### PIM Quick Facts
- Eligible assignments require **activation** before use.
- Activation can require: MFA, justification, approval.
- Max activation duration: configurable (1–24 hours).
- Access reviews in PIM: missing reviewer response → auto-remove (if configured).
- Requires: **Entra ID P2**.

### Managed Identities
| Type | Tied To | Auto-Deleted? | Shareable? |
|------|---------|--------------|-----------|
| System-assigned | Single resource | ✅ (with resource) | ❌ |
| User-assigned | Independent | ❌ | ✅ (multiple resources) |

### Conditional Access Must-Know
- Break-glass accounts → **always exclude from CA**.
- Sign-in risk / User risk conditions → require **P2**.
- Report-only mode → logs what would happen, no enforcement.
- Persistent browser session → Session control, not Grant.
- MFA per-user (legacy) vs CA policy → **CA is preferred**.

---

## 3. Networking — Key Facts

### NSG Processing Order
```
INBOUND:  Subnet NSG → NIC NSG
OUTBOUND: NIC NSG → Subnet NSG
(Both must Allow for traffic to pass)
```

### Azure Firewall Rule Processing
```
Threat Intelligence (optional) → DNAT → Network rules → Application rules
```

### Azure Firewall SKU Comparison
| Feature | Standard | Premium |
|---------|----------|---------|
| L3–L7 FQDN filtering | ✅ | ✅ |
| Threat Intelligence | ✅ | ✅ |
| TLS Inspection | ❌ | ✅ |
| IDPS | ❌ | ✅ |
| URL Categories | ❌ | ✅ |

### WAF Modes
| Mode | Blocks? | Logs? |
|------|---------|-------|
| Detection | ❌ | ✅ |
| Prevention | ✅ | ✅ |

### DDoS Tiers
| Tier | Per-VNet Tuning | Rapid Response | Attack Analytics | Cost |
|------|----------------|---------------|-----------------|------|
| Basic (Infrastructure) | ❌ | ❌ | ❌ | Free |
| Network Protection (Standard) | ✅ | ✅ | ✅ | ~$2,944/mo |

> DDoS + WAF = L3/L4 + L7 protection (both needed for full coverage).

### Bastion Facts
- Subnet: `AzureBastionSubnet` (exact name, case-sensitive)
- Minimum subnet size: **/26**
- No public IP needed on VMs.
- Basic SKU: browser only. Standard SKU: native client, file transfer, custom ports.

### Private Endpoint vs Service Endpoint
| Feature | Private Endpoint | Service Endpoint |
|---------|-----------------|-----------------|
| Private IP in VNet | ✅ | ❌ |
| Works from on-prem | ✅ | ❌ |
| DNS change required | ✅ | ❌ |
| Cost | Yes (per-hour + data) | Free |
| Disables public access | ❌ (manual) | ❌ (manual) |

> **On-prem access to PaaS** → always use **Private Endpoint** (not Service Endpoint).

---

## 4. Compute, Storage & DB — Key Facts

### Key Vault Access Models
| Model | How Access is Granted |
|-------|----------------------|
| Access Policies (legacy) | Per-object-type permissions (Get, List, Set...) per principal |
| Azure RBAC (recommended) | Standard RBAC roles (Key Vault Administrator, Secrets User, etc.) |

### Key Vault Roles (RBAC Model)
| Role | Can Manage Vault? | Can Read Secrets? | Can Create Secrets? |
|------|------------------|------------------|---------------------|
| Key Vault Administrator | ✅ | ✅ | ✅ |
| Key Vault Secrets Officer | ❌ | ✅ | ✅ |
| Key Vault Secrets User | ❌ | ✅ | ❌ |
| Key Vault Reader | ❌ | ❌ (metadata only) | ❌ |

### Soft-Delete & Purge Protection
| Feature | State |
|---------|-------|
| Soft-delete | Always enabled (cannot be disabled for new vaults) |
| Purge Protection | Optional; once enabled, **cannot be disabled** |

### Encryption Comparison
| Solution | Level | OS-visible | Key Location |
|----------|-------|-----------|-------------|
| SSE with PMK | Storage layer | No | Microsoft managed |
| SSE with CMK | Storage layer | No | Customer Key Vault |
| Azure Disk Encryption (ADE) | OS layer (BitLocker/dm-crypt) | Yes | Customer Key Vault |

### Storage Authentication (most to least secure)
1. **Azure AD (RBAC)** — recommended
2. **User Delegation SAS** — uses Entra ID credentials; max 7 days
3. **Service/Account SAS** — uses storage account key; time-limited
4. **Storage Account Key** — full admin access; avoid in apps

### SQL Security Quick Reference
| Feature | What It Does |
|---------|-------------|
| TDE | Encrypts database files at rest (transparent to app) |
| Always Encrypted | Client-side encryption; DB never sees plaintext |
| Dynamic Data Masking | Masks query results for non-privileged users (no encryption) |
| Row-Level Security | Filters rows based on user context |
| SQL Auditing | Logs queries and events to Storage/LA/Event Hub |
| Defender for SQL | Real-time threat detection (SQL injection, anomalies) |
| Vulnerability Assessment | Scans for misconfigurations, missing patches |

---

## 5. Security Operations — Key Facts

### Defender for Cloud Tiers
| Tier | Cost | Key Features |
|------|------|-------------|
| Foundational CSPM | Free | Secure Score, basic recommendations |
| Defender CSPM | Paid | Attack path, cloud security explorer, agentless scan |
| Defender Plans | Paid per resource | Threat detection per workload type |

### JIT VM Access
- Included in: **Defender for Servers Plan 1** (not just Plan 2).
- Locks RDP/SSH ports with NSG deny rules.
- Requestor's IP gets temporary allow rule.
- Default max access time: 3 hours.

### Defender for Servers Plans
| Feature | Plan 1 | Plan 2 |
|---------|--------|--------|
| JIT VM Access | ✅ | ✅ |
| Adaptive App Controls | ✅ | ✅ |
| Adaptive Network Hardening | ✅ | ✅ |
| Defender for Endpoint | ❌ | ✅ |
| File Integrity Monitoring | ❌ | ✅ |
| OS Baseline Assessment | ❌ | ✅ |
| Network Map | ❌ | ✅ |

### Secure Score Rules
- Points per control = Max score only when **ALL** recommendations remediated.
- Partial completion = **0 points** for the control.
- Exempt resources: don't count against the score.

### Sentinel Analytics Rule Types
| Type | Detection Method | Latency |
|------|-----------------|---------|
| Scheduled | KQL query on schedule | Minutes |
| NRT (Near Real-Time) | KQL every ~1 minute | ~1 min |
| Microsoft Security | Forward Defender alerts | Near real-time |
| Anomaly | ML baseline deviation | Varies |
| Fusion | Multi-signal ML correlation | Varies |
| ML Behavioral Analytics | UEBA ML models | Varies |

### Azure Policy Effects (most to least restrictive)
```
Deny → Modify/Append → DeployIfNotExists/AuditIfNotExists → Audit → Disabled
```

| Effect | Blocks Creation? | Auto-Remediation? |
|--------|-----------------|------------------|
| Deny | ✅ | ❌ |
| Audit | ❌ | ❌ |
| DeployIfNotExists | ❌ | ✅ (deploys related resource) |
| Modify | ❌ | ✅ (modifies resource properties) |

---

## 6. Azure CLI Quick Reference

### Identity
```bash
# Create user
az ad user create --display-name "Name" --user-principal-name "u@domain.com" --password "P@ss"

# Assign RBAC role
az role assignment create --assignee <principal-id> --role "Contributor" --scope <resource-id>

# List role assignments
az role assignment list --assignee <principal-id> --all -o table

# Create managed identity
az identity create --resource-group <rg> --name <identity-name>
```

### Key Vault
```bash
# Create Key Vault (RBAC mode)
az keyvault create --name <name> --resource-group <rg> --enable-rbac-authorization true --enable-purge-protection true

# Set secret
az keyvault secret set --vault-name <name> --name <secret-name> --value <value>

# Get secret
az keyvault secret show --vault-name <name> --name <secret-name> --query value -o tsv

# Add firewall rule
az keyvault network-rule add --name <vault> --resource-group <rg> --ip-address <ip>/32
```

### Security
```bash
# Enable Defender plan
az security pricing create --name VirtualMachines --tier Standard --subplan P2

# List Secure Score
az security secure-score list -o table

# Set security contact
az security contact create --name default --email sec@co.com --alert-notifications On
```

### Networking
```bash
# Create NSG rule
az network nsg rule create --resource-group <rg> --nsg-name <nsg> --name <rule> \
  --priority 100 --direction Inbound --protocol Tcp \
  --source-address-prefixes "*" --destination-port-ranges 443 --access Allow

# Create UDR
az network route-table route create --resource-group <rg> --route-table-name <rt> \
  --name DefaultRoute --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance --next-hop-ip-address <firewall-ip>

# Enable NSG flow logs
az network watcher flow-log create --resource-group <rg> --name <name> \
  --nsg <nsg-id> --storage-account <storage-id> --enabled true
```

---

## 7. KQL Quick Reference

### Basic Structure
```kql
TableName
| where TimeGenerated > ago(1d)
| where Column == "value"
| project Column1, Column2, Column3
| summarize Count = count() by Column1
| order by Count desc
| take 10
```

### Useful Operators
| Operator | Purpose | Example |
|----------|---------|---------|
| `where` | Filter rows | `where Severity == "High"` |
| `project` | Select columns | `project Time, User, IP` |
| `extend` | Add computed column | `extend Hour = bin(TimeGenerated, 1h)` |
| `summarize` | Aggregate | `summarize count() by User` |
| `order by` | Sort | `order by TimeGenerated desc` |
| `join` | Combine tables | `Table1 \| join Table2 on Key` |
| `union` | Stack tables | `union Table1, Table2` |
| `parse` | Extract values from string | `parse msg_s with "from " SourceIP ":"` |
| `make_set` | Create array of unique values | `summarize IPs = make_set(IPAddress)` |
| `bin` | Time bucketing | `bin(TimeGenerated, 5m)` |

### Key Security Tables
| Table | Contains |
|-------|---------|
| `SigninLogs` | Entra ID sign-in events |
| `AuditLogs` | Entra ID directory changes |
| `AzureActivity` | Azure management plane operations |
| `SecurityAlert` | Defender for Cloud / Sentinel alerts |
| `SecurityEvent` | Windows Security Event Log |
| `Syslog` | Linux system logs |
| `AzureDiagnostics` | Azure resource diagnostics |
| `AzureFirewallApplicationRule` | Azure Firewall app rule hits |
| `AzureFirewallNetworkRule` | Azure Firewall network rule hits |
| `CommonSecurityLog` | CEF format from third-party devices |

---

## 8. Common Decision Trees

### Which encryption solution?
```
Need to encrypt VM OS disk?
  └── YES → Azure Disk Encryption (ADE) with Key Vault
  
Need to encrypt storage at rest?
  ├── You manage the key → SSE with CMK (Key Vault)
  └── Microsoft manages the key → SSE with PMK (default, already on)

SQL data: DB engine must NOT see plaintext?
  └── Always Encrypted (client-side)
  
SQL data: Mask for non-admin users?
  └── Dynamic Data Masking
```

### Which access control (Key Vault)?
```
New deployment?
  └── Azure RBAC model (recommended)
  
Existing deployment using access policies?
  └── Keep using access policies OR migrate to RBAC
  
Need HSM-backed keys, FIPS 140-2 Level 3?
  └── Key Vault Premium SKU or Managed HSM
```

### Which network security solution?
```
Block/allow by IP, port, protocol (L3/L4) within VNet?
  └── NSG

Centralized L3–L7 firewall with logging, FQDN rules?
  └── Azure Firewall (Standard for basic; Premium for TLS + IDPS)

Protect web application from OWASP attacks?
  └── WAF (Application Gateway for regional; Front Door for global)

Protect against volumetric DDoS?
  └── DDoS Network Protection Standard

RDP/SSH to VMs without public IP?
  └── Azure Bastion

Temporary/on-demand RDP/SSH with audit trail?
  └── JIT VM Access (Defender for Servers P1+)

Private connectivity to PaaS service (on-prem support needed)?
  └── Private Endpoint

Private connectivity to PaaS service (Azure-only, free option)?
  └── Service Endpoint
```

### Which Sentinel rule type?
```
Forward alerts from Defender / MDE?
  └── Microsoft Security rule

Detect pattern in logs with KQL?
  ├── Need low latency (< 5 min)? → NRT rule
  └── Normal latency acceptable? → Scheduled rule

Detect behavioral anomalies (ML-based)?
  └── Anomaly rule

Correlate multiple weak signals into one high-confidence incident?
  └── Fusion rule
```

### Which Conditional Access grant control?
```
Require second factor for sign-in?
  └── Require MFA

Require device managed by Intune?
  └── Require compliant device

Require corporate domain-joined device?
  └── Require Hybrid Azure AD joined

Block access entirely?
  └── Block access
```

---

*Good luck on the AZ-500 exam! Remember: 700/1000 to pass. You've got this! 🎯*
