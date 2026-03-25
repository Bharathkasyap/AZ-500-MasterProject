# Domain 2: Secure Networking (20–25%)

← [Back to main README](../../README.md)

This domain covers Azure network security services including **NSGs, Azure Firewall, DDoS Protection, VPN Gateway, ExpressRoute security, Private Link, and Web Application Firewall**. It accounts for **20–25%** of the AZ-500 exam.

---

## Table of Contents

1. [Network Security Groups (NSG)](#1-network-security-groups-nsg)
2. [Application Security Groups (ASG)](#2-application-security-groups-asg)
3. [Azure Firewall](#3-azure-firewall)
4. [Azure Firewall Premium](#4-azure-firewall-premium)
5. [Azure Firewall Manager](#5-azure-firewall-manager)
6. [Web Application Firewall (WAF)](#6-web-application-firewall-waf)
7. [Azure DDoS Protection](#7-azure-ddos-protection)
8. [Virtual Network Service Endpoints](#8-virtual-network-service-endpoints)
9. [Azure Private Link and Private Endpoints](#9-azure-private-link-and-private-endpoints)
10. [Azure VPN Gateway](#10-azure-vpn-gateway)
11. [Azure ExpressRoute Security](#11-azure-expressroute-security)
12. [Azure Bastion](#12-azure-bastion)
13. [Network Watcher](#13-network-watcher)
14. [Key Exam Tips for Domain 2](#key-exam-tips-for-domain-2)

---

## 1. Network Security Groups (NSG)

### What NSGs Do
NSGs filter inbound and outbound network traffic using **security rules** at the **subnet** and/or **network interface (NIC)** level.

### NSG Rule Properties

| Property | Description |
|---|---|
| **Priority** | 100–4096; lower number = higher priority |
| **Source/Destination** | IP address, IP range, service tag, or ASG |
| **Protocol** | TCP, UDP, ICMP, ESP, AH, or Any |
| **Port range** | Single port, range (e.g., 80-443), or wildcard (*) |
| **Direction** | Inbound or Outbound |
| **Action** | Allow or Deny |

### Default NSG Rules (cannot be deleted)

**Inbound defaults:**
| Priority | Name | Source | Destination | Action |
|---|---|---|---|---|
| 65000 | AllowVnetInBound | VirtualNetwork | VirtualNetwork | Allow |
| 65001 | AllowAzureLoadBalancerInBound | AzureLoadBalancer | Any | Allow |
| 65500 | DenyAllInBound | Any | Any | **Deny** |

**Outbound defaults:**
| Priority | Name | Source | Destination | Action |
|---|---|---|---|---|
| 65000 | AllowVnetOutBound | VirtualNetwork | VirtualNetwork | Allow |
| 65001 | AllowInternetOutBound | Any | Internet | Allow |
| 65500 | DenyAllOutBound | Any | Any | **Deny** |

### NSG Processing Order

1. Azure evaluates rules from **lowest priority number to highest**
2. The **first matching rule** is applied; evaluation stops
3. If no rule matches, the default deny rule applies

### NSG Association

An NSG can be associated to:
- **Subnet**: Rules apply to all NICs in the subnet
- **NIC**: Rules apply only to that specific NIC

When both subnet NSG and NIC NSG exist:
- **Inbound**: Subnet NSG evaluated first, then NIC NSG
- **Outbound**: NIC NSG evaluated first, then subnet NSG
- **Both must allow** the traffic for it to pass

### Service Tags

Pre-defined groups of IP ranges managed by Microsoft:

| Tag | Represents |
|---|---|
| `Internet` | All public internet IP ranges |
| `VirtualNetwork` | VNet address space + peered VNets + on-premises (via VPN/ExpressRoute) |
| `AzureLoadBalancer` | Azure load balancer probe source |
| `Storage` | Azure Storage service IP ranges |
| `Sql` | Azure SQL Database IP ranges |
| `AzureCloud` | All Azure datacenter IP ranges |

> **Exam Tip**: Service tags are **automatically updated** by Microsoft. Use them instead of hardcoding IP ranges.

---

## 2. Application Security Groups (ASG)

### What ASGs Do
ASGs allow you to group VMs by **workload function** (e.g., WebServers, AppServers, DBServers) and use those groups in NSG rules instead of individual IP addresses.

### How It Works

```
1. Create ASGs: "WebServerASG", "AppServerASG", "DbServerASG"
2. Associate VM NICs with the appropriate ASG
3. Write NSG rules using ASG names as source/destination

Example NSG rule:
  Source: WebServerASG
  Destination: AppServerASG
  Port: 8080
  Action: Allow
```

### Benefits

- Rules automatically apply to new VMs added to an ASG
- No IP address management required
- Rules scale with infrastructure without modification

> **Exam Tip**: ASGs are used *within* a VNet only. They cannot be used across VNets.

---

## 3. Azure Firewall

### What Azure Firewall Is
A **managed, stateful, cloud-native firewall** service with built-in high availability and unrestricted cloud scalability.

### Rule Types

| Rule Type | Layer | Example Use Case |
|---|---|---|
| **DNAT rules** | L3/L4 | Translate inbound public IP:port to private IP:port |
| **Network rules** | L3/L4 | Allow/deny by source IP, destination IP, port, protocol |
| **Application rules** | L7 | Filter HTTP/HTTPS by FQDN (e.g., allow *.microsoft.com) |

### Rule Processing Order

```
1. DNAT rules (inbound only)
2. Network rules
3. Application rules
```

If a DNAT rule matches, the traffic is translated then re-evaluated against network rules.

### Threat Intelligence

- Built-in threat intelligence feed blocks traffic to/from known malicious IPs and FQDNs
- Modes: **Alert only** or **Alert and deny**

### Azure Firewall SKUs

| SKU | Features |
|---|---|
| **Standard** | L3/L4 filtering, FQDN filtering, threat intelligence |
| **Premium** | Standard + TLS inspection, IDPS, URL filtering, web categories |
| **Basic** | Limited features; for SMB/dev environments |

### Hub-and-Spoke Topology with Azure Firewall

```
Hub VNet (contains Azure Firewall)
  ├── Spoke VNet 1 (workload)
  ├── Spoke VNet 2 (workload)
  └── On-premises (via VPN/ExpressRoute)

All traffic routes through the hub firewall via UDRs (User-Defined Routes)
```

---

## 4. Azure Firewall Premium

### Additional Features Over Standard

| Feature | Description |
|---|---|
| **TLS Inspection** | Decrypt and inspect HTTPS traffic (requires certificate authority config) |
| **IDPS** (Intrusion Detection and Prevention) | Signature-based detection of attacks; can alert or deny |
| **URL Filtering** | More granular than FQDN filtering; filter by full URL path |
| **Web Categories** | Block categories of websites (gambling, malware, social media) |

### TLS Inspection Requirements

- Azure Key Vault to store the CA certificate
- Managed identity assigned to Azure Firewall for Key Vault access
- Certificate deployed to clients as trusted CA

---

## 5. Azure Firewall Manager

### What It Does
Centralized **security policy management** for Azure Firewall across multiple firewalls and regions.

### Key Concepts

| Concept | Description |
|---|---|
| **Firewall Policy** | Collection of rules (DNAT, network, application) applied to one or more firewalls |
| **Parent/child policies** | Inheritance model; child policies inherit base rules from parent |
| **Secured Virtual Hub** | Azure Virtual WAN hub with Azure Firewall deployed |

---

## 6. Web Application Firewall (WAF)

### What WAF Protects Against
OWASP Top 10 and common web attacks:
- SQL injection
- Cross-site scripting (XSS)
- Remote file inclusion
- HTTP protocol violations
- Bot protection

### WAF Deployment Options

| Platform | Use Case |
|---|---|
| **Application Gateway WAF** | Protect web apps in one region; L7 load balancing + WAF |
| **Azure Front Door WAF** | Global multi-region protection; CDN + WAF |
| **Azure CDN WAF** | Edge protection for CDN-delivered content |

### WAF Modes

| Mode | Behavior |
|---|---|
| **Detection mode** | Logs threats but does not block |
| **Prevention mode** | Actively blocks detected attacks |

> **Exam Tip**: WAF is deployed in **Detection mode by default**. Always switch to **Prevention mode** in production.

### WAF Rule Sets

| Rule Set | Description |
|---|---|
| **OWASP CRS 3.2** | Core Rule Set; industry standard; recommended |
| **OWASP CRS 3.1** | Previous version |
| **Microsoft Default Rule Set (DRS)** | Used on Azure Front Door |
| **Bot Manager** | Bot protection rules (add-on) |

### Custom WAF Rules

Define your own rules with:
- **Match conditions**: IP address, geo-location, HTTP variables (headers, URI, body)
- **Actions**: Allow, Block, Log, Redirect
- **Priority**: 1–100; lower = higher priority; evaluated before managed rules

---

## 7. Azure DDoS Protection

### DDoS Attack Types

| Type | Description |
|---|---|
| **Volumetric** | Flood the network with massive traffic (Gbps/Tbps) |
| **Protocol** | Exploit L3/L4 protocol weaknesses (SYN floods, ping of death) |
| **Application layer** | Target L7; HTTP floods, slow-rate attacks |

### DDoS Protection Tiers

| Tier | Cost | Features |
|---|---|---|
| **DDoS Network Protection** | ~$2,944/month per protected VNet | Adaptive tuning, attack analytics, rapid response team, cost protection guarantee |
| **DDoS IP Protection** | Per public IP pricing | Basic mitigation; no adaptive tuning or SLA guarantee |
| **Infrastructure Protection** | Free | Baseline protection applied to all Azure services automatically |

> **Exam Tip**: "DDoS Network Protection" is the former "DDoS Standard" plan. It includes access to **Microsoft's DDoS rapid response team** and **SLA guarantee for application scaling costs incurred during an attack**.

### Metrics and Alerts

Key DDoS metrics to monitor (in Azure Monitor):
- `Under DDoS attack or not` — Boolean; set alert on this
- `Inbound packets dropped DDoS`
- `Inbound bytes DDoS`

### Attack Analytics

DDoS Network Protection provides:
- Attack telemetry during and after attacks
- Post-attack mitigation reports
- Integration with Microsoft Sentinel

---

## 8. Virtual Network Service Endpoints

### What Service Endpoints Do
Extend your VNet identity to Azure services, routing traffic over the **Azure backbone network** instead of the public internet.

### How Service Endpoints Work

1. Enable service endpoint on a subnet (e.g., `Microsoft.Storage`)
2. Configure the Azure service to allow traffic only from that subnet
3. Traffic between subnet and service stays on the Azure backbone

### Supported Services

`Microsoft.Storage` | `Microsoft.Sql` | `Microsoft.KeyVault` | `Microsoft.ServiceBus` | `Microsoft.EventHub` | `Microsoft.CosmosDb` | `Microsoft.Web` | `Microsoft.ContainerRegistry`

### Limitations

- Traffic still uses **public IP** of the service (but routed privately)
- Service endpoint policies can restrict which specific storage accounts are accessible
- Does **not** block access from other Azure services or the public internet (must combine with service firewall rules)

> **Exam Tip**: Service endpoints are **free** but offer limited isolation. **Private Endpoints** provide stronger isolation by assigning a private IP to the service.

---

## 9. Azure Private Link and Private Endpoints

### Private Endpoint vs Service Endpoint

| Feature | Service Endpoint | Private Endpoint |
|---|---|---|
| **How it works** | Routes via Azure backbone; service still has public IP | Assigns **private IP** from your VNet to the service |
| **Source IP to service** | Private VNet IP | Private VNet IP |
| **Service IP** | Still public | Private IP (in your VNet) |
| **Blocks public access** | No (must configure separately) | Yes (can disable public endpoint) |
| **DNS requirement** | None | Yes — private DNS zone required |
| **Cost** | Free | Per-hour + data processing fees |

### Private Endpoint Architecture

```
Your VNet (10.0.0.0/16)
  ├── Subnet (10.0.1.0/24)
  │     └── Private Endpoint: 10.0.1.5  ──→  Azure Storage Account
  └── Private DNS Zone: privatelink.blob.core.windows.net
        └── DNS record: mystorageaccount → 10.0.1.5
```

### DNS Configuration

Private endpoints require DNS to resolve to the private IP:

| Service | Private DNS Zone Name |
|---|---|
| Azure Storage (blob) | `privatelink.blob.core.windows.net` |
| Azure SQL Database | `privatelink.database.windows.net` |
| Azure Key Vault | `privatelink.vaultcore.azure.net` |
| Azure Container Registry | `privatelink.azurecr.io` |

> **Exam Tip**: Without proper DNS configuration, the private endpoint won't work — clients will still resolve the public IP.

### Azure Private Link Service

Allows you to expose **your own service** (behind a Standard Load Balancer) to other customers via Private Link — enabling private connectivity without VNet peering or exposing public IPs.

---

## 10. Azure VPN Gateway

### VPN Gateway Types

| Type | Use Case |
|---|---|
| **Site-to-Site (S2S)** | On-premises to Azure VNet over IPsec/IKE |
| **Point-to-Site (P2S)** | Individual clients to Azure VNet |
| **VNet-to-VNet** | Connect two Azure VNets (different regions) |

### VPN Authentication Methods (P2S)

| Method | Description |
|---|---|
| **Azure Certificate** | Client certificate generated and distributed |
| **Azure AD (OpenVPN)** | Azure AD credentials + Conditional Access supported |
| **RADIUS** | Authenticate against on-premises RADIUS server |

### VPN SKUs and Features

| SKU | Max Throughput | Notes |
|---|---|---|
| Basic | 100 Mbps | No BGP, no active-active |
| VpnGw1–5 | 650 Mbps – 10 Gbps | Supports BGP, active-active |

### IKE/IPsec Security

- **IKEv2** recommended (IKEv1 available but less secure)
- **Custom IPsec/IKE policy**: Configure specific cipher suites instead of defaults
- Disable weak algorithms (DES, 3DES, MD5)

---

## 11. Azure ExpressRoute Security

### ExpressRoute Overview

Private, dedicated connection from on-premises to Azure — does **not traverse the public internet**.

### ExpressRoute Security Considerations

| Concern | Mitigation |
|---|---|
| **Data in transit** | Enable **MACsec** for L2 encryption on ExpressRoute Direct |
| **Route filtering** | Configure BGP route filters to limit advertised prefixes |
| **Network segmentation** | Use ExpressRoute with private peering only; avoid Microsoft peering if not needed |
| **NVA inspection** | Route ExpressRoute traffic through Azure Firewall or NVA for inspection |

### ExpressRoute + VPN as Backup

- Configure S2S VPN as a backup path for ExpressRoute failover
- Use BGP to automatically failover between connections

---

## 12. Azure Bastion

### What Azure Bastion Is
A **fully managed PaaS service** that provides secure, seamless RDP/SSH to VMs directly in the Azure portal — **without exposing VMs to the public internet**.

### Benefits

- No public IP required on target VMs
- No need to open port 3389 (RDP) or 22 (SSH) in NSGs
- Session over **TLS 443** from browser to Azure Bastion
- No VPN client required

### Azure Bastion SKUs

| SKU | Features |
|---|---|
| **Basic** | RDP/SSH in browser; native client support (RDP/SSH via local clients) |
| **Standard** | Basic + IP-based connect, shareable links, file transfer, video streaming, session scaling |

### Deployment

- Deploy Azure Bastion in a **dedicated subnet** named `AzureBastionSubnet` (minimum /26)
- Assign a **Standard SKU public IP** to Azure Bastion (not the VMs)

> **Exam Tip**: Azure Bastion eliminates the need for jump servers (bastion hosts deployed as VMs). It provides audit logs of all sessions via Azure Monitor.

---

## 13. Network Watcher

### What Network Watcher Is
A regional monitoring service for network diagnostics and traffic analysis.

### Key Features

| Feature | Description |
|---|---|
| **IP Flow Verify** | Check if traffic is allowed/denied by NSG rules for a specific VM |
| **NSG Flow Logs** | Log all traffic allowed/denied by NSGs to a Storage Account |
| **Connection Monitor** | Continuously test connectivity between resources |
| **Next Hop** | Identify routing for traffic from a VM (which route table entry applies) |
| **Packet Capture** | Capture packets on a VM NIC for analysis |
| **VPN Troubleshoot** | Diagnose VPN gateway/connection issues |

### NSG Flow Logs

- Version 1: Records source/dest IP, port, protocol, allow/deny
- Version 2: Adds byte and packet counts
- Can be analyzed with **Traffic Analytics** (requires Log Analytics workspace)

> **Exam Tip**: **Traffic Analytics** processes NSG flow logs to provide visual dashboards, top talkers, threat detection, and geolocation data.

---

## Key Exam Tips for Domain 2

1. **NSG rule evaluation**: Lower priority number wins. Both subnet NSG AND NIC NSG must allow traffic.
2. **Service endpoints vs Private endpoints**: Service endpoints are free but weaker; Private endpoints assign a private IP and are stronger.
3. **Azure Firewall rule order**: DNAT → Network → Application rules (top to bottom within each collection).
4. **WAF Default mode**: Detection (not Prevention). Exam will often ask which mode blocks traffic — it's Prevention.
5. **DDoS tiers**: Free infrastructure protection is automatic; DDoS Network Protection is paid and adds adaptive tuning + SLA.
6. **Azure Bastion subnet name**: Must be exactly `AzureBastionSubnet` — cannot be renamed.
7. **Private endpoint DNS**: Without a private DNS zone pointing to the private IP, clients resolve to the public IP instead.
8. **ASGs**: Simplify NSG rules; automatically apply to new VMs in the group; only work within a single VNet.
9. **ExpressRoute MACsec**: The only way to encrypt L2 traffic on ExpressRoute Direct connections.
10. **Network Watcher IP Flow Verify**: Great for troubleshooting "why is this VM being blocked" — tells you which NSG rule is responsible.
