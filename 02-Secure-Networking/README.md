# Domain 2: Secure Networking

**Exam Weight: 20–25%**

← [Back to Main Guide](../README.md)

---

## Overview

This domain covers how to design and implement network security controls in Azure. You need to understand how to segment networks, control traffic flows, protect against DDoS attacks, and secure connectivity between on-premises and Azure environments.

---

## Table of Contents

1. [Virtual Networks (VNets) and Subnets](#1-virtual-networks-vnets-and-subnets)
2. [Network Security Groups (NSGs)](#2-network-security-groups-nsgs)
3. [Application Security Groups (ASGs)](#3-application-security-groups-asgs)
4. [Azure Firewall](#4-azure-firewall)
5. [Azure Web Application Firewall (WAF)](#5-azure-web-application-firewall-waf)
6. [DDoS Protection](#6-ddos-protection)
7. [Private Endpoints and Private Link](#7-private-endpoints-and-private-link)
8. [Service Endpoints](#8-service-endpoints)
9. [VNet Peering](#9-vnet-peering)
10. [VPN Gateway and ExpressRoute](#10-vpn-gateway-and-expressroute)
11. [Azure Bastion](#11-azure-bastion)
12. [Network Watcher](#12-network-watcher)
13. [Key Exam Tips](#key-exam-tips)

---

## 1. Virtual Networks (VNets) and Subnets

### What It Is
A VNet is an isolated network in Azure that lets you securely communicate between Azure resources, the internet, and on-premises networks.

### Key Concepts
| Concept | Description |
|---|---|
| **Address space** | CIDR range assigned to the VNet (e.g., 10.0.0.0/16) |
| **Subnet** | Subdivision of the VNet address space |
| **System routes** | Automatically created routing rules |
| **Route tables (UDR)** | Custom routes to override system routes |
| **Network Interface (NIC)** | Connects a VM to a subnet |

### Subnet Planning
- Reserve first 5 IP addresses in each subnet (Azure uses these)
- Certain services require **dedicated subnets**: Azure Firewall, VPN Gateway, Bastion, App Gateway, Azure Kubernetes Service
- Use subnet delegation for PaaS services (e.g., `Microsoft.Web/serverFarms`)

### User-Defined Routes (UDR)
- Override Azure's default routing behavior
- Common use: Force tunnel all internet traffic through Azure Firewall (`0.0.0.0/0` → Virtual Appliance)
- Associated with subnets, not individual NICs

---

## 2. Network Security Groups (NSGs)

### What It Is
NSGs are stateful packet filtering firewalls that control inbound and outbound traffic to and from Azure resources.

### NSG Components
| Component | Description |
|---|---|
| **Security rule** | Allow/Deny rule with priority, source, destination, port, protocol |
| **Priority** | Lower number = higher priority (100–4096) |
| **Direction** | Inbound or Outbound |
| **Default rules** | Pre-existing rules that cannot be deleted |

### Default NSG Rules
**Inbound:**
| Priority | Name | Source | Destination | Port | Action |
|---|---|---|---|---|---|
| 65000 | AllowVnetInBound | VirtualNetwork | VirtualNetwork | Any | Allow |
| 65001 | AllowAzureLoadBalancerInBound | AzureLoadBalancer | Any | Any | Allow |
| 65500 | DenyAllInBound | Any | Any | Any | **Deny** |

**Outbound:**
| Priority | Name | Source | Destination | Port | Action |
|---|---|---|---|---|---|
| 65000 | AllowVnetOutBound | VirtualNetwork | VirtualNetwork | Any | Allow |
| 65001 | AllowInternetOutBound | Any | Internet | Any | Allow |
| 65500 | DenyAllOutBound | Any | Any | Any | **Deny** |

### NSG Association
- Can be associated with **subnets** and/or **NICs**
- When associated with both: both NSGs are evaluated; most restrictive wins
- Associate at **subnet level** for consistent control; NIC-level for per-VM rules

### Service Tags
Pre-defined groups of IP address prefixes for Azure services:
| Tag | Description |
|---|---|
| `Internet` | Public internet addresses |
| `VirtualNetwork` | VNet address space + peered VNets |
| `AzureLoadBalancer` | Azure load balancer IPs |
| `AzureCloud` | All Azure datacenter IPs |
| `Storage` | Azure Storage service IPs |
| `Sql` | Azure SQL service IPs |
| `AppService` | Azure App Service IPs |

### NSG Flow Logs
- Log all traffic flows (allowed and denied) through an NSG
- Stored in Azure Storage Account
- Analyzed using **Traffic Analytics** in Network Watcher

### Exam Tips
- NSGs are **stateful** — if inbound is allowed, the response is automatically allowed outbound
- Lower priority number = **evaluated first**
- An explicit **Deny** rule in an NSG overrides any lower-priority Allow rules

---

## 3. Application Security Groups (ASGs)

### What It Is
ASGs allow you to group VMs logically and use these groups in NSG rules, reducing the need to manage IP addresses.

### How It Works
1. Create an ASG (e.g., `WebServers`, `DatabaseServers`)
2. Associate VMs' NICs with the ASG
3. Use the ASG as source/destination in NSG rules

```
Rule: Allow WebServers → DatabaseServers on port 1433
```

### Exam Tips
- ASGs simplify rule management when VMs are added/removed
- A NIC can belong to multiple ASGs
- ASGs must be in the same region and VNet as the NIC

---

## 4. Azure Firewall

### What It Is
Azure Firewall is a managed, cloud-native network security service that provides stateful packet inspection, FQDN filtering, threat intelligence, and more.

### Azure Firewall SKUs
| Feature | Standard | Premium |
|---|---|---|
| FQDN filtering | ✅ | ✅ |
| Threat intelligence | ✅ | ✅ |
| TLS inspection | ❌ | ✅ |
| IDPS (Intrusion Detection/Prevention) | ❌ | ✅ |
| URL filtering | ❌ | ✅ |
| Web categories | ❌ | ✅ |

### Rule Types
| Rule Type | Description |
|---|---|
| **NAT rules** | DNAT — translate inbound internet traffic to private IPs |
| **Network rules** | Layer 4 — allow/deny based on IP, port, protocol |
| **Application rules** | Layer 7 — allow/deny based on FQDN/URL |

### Rule Processing Order
1. **NAT rules** first
2. **Network rules** next
3. **Application rules** last
- If a match is found, processing stops
- Application rules implicitly allow DNS queries to rule-specified FQDNs

### Azure Firewall Policy
- Centrally manage rules across multiple firewalls
- **Parent/child policy hierarchy**: Child inherits parent rules + adds its own
- Use with **Azure Firewall Manager** for multi-hub deployments

### Forced Tunneling
- Route all internet-bound traffic through Azure Firewall using UDR
- Set `0.0.0.0/0` → Azure Firewall private IP in subnet route table
- Requires **management subnet** for Azure Firewall's own traffic

### Exam Tips
- Azure Firewall is **always highly available** and **scales automatically**
- Requires a **dedicated subnet** named `AzureFirewallSubnet` (min /26)
- **IDPS** and **TLS inspection** require Premium SKU
- Azure Firewall vs NSG: Firewall is centralized, managed, Layer 7; NSG is per-VNet/subnet, Layer 4

---

## 5. Azure Web Application Firewall (WAF)

### What It Is
WAF provides centralized protection for web applications from common web exploits (OWASP Top 10) and vulnerabilities.

### WAF Deployment Options
| Option | Placement |
|---|---|
| **Azure Application Gateway** | Regional WAF (L7 load balancer + WAF) |
| **Azure Front Door** | Global WAF (CDN + global load balancer + WAF) |
| **Azure CDN** | WAF for content delivery scenarios |

### WAF Modes
| Mode | Behavior |
|---|---|
| **Detection** | Logs threats but does NOT block — use for initial rollout |
| **Prevention** | Actively blocks malicious requests |

### WAF Rule Sets
| Rule Set | Description |
|---|---|
| **OWASP CRS 3.2** | Core Rule Set — covers OWASP Top 10 |
| **Microsoft Default Rule Set (DRS)** | Azure-managed rules for Front Door |
| **Bot Manager** | Protection against bots |

### Custom Rules
- Apply before managed rule sets
- Based on: match conditions (IP, headers, URI, query string, body), rate limiting

### Exam Tips
- Start in **Detection mode**, review logs, then switch to **Prevention mode**
- WAF on Application Gateway is **regional**; WAF on Front Door is **global**
- Know the difference between **Exclusion rules** (exclude specific request attributes from evaluation) and **custom rules**

---

## 6. DDoS Protection

### Plans
| Plan | Description |
|---|---|
| **DDoS Network Protection** | Per-VNet protection; advanced telemetry, alerts, mitigation reports; dedicated support |
| **DDoS IP Protection** | Per-public-IP protection; lower cost option for protecting specific IPs |
| **Basic (default)** | Included free; protects Azure infrastructure, not customer resources specifically |

### Protection Features (Network Protection)
- Always-on monitoring
- Adaptive real-time tuning
- Attack analytics, metrics, and alerts
- Rapid Response support team
- Cost protection (credits for resource scaling during an attack)

### Exam Tips
- **Basic protection** is always enabled on Azure infrastructure
- **Network Protection** must be explicitly enabled per VNet
- DDoS Protection does NOT protect application-layer (L7) attacks — use WAF for that
- Combined with WAF for comprehensive protection (L3/L4 + L7)

---

## 7. Private Endpoints and Private Link

### Private Link
Azure Private Link lets you access Azure PaaS services (Storage, SQL, Cosmos DB, etc.) and partner services over a **private endpoint** in your VNet.

### Private Endpoint
- A network interface in your VNet with a private IP address
- Connected to a specific resource instance (e.g., a specific Storage account)
- Traffic to the service never leaves the Microsoft network

### DNS Configuration
- Must configure **Private DNS Zones** to resolve the service's public hostname to the private IP
- Azure creates Private DNS Zone entries automatically if configured

```
storageaccount.blob.core.windows.net → 10.0.1.5 (private IP)
```

### Exam Tips
- Private Endpoint vs Service Endpoint: Private Endpoint gives a **private IP in your VNet**; Service Endpoint keeps traffic on Azure backbone but the resource still has a public IP
- Private Endpoint **overrides** service endpoint for the same resource
- Disable **public access** on the PaaS resource after creating a Private Endpoint
- **Private Link Service**: Lets you expose YOUR service to other tenants via Private Link

---

## 8. Service Endpoints

### What It Is
Service Endpoints extend your VNet's identity to Azure services, routing traffic over the Azure backbone instead of the public internet.

### Key Characteristics
- **No private IP** in your VNet — resource still has public IP
- Traffic stays on Azure backbone but uses the **service's public endpoint**
- Configure on the **subnet level**
- Must also configure the resource's **firewall** to allow the specific subnet

### Service Endpoint Policies
- Filter traffic to specific service instances (e.g., only allow your own Storage account, not all Storage accounts)

### Exam Tips
- Service Endpoints: simpler, free, traffic via public endpoint but over backbone
- Private Endpoints: more secure (private IP, no public exposure), costs more
- For maximum security: use **Private Endpoints** and **disable public access** on PaaS resources

---

## 9. VNet Peering

### What It Is
VNet Peering connects two VNets for direct, low-latency communication over Microsoft's backbone.

### Types
| Type | Description |
|---|---|
| **Local peering** | Same Azure region |
| **Global peering** | Different Azure regions |

### Key Properties
| Property | Description |
|---|---|
| **Non-transitive** | A→B and B→C does NOT mean A→C without peering or gateway |
| **Non-overlapping** | Address spaces must not overlap |
| **Bidirectional setup** | Both sides must configure peering |
| **Allow gateway transit** | Let peered VNet use this VNet's VPN/ER gateway |
| **Use remote gateways** | Use peered VNet's gateway for connectivity |

### Exam Tips
- Peering is **non-transitive** by default — use Hub-Spoke topology with Azure Firewall or route tables for transitivity
- Changing address space after peering requires re-creating the peering
- **Hub-spoke topology**: Recommended architecture for enterprise Azure networking

---

## 10. VPN Gateway and ExpressRoute

### VPN Gateway

| Feature | Details |
|---|---|
| **Type** | Site-to-Site (S2S), Point-to-Site (P2S), VNet-to-VNet |
| **Protocol** | IPsec/IKE |
| **Authentication (P2S)** | Certificate, Azure AD, RADIUS |
| **SKUs** | Basic, VpnGw1–5 (bandwidth/tunnel count varies) |
| **High availability** | Active-active mode, zone-redundant |
| **BGP support** | Dynamic routing via BGP |

### ExpressRoute

| Feature | Details |
|---|---|
| **Type** | Dedicated private connectivity (no internet) |
| **Bandwidth** | 50 Mbps – 100 Gbps |
| **Resiliency** | ExpressRoute Global Reach, zone-redundant gateways |
| **Circuit types** | Provider (co-location), Direct (peered at Microsoft) |
| **Encryption** | ExpressRoute supports MACsec (Layer 2 encryption) |

### VPN vs ExpressRoute
| Feature | VPN Gateway | ExpressRoute |
|---|---|---|
| Connectivity | Over internet (encrypted) | Dedicated private line |
| Latency | Higher (internet) | Lower, more consistent |
| Bandwidth | Up to ~10 Gbps | Up to 100 Gbps |
| SLA | 99.9–99.95% | 99.95% |
| Cost | Lower | Higher |

### Exam Tips
- **ExpressRoute**: Not encrypted by default — use MACsec or IPsec over ExpressRoute for encryption
- **VPN Gateway**: Always encrypted (IPsec)
- Know when to use **S2S VPN** (site-to-site permanent) vs **P2S VPN** (individual remote users)
- **Co-exist**: VPN Gateway + ExpressRoute for failover scenarios

---

## 11. Azure Bastion

### What It Is
Azure Bastion provides secure, browser-based RDP/SSH access to VMs without exposing them to the public internet.

### Key Features
- **No public IP on VMs** — connects via Azure portal browser session
- **No agent required** on VMs
- Protection against port scanning (VM ports not exposed)
- Requires dedicated subnet: **`AzureBastionSubnet`** (minimum /26)

### SKUs
| SKU | Features |
|---|---|
| **Basic** | RDP/SSH via browser |
| **Standard** | IP-based connection, custom ports, tunneling, native client support, shareable links |
| **Premium** | Session recording, private-only deployment |

### Exam Tips
- Bastion **replaces the need for a jump box/bastion host VM**
- Without Bastion: you need public IP + NSG rule or jump box to access VMs securely
- Know that Bastion requires a **dedicated subnet** in the same VNet as the VMs

---

## 12. Network Watcher

### What It Is
Network Watcher provides network monitoring, diagnostics, and visualization tools for Azure networking.

### Tools
| Tool | Description |
|---|---|
| **IP Flow Verify** | Test if traffic is allowed/denied between two endpoints |
| **Next Hop** | Show where traffic is routed to from a VM |
| **Connection Monitor** | Continuous connectivity monitoring between endpoints |
| **NSG Flow Logs** | Log all traffic through an NSG (stored in Storage Account) |
| **Traffic Analytics** | Visualize NSG flow log data in Log Analytics + workbooks |
| **Packet Capture** | Capture VM network traffic for analysis |
| **Connection Troubleshoot** | Check connectivity and show issues |
| **VPN Diagnostics** | Diagnose VPN Gateway and connection issues |

### Exam Tips
- **IP Flow Verify**: First tool to use when troubleshooting NSG-related connectivity
- **NSG Flow Logs + Traffic Analytics**: Best combo for network traffic visibility
- Network Watcher is **region-specific** — enable per region

---

## Key Exam Tips

1. **NSG vs Azure Firewall**: NSG is L4 per-subnet/NIC; Firewall is centralized L7 with FQDN filtering
2. **Private Endpoint vs Service Endpoint**: Private Endpoint = private IP in VNet; Service Endpoint = backbone routing with public IP
3. **DDoS Network Protection** must be explicitly enabled; Basic is always on
4. **Forced tunneling** routes all internet traffic through a central NVA/firewall via UDR
5. **Bastion** = no public IP needed on VMs
6. **WAF modes**: Detection (log only) → Prevention (block) — always start in Detection
7. **VNet peering is non-transitive** — use hub-spoke + firewall for transit routing
8. **ExpressRoute is not encrypted** by default — add IPsec or MACsec if needed

---

← [Domain 1: Identity and Access](../01-Identity-and-Access/README.md) | [Back to Main Guide](../README.md) | [Domain 3: Compute, Storage, and Databases →](../03-Compute-Storage-Databases/README.md)
