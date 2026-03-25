# Domain 2: Secure Networking (20–25%)

> **Exam Weight:** 20–25% — Expect 8–15 questions. Focus heavily on NSGs, Azure Firewall, and Private Endpoints.

---

## Table of Contents

1. [Network Security Groups (NSGs)](#1-network-security-groups-nsgs)
2. [Azure Firewall](#2-azure-firewall)
3. [Azure DDoS Protection](#3-azure-ddos-protection)
4. [Azure Bastion](#4-azure-bastion)
5. [VPN Gateway and ExpressRoute Security](#5-vpn-gateway-and-expressroute-security)
6. [Private Endpoints and Private Link](#6-private-endpoints-and-private-link)
7. [Service Endpoints](#7-service-endpoints)
8. [Web Application Firewall (WAF)](#8-web-application-firewall-waf)
9. [Azure Front Door and CDN Security](#9-azure-front-door-and-cdn-security)
10. [Network Monitoring and Diagnostics](#10-network-monitoring-and-diagnostics)
11. [Key Exam Topics Checklist](#11-key-exam-topics-checklist)

---

## 1. Network Security Groups (NSGs)

### What It Is
NSGs are stateful packet filters that control inbound and outbound network traffic to Azure resources. They contain security rules based on 5-tuple matching.

### NSG Rule Properties

| Property | Description |
|---|---|
| **Priority** | 100–4096; lower number = higher priority |
| **Source/Destination** | IP, IP range, Service Tag, or ASG |
| **Protocol** | TCP, UDP, ICMP, or Any |
| **Port range** | Single port, range, or * for all |
| **Action** | Allow or Deny |

### Default Rules (cannot be deleted)

| Priority | Rule | Direction | Action |
|---|---|---|---|
| 65000 | AllowVnetInBound | Inbound | Allow |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allow |
| 65500 | DenyAllInBound | Inbound | Deny |
| 65000 | AllowVnetOutBound | Outbound | Allow |
| 65001 | AllowInternetOutBound | Outbound | Allow |
| 65500 | DenyAllOutBound | Outbound | Deny |

### Where NSGs Are Applied

| Level | Effect |
|---|---|
| **Subnet** | All traffic entering/leaving the subnet |
| **Network Interface (NIC)** | Traffic to/from the specific VM |

**Traffic evaluation:** When traffic passes through both a subnet NSG and a NIC NSG, both are evaluated. Inbound: subnet NSG first, then NIC NSG. Outbound: NIC NSG first, then subnet NSG.

### Service Tags
Pre-defined groups of IP addresses managed by Microsoft:

| Tag | Represents |
|---|---|
| `Internet` | Public IP address space |
| `VirtualNetwork` | All addresses in the VNet and connected VNets |
| `AzureLoadBalancer` | Azure infrastructure load balancer IPs |
| `Storage` | Azure Storage service IP ranges |
| `Sql` | Azure SQL Database and Azure Synapse IP ranges |
| `AzureCloud` | All Azure datacenter IP ranges |

### Application Security Groups (ASGs)
ASGs allow you to group VMs by application role and write NSG rules using ASG names instead of IP addresses.

```
Allow: WebServers → AppServers on port 8080
Allow: AppServers → DbServers on port 1433
```

> **Exam tip:** NSGs are stateful — if you allow inbound TCP 443, the return traffic is automatically allowed.

---

## 2. Azure Firewall

### What It Is
Azure Firewall is a managed, cloud-native, stateful network security service that protects Azure Virtual Network resources. It has built-in high availability and unrestricted cloud scalability.

### Azure Firewall vs. NSG

| Feature | NSG | Azure Firewall |
|---|---|---|
| **Layer** | L3/L4 (network/transport) | L3–L7 (network to application) |
| **FQDN filtering** | No | Yes |
| **Threat intelligence** | No | Yes |
| **Centralized management** | No | Yes (Azure Firewall Manager) |
| **Cost** | Free | Paid (per deployment + data processed) |
| **Use case** | Subnet/NIC-level filtering | Central hub firewall |

### Azure Firewall Rule Types

| Rule Type | Description | Example |
|---|---|---|
| **DNAT rules** | Translate inbound public IP to internal IP | Port-forward RDP to a VM |
| **Network rules** | L3/L4 filtering by IP, port, protocol | Allow VM to reach DNS server |
| **Application rules** | L7 filtering by FQDN | Allow VMs to access `*.microsoft.com` |

### Rule Processing Order
1. DNAT rules (processed first for inbound traffic)
2. Network rules
3. Application rules

**Default behavior:** All traffic is denied unless explicitly allowed.

### Azure Firewall Tiers

| Tier | Features |
|---|---|
| **Standard** | DNAT, network, application rules, threat intelligence |
| **Premium** | + IDPS (Intrusion Detection/Prevention), TLS inspection, URL filtering, Web categories |

### Azure Firewall Manager
Centralized security policy and route management for:
- Multiple Azure Firewalls across regions and subscriptions
- Secured Virtual Hubs (Azure Virtual WAN integration)

> **Exam tip:** Use Azure Firewall Premium for IDPS and TLS inspection. Use Firewall Manager for multi-region deployments.

---

## 3. Azure DDoS Protection

### What It Is
Azure DDoS Protection defends against Distributed Denial-of-Service attacks that attempt to overwhelm Azure resources.

### DDoS Protection Tiers

| Tier | Description | Cost |
|---|---|---|
| **Network Protection** (Basic) | Automatic, always-on monitoring; built into Azure platform | Free |
| **IP Protection** | Enhanced mitigation for individual public IP addresses | Per public IP |
| **Network Protection** (Standard) | Adaptive tuning per-VNet, attack analytics, rapid response team | Per VNet/month |

> Note: As of 2023, Microsoft renamed tiers — check the latest exam study guide terminology.

### DDoS Attack Types Defended

| Type | Description |
|---|---|
| **Volumetric attacks** | Overwhelm bandwidth (UDP floods, amplification attacks) |
| **Protocol attacks** | Exploit protocol weaknesses (SYN floods, Ping of Death) |
| **Resource layer attacks** | Target application vulnerabilities (HTTP floods) |

### DDoS Protection Features (Standard)

- **Adaptive tuning** — Profiles your traffic patterns and adjusts thresholds
- **Attack analytics** — Real-time telemetry during attacks
- **Attack mitigation reports** — Post-attack forensics
- **Cost protection** — Credit for resources scaled up due to attack
- **Rapid Response** — Access to DDoS experts during active attack

> **Exam tip:** DDoS Network Protection (Standard) protects all public IPs in a VNet. It requires a DDoS protection plan resource linked to the VNet.

---

## 4. Azure Bastion

### What It Is
Azure Bastion provides secure, seamless RDP/SSH connectivity to VMs directly in the Azure portal over TLS. VMs do not need public IP addresses.

### How Bastion Works

```
User Browser → HTTPS/TLS → Azure Bastion (in your VNet) → RDP/SSH → VM (no public IP needed)
```

### Azure Bastion Requirements
- Dedicated subnet named **`AzureBastionSubnet`** (minimum /26)
- Public IP address for the Bastion host (Standard SKU)
- Bastion must be in the same VNet as the target VMs (or peered VNet)

### Azure Bastion SKUs

| SKU | Features |
|---|---|
| **Basic** | Browser-based RDP/SSH, no additional features |
| **Standard** | + Native client support, shareable links, IP-based connections, tunneling |

### Benefits of Azure Bastion

| Benefit | Without Bastion | With Bastion |
|---|---|---|
| **Public IP on VMs** | Required for RDP/SSH | Not needed |
| **RDP port exposure** | Port 3389 open to internet | Port 3389 never exposed |
| **Attack surface** | VMs directly reachable | Only Bastion reachable |
| **JIT VM Access** | Separate policy needed | Complementary (JIT + Bastion) |

> **Exam tip:** Bastion requires a subnet named exactly `AzureBastionSubnet` with a minimum /26 prefix.

---

## 5. VPN Gateway and ExpressRoute Security

### Azure VPN Gateway

| Feature | Details |
|---|---|
| **Purpose** | Encrypted site-to-site, point-to-site, or VNet-to-VNet connectivity |
| **Protocol** | IPsec/IKE (site-to-site), SSTP/OpenVPN/IKEv2 (point-to-site) |
| **Encryption** | AES-256, IKEv2 |
| **SKUs** | Basic, VpnGw1–5 (higher = more throughput and connections) |

### VPN Gateway Types

| Type | Description |
|---|---|
| **Site-to-Site (S2S)** | Connect on-premises network to Azure VNet via IPsec tunnel |
| **Point-to-Site (P2S)** | Individual client devices connect to Azure VNet |
| **VNet-to-VNet** | Connect two Azure VNets (alternative to peering) |

### ExpressRoute Security

| Aspect | Details |
|---|---|
| **Connection** | Private, dedicated connection through a connectivity provider |
| **Traffic** | Does NOT traverse the public internet |
| **Encryption** | Not encrypted by default (provider's network); add MACsec for L2 encryption |
| **ExpressRoute + VPN** | Can use VPN gateway over ExpressRoute for encryption |

> **Exam tip:** ExpressRoute provides private connectivity but is NOT encrypted by default. Use MACsec or IPsec over ExpressRoute for encryption.

---

## 6. Private Endpoints and Private Link

### Azure Private Link
Azure Private Link allows you to access Azure PaaS services (Storage, SQL, Key Vault, etc.) over a private endpoint in your VNet, eliminating public internet exposure.

### Private Endpoint

| Aspect | Details |
|---|---|
| **What it is** | A NIC with a private IP from your VNet subnet |
| **Connected to** | An Azure PaaS service or your own Private Link Service |
| **DNS requirement** | Private DNS Zone must resolve the service FQDN to the private IP |
| **NSG support** | NSGs can be applied to private endpoint subnets |

### How Private Endpoints Work

```
VM (10.0.1.4) → Private Endpoint (10.0.2.5) → Azure Storage Account
                                                 (traffic never leaves Microsoft network)
```

### Private DNS Zones for Common Services

| Service | Private DNS Zone |
|---|---|
| Azure Blob Storage | `privatelink.blob.core.windows.net` |
| Azure SQL Database | `privatelink.database.windows.net` |
| Azure Key Vault | `privatelink.vaultcore.azure.net` |
| Azure Container Registry | `privatelink.azurecr.io` |

### Service Endpoints vs. Private Endpoints

| Feature | Service Endpoints | Private Endpoints |
|---|---|---|
| **Traffic** | Stays in Azure backbone but uses public IP of service | Uses private IP from your VNet |
| **Source IP** | VNet source IP | NIC private IP |
| **DNS change** | No | Yes — must update DNS |
| **Cost** | Free | Per hour + data processing |
| **Network policy (NSG)** | NSG applies to source subnet | NSG applies to endpoint subnet |

> **Exam tip:** Private Endpoints are preferred for security; Service Endpoints are simpler but traffic reaches the service's public IP.

---

## 7. Service Endpoints

### What They Are
Service Endpoints extend your VNet's private address space to Azure services, routing traffic over the Azure backbone network.

### Supported Services
- Azure Storage
- Azure SQL Database
- Azure Key Vault
- Azure Container Registry
- Azure Service Bus
- Azure Event Hubs
- Azure Cosmos DB
- Azure App Service

### Configuring Service Endpoints

1. Enable on a VNet subnet (specify which service)
2. Configure service firewall to allow only from that VNet subnet
3. Traffic from that subnet to the service uses private routing

```
Subnet → Service Endpoint → Storage Account Firewall allows this VNet subnet → Access granted
```

> **Exam tip:** Service Endpoints are configured on subnets, not on individual VMs.

---

## 8. Web Application Firewall (WAF)

### What It Is
WAF provides centralized protection for web applications from common web exploits and vulnerabilities.

### WAF Deployment Options

| Service | SKU Required | Use Case |
|---|---|---|
| **Application Gateway** | WAF v2 | Regional WAF for web apps in a region |
| **Azure Front Door** | Premium | Global WAF, CDN + WAF combination |
| **Azure CDN** | Azure CDN from Microsoft | WAF at CDN edge |

### WAF Rule Sets
WAF uses the **OWASP Core Rule Set (CRS)** to protect against:

| Category | Examples |
|---|---|
| **Injection** | SQL injection, OS command injection |
| **XSS** | Cross-site scripting |
| **LFI/RFI** | Local/Remote file inclusion |
| **RCE** | Remote code execution |
| **Protocol violations** | Malformed HTTP requests |

**Available CRS versions:** CRS 3.2 (recommended), CRS 3.1, CRS 3.0

### WAF Modes

| Mode | Behavior |
|---|---|
| **Detection** | Logs alerts but does not block traffic (use for testing) |
| **Prevention** | Blocks malicious requests (use in production) |

### WAF Exclusions and Custom Rules
- **Exclusions** — Skip specific WAF rules for specific requests (e.g., a field that legitimately contains SQL-like syntax)
- **Custom rules** — Create rules based on specific conditions (IP address, geographic location, request size)

> **Exam tip:** Start WAF in Detection mode to tune rules before switching to Prevention mode.

---

## 9. Azure Front Door and CDN Security

### Azure Front Door (Premium) Security Features

| Feature | Description |
|---|---|
| **WAF** | Global WAF protection at the edge |
| **Bot protection** | Managed bot protection rule set |
| **Custom domains + HTTPS** | Enforce HTTPS with managed certificates |
| **Private Link integration** | Connect origins over Private Link |
| **DDoS protection** | Absorbs L7 DDoS at edge locations |

### Rate Limiting
Configure rate limit rules in WAF to throttle excessive requests from a single IP.

---

## 10. Network Monitoring and Diagnostics

### Azure Network Watcher

| Feature | Description |
|---|---|
| **IP flow verify** | Test if a packet from a VM is allowed/denied by NSG |
| **NSG flow logs** | Log all IP traffic traversing an NSG to a storage account |
| **Connection Monitor** | Monitor end-to-end connectivity between resources |
| **Packet capture** | Capture packets to/from a VM NIC |
| **Next hop** | Determine routing path from a VM to a destination |
| **Topology** | Visual map of network resources |

### NSG Flow Logs
- Version 2 recommended (includes byte/packet counts)
- Stored in a storage account
- Analyzed with **Traffic Analytics** (requires Log Analytics workspace)

### Traffic Analytics
- Processes NSG flow logs to provide insights on:
  - Most chatty VMs
  - Traffic distribution across regions
  - Open ports detected
  - Malicious flows blocked

> **Exam tip:** NSG flow logs must be enabled per NSG. Traffic Analytics visualizes and analyzes the aggregated flow data.

---

## 11. Key Exam Topics Checklist

Use this checklist to confirm your readiness for Domain 2:

- [ ] Create and configure NSG inbound and outbound rules
- [ ] Apply NSGs to subnets and NICs
- [ ] Use Service Tags and ASGs in NSG rules
- [ ] Deploy and configure Azure Firewall (Standard and Premium)
- [ ] Configure Azure Firewall DNAT, network, and application rules
- [ ] Enable Azure DDoS Network Protection on a VNet
- [ ] Deploy Azure Bastion in the correct subnet
- [ ] Configure site-to-site and point-to-site VPN
- [ ] Understand ExpressRoute security considerations
- [ ] Create Private Endpoints for PaaS services
- [ ] Configure private DNS zones for Private Endpoints
- [ ] Enable Service Endpoints on subnets
- [ ] Deploy WAF on Application Gateway or Azure Front Door
- [ ] Configure WAF in Detection vs. Prevention mode
- [ ] Enable NSG flow logs with Network Watcher
- [ ] Use IP flow verify to test NSG rules

---

*Previous: [Domain 1 — Manage Identity and Access ←](01-identity-and-access.md) | Next: [Domain 3 — Secure Compute, Storage, and Databases →](03-compute-storage-db.md)*
