# Domain 2 — Secure Networking (20–25%)

## Overview

This domain covers how to protect Azure network infrastructure using layered defense-in-depth controls — from basic NSGs all the way to advanced threat protection with Azure Firewall Premium and DDoS Protection.

---

## 2.1 Network Security Groups (NSGs)

NSGs are **stateful packet filters** applied at the subnet or NIC level.

### NSG Rule Components

| Property | Description |
|----------|-------------|
| **Priority** | 100–4096; lower number = higher priority |
| **Source/Destination** | IP, CIDR, Service Tag, or ASG |
| **Protocol** | TCP, UDP, ICMP, or Any |
| **Port range** | Single port or range |
| **Action** | Allow or Deny |

### Default NSG Rules (cannot be deleted)

| Priority | Name | Direction | Action |
|----------|------|-----------|--------|
| 65000 | AllowVnetInBound | Inbound | Allow |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allow |
| 65500 | DenyAllInBound | Inbound | **Deny** |
| 65000 | AllowVnetOutBound | Outbound | Allow |
| 65001 | AllowInternetOutBound | Outbound | Allow |
| 65500 | DenyAllOutBound | Outbound | **Deny** |

### Application Security Groups (ASGs)
- Logical grouping of VMs (no IPs needed in rules)
- Simplify NSG rule management for app tiers
- Example: Allow `WebTier` ASG → `AppTier` ASG on port 8080

### NSG Flow Logs
- Logged to Azure Storage (V1) or Log Analytics + Traffic Analytics (V2)
- Required for: security audits, compliance, network monitoring

---

## 2.2 Azure Firewall

Azure Firewall is a **managed, cloud-native, stateful network firewall** with built-in high availability.

### Standard vs. Premium

| Feature | Standard | Premium |
|---------|----------|---------|
| FQDN filtering | ✅ | ✅ |
| Network rules | ✅ | ✅ |
| NAT rules | ✅ | ✅ |
| Threat Intelligence | ✅ (alert/deny) | ✅ |
| **IDPS** (Intrusion Detection & Prevention) | ❌ | ✅ |
| **TLS Inspection** | ❌ | ✅ |
| **Web Categories** | ❌ | ✅ |
| **URL Filtering** | ❌ | ✅ |

### Rule Collection Types (evaluation order)

```
1. DNAT Rules       (Destination NAT — inbound)
2. Network Rules    (Layer 3/4 — IP, port, protocol)
3. Application Rules(Layer 7 — FQDNs, HTTP/HTTPS)
```

Rule collections within a type are evaluated in **priority order (lowest number first)**.

### Forced Tunneling
- Routes all internet-bound traffic through on-premises firewall
- Requires a separate management public IP or subnet

### Azure Firewall Manager
- Central security policy management for multiple firewalls
- Uses **Firewall Policy** (ARM resource) instead of classic firewall rules
- Supports **Secured Virtual Hubs** (Azure Virtual WAN)

---

## 2.3 DDoS Protection

| Plan | Description |
|------|-------------|
| **DDoS Network Protection** (formerly Standard) | Per-VNet; adaptive tuning, telemetry, rapid response team, cost guarantee |
| **DDoS IP Protection** | Per-public IP; same protection, no rapid response team |
| **Basic (Infrastructure)** | Always-on; protects Azure infrastructure only |

### Protected Resource Types
- Virtual machine public IPs
- Azure Load Balancer public IPs
- Azure Application Gateway
- Azure Firewall

### DDoS Telemetry
- Metrics available in Azure Monitor
- Attack alerts via Azure Monitor action groups
- Diagnostic logs sent to Log Analytics or Storage

---

## 2.4 Web Application Firewall (WAF)

WAF protects web applications from common exploits (OWASP Top 10).

### WAF Deployment Points

| Service | Use Case |
|---------|---------|
| **Application Gateway WAF** | Regional HTTP/HTTPS load balancer + WAF |
| **Azure Front Door WAF** | Global CDN + WAF (multi-region) |
| **Azure CDN WAF** | Content delivery + WAF |

### WAF Policy Modes

| Mode | Behavior |
|------|---------|
| **Detection** | Log threats but do not block |
| **Prevention** | Block and log threats |

### OWASP Rule Sets
- **OWASP 3.2** (latest recommended)
- **OWASP 3.1 / 3.0** (legacy)
- **Microsoft Default Rule Set (DRS)** — for Front Door

### Custom WAF Rules
- Rate limiting, geo-filtering, IP allow/block lists
- Evaluated **before** managed rule sets

---

## 2.5 Private Link & Private Endpoints

### Azure Private Link
- Access Azure PaaS services (Storage, SQL, Key Vault, etc.) over a **private IP** in your VNet
- Traffic stays on the Microsoft backbone — never traverses the public internet

