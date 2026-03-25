# Domain 2 — Secure Networking (20–25%)

---

## 2.1 Network Security Groups (NSGs)

### Overview

An NSG is a stateful L3/L4 packet filter applied to **subnets** or **individual NICs**. Rules are evaluated in priority order (lowest number wins).

### Rule Properties

| Property | Description |
|---|---|
| **Priority** | 100–4096. Lower = higher priority. Azure adds default rules at 65000, 65001, 65500. |
| **Protocol** | TCP, UDP, ICMP, Esp, Ah, or Any |
| **Source/Destination** | CIDR, IP, Service Tag, or Application Security Group (ASG) |
| **Port range** | Single port, range (e.g., 8080–8090), or `*` |
| **Action** | Allow or Deny |

### Default Rules (cannot be deleted)

| Priority | Name | Action | Notes |
|---|---|---|---|
| 65000 | AllowVnetInBound | Allow | All intra-VNet traffic |
| 65001 | AllowAzureLoadBalancerInBound | Allow | Azure health probes |
| 65500 | DenyAllInBound | Deny | Catch-all deny |

### Application Security Groups (ASGs)

- Logical grouping of VMs by workload role (e.g., `asg-web`, `asg-db`).
- NSG rules reference ASGs instead of IPs → **zero maintenance when IPs change**.
- ASG and NSG must be in the **same region** and **same VNet**.

### Service Tags

Pre-built IP range groups maintained by Microsoft:

| Tag | Covers |
|---|---|
| `Internet` | Public internet space |
| `VirtualNetwork` | VNet address space + peered VNets + VPN connected |
| `AzureLoadBalancer` | Azure infrastructure IPs for health probes |
| `Storage` | Azure Storage public endpoints (per region: `Storage.EastUS`) |
| `Sql` | Azure SQL public endpoints |
| `AppService` | App Service outbound IPs |
| `AzureMonitor` | Log Analytics / Monitor endpoints |

### Architecture Decision

```
Use NSG service tags to avoid manual IP list maintenance.
Use ASGs for workload-level rules in large environments.
Layer: subnet NSG (zone isolation) + NIC NSG (per-VM control) if needed.
```

---

## 2.2 Azure Firewall

### SKU Comparison

| Feature | Standard | Premium |
|---|---|---|
| Network rules (L3/L4) | ✅ | ✅ |
| Application rules (FQDN) | ✅ | ✅ |
| DNS proxy | ✅ | ✅ |
| Threat intelligence (alert) | ✅ | ✅ |
| Threat intelligence (alert + deny) | ❌ | ✅ |
| TLS inspection | ❌ | ✅ |
| IDPS (signature-based) | ❌ | ✅ |
| URL filtering | ❌ | ✅ |
| Web categories | ❌ | ✅ |

### Rule Collection Types (priority order within policy)

1. **DNAT rules** — Translate inbound destination IP:port (used for inbound NAT)
2. **Network rules** — IP/port-based L3/L4 allow/deny
3. **Application rules** — FQDN / URL / web category (HTTP/S + others)

> Network rules are evaluated **before** application rules. If a network rule matches, application rules are skipped.

### Forced Tunneling

- Route all internet-bound traffic through Firewall by creating a UDR (0.0.0.0/0 → Firewall private IP) on all subnets.
- Firewall subnet (`AzureFirewallSubnet`) must have a separate management NIC route when forced tunneling is enabled (or use Firewall Management Subnet).

### Firewall Policy vs Classic Rules

- **Azure Firewall Policy** — Recommended. Hierarchical (parent/child), centralised management via Firewall Manager.
- **Classic rules** — Per-firewall, not shareable. Legacy approach.

---

## 2.3 Azure DDoS Protection

### Tiers

| Tier | Cost | Features |
|---|---|---|
| **Network Protection — Basic** | Free (included) | Always-on, volumetric attack mitigation |
| **Network Protection — Standard** | ~$2,944/month (first 100 Public IPs) | Adaptive tuning, DDoS Rapid Response team, SLA, cost protection, attack analytics, metrics & alerts |
| **IP Protection** | Per-IP (pay-as-you-go) | Single public IP protection, subset of Standard features |

