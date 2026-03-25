# Domain 2: Secure Networking (15–20%)

> This domain covers Azure network security services including NSGs, Azure Firewall, DDoS Protection, VPN Gateways, Private Endpoints, and more. Expect 6–12 questions.

---

## Table of Contents

1. [Network Security Groups (NSGs)](#1-network-security-groups-nsgs)
2. [Azure Firewall](#2-azure-firewall)
3. [Azure DDoS Protection](#3-azure-ddos-protection)
4. [Azure Bastion](#4-azure-bastion)
5. [Azure VPN Gateway and ExpressRoute](#5-azure-vpn-gateway-and-expressroute)
6. [Private Link and Private Endpoints](#6-private-link-and-private-endpoints)
7. [Service Endpoints](#7-service-endpoints)
8. [Azure Web Application Firewall (WAF)](#8-azure-web-application-firewall-waf)
9. [Azure Front Door and CDN Security](#9-azure-front-door-and-cdn-security)
10. [Network Monitoring and Diagnostics](#10-network-monitoring-and-diagnostics)
11. [Key Exam Topics Checklist](#11-key-exam-topics-checklist)

---

## 1. Network Security Groups (NSGs)

### Overview
NSGs filter network traffic to and from Azure resources in a virtual network. They contain security rules that allow or deny inbound/outbound traffic.

### NSG Rule Properties

| Property | Description | Values |
|----------|-------------|--------|
| **Priority** | Order in which rules are evaluated | 100–4096 (lower = higher priority) |
| **Source/Destination** | IP address, CIDR, service tag, or ASG | IP, CIDR, service tag, ASG |
| **Source/Dest Port** | Single port, range, or * for all | 80, 443, 1000-2000, * |
| **Protocol** | Network protocol | TCP, UDP, ICMP, Any |
| **Action** | Allow or Deny | Allow, Deny |

### Default NSG Rules (Cannot be deleted)

**Inbound defaults:**

| Priority | Name | Source | Destination | Action |
|----------|------|--------|-------------|--------|
| 65000 | AllowVnetInBound | VirtualNetwork | VirtualNetwork | Allow |
| 65001 | AllowAzureLoadBalancerInBound | AzureLoadBalancer | Any | Allow |
| 65500 | DenyAllInBound | Any | Any | Deny |

**Outbound defaults:**

| Priority | Name | Source | Destination | Action |
|----------|------|--------|-------------|--------|
| 65000 | AllowVnetOutBound | VirtualNetwork | VirtualNetwork | Allow |
| 65001 | AllowInternetOutBound | Any | Internet | Allow |
| 65500 | DenyAllOutBound | Any | Any | Deny |

### NSG Association

- **Subnet level**: Applies to all resources in the subnet
- **NIC level**: Applies to a specific VM's network interface
- Both can be applied simultaneously; traffic must pass BOTH NSGs
- For inbound: **subnet NSG first**, then NIC NSG
- For outbound: **NIC NSG first**, then subnet NSG

### Service Tags

Pre-defined groups of IP address prefixes for Azure services:

| Service Tag | Description |
|-------------|-------------|
| `Internet` | All public IPs outside the VNet |
| `VirtualNetwork` | The VNet address space and peered VNet spaces |
| `AzureLoadBalancer` | Azure infrastructure load balancer |
| `AzureCloud` | All Azure datacenter IPs |
| `Storage` | Azure Storage IPs |
| `Sql` | Azure SQL and Azure Synapse IPs |
| `AppService` | Azure App Service IPs (for inbound to Web Apps) |
| `GatewayManager` | Azure VPN and App Gateway management IPs |

### Application Security Groups (ASGs)

- Group VMs logically (like tags) and apply NSG rules to ASGs instead of IP addresses
- Simplifies management for large deployments
- VMs can be members of multiple ASGs

```bash
# Create an ASG
az network asg create --name WebServers --resource-group MyRG

# Assign a NIC to the ASG
az network nic ip-config update \
  --nic-name MyVMNic \
  --name ipconfig1 \
  --resource-group MyRG \
  --application-security-groups WebServers

# Create NSG rule using ASG
az network nsg rule create \
  --nsg-name MyNSG \
  --resource-group MyRG \
  --name AllowHTTP \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-asgs WebServers \
  --destination-port-ranges 80 443 \
  --protocol Tcp \
  --access Allow
```

### Key Exam Points — NSGs
- NSG rules are **stateful** — if inbound traffic is allowed, response traffic is automatically allowed
- Priority **100** is highest (evaluated first), **4096** is lowest
- A **Deny** rule with lower priority number overrides an **Allow** rule with higher priority number
- NSGs can be applied to **subnets** and/or **NICs** (not VMs directly)
- **Default rules** cannot be deleted but can be overridden with lower priority numbers

---

## 2. Azure Firewall

### Overview
Azure Firewall is a managed, cloud-native network security service that provides stateful packet inspection for Azure VNet resources.

### Azure Firewall vs NSG

| Feature | NSG | Azure Firewall |
|---------|-----|----------------|
| **Layer** | Layer 3/4 | Layer 3/4/7 |
| **FQDN filtering** | No | Yes |
| **Threat intelligence** | No | Yes |
| **Centralized management** | No | Yes (Firewall Policy) |
| **Cost** | Free | ~$900–$1,100/month |
| **Use case** | Basic traffic filtering | Advanced, centralized filtering |

### Azure Firewall Rule Types

| Rule Type | Function |
|-----------|----------|
| **Network rules** | L3/L4 filtering based on IP, port, protocol |
| **Application rules** | L7 filtering based on FQDN, HTTP/HTTPS categories |
| **NAT rules** | DNAT (Destination NAT) to translate inbound public IPs to private IPs |

### Azure Firewall Tiers

| Tier | Features |
|------|----------|
| **Standard** | L3-L7 filtering, FQDN filtering, threat intelligence, IDPS (alert mode) |
| **Premium** | All Standard features + TLS inspection, IDPS (alert & deny mode), URL filtering, Web categories |

### Forced Tunneling

- Routes all internet-bound traffic through the firewall (or on-premises)
- Requires a dedicated management subnet (`AzureFirewallManagementSubnet`)
- Uses a route table to send 0.0.0.0/0 to the firewall's private IP

### Hub-Spoke Topology with Azure Firewall

```
On-premises ──── VPN/ExpressRoute ──── Hub VNet (Azure Firewall)
                                              │
                              ┌───────────────┼───────────────┐
                              │               │               │
                           Spoke1 VNet    Spoke2 VNet    Spoke3 VNet
                           (Dev)          (Test)         (Prod)
```

```bash
# Create Azure Firewall
az network firewall create \
  --name MyFirewall \
  --resource-group MyRG \
  --location eastus \
  --sku-name AZFW_VNet \
  --tier Standard

# Create application rule to allow Azure Windows Update
az network firewall application-rule create \
  --firewall-name MyFirewall \
  --resource-group MyRG \
  --collection-name WindowsUpdate \
  --name AllowWindowsUpdate \
  --priority 100 \
  --action Allow \
  --source-addresses 10.0.0.0/24 \
  --protocols https=443 \
  --fqdn-tags WindowsUpdate
```

### Key Exam Points — Azure Firewall
- Azure Firewall requires a **dedicated subnet** named `AzureFirewallSubnet` (minimum /26)
- Azure Firewall is **stateful** — no need to configure return traffic rules
- Use **Firewall Policy** for centralized rule management across multiple firewalls
- **Threat Intelligence** mode: Alert only or Alert and Deny (deny blocks known malicious IPs/FQDNs)
- Azure Firewall Premium adds **TLS inspection** (breaks and inspects encrypted traffic)

---

## 3. Azure DDoS Protection

### DDoS Protection Tiers

| Tier | Features | Cost |
|------|----------|------|
| **Network Protection** (formerly Basic) | Automatic, always-on DDoS mitigation for platform infrastructure | Free |
| **IP Protection** | Enhanced mitigation for a single public IP address | Per-IP pricing |
| **Network Protection** (plan) | Enhanced mitigation for all public IPs in protected VNets, cost guarantee, DDoS Rapid Response | ~$2,944/month per DDoS plan |

### DDoS Attack Types Defended

| Attack Type | Description |
|------------|-------------|
| **Volumetric** | Floods bandwidth (e.g., UDP floods, ICMP floods) |
| **Protocol** | Exploits L3/L4 protocol weaknesses (e.g., SYN floods) |
| **Resource layer** | Targets application layer (requires WAF for Layer 7) |

### DDoS Telemetry and Alerts

- Real-time metrics: Inbound packets dropped, TCP packets forwarded
- Diagnostic logs: DDoS mitigation flow logs, attack analytics
- Alert on: "Under DDoS attack" metric in Azure Monitor

### Key Exam Points — DDoS Protection
- **Network Protection** (free): Protects Azure platform infrastructure, NOT your specific resources
- **DDoS Network Protection Plan**: Required for SLA guarantees and cost credits during attacks
- DDoS Protection Plan defends **public IP addresses** — private IPs are not protected
- DDoS Protection works with **Azure Firewall** and **WAF** for layered defense
- One DDoS plan can protect public IPs across **multiple subscriptions**

---

## 4. Azure Bastion

### Overview
Azure Bastion provides secure, browser-based RDP/SSH connectivity to VMs without exposing them to the public internet.

### How Azure Bastion Works

```
User (Browser) ──HTTPS 443──► Azure Bastion ──RDP/SSH──► VM (no public IP)
```

- No public IP required on VMs
- No NSG rules needed for RDP (3389) or SSH (22) from the internet
- Session is encrypted end-to-end via TLS

### Azure Bastion SKUs

| SKU | Features |
|-----|----------|
| **Basic** | Browser-based RDP/SSH, supports native client (with flag) |
| **Standard** | All Basic + file transfer, copy/paste, shareable links, IP-based connection, custom ports |
| **Developer** | Lightweight, shared deployment (no dedicated host), Basic features |
| **Premium** | All Standard + session recording, Private-only Bastion |

### Deployment Requirements

- Dedicated subnet: `AzureBastionSubnet` (minimum **/27** for Basic, **/26** for Standard)
- Public IP required on the **Bastion host** itself (Standard SKU public IP)
- The VNet where Bastion is deployed must be reachable from the target VMs (VNet peering supported)

```bash
# Create Bastion subnet
az network vnet subnet create \
  --vnet-name MyVNet \
  --resource-group MyRG \
  --name AzureBastionSubnet \
  --address-prefixes 10.0.1.0/27

# Deploy Azure Bastion
az network bastion create \
  --name MyBastion \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --public-ip-address MyBastionPublicIP \
  --location eastus \
  --sku Standard
```

### Key Exam Points — Azure Bastion
- Bastion subnet must be named exactly **`AzureBastionSubnet`** (case-sensitive)
- Minimum subnet size: **/27** (Basic), **/26** (Standard)
- Bastion eliminates the need for **jump servers** / **jumpboxes**
- VMs connected via Bastion do NOT need public IPs or open RDP/SSH ports
- Bastion supports connections to VMs in **peered VNets** (requires Standard SKU)

---

## 5. Azure VPN Gateway and ExpressRoute

### VPN Gateway

| VPN Type | Use Case |
|----------|----------|
| **Site-to-Site (S2S)** | Connect on-premises network to Azure VNet over IPsec/IKE |
| **Point-to-Site (P2S)** | Connect individual client computers to Azure VNet |
| **VNet-to-VNet** | Connect two Azure VNets via encrypted tunnel |

### VPN Gateway SKUs (Generation 2 — Exam Focus)

| SKU | Max S2S Tunnels | Max P2S Connections | Max Throughput |
|-----|----------------|--------------------|-|
| VpnGw1 | 30 | 250 | 650 Mbps |
| VpnGw2 | 30 | 500 | 1 Gbps |
| VpnGw3 | 30 | 1,000 | 1.25 Gbps |
| VpnGw4 | 100 | 5,000 | 5 Gbps |
| VpnGw5 | 100 | 10,000 | 10 Gbps |

### Point-to-Site (P2S) Authentication Methods

| Method | Details |
|--------|---------|
| **Azure Certificate** | Client certificate issued from a root CA; root CA public key uploaded to Azure |
| **Entra ID (Azure AD)** | Users authenticate with Entra ID credentials; supports Conditional Access |
| **RADIUS** | Uses on-premises RADIUS server for authentication |

### ExpressRoute

| Feature | Details |
|---------|---------|
| **Type** | Private, dedicated circuit (not over internet) |
| **Speeds** | 50 Mbps to 100 Gbps |
| **Redundancy** | Two circuits (active/active) for HA |
| **Peering types** | Azure private peering (VNet), Microsoft peering (M365/Azure public services) |
| **Encryption** | Traffic is NOT encrypted by default — use MACsec or IPsec over ExpressRoute for encryption |

### ExpressRoute Security

- ExpressRoute traffic is **not encrypted** by default (it's a private connection, but not encrypted)
- For encryption over ExpressRoute: Use **IPsec/IKE** tunnel or **MACsec** (Layer 2 encryption)
- **ExpressRoute Global Reach**: Connect on-premises sites through Microsoft backbone

### Key Exam Points — VPN/ExpressRoute
- VPN Gateway requires a **GatewaySubnet** (minimum /27 recommended)
- P2S using **Entra ID authentication** supports Conditional Access (e.g., require compliant device)
- ExpressRoute is **NOT encrypted** by default — add IPsec for encryption over ExpressRoute
- **Active-active** VPN Gateway configuration provides higher availability
- S2S VPN uses **BGP** for dynamic routing or static routes

---

## 6. Private Link and Private Endpoints

### Overview
Private Endpoints bring Azure PaaS services (Storage, SQL, Key Vault, etc.) into your VNet with a private IP address, eliminating public internet exposure.

### Private Endpoint vs Service Endpoint

| Feature | Private Endpoint | Service Endpoint |
|---------|-----------------|-----------------|
| **Network integration** | Private IP in your VNet | Traffic remains on Azure backbone but from VNet |
| **DNS** | Private DNS zone required | Uses public DNS (resolves to same public IP) |
| **Access from internet** | Resource can disable public access | Resource still has public endpoint |
| **On-premises access** | Yes (via VPN/ExpressRoute) | No |
| **Cross-region** | Yes | No |
| **Cost** | Per-endpoint + data processing | Free |

### Private Endpoint Architecture

```
VNet
├── Subnet
│   └── Private Endpoint (private IP: 10.0.1.5)
│                    │
│                    └──► Storage Account (privatelink.blob.core.windows.net)
└── Private DNS Zone (privatelink.blob.core.windows.net)
    └── A record: mystorageaccount → 10.0.1.5
```

```bash
# Create private endpoint for a storage account
az network private-endpoint create \
  --name MyStoragePrivateEndpoint \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --subnet MySubnet \
  --private-connection-resource-id /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account> \
  --group-id blob \
  --connection-name MyStorageConnection

# Create private DNS zone
az network private-dns zone create \
  --resource-group MyRG \
  --name "privatelink.blob.core.windows.net"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group MyRG \
  --zone-name "privatelink.blob.core.windows.net" \
  --name MyDNSLink \
  --virtual-network MyVNet \
  --registration-enabled false
```

### Key Private DNS Zone Names

| Service | Private DNS Zone |
|---------|-----------------|
| Blob Storage | `privatelink.blob.core.windows.net` |
| Azure SQL | `privatelink.database.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| Azure Container Registry | `privatelink.azurecr.io` |
| Azure Kubernetes Service API | `privatelink.<region>.azmk8s.io` |

### Key Exam Points — Private Link/Endpoints
- Private Endpoints require **private DNS zones** for proper name resolution
- Without correct DNS, traffic may go to the public endpoint even with a private endpoint configured
- Private Endpoints support access **from on-premises** via VPN or ExpressRoute
- **Service Endpoints** are simpler but don't fully isolate the service from the internet
- After creating a private endpoint, you should **disable public access** on the resource

---

## 7. Service Endpoints

### Overview
Service Endpoints extend VNet identity to Azure services over the Azure backbone network (not over the internet).

### Service Endpoints vs Private Endpoints (Summary)

- **Service Endpoints**: Free, simpler, but traffic still uses the service's public IP; good for restricting access to specific VNets
- **Private Endpoints**: Paid, complex DNS setup, but provides true network isolation with private IP

### Configuring Service Endpoints

```bash
# Enable service endpoint on a subnet
az network vnet subnet update \
  --vnet-name MyVNet \
  --name MySubnet \
  --resource-group MyRG \
  --service-endpoints Microsoft.Storage Microsoft.Sql

# Restrict storage account to specific VNet (firewall rule)
az storage account network-rule add \
  --account-name MyStorage \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --subnet MySubnet
```

### Key Exam Points — Service Endpoints
- Service Endpoints must be enabled on **the subnet**, not the VNet
- The service (Storage, SQL) must then be configured to **allow traffic from that subnet**
- Service Endpoints do NOT prevent the service from being accessible from the internet (just adds a VNet access rule)
- For complete isolation, use **Private Endpoints** instead

---

## 8. Azure Web Application Firewall (WAF)

### Overview
WAF protects web applications from common web exploits (OWASP top 10) at Layer 7.

### WAF Deployment Options

| Service | WAF Type | Use Case |
|---------|----------|----------|
| **Application Gateway** | Regional WAF (v2) | Single-region apps, internal apps |
| **Azure Front Door** | Global WAF | Global apps, multi-region, CDN-integrated |
| **Azure CDN** | WAF (limited) | CDN-delivered content protection |

### WAF Rule Sets

| Rule Set | Description |
|----------|-------------|
| **OWASP CRS 3.2** | Default; covers OWASP Top 10 (SQLi, XSS, etc.) |
| **OWASP CRS 3.1** | Older version |
| **Microsoft_BotManagerRuleSet** | Bot protection (default rules for known bad bots) |
| **DRS (Default Rule Set)** | Used with Azure Front Door WAF |

### WAF Modes

| Mode | Behavior |
|------|----------|
| **Detection** | Logs matching requests but does not block them (testing/analysis) |
| **Prevention** | Blocks and logs requests matching WAF rules |

### WAF Custom Rules

```json
{
  "name": "BlockCountry",
  "priority": 1,
  "ruleType": "MatchRule",
  "action": "Block",
  "matchConditions": [
    {
      "matchVariables": [{"variableName": "RemoteAddr"}],
      "operator": "GeoMatch",
      "matchValues": ["CN", "RU"]
    }
  ]
}
```

### Key Exam Points — WAF
- WAF operates at **Layer 7** (application layer); NSGs and Azure Firewall are Layer 3/4
- **Detection mode** for testing — never use in production without reviewing logs first
- **Prevention mode** for production — blocks attacks
- Custom rules have **higher priority** than managed rule sets
- WAF on Application Gateway is **regional**; WAF on Front Door is **global**

---

## 9. Azure Front Door and CDN Security

### Azure Front Door Security Features

| Feature | Description |
|---------|-------------|
| **WAF** | Global WAF with managed rules and custom rules |
| **Bot protection** | Blocks known malicious bots using Microsoft Threat Intelligence |
| **Private Link** | Connect Front Door to private origin backends |
| **TLS/SSL offloading** | Terminates TLS at edge nodes |
| **Custom domains** | Enforce HTTPS with managed or custom certificates |
| **Rate limiting** | Throttle requests from IPs exceeding thresholds |

### Key Exam Points — Front Door/CDN
- Azure Front Door is a **global** load balancer and CDN with WAF capabilities
- Use Front Door WAF for **global protection** and Application Gateway WAF for **regional protection**
- Front Door can be used to **accelerate** and **protect** APIs and web apps globally

---

## 10. Network Monitoring and Diagnostics

### Azure Network Watcher

| Feature | Description |
|---------|-------------|
| **IP Flow Verify** | Tests if traffic is allowed/denied by NSG rules for a VM |
| **Next Hop** | Shows the next routing hop for a packet from a VM |
| **Connection Monitor** | Continuous monitoring of network connections |
| **NSG Flow Logs** | Captures information about IP traffic flowing through NSGs |
| **Packet Capture** | Captures packets on a VM's NIC |
| **VPN Troubleshoot** | Diagnoses VPN gateway and connection issues |
| **Topology** | Visual representation of network resources |

### NSG Flow Logs

- Stored in Azure Storage (BLOB) in JSON format
- Version 2 includes bytes/packets per flow
- Can be analyzed with **Traffic Analytics** (requires Log Analytics workspace)

```bash
# Enable NSG flow logs
az network watcher flow-log create \
  --name MyFlowLog \
  --nsg MyNSG \
  --resource-group MyRG \
  --storage-account MyStorageAccount \
  --enabled true \
  --format JSON \
  --log-version 2

# Run IP flow verify
az network watcher test-ip-flow \
  --vm MyVM \
  --direction Inbound \
  --local 10.0.0.4:80 \
  --remote 203.0.113.1:* \
  --protocol TCP \
  --resource-group MyRG
```

### Traffic Analytics

- Built on Log Analytics + NSG Flow Logs
- Provides visual maps of network traffic patterns
- Identifies top talkers, malicious IPs, geo-distribution
- Requires a **Log Analytics workspace**

### Key Exam Points — Network Monitoring
- **IP Flow Verify** tests specific flows against NSG rules — great for troubleshooting blocked traffic
- **NSG Flow Logs** must be enabled manually (not on by default)
- **Traffic Analytics** requires NSG Flow Logs + Log Analytics workspace
- Network Watcher is **region-specific** — enable it in each region you monitor
- **Connection Monitor** replaces the deprecated Network Performance Monitor for Azure resources

---

## 11. Key Exam Topics Checklist

### Must-Know for Domain 2

- [ ] NSG rule evaluation order (priority, inbound vs outbound direction)
- [ ] Default NSG rules (AllowVnetInBound, DenyAllInBound, etc.)
- [ ] Service tags (VirtualNetwork, Internet, AzureLoadBalancer)
- [ ] NSG applied to subnet vs NIC (both applied simultaneously; inbound: subnet first)
- [ ] Azure Firewall vs NSG differences (Layer 7, FQDN, centralized)
- [ ] Azure Firewall subnet name (AzureFirewallSubnet) and minimum size (/26)
- [ ] DDoS Protection tiers (free Network Protection vs paid plan)
- [ ] Azure Bastion subnet name (AzureBastionSubnet) and minimum size (/27)
- [ ] Private Endpoint vs Service Endpoint differences
- [ ] Private DNS zones required for Private Endpoints
- [ ] ExpressRoute is NOT encrypted by default
- [ ] P2S VPN with Entra ID authentication supports Conditional Access
- [ ] WAF modes: Detection (log only) vs Prevention (block)
- [ ] Application Gateway WAF (regional) vs Front Door WAF (global)
- [ ] Network Watcher tools: IP Flow Verify, NSG Flow Logs, Traffic Analytics

---

## 📖 Microsoft Learn Resources

- [Network security groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Firewall documentation](https://learn.microsoft.com/en-us/azure/firewall/overview)
- [Azure DDoS Protection overview](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)
- [Azure Bastion documentation](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
- [Azure Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview)
- [Azure WAF documentation](https://learn.microsoft.com/en-us/azure/web-application-firewall/overview)

---

*← [Domain 1: Identity and Access](01-identity-and-access.md) | [Domain 3: Compute, Storage & Databases →](03-compute-storage-databases.md)*
