# Domain 2: Secure Networking (20–25%)

← [Back to README](../README.md) | [← Domain 1](./01-identity-and-access.md)

---

## Table of Contents

1. [Network Security Groups (NSGs)](#1-network-security-groups-nsgs)
2. [Azure Firewall](#2-azure-firewall)
3. [Azure DDoS Protection](#3-azure-ddos-protection)
4. [Azure Application Gateway & WAF](#4-azure-application-gateway--waf)
5. [Azure Front Door & CDN WAF](#5-azure-front-door--cdn-waf)
6. [VPN Gateway & ExpressRoute Security](#6-vpn-gateway--expressroute-security)
7. [Private Link & Private Endpoints](#7-private-link--private-endpoints)
8. [Service Endpoints](#8-service-endpoints)
9. [Azure Bastion](#9-azure-bastion)
10. [Network Watcher & Monitoring](#10-network-watcher--monitoring)
11. [Key Exam Facts & Practice Questions](#11-key-exam-facts--practice-questions)

---

## 1. Network Security Groups (NSGs)

An **NSG** is a stateful packet filter that allows or denies inbound/outbound network traffic based on 5-tuple rules: source IP, source port, destination IP, destination port, protocol.

### NSG Rules

Each rule has:
- **Priority**: 100–4096 (lower number = higher priority; processed first)
- **Source / Destination**: IP address, CIDR range, service tag, or ASG
- **Port ranges**: Single port, range (80-443), or `*` for all
- **Protocol**: TCP, UDP, ICMP, `*`
- **Action**: Allow or Deny

### Default Rules (cannot be deleted, only overridden)

| Priority | Name | Direction | Action | Description |
|----------|------|-----------|--------|-------------|
| 65000 | AllowVnetInBound | Inbound | Allow | All VNet-to-VNet traffic allowed |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allow | Azure LB health probes |
| 65500 | DenyAllInBound | Inbound | Deny | Deny all remaining inbound |
| 65000 | AllowVnetOutBound | Outbound | Allow | VNet-to-VNet allowed |
| 65001 | AllowInternetOutBound | Outbound | Allow | Outbound internet allowed |
| 65500 | DenyAllOutBound | Outbound | Deny | Deny all remaining outbound |

### Association

- **Subnet-level NSG**: Applied to all resources in the subnet.
- **NIC-level NSG**: Applied to a specific VM network interface.
- Traffic passes through **both** — subnet NSG first (inbound), NIC NSG second (inbound). For outbound, NIC NSG first, then subnet NSG.

> **Exam Tip:** If both subnet and NIC NSGs are applied, traffic must be **allowed by both** to pass. Either can block it.

### Service Tags

Service tags represent a group of IP address prefixes for Azure services. Use instead of manually managing IP ranges.

Common service tags:
- `Internet` — public internet
- `VirtualNetwork` — current VNet and all peered VNets
- `AzureLoadBalancer` — Azure LB infrastructure IPs
- `Storage` — Azure Storage endpoints
- `Sql` — Azure SQL endpoints
- `AzureMonitor` — Log Analytics, App Insights
- `AzureCloud` — All Azure datacenter IPs

### Application Security Groups (ASGs)

ASGs let you group VMs logically and apply NSG rules to those groups rather than IP addresses.

```bash
# Create an ASG
az network asg create -g MyRG -n WebServers

# Create an NSG rule using ASG as source
az network nsg rule create \
  --nsg-name MyNSG \
  --resource-group MyRG \
  --name AllowWebToApp \
  --priority 100 \
  --source-asgs WebServers \
  --destination-asgs AppServers \
  --destination-port-ranges 8080 \
  --protocol TCP \
  --access Allow
```

### NSG Flow Logs

- Logs all allowed/denied traffic through an NSG.
- Stored in Azure Storage (required) and optionally streamed to Log Analytics.
- Version 2 includes bytes/packets transferred per flow.
- Used by **Network Watcher Traffic Analytics** for visualization.

---

## 2. Azure Firewall

Azure Firewall is a **managed, stateful, cloud-native firewall** with built-in high availability and unrestricted cloud scalability.

### SKUs

| Feature | Standard | Premium |
|---------|----------|---------|
| FQDN filtering | ✅ | ✅ |
| Network/Application rules | ✅ | ✅ |
| Threat intelligence | Alert mode | Alert + Deny mode |
| IDPS (Intrusion Detection) | ❌ | ✅ |
| TLS inspection | ❌ | ✅ |
| URL filtering | ❌ | ✅ |
| Web categories | ❌ | ✅ |

### Rule Collections

Azure Firewall processes rules in this order:
1. **DNAT rules** (Destination Network Address Translation — inbound)
2. **Network rules** (IP/port-based filtering)
3. **Application rules** (FQDN/URL-based filtering for outbound HTTP/HTTPS)

> Rules within a collection are processed by **priority** (lower = first). If no rule matches, traffic is **denied** by default.

### Azure Firewall Policy

- Recommended management approach (vs classic rules)
- **Hierarchical**: Parent policy + child policies (inherited by children)
- Supports **rule collection groups** with priorities
- Can use with **Firewall Manager** for centralized management across multiple firewalls

### Forced Tunneling

Route all internet-bound traffic through an on-premises firewall by using a 0.0.0.0/0 route pointing to your VPN/ExpressRoute gateway instead of the internet.

```bash
# Create a route table that sends all internet traffic to Azure Firewall
az network route-table create -g MyRG -n FWRouteTable
az network route-table route create \
  -g MyRG --route-table-name FWRouteTable \
  -n ToFirewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address <firewall-private-ip>
```

### FQDN Tags

Pre-defined FQDN groups for common services:
- `WindowsUpdate` — Windows Update URLs
- `WindowsDiagnostics`
- `MicrosoftActiveProtectionService`

---

## 3. Azure DDoS Protection

### Plans

| Plan | Description |
|------|-------------|
| **Infrastructure (Basic)** | Free; automatically enabled for all Azure resources; protects Azure platform |
| **Network (Standard/DDoS Network Protection)** | Per-VNet; adaptive tuning; attack analytics; cost protection; requires explicit enablement |
| **IP Protection** | Per-public-IP; cost-effective for protecting individual IPs |

### DDoS Network Protection Features

- **Adaptive real-time tuning**: Policies tuned per public IP based on traffic patterns.
- **Attack analytics**: Real-time metrics and reports during attacks.
- **Attack alerting**: Azure Monitor alerts when mitigation is triggered.
- **Cost protection**: Credit for resources scaled out during an attack.
- **DDoS Rapid Response (DRR)**: Access to Microsoft DDoS specialists during active attacks.

> **Exam Tip:** Basic protection is **free** but has no SLA, no advanced analytics, and no cost protection. Standard/Network is a paid plan that adds these capabilities.

### Attack Types Protected

- **Volumetric attacks**: Flood the network with traffic (UDP/ICMP floods)
- **Protocol attacks**: Exhaust server resources (SYN floods, Smurf attacks)
- **Resource/Application layer attacks**: Target web application weaknesses (requires WAF, not DDoS)

> **Exam Tip:** DDoS Protection does **NOT** protect against Layer 7 (application layer) attacks. Use **WAF** for L7 protection.

---

## 4. Azure Application Gateway & WAF

**Application Gateway** is a Layer 7 (HTTP/HTTPS) load balancer with optional **Web Application Firewall (WAF)**.

### Key Components

| Component | Description |
|-----------|-------------|
| **Frontend IP** | Public or private IP receiving traffic |
| **Listener** | Port + protocol + SSL cert; multi-site listeners support host-based routing |
| **Routing rule** | Associates listener → backend pool |
| **Backend pool** | VMs, VMSS, App Service, IP addresses, FQDNs |
| **HTTP Settings** | Protocol, port, cookie-based affinity, connection draining, custom probes |
| **Health probes** | Active monitoring of backend health |

### WAF (Web Application Firewall)

- Based on **OWASP CRS (Core Rule Set)** 3.0, 3.1, 3.2
- **Detection mode**: Logs threats without blocking (use for testing/tuning)
- **Prevention mode**: Blocks malicious requests and logs
- **WAF Policy**: Reusable set of rules; can be applied to multiple Application Gateways or per-listener/per-URI

**WAF protects against:**
- SQL injection
- Cross-site scripting (XSS)
- Command injection
- HTTP protocol violations
- Bots (via bot protection ruleset)

```bash
# Create Application Gateway WAF policy
az network application-gateway waf-policy create \
  --name MyWAFPolicy \
  --resource-group MyRG \
  --location eastus

# Set WAF mode to Prevention
az network application-gateway waf-policy policy-setting update \
  --policy-name MyWAFPolicy \
  --resource-group MyRG \
  --mode Prevention \
  --state Enabled
```

### SSL/TLS Termination

- **SSL termination at gateway**: Decrypt at gateway; backend communication may be HTTP (less overhead)
- **End-to-end SSL**: Re-encrypt traffic to backend (use for compliance or sensitive data)
- **SSL policy**: Enforce minimum TLS version (1.2 recommended); disable weak cipher suites

---

## 5. Azure Front Door & CDN WAF

**Azure Front Door** is a global, scalable entry point for web apps — combining CDN, global load balancing, and WAF.

- Works at the **network edge** (Points of Presence globally)
- WAF policy applied at Front Door protects globally before traffic reaches your origin
- Supports **custom rules** (match conditions + actions) and **managed rule sets** (Microsoft DRS)

### Front Door WAF vs Application Gateway WAF

| Feature | Application Gateway WAF | Front Door WAF |
|---------|------------------------|----------------|
| Scope | Regional | Global |
| Layer | L7 | L7 |
| OWASP CRS | ✅ | ✅ |
| Bot protection | ✅ | ✅ |
| Geo-filtering | ❌ | ✅ |
| Rate limiting | ❌ (via custom rules) | ✅ |
| Best for | Single-region apps | Multi-region/global apps |

---

## 6. VPN Gateway & ExpressRoute Security

### VPN Gateway

Provides encrypted connectivity between Azure VNets and on-premises or other VNets.

**Connection types:**
- **Site-to-Site (S2S)**: On-premises network ↔ Azure VNet via IPsec/IKE tunnel
- **Point-to-Site (P2S)**: Individual clients ↔ Azure VNet
- **VNet-to-VNet**: Azure VNet ↔ Azure VNet (across regions/subscriptions)

**P2S Authentication options:**
- Azure certificate authentication (client certificate)
- RADIUS server authentication
- Entra ID (Azure AD) authentication (OpenVPN protocol only)

**SKUs:** Basic (deprecated), VpnGw1–VpnGw5, VpnGw1AZ–VpnGw5AZ (Zone-redundant)

### IKE/IPsec Policies

Custom IKE/IPsec policies can enforce specific encryption/integrity algorithms:
- **IKEv2** (preferred over IKEv1)
- Encryption: AES256, AES128, 3DES
- Integrity: SHA256, SHA1, MD5

### ExpressRoute Security

- Private, dedicated connection to Azure (no internet; traverses MPLS provider network)
- Does **NOT** encrypt traffic by default — it's a private circuit, not encrypted
- **MACsec**: Layer 2 encryption between on-premises edge and Microsoft edge (ExpressRoute Direct only)
- **IPsec over ExpressRoute**: Layer 3 encryption using VPN Gateway over the ExpressRoute private peering

> **Exam Tip:** ExpressRoute is **not encrypted by default**. For encryption, use MACsec (Layer 2) or IPsec over ExpressRoute (Layer 3).

---

## 7. Private Link & Private Endpoints

### Private Endpoint

A **Private Endpoint** is a network interface in your VNet with a private IP from your VNet address space, connected to an Azure PaaS service.

Benefits:
- Azure PaaS traffic stays on **Microsoft backbone** (no internet traversal)
- Service is accessible via private IP only (you can disable public network access)
- Protects against data exfiltration

```bash
# Create a private endpoint for Azure SQL Database
az network private-endpoint create \
  --name SqlPrivateEndpoint \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --subnet MySubnet \
  --private-connection-resource-id "<sql-server-resource-id>" \
  --group-id sqlServer \
  --connection-name SqlConnection
```

### Private DNS

Private Endpoints require DNS resolution to map the service FQDN to the private IP:
- `server.database.windows.net` → `10.0.0.5` (private IP in your VNet)
- Use **Azure Private DNS Zones** (e.g., `privatelink.database.windows.net`)
- Link the Private DNS Zone to your VNet

### Azure Private Link Service

Allows you to **expose your own service** privately to other VNets/tenants via Private Link (your service acts as the provider).

---

## 8. Service Endpoints

**Service Endpoints** extend your VNet private address space to Azure services, keeping traffic on the Azure backbone.

| Feature | Service Endpoint | Private Endpoint |
|---------|------------------|-----------------|
| Where traffic goes | Azure backbone | Azure backbone |
| Source IP seen by service | VNet private IP | VNet private IP |
| Service accessible via | Public FQDN (resolved to private) | Private IP in VNet |
| Data exfiltration protection | Partial (you restrict to specific service) | Strong (disable public access entirely) |
| DNS change needed | No | Yes (Private DNS Zone) |
| Cost | Free | Per-endpoint cost |

> **Exam Tip:** Private Endpoints are generally **preferred** over Service Endpoints for stronger isolation and data exfiltration protection. Service Endpoints are simpler and free.

### Configuring Service Endpoints

```bash
# Enable service endpoint for Azure Storage on a subnet
az network vnet subnet update \
  --vnet-name MyVNet \
  --name MySubnet \
  --resource-group MyRG \
  --service-endpoints Microsoft.Storage

# Restrict Storage Account to this VNet/subnet only
az storage account network-rule add \
  --account-name mystorageacct \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --subnet MySubnet
```

---

## 9. Azure Bastion

**Azure Bastion** provides secure, browser-based RDP and SSH access to Azure VMs **without exposing them to the internet** (no public IPs on VMs required).

### How It Works

1. Bastion is deployed to a dedicated subnet (`AzureBastionSubnet`, minimum /26)
2. User connects via Azure Portal (browser) or native client
3. Bastion connects to VM's private IP via RDP (3389) or SSH (22)
4. VM requires **no public IP** and **no inbound NSG rules** for RDP/SSH from internet

### SKUs

| Feature | Basic | Standard |
|---------|-------|----------|
| Browser-based RDP/SSH | ✅ | ✅ |
| Native client support | ❌ | ✅ |
| VNet peering | ❌ | ✅ |
| Custom ports | ❌ | ✅ |
| Shareable link | ❌ | ✅ |

> **Exam Tip:** You must create a subnet named exactly **`AzureBastionSubnet`** — Azure Bastion won't work with any other subnet name.

### Just-In-Time (JIT) VM Access (Comparison)

| Feature | Azure Bastion | JIT VM Access (Defender for Cloud) |
|---------|--------------|-------------------------------------|
| Purpose | No public IP needed; browser-based | Reduce attack surface by limiting time RDP/SSH ports are open |
| Approach | Private connectivity via Bastion | Opens NSG rule only when explicitly requested, auto-closes after timeout |
| Requires public IP on VM | No | Optional (can use public or private IP) |

---

## 10. Network Watcher & Monitoring

**Azure Network Watcher** provides tools to monitor, diagnose, and gain insights into Azure networking.

### Key Tools

| Tool | Purpose |
|------|---------|
| **IP Flow Verify** | Check if a packet is allowed/denied by NSG rules for a specific source/destination |
| **NSG Diagnostics** | Show all NSG rules that apply to a given flow |
| **Next Hop** | Determine the next hop for a packet (useful for routing issues) |
| **Connection Monitor** | Continuous monitoring of connectivity between sources and destinations |
| **VPN Diagnostics** | Troubleshoot VPN gateway and connection issues |
| **Packet Capture** | Capture packets to/from a VM's NIC |
| **NSG Flow Logs** | Log all traffic through NSGs (Version 1 and 2) |
| **Traffic Analytics** | Visual representation of flow logs via Log Analytics |
| **Topology** | Visual map of VNet resources |

```bash
# Check if NSG blocks a specific flow (IP Flow Verify)
az network watcher test-ip-flow \
  --vm MyVM \
  --resource-group MyRG \
  --direction Inbound \
  --protocol TCP \
  --local 10.0.0.4:80 \
  --remote 203.0.113.1:52000
```

---

## 11. Key Exam Facts & Practice Questions

### Must-Know Facts

1. **NSG rules**: Lower priority number = higher priority (processed first); last rule is deny-all (65500)
2. **NSG with subnet + NIC**: Traffic must be allowed by **both** — either can block
3. **Azure Firewall vs NSG**: Firewall is a fully managed, centralized firewall; NSG is a basic packet filter. Firewall processes DNAT → Network → Application rules in order
4. **DDoS Basic is free**; DDoS Network Protection is paid but required for analytics and cost protection
5. **DDoS does NOT protect against Layer 7 attacks** — use WAF for that
6. **WAF Detection mode** logs; **Prevention mode** blocks
7. **ExpressRoute is NOT encrypted** by default; use MACsec or IPsec over ExpressRoute for encryption
8. **Private Endpoints** are preferred over **Service Endpoints** for stronger isolation; they require Private DNS Zone configuration
9. **Azure Bastion** requires subnet named exactly `AzureBastionSubnet`
10. **IP Flow Verify** tells you if NSG rules allow or block a specific traffic flow

### Practice Questions

**Q1.** An NSG has two rules: Priority 100 (Allow TCP 443 from Internet) and Priority 200 (Deny TCP 443 from Internet). What happens when an HTTPS request arrives from the internet?

- A) The request is denied because deny rules always take precedence
- B) The request is allowed because priority 100 is processed first
- C) Both rules are evaluated and the result depends on which subnet the NSG is on
- D) The request is blocked until an admin resolves the conflict

<details><summary>Answer</summary>
**B** — NSG rules are processed in priority order (lowest number first). Priority 100 (Allow) is processed before Priority 200 (Deny), so the request is allowed.
</details>

---

**Q2.** Your organization needs to protect Azure VMs from RDP brute-force attacks without deploying Azure Bastion. You also want RDP access to be available only during business hours by specific administrators. Which Defender for Cloud feature should you enable?

- A) Adaptive network hardening
- B) Just-in-time VM access
- C) Network security group recommendations
- D) Azure Firewall integration

<details><summary>Answer</summary>
**B** — Just-in-time VM access locks down inbound NSG rules for management ports (RDP/SSH) and only opens them for specific IPs and durations when explicitly requested.
</details>

---

**Q3.** A web application running on Azure App Service must be protected from SQL injection and XSS attacks. Traffic comes from users across the globe. Which Azure service should you deploy?

- A) Azure Firewall Premium with IDPS enabled
- B) Azure DDoS Protection Standard
- C) Azure Front Door with WAF policy in Prevention mode
- D) NSG with custom inbound rules

