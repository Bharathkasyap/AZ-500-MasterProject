# AZ-500 Exam Day Cheat Sheet

← [Back to README](../README.md)

> **Quick-reference for key facts, numbers, and concepts. Review the night before your exam.**

---

## 🔐 Domain 1: Identity & Access — Quick Reference

### Entra ID License Requirements

| Feature | License |
|---------|---------|
| Conditional Access | P1 or P2 |
| Privileged Identity Management (PIM) | **P2 only** |
| Identity Protection | **P2 only** |
| Access Reviews | P2 (Governance) |
| SSPR (hybrid) | P1 or P2 |
| Dynamic groups | P1 or P2 |
| B2B collaboration | Free |
| Security Defaults | Free |

### Key Rules

- **Security Defaults vs Conditional Access**: Mutually exclusive — cannot use both
- **RBAC is additive**: effective permissions = union of all role assignments
- **RBAC deny assignments**: only created via Blueprints — admins can't create directly
- **Owner** can assign roles; **Contributor** cannot
- **User Access Administrator**: manages access (role assignments) only, no resource management
- System-assigned MI → deleted with resource; User-assigned MI → independent lifecycle
- **Application permissions** → always require admin consent
- **Delegated permissions** → may require admin consent depending on scope
- Guest users (B2B) authenticate via their **home tenant**
- **SSPR + high user risk policy** → requires user to be registered for SSPR first

### RBAC Scope Hierarchy (inheritance flows down ↓)

```
Management Group
    └── Subscription
            └── Resource Group
                    └── Resource
```

### PIM Activation Workflow

```
Eligible Assignment → User Activates → (MFA + Justification + Approval) → Active (time-limited) → Auto-expires
```

---

## 🌐 Domain 2: Secure Networking — Quick Reference

### NSG Essentials

| Rule number | Action |
|-------------|--------|
| Lower number | Higher priority (processed first) |
| 65000 | Default AllowVNetInBound / AllowVNetOutBound |
| 65001 | Default AllowAzureLoadBalancerInBound / AllowInternetOutBound |
| 65500 | **DenyAllInBound / DenyAllOutBound** (final catch-all deny) |

- Subnet NSG + NIC NSG → traffic must pass **both** (either can block)
- **Service tags**: represent Azure service IP ranges (e.g., `Storage`, `Sql`, `AzureMonitor`)
- **ASGs**: group VMs by role; use in NSG rules instead of IP addresses

### Azure Firewall Processing Order

```
1. DNAT rules → 2. Network rules → 3. Application rules
```

- FQDN filtering → Application rules (not NSG)
- Threat intelligence → Firewall Standard (alert) / Premium (alert+deny)
- TLS inspection, IDPS, URL categories → **Firewall Premium only**

### DDoS Protection

| Plan | Cost | Analytics | Cost Protection |
|------|------|-----------|----------------|
| Basic/Infrastructure | Free | ❌ | ❌ |
| Network Protection | Paid | ✅ | ✅ |
| IP Protection | Paid/per IP | ✅ | ✅ |

- DDoS protects **L3/L4** only; WAF needed for **L7**

### Private Endpoint vs Service Endpoint

| | Private Endpoint | Service Endpoint |
|-|-----------------|-----------------|
| Cost | Per-endpoint | Free |
| DNS change needed | Yes (Private DNS Zone) | No |
| Disable public access | Yes (can fully) | Partial |
| Exfiltration protection | Strong | Weaker |

### Azure Bastion

- Subnet name: **exactly `AzureBastionSubnet`** (minimum /26)
- No public IP on VMs needed
- No NSG changes for internet RDP/SSH needed
- Standard SKU supports: native client, VNet peering, custom ports

### ExpressRoute Encryption

- Default: **NOT encrypted**
- MACsec: L2 encryption; requires **ExpressRoute Direct**
- IPsec over ExpressRoute: L3 encryption; uses **VPN Gateway** over private peering

### IP Flow Verify

- Tests if NSG allows/blocks a specific source→destination flow
- Found in **Network Watcher**

---

## 🖥️ Domain 3: Compute, Storage & Databases — Quick Reference

### Azure Key Vault

| Feature | Details |
|---------|---------|
| Object types | Secrets, Keys, Certificates |
| Soft delete | Always enabled by default; cannot disable |
| Purge protection | Must enable explicitly; required for CMK |
| Access models | RBAC (recommended) or Vault Access Policies |
| HSM tiers | Standard (software), Premium (FIPS 140-2 L2), Managed HSM (FIPS 140-2 L3) |

### Key Vault RBAC Roles