### Key Points

- Standard protection applies to **all public IPs** within protected VNets (up to 100 included).
- Works with **Azure Firewall**, **Application Gateway WAF**, and **Azure Load Balancer**.
- Mitigation types: **Volumetric**, **Protocol**, **Resource (application) layer**.
- Use **DDoS Protection Alert** metric → Azure Monitor Alerts for notification.

---

## 2.4 Web Application Firewall (WAF)

### Deployment Targets

| Target | Layer | Use Case |
|---|---|---|
| **Application Gateway WAF** | Regional, L7 | HTTP/S traffic for regional web apps |
| **Azure Front Door WAF** | Global (CDN edge), L7 | Global web apps, multi-region |
| **Azure CDN WAF** | Global CDN edge | Static content protection |

### WAF Modes

| Mode | Behaviour |
|---|---|
| **Detection** | Logs only, does not block |
| **Prevention** | Detects and blocks malicious requests |

### Rule Sets

- **OWASP CRS** (Core Rule Set) 3.0, 3.1, 3.2 — Covers OWASP Top 10
- **Microsoft Default Rule Set (DRS)** — On Azure Front Door
- **Bot Manager** rules — Differentiate good/bad bots

### Custom WAF Rules

```
IF  match conditions (IP, geo, URI, header, cookie, request body)
THEN  Allow / Block / Log / Redirect / Rate-limit
```

---

## 2.5 Private Link and Service Endpoints

### Service Endpoints

- Extends your VNet's **routing** to include the Azure service's **public IP range**.
- Traffic still egresses through the public IP of the service.
- **Cannot** be accessed from on-premises over VPN without additional config.
- Free; easy to set up.

### Private Endpoints

- Injects a **private IP from your VNet subnet** into the Azure service (PaaS).
- Traffic never leaves the Microsoft network (no public IP traversal).
- Requires **Private DNS Zone** (e.g., `privatelink.blob.core.windows.net`) for DNS resolution.
- Accessible from on-premises over VPN/ExpressRoute.
- Prevents data exfiltration to other tenants.

### When to Use Which

| Requirement | Use |
|---|---|
| Simple, low-cost, regional access | Service Endpoint |
| On-premises access to PaaS | Private Endpoint |
| Data exfiltration prevention | Private Endpoint |
| Regulatory: no public internet traversal | Private Endpoint |

---

## 2.6 Azure Virtual Network Peering

### Types

| Type | Scope | Latency |
|---|---|---|
| **VNet Peering** | Same region | Low (Microsoft backbone) |
| **Global VNet Peering** | Cross-region | Low (Microsoft backbone) |

### Peering Properties

| Setting | Description |
|---|---|
| Allow forwarded traffic | Accept traffic routed through the peered VNet |
| Allow gateway transit | Hub can share its VPN/ER gateway with spokes |
| Use remote gateways | Spoke uses hub's gateway (requires transit enabled) |

### Hub-Spoke Architecture

```
Hub VNet
├── AzureFirewallSubnet  → Azure Firewall (centralised egress)
├── GatewaySubnet        → VPN/ER Gateway (on-premises connectivity)
└── BastionSubnet        → Azure Bastion (secure jump access)

Spoke VNets (peered to Hub)
├── Spoke-Prod
├── Spoke-Dev
└── Spoke-DMZ
```

All spoke-to-internet and spoke-to-spoke traffic routes through the Hub Firewall via UDRs.

---

## 2.7 VPN Gateway and ExpressRoute Encryption

### VPN Gateway SKUs

| SKU | Max Throughput | Use Case |
|---|---|---|
| Basic | 100 Mbps | Dev/test only (no SLA) |
| VpnGw1–5 | 650 Mbps – 10 Gbps | Production |
| VpnGw1AZ–5AZ | Same | Zone-redundant |

### VPN Types

| Type | Description |
|---|---|
| **Route-based** | Uses routing table; supports IKEv2, BGP; recommended |
| **Policy-based** | Static routes; older, limited to basic SKU |

