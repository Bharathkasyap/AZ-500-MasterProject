# Domain 2 — Secure Networking

> **Weight: 20–25% of the AZ-500 Exam**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Virtual Network Fundamentals](#virtual-network-fundamentals)
- [Network Security Groups (NSGs)](#network-security-groups-nsgs)
- [Application Security Groups (ASGs)](#application-security-groups-asgs)
- [Azure Firewall](#azure-firewall)
- [Azure DDoS Protection](#azure-ddos-protection)
- [Azure Bastion](#azure-bastion)
- [VPN Gateway & ExpressRoute](#vpn-gateway--expressroute)
- [Private Link & Private Endpoints](#private-link--private-endpoints)
- [Service Endpoints](#service-endpoints)
- [Web Application Firewall (WAF)](#web-application-firewall-waf)
- [Azure Front Door & CDN](#azure-front-door--cdn)
- [Network Monitoring](#network-monitoring)
- [Key Exam Points](#key-exam-points)

---

## Overview

Domain 2 covers protecting Azure network infrastructure using defense-in-depth. Apply controls at the perimeter, network, subnet, and resource levels.

**Key Theme:** *Network segmentation + least-privilege network access + continuous monitoring*

---

## Virtual Network Fundamentals

### VNet Structure
```
Virtual Network (10.0.0.0/16)
    ├── Subnet: web-tier       (10.0.1.0/24)
    ├── Subnet: app-tier       (10.0.2.0/24)
    ├── Subnet: data-tier      (10.0.3.0/24)
    ├── Subnet: AzureFirewallSubnet  (10.0.0.0/26) ← Required name
    ├── Subnet: AzureBastionSubnet   (10.0.4.0/26) ← Required name
    └── Subnet: GatewaySubnet  (10.0.5.0/27)       ← Required name
```

### VNet Peering
- Connects two VNets; traffic uses Microsoft backbone (no internet)
- **Local peering**: Same region
- **Global peering**: Across regions
- Non-transitive: A↔B and B↔C does NOT mean A↔C (unless hub/spoke with routing)
- Can connect across subscriptions and tenants

### Service Tags
Pre-defined groups of IP ranges for Azure services:
- `Internet`, `AzureCloud`, `VirtualNetwork`, `AzureLoadBalancer`
- `Storage`, `Sql`, `AzureActiveDirectory`, `AppService`, etc.
- Use in NSG rules instead of hardcoding IP ranges

---

## Network Security Groups (NSGs)

NSGs are Layer-4 stateful firewalls applied at the **subnet** or **NIC** level.

### NSG Rule Properties
| Property | Description |
|----------|-------------|
| **Priority** | 100–4096; lower = higher priority; processed first |
| **Source/Destination** | IP/CIDR, Service Tag, or ASG |
| **Protocol** | TCP, UDP, ICMP, or Any |
| **Port** | Single port, range (80-443), or * |
| **Action** | Allow or Deny |

### Default Rules (Cannot be Deleted)
| Priority | Name | Action | Notes |
|----------|------|--------|-------|
| 65000 | AllowVnetInBound | Allow | All traffic within VNet |
| 65001 | AllowAzureLoadBalancerInBound | Allow | Azure LB health probes |
| 65500 | DenyAllInBound | Deny | Block all other inbound |
| 65000 | AllowVnetOutBound | Allow | All outbound within VNet |
| 65001 | AllowInternetOutBound | Allow | All outbound to internet |
| 65500 | DenyAllOutBound | Deny | Block all other outbound |

### NSG Association
- Applied to subnet OR NIC (or both)
- When applied to both: **NIC rules evaluated first** for inbound; **Subnet rules first** for outbound
- Best practice: Apply at subnet level for consistency

> **Exam tip:** NSG priority `100` wins over `200`. Default rules at `65000` are always evaluated last. You cannot delete default rules, only override them with lower-priority rules.

---

## Application Security Groups (ASGs)

ASGs allow you to group Azure VMs by function and write NSG rules referencing the group instead of IP addresses.

### Example
```
ASG: WebServers     → web-vm-1, web-vm-2
ASG: AppServers     → app-vm-1, app-vm-2
ASG: DatabaseServers → db-vm-1

NSG Rules:
  Allow: Internet → WebServers : 443
  Allow: WebServers → AppServers : 8080
  Allow: AppServers → DatabaseServers : 1433
  Deny: Internet → DatabaseServers
```

Benefits:
- No hardcoded IPs in rules
- VMs can be in multiple ASGs
- Simplified rule management

---

## Azure Firewall

Azure Firewall is a **managed, stateful, cloud-native** network firewall with built-in high availability.

### Tiers
| Feature | Azure Firewall Standard | Azure Firewall Premium |
|---------|------------------------|----------------------|
| FQDN filtering | ✅ | ✅ |
| Network rules | ✅ | ✅ |
| Application rules | ✅ | ✅ |
| Threat Intelligence | ✅ (Alert) | ✅ (Alert + Deny) |
| **IDPS** | ❌ | ✅ |
| **TLS inspection** | ❌ | ✅ |
| **URL Filtering** | ❌ | ✅ |
| **Web categories** | Limited | ✅ |

### Rule Types
| Rule Type | Layer | Examples |
|-----------|-------|---------|
| **DNAT rules** | L3/4 | Inbound port translation (e.g., public IP:443 → internal VM:443) |
| **Network rules** | L3/4 | Allow/Deny by source IP, dest IP/FQDN, port, protocol |
| **Application rules** | L7 | Allow/Deny by FQDN, URL, HTTP(S) — outbound traffic |

### Rule Processing Order
1. DNAT rules (if match → stop processing)
2. Network rules (if match → stop processing)
3. Application rules (if match → stop processing)
4. Default: **Deny** (implicit deny all)

### Azure Firewall Policy
- Centrally manage rules for multiple firewalls
- **Parent policy** + **child policy** inheritance
- Supports **Firewall Manager** for multi-firewall management

### Forced Tunneling
- Route all internet-bound traffic through an on-premises firewall
- Requires dedicated `AzureFirewallManagementSubnet` (/26 minimum)

### Deployment Requirements
- Dedicated subnet named `AzureFirewallSubnet` (minimum /26)
- Public IP address required (standard SKU)
- Deployed in a Virtual Network (VNet)

---

## Azure DDoS Protection

### Plans
| Plan | Description | Cost |
|------|-------------|------|
| **Free (Infrastructure Protection)** | Basic protection for all Azure services | Free |
| **DDoS Network Protection** | Enhanced mitigation, telemetry, rapid response | ~$2,944/month per plan |
| **DDoS IP Protection** | Per-IP protection for individual public IPs | Per protected IP |

### DDoS Network Protection Features
- Automatic attack traffic mitigation
- Real-time attack metrics and diagnostics
- **DDoS Rapid Response** team access during active attack
- Cost protection (credits for scale-out during attack)
- Attack analytics (post-attack reports)
- Adaptive tuning per VNet

### Attack Types Protected
- **Volumetric**: Flood the network (UDP amplification, DNS reflection)
- **Protocol**: Exploit protocol weaknesses (SYN flood, Ping of Death)
- **Application layer (L7)**: HTTP flood — use WAF in combination

> **Exam tip:** DDoS Network Protection protects all resources in the associated VNet. It does NOT protect against application-layer (L7) attacks — use WAF for that.

---

## Azure Bastion

Azure Bastion provides secure **RDP/SSH** access to Azure VMs **without** exposing them to the internet.

### How It Works
```
User Browser (HTML5/WebSocket)
    → HTTPS to Azure Bastion (in AzureBastionSubnet)
        → RDP/SSH to VM (via private IP, within VNet)
```

### Requirements
- Dedicated subnet named `AzureBastionSubnet` (minimum /26)
- Standard public IP address
- Port 443 from internet to Bastion
- Port 3389/22 from Bastion subnet to VM subnets (NSG must allow)

### SKU Comparison
| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| RDP/SSH via browser | ✅ | ✅ | ✅ |
| Native client support | ❌ | ✅ | ✅ |
| Host scaling | ❌ | ✅ | ✅ |
| IP-based connection | ❌ | ✅ | ✅ |
| Shareable links | ❌ | ✅ | ✅ |
| Private-only Bastion | ❌ | ❌ | ✅ |

> **Exam tip:** With Bastion, the VM does **NOT** need a public IP. The VM's NSG should NOT allow RDP (3389) or SSH (22) from the internet.

---

## VPN Gateway & ExpressRoute

### VPN Gateway
- Connects on-premises networks to Azure VNets over **encrypted IPsec/IKE tunnels**
- VPN types: **Route-based** (most common) and Policy-based

| SKU | Throughput | VNet-to-VNet | BGP | Zone-redundant |
|-----|-----------|-------------|-----|---------------|
| Basic | 100 Mbps | ✅ | ❌ | ❌ |
| VpnGw1–5 | 650 Mbps–10 Gbps | ✅ | ✅ | ❌ |
| VpnGw1AZ–5AZ | 650 Mbps–10 Gbps | ✅ | ✅ | ✅ |

### VPN Connection Types
- **Site-to-Site (S2S)**: On-premises VPN device to Azure VPN Gateway
- **Point-to-Site (P2S)**: Individual clients to Azure (SSTP, OpenVPN, IKEv2)
- **VNet-to-VNet**: Two Azure VNets (cross-region, cross-subscription)

### ExpressRoute
- **Private dedicated connection** to Azure (not over the internet)
- Via connectivity provider (AT&T, Verizon, Equinix, etc.)
- Lower latency, higher bandwidth, SLA guarantees
- **ExpressRoute + VPN** = redundant hybrid connectivity

### ExpressRoute Circuit
- **SKUs**: Local, Standard, Premium (for global reach)
- **Peering types**: Azure Private Peering (VNet access), Microsoft Peering (M365/Azure services)
- **ExpressRoute Global Reach**: Connect multiple on-prem sites through Microsoft backbone

---

## Private Link & Private Endpoints

### Private Endpoints
- Creates a **private IP** in your VNet for a PaaS service (Storage, SQL, Key Vault, etc.)
- Traffic from VNet to the service stays **entirely within the Microsoft network**
- Prevents data exfiltration to other tenants

```
VNet (10.0.0.0/16)
    └── Subnet (10.0.1.0/24)
            └── Private Endpoint: myStorageAccount.privatelink.blob.core.windows.net → 10.0.1.5
```

### Private DNS Zones
- Required for DNS resolution to work with private endpoints
- Automatically created by Azure or manually configured
- Zone name examples:
  - `privatelink.blob.core.windows.net` (Azure Blob Storage)
  - `privatelink.vaultcore.azure.net` (Key Vault)
  - `privatelink.database.windows.net` (Azure SQL)

### Azure Private Link Service
- Expose **your own service** behind a Private Link
- Consumers create private endpoints to reach your service
- Use case: ISV services, internal platform teams

> **Exam tip:** Private Endpoints disable public network access to the service (optionally). Service Endpoints do NOT disable public access — they just add a VNet route.

---

## Service Endpoints

- Extends VNet identity to Azure services
- Optimizes routing (traffic goes over Azure backbone, not internet gateway)
- Restricts access to specific VNets in service firewall rules
- Available for: Storage, SQL Database, Key Vault, Service Bus, Event Hub, etc.

### Service Endpoints vs. Private Endpoints
| Feature | Service Endpoint | Private Endpoint |
|---------|-----------------|-----------------|
| Private IP in VNet | ❌ | ✅ |
| On-premises access | ❌ | ✅ (via VPN/ER) |
| DNS changes needed | ❌ | ✅ |
| Data exfiltration protection | Partial | ✅ (resource-level) |
| Cost | Free | Per endpoint/hour |

---

## Web Application Firewall (WAF)

WAF protects web applications from **common Layer-7 attacks**.

### OWASP Core Rule Set (CRS) Attack Categories
- SQL Injection
- Cross-Site Scripting (XSS)
- Local/Remote File Inclusion
- Command Injection
- HTTP Protocol violations
- Bots / scanners

### WAF Deployment Options
| Platform | Mode | Notes |
|----------|------|-------|
| **Application Gateway** | Detection / Prevention | Regional; integrates with backend pools |
| **Azure Front Door** | Detection / Prevention | Global; CDN + WAF |
| **Azure CDN** (Microsoft) | Detection / Prevention | Static content + WAF |

### WAF Modes
- **Detection**: Log attacks; do NOT block
- **Prevention**: Log AND block attacks

### WAF Policy
- Can be associated with an Application Gateway listener or Front Door endpoint
- Custom rules (priority-based; evaluated before managed rules)
- Exclusions: Bypass specific rules for false positives

---

## Azure Front Door & CDN

### Azure Front Door
- Global HTTP load balancer + CDN + WAF at the edge
- Anycast routing to nearest PoP (Point of Presence)
- Features: URL-based routing, SSL offload, session affinity, health probes, caching

### Security Features
- **WAF**: Protect against OWASP attacks at the edge
- **Bot protection**: Managed rule set for known bad bots
- **HTTPS enforcement**: HTTP → HTTPS redirect
- **Private Link origins**: Connect to backend without public IPs (Premium tier)
- **Custom domains + managed certificates**

### Application Gateway vs. Front Door
| Feature | Application Gateway | Azure Front Door |
|---------|-------------------|-----------------|
| Scope | Regional | Global |
| Layer | L7 (HTTP/HTTPS) | L7 (HTTP/HTTPS) |
| WAF | ✅ | ✅ |
| SSL offload | ✅ | ✅ |
| Private backend | ✅ | ✅ (Premium) |
| CDN caching | ❌ | ✅ |
| DDoS protection | Basic | Built-in (standard) |

---

## Network Monitoring

### Network Watcher
Regional service for monitoring and diagnosing network issues.

| Tool | Purpose |
|------|---------|
| **IP Flow Verify** | Test if traffic is allowed/denied by NSG rules |
| **Next Hop** | Find the routing decision for a packet |
| **Connection Monitor** | Continuous end-to-end connectivity monitoring |
| **NSG Flow Logs** | Log all traffic processed by NSGs (to Storage Account) |
| **Traffic Analytics** | Analyze NSG Flow Logs with visualizations |
| **Packet Capture** | Capture packets on a VM NIC |
| **VPN Diagnostics** | Diagnose VPN Gateway connectivity issues |

### NSG Flow Logs
- Log: source/dest IP, port, protocol, direction, action, flow state
- Stored in Azure Storage Account (blob containers)
- Version 2: Adds byte/packet counts per flow
- Retention: 1–365 days

### Traffic Analytics
- Analyzes NSG Flow Logs using Log Analytics Workspace
- Provides geographics of traffic, top talkers, protocol breakdown
- Identify open ports and unauthorized access attempts

---

## Key Exam Points

### Decision Guide: Which Network Security Tool?
| Need | Tool |
|------|------|
| Filter L4 traffic to subnet/NIC | NSG |
| Group VMs for NSG rules | ASG |
| Stateful L3-L7 centralized firewall | Azure Firewall |
| Protect from DDoS volumetric attacks | DDoS Protection |
| Secure RDP/SSH without public IP | Azure Bastion |
| Protect web apps from OWASP attacks | WAF (App Gateway or Front Door) |
| Private connection to PaaS service | Private Endpoint |
| Connect on-prem to Azure securely | VPN Gateway or ExpressRoute |
| Global L7 load balancing | Azure Front Door |
| Regional L7 load balancing | Application Gateway |

### NSG Common Exam Scenarios
- **"Block all internet access to backend VMs"**: NSG on backend subnet, deny inbound from Internet service tag
- **"Allow web servers to talk to app servers only"**: Use ASGs in NSG rules
- **"Identify which NSG rule is blocking traffic"**: IP Flow Verify in Network Watcher
- **"Log all NSG traffic for compliance"**: Enable NSG Flow Logs → Traffic Analytics

---

📖 [Detailed Study Notes →](study-notes.md) | [Practice Questions →](../../practice-questions/domain2-networking.md)