| Role | Can Do |
|------|--------|
| Key Vault Administrator | Everything |
| Key Vault Secrets Officer | Manage secrets (CRUD), NOT read values |
| **Key Vault Secrets User** | **Read secret values** (for apps) |
| Key Vault Crypto User | Use keys (sign/encrypt) |
| Key Vault Reader | View metadata only (no values) |

### Disk Encryption

| Type | Level | Tool | Key Location |
|------|-------|------|--------------|
| ADE (Azure Disk Encryption) | In-VM (OS level) | BitLocker (Win) / DM-Crypt (Linux) | Key Vault |
| SSE (Server-Side Encryption) | Storage platform | Managed | Platform or Key Vault (CMK) |
| Infrastructure Encryption | Platform (double) | N/A | Platform |

### Storage Security

- **SAS types**: Account SAS > Service SAS > **User Delegation SAS** (most secure, uses Entra ID)
- Disable public blob access at account level
- Enforce HTTPS only (min TLS 1.2)
- Rotate keys to revoke all SAS tokens based on that key

### Azure SQL Security

| Feature | What it Does |
|---------|-------------|
| TDE | Encrypts database FILES at rest; enabled by default |
| Always Encrypted | Encrypts column data at CLIENT; server never sees plaintext |
| Dynamic Data Masking | Masks QUERY RESULTS; actual data unchanged |
| Row-Level Security | Filters rows based on user context |
| Auditing | Logs all DB operations (Storage, Log Analytics, Event Hub) |

### Always Encrypted Encryption Types

| Type | Same plaintext = same ciphertext? | Supports equality search? |
|------|-----------------------------------|--------------------------|
| Deterministic | ✅ Yes | ✅ Yes |
| Randomized | ❌ No (more secure) | ❌ No |

### Just-In-Time VM Access

- Managed by **Defender for Cloud**
- Blocks RDP/SSH ports in NSG by default
- Opens temporarily when requested (specific IP, duration)
- Auto-removes NSG rule after timeout

---

## 🔍 Domain 4: Security Operations — Quick Reference

### Microsoft Sentinel Components

| Component | Purpose |
|-----------|---------|
| Data connectors | Ingest data from sources |
| Analytics rules | Detect threats → create incidents |
| Incidents | Grouped security alerts for investigation |
| Playbooks | Azure Logic Apps for automated response |
| Automation rules | No-code incident management; run before playbooks |
| Workbooks | Dashboards and visualizations |
| Hunting queries | Proactive threat search |
| Watchlists | CSV-based reference data for analytics |
| UEBA | Behavioral analytics (needs P2 and AAD logs) |
| Threat Intelligence | IOC feeds matched against logs |

### Sentinel Analytics Rule Types

| Type | How it works |
|------|-------------|
| Scheduled | KQL runs every N minutes |
| NRT (Near Real-Time) | Runs every ~1 minute |
| Microsoft Security | From M365 Defender alerts |
| Fusion | ML multi-stage attack |
| Anomaly | ML behavioral anomaly |
| Threat Intelligence | IOC matching |

### Azure Monitor Log Tables (Security)

| Table | Contains |
|-------|---------|
| `AzureActivity` | ARM operations (who did what with Azure resources) |
| `SigninLogs` | Entra ID sign-ins |
| `AuditLogs` | Entra ID directory changes |
| `SecurityEvent` | Windows security events from VMs |
| `Syslog` | Linux logs from VMs |
| `SecurityAlert` | Defender for Cloud alerts |
| `AzureFirewallApplicationRule` | Firewall app rule hits |
| `KeyVaultLogs` | Key Vault access audit |

### Activity Log Retention

- **Default**: 90 days
- **Export to Log Analytics**: For longer retention (up to 2 years interactive, or archive)
- **Archive to Storage**: Most cost-effective for long-term retention

### Azure Policy Effects (Priority Order)

```
Disabled > Append/Modify > Deny > Audit > AuditIfNotExists > DeployIfNotExists
```

- `Deny`: Blocks non-compliant resource creation
- `Audit`: Logs non-compliance (no blocking)
- `DeployIfNotExists` / `Modify`: Requires managed identity on assignment for remediation

### Defender for Cloud

- **Secure Score**: % of completed security controls; more controls completed = higher score
- **Recommendations**: Actionable items per security control
- **Alerts**: Generated by Defender plans; can trigger playbooks
- **Regulatory Compliance**: Maps to PCI DSS, NIST, ISO 27001, CIS, etc.
- **Continuous Export**: Stream alerts/recommendations to Log Analytics or Event Hub

---

## ⚡ Key Numbers to Remember

