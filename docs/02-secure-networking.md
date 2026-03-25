# Domain 2: Secure Networking (20–25%)

> **Back to:** [README](../README.md) | **Previous:** [Domain 1 — Identity and Access](01-identity-and-access.md)

---

## Table of Contents

1. [Virtual Network Security Fundamentals](#1-virtual-network-security-fundamentals)
2. [Network Security Groups (NSGs) and Application Security Groups (ASGs)](#2-network-security-groups-nsgs-and-application-security-groups-asgs)
3. [Azure Firewall and Firewall Manager](#3-azure-firewall-and-firewall-manager)
4. [Azure DDoS Protection](#4-azure-ddos-protection)
5. [Azure Bastion and Just-in-Time (JIT) VM Access](#5-azure-bastion-and-just-in-time-jit-vm-access)
6. [Azure Private Link and Private Endpoints](#6-azure-private-link-and-private-endpoints)
7. [Web Application Firewall (WAF)](#7-web-application-firewall-waf)
8. [Network Monitoring and Diagnostics](#8-network-monitoring-and-diagnostics)
9. [Key Exam Tips](#key-exam-tips)

---

## 1. Virtual Network Security Fundamentals

### Azure Virtual Network (VNet)
A VNet is the fundamental building block of private networking in Azure. It provides isolation, segmentation, and communication control.

| Concept | Description |
|---------|-------------|
| **Address space** | One or more CIDR blocks assigned to the VNet |
| **Subnet** | Subdivision of a VNet's address space; where resources are deployed |
| **Region-scoped** | A VNet exists within a single Azure region |
| **Subscription-scoped** | A VNet belongs to one subscription |

### VNet Peering
Connect two VNets so resources in both can communicate.

| Type | Scope |
|------|-------|
| **VNet Peering** | Same region |
| **Global VNet Peering** | Different regions |

**Key properties:**
- Traffic stays on Microsoft backbone — never traverses public internet
- Non-transitive: if A peers with B and B peers with C, A cannot reach C unless A peers with C directly
- Can peer across subscriptions and tenants (requires permissions in both)

### Route Tables (User-Defined Routes)
Override Azure's default system routes to control traffic flow.

| Use Case | Action |
|----------|--------|
| Force traffic through Azure Firewall | Route `0.0.0.0/0` next hop = Azure Firewall private IP |
| Isolate subnets | Create explicit routes per subnet |
| Force-tunnel to on-premises | Route internet traffic back through VPN/ExpressRoute |

**Next hop types:** Virtual appliance, Virtual network gateway, VNet, Internet, None (drop)

### Service Endpoints
Extend VNet identity to Azure service traffic, allowing you to lock down PaaS services to a VNet.

- Configures the service firewall to allow only your VNet subnet
- Traffic remains on the Microsoft backbone
- Does NOT give the service a private IP (still uses public endpoint)
- Supported services: Storage, SQL, Key Vault, Service Bus, Event Hubs, and more

---

## 2. Network Security Groups (NSGs) and Application Security Groups (ASGs)

### Network Security Groups (NSGs)
NSGs filter inbound and outbound network traffic using security rules.

**Can be applied to:**
- Subnet (affects all resources in the subnet)
- Network Interface Card (NIC) (affects only that specific VM)

**Rule properties:**
| Property | Description |
|----------|-------------|
| Priority | 100–4096; lower number = higher priority |
| Source/Destination | IP, CIDR, Service Tag, or ASG |
| Protocol | TCP, UDP, ICMP, Any |
| Port range | Single port, range, or `*` |
| Action | Allow or Deny |

**Default rules (cannot be deleted, but can be overridden with lower priority numbers):**
| Rule Name | Priority | Direction | Effect |
|-----------|----------|-----------|--------|
| AllowVnetInBound | 65000 | Inbound | Allow VNet ↔ VNet |
| AllowAzureLoadBalancerInBound | 65001 | Inbound | Allow LB health probes |
| DenyAllInBound | 65500 | Inbound | **Block everything else** |
| AllowVnetOutBound | 65000 | Outbound | Allow VNet ↔ VNet |
| AllowInternetOutBound | 65001 | Outbound | Allow internet egress |
| DenyAllOutBound | 65500 | Outbound | Block everything else |

**Effective NSG rules:** When NSGs are applied at both subnet and NIC, traffic must pass *both* sets of rules (AND logic).

### Service Tags
Service tags represent groups of IP prefixes managed by Microsoft — use them instead of hard-coding IP ranges.

| Service Tag | Represents |
|-------------|-----------|
| `Internet` | Public IP space outside VNet |
| `VirtualNetwork` | All VNet address spaces + peered VNets |
| `AzureLoadBalancer` | Azure load balancer infrastructure |
| `AzureCloud` | All Azure datacenter IPs |
| `Storage` | Azure Storage service IPs |
| `Sql` | Azure SQL and Synapse IPs |
| `AzureActiveDirectory` | Entra ID / Azure AD service IPs |
| `AppService` | App Service outbound IPs |

### Application Security Groups (ASGs)
ASGs group VMs logically so you can write NSG rules using workload names instead of IP addresses.

```
ASG: WebServers  → NSG rule: Allow Port 80/443 from Internet to WebServers
ASG: AppServers  → NSG rule: Allow Port 8080 from WebServers to AppServers
ASG: DbServers   → NSG rule: Allow Port 1433 from AppServers to DbServers
```

**Benefits:**
- No more hard-coded IPs in security rules
- Automatic membership as VMs are assigned to ASGs
- Simplifies rule management at scale

---

## 3. Azure Firewall and Firewall Manager

### Azure Firewall
A fully managed, cloud-native, stateful network security service with high availability and unlimited cloud scalability.

**SKUs:**
| SKU | Key Features |
|-----|-------------|
| **Standard** | Application/network rules, FQDN filtering, SNAT, DNAT, threat intelligence |
| **Premium** | + TLS inspection, IDPS, URL categorization, web categories |
| **Basic** | Cost-optimized for SMB; basic SNAT/DNAT |

**Rule types:**
| Rule Type | OSI Layer | Use Case |
|-----------|-----------|----------|
| **Network rules** | L3/L4 | IP/port-based traffic control |
| **Application rules** | L7 | FQDN/URL filtering for HTTP(S)/MSSQL |
| **DNAT rules** | L3/L4 | Inbound traffic; translate public IP/port to private IP/port |
| **Threat Intelligence** | L7 | Block/alert on known malicious IPs and domains (Microsoft Threat Intelligence feed) |

**Processing order:** DNAT → Network → Application (first match wins within a rule collection)

**Rule Collections and Rule Collection Groups:**
- Rules are organized in collections (share priority + action)
- Collections are organized in groups (priority order)
- Firewall Policy (recommended) vs. classic rules

### Azure Firewall Premium — IDPS
Intrusion Detection and Prevention System (IDPS):
- Signature-based detection of attacks
- Over 58,000+ signatures
- Modes: Off, Alert, Alert and Deny
- TLS inspection: decrypt, inspect, re-encrypt HTTPS traffic

### Azure Firewall Manager
Centrally manage firewall policies and route tables across multiple Azure Firewall instances and regions.

**Key capabilities:**
- Centralized security policy management
- Associate Azure Firewall with Virtual WAN Hubs or VNets
- Third-party security-as-a-service (SECaaS) integration (Zscaler, Check Point, iboss)

### Force Tunneling with Azure Firewall
Route ALL internet-bound traffic through an on-premises firewall or inspection device:
- Requires a dedicated management subnet (`AzureFirewallManagementSubnet`)
- Requires Azure Firewall with a management public IP

---

## 4. Azure DDoS Protection

### DDoS Attack Types
| Type | Description |
|------|-------------|
| **Volumetric** | Flood the network with traffic (UDP floods, ICMP floods) |
| **Protocol** | Exploit weaknesses in L3/L4 (SYN floods, Smurf attacks) |
| **Resource/Application layer** | Target HTTP/HTTPS application logic (L7) |

### Azure DDoS Protection Tiers
| Tier | Description | Use Case |
|------|-------------|----------|
| **Network Protection** (formerly Standard) | Per-VNet; adaptive tuning, attack analytics, rapid response team | Production workloads; public-facing |
| **IP Protection** | Per-public IP; pay per protected IP | Cost-optimized; specific IP protection |
| **Basic** (built-in) | Always-on; Microsoft infrastructure protection only | Covers Azure platform |

**Network Protection key features:**
- Always-on traffic monitoring and adaptive real-time tuning
- Attack analytics, metrics, and alerting in Azure Monitor
- Azure DDoS Rapid Response (DRR) team access during active attack
- Cost protection (credits for scale-out costs during attack)
- Integration with Defender for Cloud

**DDoS protection scope:** Protects all public IPs on resources in the protected VNet (VMs, Load Balancers, Application Gateway, Firewall, etc.)

### What DDoS Protection Does NOT Protect
- Applications on Private IPs within a VNet
- Against L7 application-layer attacks (use WAF for this)
- DNS zones (use Azure DNS with Traffic Manager redundancy)

---

## 5. Azure Bastion and Just-in-Time (JIT) VM Access

### Azure Bastion
A fully managed PaaS service that provides secure RDP/SSH connectivity to VMs through the Azure portal — no public IP needed on the VM.

**How it works:**
1. Deploy Azure Bastion in a dedicated subnet (`AzureBastionSubnet` — minimum /26)
2. Connect to VMs via browser (HTML5 WebSocket) through the Bastion host
3. RDP/SSH traffic never touches the public internet

**SKUs:**
| SKU | Features |
|-----|---------|
| **Basic** | RDP/SSH, shareable links |
| **Standard** | + Native client support, IP-based connections, custom ports, tunnel to VMs |
| **Premium** | + Session recording, Private-only Bastion |

**Benefits:**
- No public IP on VMs
- No need to manage NSG rules for RDP/SSH from internet
- Sessions are private (no lateral movement from session)
- Integrated with Entra ID authentication

### Just-in-Time (JIT) VM Access
A Defender for Servers (Defender for Cloud) feature that locks down management ports (RDP 3389, SSH 22, etc.) and opens them only for a defined time window.

**How it works:**
1. JIT policy configured on the VM (define allowed ports, source IPs, max time)
2. By default, the NSG rule **blocks** management ports
3. User requests access → Defender for Cloud creates a temporary NSG rule
4. Access granted for the requested time (max configurable, default 3 hours)
5. NSG rule automatically deleted after the time window expires

**Requirements:** Defender for Servers Plan 1 or Plan 2 must be enabled.

**Best practice:** Combine JIT with Azure Bastion — remove all public IPs from VMs, use Bastion for access, and use JIT to control when even Bastion can initiate connections (optional defense-in-depth).

---

## 6. Azure Private Link and Private Endpoints

### The Problem
By default, PaaS services (Storage, SQL, Key Vault) are accessed via public endpoints (public IPs). Even with Service Endpoints, traffic goes through public IP space and the service still has a public endpoint.

### Private Endpoints
A **private endpoint** is a network interface with a private IP from your VNet, connected to an Azure PaaS service. This eliminates the service's public endpoint exposure.

**Benefits:**
- Service accessible via private IP only
- Traffic stays on Microsoft backbone — never leaves VNet
- Public endpoint can be disabled entirely
- Protects against data exfiltration (traffic cannot go to a different tenant's service)
- Works across VNet peering, VPN, and ExpressRoute

**Components:**
| Component | Role |
|-----------|------|
| **Private endpoint** | NIC in your subnet with a private IP |
| **Private Link service** | The service being connected to |
| **Private DNS zone** | Resolves service FQDN to private IP |

### Private DNS Integration (Critical!)
Without proper DNS, the service FQDN resolves to the public IP even after creating a private endpoint.

**Resolution flow:**
1. Client queries `mystorageaccount.blob.core.windows.net`
2. DNS resolves to `mystorageaccount.privatelink.blob.core.windows.net` (CNAME)
3. Private DNS zone `privatelink.blob.core.windows.net` resolves to `10.0.1.5` (private IP)

**Private DNS zone names (exam favorites):**
| Service | Private DNS Zone |
|---------|-----------------|
| Azure Blob Storage | `privatelink.blob.core.windows.net` |
| Azure SQL Database | `privatelink.database.windows.net` |
| Azure Key Vault | `privatelink.vaultcore.azure.net` |
| Azure Container Registry | `privatelink.azurecr.io` |
| Azure Kubernetes Service API | `privatelink.{region}.azmk8s.io` |
| Azure Monitor | `privatelink.monitor.azure.com` |

### Private Link Service
Allows you to expose **your own service** behind a Private Link, so other customers can connect to your service via a private endpoint in their VNet. Used by ISVs and large organizations.

### Service Endpoint vs. Private Endpoint
| Feature | Service Endpoint | Private Endpoint |
|---------|-----------------|-----------------|
| **Private IP in VNet** | No (still public endpoint) | Yes |
| **Public endpoint disabled** | No | Yes (optional) |
| **Cross-region** | No | Yes |
| **Cost** | Free | Charged per endpoint + data |
| **DNS change needed** | No | Yes |
| **Data exfiltration protection** | Limited | Strong |
| **Recommended for** | Basic isolation | High security / compliance requirements |

---

## 7. Web Application Firewall (WAF)

### What is WAF
An L7 firewall that inspects HTTP/HTTPS traffic and protects web applications from common exploits.

**Integrated platforms:**
| Platform | Scope |
|----------|-------|
| **Azure Application Gateway WAF** | Regional; protects apps in a single region |
| **Azure Front Door WAF** | Global; CDN + WAF at Microsoft's edge network |
| **Azure CDN WAF** | Akamai/Verizon CDN-based |

### WAF Modes
| Mode | Action |
|------|--------|
| **Detection** | Log only; does not block — use for initial tuning |
| **Prevention** | Block and log matching requests — production mode |

### WAF Rule Sets
Based on OWASP Core Rule Set (CRS):
- **CRS 3.2 / 4.0** (Application Gateway) — latest recommended versions
- Protects against: SQL injection, XSS, command injection, path traversal, scanner detection, protocol violations, and more

**Managed rules:** Automatically updated by Microsoft  
**Custom rules:** Create your own match conditions and actions (allow/block/log/redirect)

### WAF Exclusions
Sometimes legitimate traffic triggers WAF rules (false positives). Exclusions allow specific request attributes to bypass rule inspection:
- Exclusion by request header name/value
- Exclusion by request cookie name/value
- Exclusion by request arg name/value
- Apply per rule or globally

### Application Gateway WAF vs. Front Door WAF
| Feature | Application Gateway WAF | Front Door WAF |
|---------|------------------------|---------------|
| **Scope** | Regional | Global (edge) |
| **Bot protection** | Yes (managed rule) | Yes (managed rule) |
| **Rate limiting** | Yes (custom rules) | Yes (custom rules) |
| **Geo-filtering** | Yes | Yes |
| **SSL termination** | At gateway | At edge |
| **Use case** | Single-region web apps | Multi-region, global apps |

---

## 8. Network Monitoring and Diagnostics

### Azure Network Watcher
Centralized network diagnostic and monitoring service.

**Key tools:**
| Tool | Purpose |
|------|---------|
| **IP Flow Verify** | Check if a packet is allowed/denied by NSG rules for a specific VM |
| **NSG Flow Logs** | Log all IP traffic through NSGs (source, destination, port, action) |
| **Connection Monitor** | Continuously monitor connectivity between endpoints |
| **Packet Capture** | Capture network packets from a VM for deep analysis |
| **Next Hop** | Determine the next hop for traffic from a VM |
| **Effective Security Rules** | View the aggregated NSG rules effective on a NIC/subnet |
| **VPN Diagnostics** | Diagnose VPN gateway and connection issues |
| **Topology** | Visual map of resources in a VNet |

### NSG Flow Logs
- Stored in Azure Storage accounts
- Version 2 includes bytes/packets per flow
- Analyzed with **Traffic Analytics** (requires Log Analytics workspace)
- Traffic Analytics provides: top talkers, geo-location mapping, open ports, threat detection

### Diagnostic Settings
Enable diagnostic logs for network resources:
- Azure Firewall: AzureFirewallApplicationRule, AzureFirewallNetworkRule, AzureFirewallDnsProxy
- Application Gateway: ApplicationGatewayAccessLog, ApplicationGatewayFirewallLog
- NSG: NetworkSecurityGroupEvent, NetworkSecurityGroupRuleCounter

---

## Key Exam Tips

1. **NSG association:** NSGs can be applied to subnets OR NICs. When applied to both, traffic must pass BOTH. When troubleshooting, check both levels.

2. **Azure Firewall vs. NSG:** NSGs are L4 stateful filtering (IP/port). Azure Firewall adds L7 capabilities (FQDN, URL, IDPS). For internet egress control, Azure Firewall is the answer.

3. **Private Endpoint = Private IP + DNS change.** You must configure Private DNS zones AND link them to the VNet. Without DNS, clients still resolve to the public IP.

4. **JIT requires Defender for Servers.** If a question mentions "temporarily open management ports" or "lock down RDP," the answer is JIT VM Access.

5. **Bastion subnet name must be exactly `AzureBastionSubnet`** and must be at least /26.

6. **DDoS Standard / Network Protection:** Enabled per VNet; protects all public IPs in that VNet. Does NOT protect against L7 attacks — pair with WAF.

7. **WAF Detection vs. Prevention:** Always start in Detection mode when deploying a WAF to avoid blocking legitimate traffic. Switch to Prevention after tuning exclusions.

8. **Service Tags reduce management overhead.** Always use service tags (`Storage`, `Sql`, `AzureCloud`) in NSG rules rather than managing IP ranges manually.

9. **UDR + Azure Firewall = forced tunneling of internet traffic.** Create a route table with `0.0.0.0/0 → Virtual Appliance (Firewall IP)` and associate it with the subnet.

10. **VNet peering is non-transitive.** Hub-and-spoke topologies require Azure Firewall or Route Server for spoke-to-spoke communication through the hub.

---

> **Previous:** [Domain 1 — Identity and Access](01-identity-and-access.md) | **Next:** [Domain 3 — Compute, Storage, and Databases →](03-compute-storage-databases.md)