<details><summary>Answer</summary>
**C** — Azure Front Door with WAF in Prevention mode provides global L7 protection including OWASP rule sets that protect against SQL injection and XSS. Azure Firewall (A) operates at L3/L4 and L7 network level but is not the right tool for web app protection. DDoS (B) protects against volumetric attacks, not app attacks. NSG (D) operates at L4.
</details>

---

**Q4.** Your company is connecting to Azure via ExpressRoute. The security team requires that all traffic between on-premises and Azure be encrypted. ExpressRoute Direct is NOT available. What is the most appropriate solution?

- A) Enable MACsec on the ExpressRoute circuit
- B) Configure IPsec VPN over the ExpressRoute private peering using a VPN Gateway
- C) ExpressRoute automatically encrypts traffic; no action needed
- D) Use Azure Firewall with TLS inspection on the ExpressRoute connection

<details><summary>Answer</summary>
**B** — IPsec over ExpressRoute using a VPN Gateway is the solution when ExpressRoute Direct (required for MACsec) is not available. Option A (MACsec) requires ExpressRoute Direct. Option C is incorrect — ExpressRoute does NOT encrypt by default.
</details>

---

**Q5.** You need to ensure an Azure Storage account can only be accessed from a specific virtual network subnet and not from the public internet. You want the simplest and most cost-effective solution that maintains the ability to access the storage using its existing FQDN. Which approach should you use?

- A) Create a Private Endpoint and configure a Private DNS Zone
- B) Enable the Storage service endpoint on the subnet and restrict the Storage Account to allow access from that subnet only
- C) Deploy an Azure Firewall and route all storage traffic through it
- D) Add a Network Security Group to the Storage Account

<details><summary>Answer</summary>
**B** — Service Endpoints are free, maintain the public FQDN (no DNS changes needed), and can restrict access to specific subnets. Private Endpoints (A) are stronger but cost more and require DNS configuration. NSGs (D) cannot be applied directly to storage accounts.
</details>

---

← [Back to README](../README.md) | [← Domain 1](./01-identity-and-access.md) | [Next: Domain 3 →](./03-compute-storage-databases.md)