| Item | Value |
|------|-------|
| NSG default deny-all rule priority | **65500** |
| NSG rule priority range | **100–4096** |
| AzureBastionSubnet minimum size | **/26** |
| Key Vault soft delete retention (default) | **90 days** |
| Key Vault max access policies | **1024** |
| Client secret max expiry in Entra ID | **2 years** |
| Azure Activity Log default retention | **90 days** |
| PIM activation (maximum duration, configurable) | **Up to 24 hours** |
| P2S VPN — Entra ID auth protocol | **OpenVPN only** |
| Passing score for AZ-500 | **700 / 1000** |

---

## 🎯 Key "vs." Distinctions

### Managed Identity vs Service Principal

| | Managed Identity | Service Principal (non-MI) |
|-|-----------------|--------------------------|
| Credentials | None (Azure manages) | Client secret or certificate |
| Rotation | Automatic | Manual |
| Best for | Azure services accessing other Azure services | Apps outside Azure or cross-tenant |

### JIT VM Access vs Azure Bastion

| | JIT VM Access | Azure Bastion |
|-|--------------|--------------|
| Requires public IP on VM | Optional | No |
| Mechanism | Temporarily opens NSG rule | Proxy (private IP only) |
| Protocol | RDP/SSH via client | Browser or native client |
| Cost | Included with Defender for Servers | Separate per-hour cost |

### WAF Detection Mode vs Prevention Mode

| | Detection | Prevention |
|-|-----------|-----------|
| Logs threats | ✅ | ✅ |
| Blocks requests | ❌ | ✅ |
| Use for | Testing/tuning | Production |

### Always Encrypted vs TDE

| | Always Encrypted | TDE |
|-|-----------------|-----|
| Encryption level | Column (client-side) | Database files (platform) |
| Who can read plaintext | Only authorized clients | DBAs and cloud admins CAN read |
| Protects against | DBAs, cloud admin, insider threat | Physical media theft, backup theft |

### Security Defaults vs Conditional Access

| | Security Defaults | Conditional Access |
|-|-------------------|------------------|
| License | Free | P1 or P2 |
| Customization | None | Fully configurable |
| Can coexist? | **No** | **No** |
| Best for | Small orgs with no customization | Organizations needing granular control |

---

## 🔑 CLI Commands to Know

```bash
# Revoke all user sessions (containment)
az ad user revoke-sign-in-sessions --id user@domain.com

# Disable a user account
az ad user update --id user@domain.com --account-enabled false

# Rotate storage account key
az storage account keys renew --account-name <name> --resource-group <rg> --key primary

# Check VM encryption status
az vm encryption show --name <vm> --resource-group <rg>

# List PIM assignments
Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -ResourceId "<tenant-id>"

# Test NSG traffic flow
az network watcher test-ip-flow --vm <vm> --resource-group <rg> \
  --direction Inbound --protocol TCP --local 10.0.0.4:80 --remote 1.2.3.4:52000

# Create firewall application rule
az network firewall application-rule create \
  --firewall-name <fw> --resource-group <rg> \
  --collection-name AllowWeb --priority 200 --action Allow \
  --name AllowMicrosoft --source-addresses '*' \
  --target-fqdns '*.microsoft.com' --protocols Https=443
```

---

## 📋 Last-Minute Reminders

1. ✅ **PIM needs P2** — not P1, not just Defender for Cloud
2. ✅ **Security Defaults ≠ Conditional Access** — pick one, not both
3. ✅ **NSG lower number = higher priority** (processed first)
4. ✅ **Firewall order**: DNAT → Network → Application rules
5. ✅ **Bastion subnet**: Must be named **exactly** `AzureBastionSubnet`
6. ✅ **ExpressRoute**: NOT encrypted by default
7. ✅ **Key Vault purge protection**: NOT enabled by default — must enable manually
8. ✅ **TDE**: Enabled by default on all new Azure SQL databases
9. ✅ **Always Encrypted**: Deterministic = searchable; Randomized = not searchable
10. ✅ **DDM**: Masks query RESULTS only — does NOT encrypt data
11. ✅ **User Delegation SAS**: Most secure SAS type (signed with Entra ID token)
12. ✅ **JIT VM Access**: Part of Defender for Cloud (Defender for Servers plan)
13. ✅ **Sentinel playbooks = Logic Apps** (SOAR automation)
14. ✅ **Activity Log**: Retains for 90 days; audit control plane operations
15. ✅ **DeployIfNotExists/Modify policies**: Need managed identity on assignment

---

← [Back to README](../README.md) | [Study Resources →](./study-resources.md)