### ExpressRoute Security

- Private circuit; traffic does NOT traverse the public internet.
- **MACsec** — Layer 2 encryption on ExpressRoute Direct circuits.
- **IPsec over ExpressRoute** — Layer 3 encryption for PrivatePeering traffic.
- ExpressRoute does NOT encrypt traffic by default — use IPsec/MACsec if required.

---

## 2.8 Azure Bastion

### SKU Comparison

| Feature | Basic | Standard |
|---|---|---|
| RDP/SSH via browser | ✅ | ✅ |
| Native client support | ❌ | ✅ |
| IP-based connection | ❌ | ✅ |
| File transfer | ❌ | ✅ (SSH) |
| VNet peering support | ❌ | ✅ |
| Session recording | ❌ | ✅ (via ADLS integration) |
| Host scaling (instances) | 2 fixed | 2–50 |

### Key Points

- Bastion lives in `AzureBastionSubnet` (minimum /26).
- VMs do **not** need public IPs when accessed via Bastion.
- JIT VM Access (Defender for Servers) works alongside Bastion.

---

## 2.9 Practice Questions

**Q1.** You need to allow VMs in the `web-tier` ASG to communicate with VMs in the `db-tier` ASG on port 1433, and deny all other access to the db-tier. Which NSG rule configuration achieves this with the least maintenance overhead?

- A. Create rules using CIDR IP ranges for web-tier VMs  
- B. Create rules referencing the `web-tier` ASG as source and `db-tier` ASG as destination  
- C. Use a service tag `AzureSQL` as the destination  
- D. Use `VirtualNetwork` service tag as the source  

<details><summary>Answer</summary>
**B** — ASG references remove the need to maintain IP lists. When VMs are added/removed from the ASG, no rule changes are needed.
</details>

---

**Q2.** An organisation's security policy requires that all traffic from Azure VMs to the internet must pass through Azure Firewall for inspection. What must you configure?

- A. NSG deny rule for internet-bound traffic on all subnets  
- B. A User-Defined Route (UDR) with 0.0.0.0/0 next hop set to Azure Firewall private IP on all spoke subnets  
- C. Set Azure Firewall as the default gateway in VM OS  
- D. Enable DDoS Standard on the VNet  

<details><summary>Answer</summary>
**B** — A UDR (0.0.0.0/0 → Firewall private IP) on each spoke subnet forces all internet traffic through Azure Firewall. This is forced tunneling.
</details>

---

**Q3.** A company wants to connect its Azure SQL Database to a VNet so that SQL is not reachable from the public internet and accessible from on-premises via VPN. Which option should they use?

- A. Service Endpoint for SQL on the VNet subnet  
- B. Azure SQL Firewall rules allowing the VNet's IP range  
- C. Private Endpoint for Azure SQL with Private DNS Zone  
- D. VNet injection for Azure SQL  

<details><summary>Answer</summary>
**C** — Private Endpoint gives SQL a private IP in the VNet, makes it accessible from on-premises (via VPN), and removes it from the public internet. Service Endpoints do not work reliably over VPN and still use public IPs.
</details>

---

**Q4.** Azure Firewall Premium adds which capability that is NOT available in Azure Firewall Standard?

- A. FQDN-based application rules  
- B. Network rules (L3/L4)  
- C. TLS inspection and IDPS  
- D. Threat intelligence alerts  

<details><summary>Answer</summary>
**C** — TLS inspection and IDPS (Intrusion Detection and Prevention System) are Premium-only features.
</details>

---

**Q5.** ExpressRoute does not encrypt traffic by default. Which technology should you implement to add Layer 2 encryption on an ExpressRoute Direct circuit?

- A. IPsec VPN over ExpressRoute  
- B. MACsec  
- C. Azure Firewall TLS inspection  
- D. NSG flow log encryption  

<details><summary>Answer</summary>
**B** — MACsec provides IEEE 802.1AE Layer 2 encryption specifically for ExpressRoute Direct circuits.
</details>