### Private Endpoint
- A **NIC** in your VNet with a private IP mapped to the PaaS service
- DNS must be updated to resolve the service FQDN to the private IP

```
Consumer VNet
  ├── VM ──→ private-endpoint-NIC (10.0.1.5)
  │                ↓ (private connection)
  └──────────────────────────────────────────→ Azure Storage Account
                                                (no public internet traversal)
```

### Private DNS Zone Integration
- Auto-linked private DNS zone resolves the FQDN to the private IP
- Example: `mystorageaccount.blob.core.windows.net` → `10.0.1.5`
- Common zones: `privatelink.blob.core.windows.net`, `privatelink.vaultcore.azure.net`

### Service Endpoints vs. Private Endpoints

| Feature | Service Endpoint | Private Endpoint |
|---------|-----------------|-----------------|
| Private IP in VNet | ❌ | ✅ |
| Traffic stays on backbone | ✅ | ✅ |
| Accessible from on-prem/peered VNets | ❌ | ✅ |
| DNS resolution change needed | ❌ | ✅ |
| Cost | Free | Per-hour + data |

---

## 2.6 VPN Gateway Security

### VPN Types

| Type | Use Case |
|------|---------|
| **Site-to-Site (S2S)** | On-premises ↔ Azure |
| **Point-to-Site (P2S)** | Individual client ↔ Azure |
| **VNet-to-VNet** | Two Azure VNets |

### P2S Authentication Methods

| Method | Security Level |
|--------|---------------|
| Certificate | High |
| Azure AD (OpenVPN) | High |
| RADIUS (on-prem) | High |

### VPN Gateway SKUs
- **Basic**: No zone redundancy, IKEv1 only
- **VpnGw1–5**: Zone-redundant options (AZ SKUs), IKEv2
- Use **IKEv2** and **AES-256 / SHA-256** for strong encryption

### ExpressRoute Security
- Private connectivity via carrier — does **not** traverse the internet
- **ExpressRoute encryption**: MACsec (layer 2) or IPsec over ExpressRoute (layer 3)
- Use **Azure VPN Gateway** on top of ExpressRoute for end-to-end encryption

---

## 2.7 Azure Bastion

Azure Bastion provides **browser-based RDP/SSH** to VMs **without exposing public IPs** or requiring a jump server.

| Feature | Basic SKU | Standard SKU |
|---------|-----------|--------------|
| RDP/SSH via browser | ✅ | ✅ |
| Shareable link | ❌ | ✅ |
| File transfer | ❌ | ✅ |
| Session recording | ❌ | ✅ |
| IP-based connections | ❌ | ✅ |
| Native client support | ❌ | ✅ |

### Deployment Requirements
- Dedicated **AzureBastionSubnet** (/26 or larger) in the target VNet
- Standard public IP (static)
- NSGs on AzureBastionSubnet must allow:
  - Inbound: 443 from internet, 443 & 8080 from `GatewayManager` service tag
  - Outbound: 3389 & 22 to `VirtualNetwork`, 443 to `AzureCloud`

---

## 2.8 Network Security Best Practices

```
Defense in Depth — Network Layer
─────────────────────────────────────────────────────────
[Internet]
    ↓
DDoS Protection (volumetric attacks)
    ↓
Azure Firewall / WAF (layer 7 inspection)
    ↓
NSG on Subnet (layer 4 filtering)
    ↓
NSG on NIC (additional granularity)
    ↓
Private Endpoints (eliminate public surface)
    ↓
[Azure Resource — VM, Storage, SQL, etc.]
```

### Hub-and-Spoke Architecture
- **Hub VNet**: Contains Azure Firewall, VPN/ExpressRoute Gateway, Bastion
- **Spoke VNets**: Application workloads, peered to hub
- All spoke-to-spoke and spoke-to-internet traffic flows through hub firewall

---

## 🎯 Exam Focus Points — Domain 2

1. **NSG default rules** — know the priority numbers and what they do.
2. **Azure Firewall rule evaluation order** — DNAT → Network → Application.
3. **Firewall Standard vs. Premium** — IDPS and TLS inspection are Premium-only.
4. **Private Endpoint vs. Service Endpoint** — Private Endpoint gives a private IP and works from on-prem.
5. **DDoS Standard (Network Protection) vs. Basic** — what features require the paid plan.
6. **WAF modes** — Detection (log only) vs. Prevention (block + log).
7. **Azure Bastion** — eliminates need for public IPs on VMs; requires `AzureBastionSubnet`.
8. **VPN IKEv2** — always prefer over IKEv1; use AES-256 cipher suites.
9. **Hub-and-spoke** — centralize security controls in a hub; spokes should not have direct internet routes.
