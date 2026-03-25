# Domain 2 — Secure Networking (20–25%)

> **Exam weight:** 20–25% of the total score (~12–15 questions out of 60)

---

## Table of Contents

1. [Virtual Network Security Fundamentals](#1-virtual-network-security-fundamentals)
2. [Network Security Groups (NSGs)](#2-network-security-groups-nsgs)
3. [Application Security Groups (ASGs)](#3-application-security-groups-asgs)
4. [Azure Firewall](#4-azure-firewall)
5. [Azure Web Application Firewall (WAF)](#5-azure-web-application-firewall-waf)
6. [Azure DDoS Protection](#6-azure-ddos-protection)
7. [Azure Bastion](#7-azure-bastion)
8. [Just-in-Time (JIT) VM Access](#8-just-in-time-jit-vm-access)
9. [Private Endpoints & Private Link](#9-private-endpoints--private-link)
10. [Service Endpoints](#10-service-endpoints)
11. [User-Defined Routes (UDRs) & Forced Tunneling](#11-user-defined-routes-udrs--forced-tunneling)
12. [Network Watcher & Flow Logs](#12-network-watcher--flow-logs)
13. [Key Exam Points](#key-exam-points)

---

## 1. Virtual Network Security Fundamentals

### Defense-in-Depth Layers (Network)
```
Internet
  ↓
DDoS Protection (perimeter)
  ↓
Azure Firewall / NVA (perimeter / hub VNet)
  ↓
Web Application Firewall (edge — App GW / Front Door)
  ↓
Network Security Groups (subnet + NIC level)
  ↓
Application Security Groups (workload-level grouping)
  ↓
Azure Bastion / JIT (management plane)
  ↓
Private Endpoints / Service Endpoints (data plane isolation)
```

### Hub-Spoke Network Topology
- **Hub VNet** — centralized shared services: Azure Firewall, VPN Gateway, Bastion.
- **Spoke VNets** — application workloads; peered to hub.
- Traffic between spokes flows through the hub firewall.

---

## 2. Network Security Groups (NSGs)

NSGs are **stateful** layer-4 packet filters that can be applied to:
- **Subnets** (preferred for broad control)
- **Network Interface Cards (NICs)** (more granular)

### Rule Properties
| Property | Description |
|----------|-------------|
| Priority | 100–4096; lower number = higher priority |
| Source/Destination | IP, CIDR, Service Tag, ASG |
| Protocol | TCP, UDP, ICMP, ESP, AH, Any |
| Port range | Single, range, or `*` |
| Action | Allow or Deny |

### Default Rules (cannot be deleted)
| Priority | Name | Direction | Action |
|----------|------|-----------|--------|
| 65000 | AllowVNetInBound | Inbound | Allow |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allow |
| 65500 | DenyAllInBound | Inbound | Deny |
| 65000 | AllowVnetOutBound | Outbound | Allow |
| 65001 | AllowInternetOutBound | Outbound | Allow |
| 65500 | DenyAllOutBound | Outbound | Deny |

### Service Tags (Common)
| Tag | Covers |
|-----|--------|
| `Internet` | Public IP space outside VNet |
| `AzureCloud` | All Azure datacenter IPs |
| `VirtualNetwork` | VNet address space + peered VNets |
| `AzureLoadBalancer` | Azure load balancer probe IP |
| `Sql` | Azure SQL service IPs |
| `Storage` | Azure Storage service IPs |
| `GatewayManager` | Azure VPN/ExpressRoute gateway IPs |

> **Exam tip:** If both subnet NSG and NIC NSG exist, **both** are evaluated. For inbound: subnet NSG first, then NIC NSG. For outbound: NIC NSG first, then subnet NSG.

---

## 3. Application Security Groups (ASGs)

ASGs let you **group VMs by workload role** and use those groups as NSG source/destination instead of IP addresses.

```
ASG: asg-web    ← webserver VMs
ASG: asg-db     ← database VMs

NSG Rule:
  Source: asg-web  → Destination: asg-db  → Port: 1433  → Allow
```

Benefits:
- No need to track IP addresses.
- Rules automatically apply when VMs are added to the ASG.

---

## 4. Azure Firewall

Azure Firewall is a **stateful, managed, cloud-native** network security service.

### SKUs
| SKU | Features |
|-----|---------|
| **Standard** | L3–L7 filtering, FQDN filtering, threat intel |
| **Premium** | + TLS inspection, IDPS (intrusion detection/prevention), URL categories, Web categories |

### Rule Collection Types (processed top to bottom)
| Type | Layer | Match on | Example |
|------|-------|---------|---------|
| **DNAT rules** | L4 | Destination IP/port | Inbound NAT for public-facing services |
| **Network rules** | L3/L4 | IP, protocol, port | Allow/deny specific IPs and ports |
| **Application rules** | L7 | FQDNs, URL patterns | Allow `*.microsoft.com` on port 443 |

### Processing Order
1. **Threat Intelligence** (if enabled, can deny before rules)
2. **DNAT rules**
3. **Network rules**
4. **Application rules**

### Forced Tunneling Mode
- All outbound traffic from the firewall goes to an on-premises network instead of the internet.
- Requires a separate **management NIC** for the firewall control plane.

### Azure Firewall Policy vs Classic Rules
- **Firewall Policy** — preferred; supports Firewall Manager, hierarchical policies, IDPS, TLS inspection.
- **Classic rules** — legacy; cannot use Firewall Manager.

> **Exam tip:** Azure Firewall **Premium** is required for TLS inspection and IDPS signature-based detection.

---

## 5. Azure Web Application Firewall (WAF)

WAF protects web applications against common exploits (OWASP Top 10).

### Deployment Options
| Platform | Scope | Use Case |
|----------|-------|---------|
| **Application Gateway WAF** | Regional | Single region, internal + external apps |
| **Azure Front Door WAF** | Global (CDN edge) | Multi-region, global apps |
| **Azure CDN WAF** | Global CDN | Static content protection |

### WAF Modes
| Mode | Action on Rule Match |
|------|---------------------|
| **Detection** | Log only — does not block |
| **Prevention** | Log and block (returns 403) |

> **Exam tip:** Always switch to **Prevention** mode in production. Detection mode is only for tuning/testing.

### Rule Sets
| Rule Set | Description |
|----------|-------------|
| OWASP CRS 3.2 / 3.1 / 3.0 | Core rule set — OWASP Top 10 |
| Microsoft Default Rule Set (DRS) | Azure-curated; updated more frequently |
| Bot Manager rules | Detect and block bad bots |

### Custom WAF Rules
Can be created to:
- Block traffic from specific IPs/IP ranges.
- Rate-limit requests from a source.
- Block based on geo-location (country).
- Allow/deny based on request headers or URI.

---

## 6. Azure DDoS Protection

### Tiers
| Tier | Cost | Protection |
|------|------|-----------|
| **DDoS Network Protection** (formerly Standard) | ~$2,944/month + per-resource | Adaptive tuning, attack analytics, rapid response team, cost protection guarantee |
| **Basic** (now default infrastructure protection) | Free | Protects Azure platform; no per-VNet tuning |

### Protected Resource Types
- Public IP addresses (attached to VMs, Load Balancers, App Gateways, etc.)
- VNet-level protection covers all public IPs in that VNet.

### DDoS Attack Types Mitigated
- **Volumetric** — flood bandwidth (UDP floods, ICMP floods).
- **Protocol** — exploit protocol weaknesses (SYN floods, Ping of Death).
- **Resource layer** — target application layer (requires WAF for L7).

> **Exam tip:** DDoS Protection **alone** does not protect against L7 (application layer) attacks — combine with WAF.

---

## 7. Azure Bastion

Azure Bastion provides **browser-based RDP and SSH** without exposing VMs to the public internet.

### How It Works
1. Bastion is deployed in a subnet named **AzureBastionSubnet** (minimum /26).
2. Users connect via Azure portal or native client — no public IP needed on the VM.
3. Traffic flows over TLS 443 from the browser to Bastion, then to the VM over the VNet.

### SKUs
| SKU | Features |
|-----|---------|
| **Basic** | Browser-based RDP/SSH, no custom ports |
| **Standard** | + Shareable links, native client support, IP-based connection, custom ports, file transfer |

### Security Benefits
- No public IP required on VMs.
- No need to manage NSG rules for RDP/SSH from the internet.
- All sessions logged (integration with Azure Monitor).

> **Exam tip:** The AzureBastionSubnet must be at least **/26** (64 addresses).

---

## 8. Just-in-Time (JIT) VM Access

JIT is a Defender for Cloud feature that **locks down** inbound management ports (RDP/SSH) and only opens them on demand.

### How It Works
1. Defender for Cloud creates NSG deny rules for RDP (3389) and SSH (22).
2. A user requests access via Defender for Cloud.
3. Defender for Cloud temporarily adds an Allow rule for the requestor's IP and specified duration (default max 3 hours).
4. Access expires automatically.

### Benefits
- Reduces attack surface to 0 when not in use.
- Audit trail of all access requests.
- Can require approval workflow.

> **Exam tip:** JIT requires **Microsoft Defender for Servers Plan 1 or higher**.

---

## 9. Private Endpoints & Private Link

### Private Endpoint
A **private IP address** in your VNet that maps to a specific Azure PaaS service instance.

```
Your VNet (10.0.0.0/16)
  ├── Subnet (10.0.1.0/24)
  │     └── Private Endpoint: 10.0.1.5  →  myaccount.blob.core.windows.net
  └── VM
        └── Connects to storage via 10.0.1.5 (never leaves Azure backbone)
```

### Azure Private Link
The technology enabling private endpoints — creates a private connection to:
- Azure PaaS services (Storage, SQL, Key Vault, etc.)
- Your own services (Private Link Service)
- Partner services

### DNS Configuration
- Azure creates private DNS zones: `privatelink.blob.core.windows.net`
- The storage account FQDN resolves to the private IP within the VNet.
- Important: DNS records must be correct — common exam scenario.

> **Exam tip:** After creating a private endpoint, the **public endpoint is not automatically disabled** — you must configure the service firewall to deny public access separately.

---

## 10. Service Endpoints

Service endpoints route VNet traffic to Azure PaaS services over the **Azure backbone**, not the internet.

### Key Differences vs. Private Endpoints
| Feature | Service Endpoint | Private Endpoint |
|---------|----------------|-----------------|
| Traffic path | Azure backbone | Azure backbone |
| Service gets private IP in VNet | ❌ | ✅ |
| Works across VNet peering | Limited | ✅ |
| Cost | Free | Per-hour + per-GB charge |
| DNS change needed | ❌ | ✅ |
| On-prem support via VPN/ER | ❌ | ✅ |

> **Exam tip:** For connecting **on-premises clients** to Azure PaaS services privately, use **Private Endpoints** (not service endpoints).

---

## 11. User-Defined Routes (UDRs) & Forced Tunneling

### User-Defined Routes
Custom routes in a route table that override Azure's default system routes.

| Next Hop Type | Use Case |
|--------------|---------|
| Virtual appliance | Route through NVA / Azure Firewall |
| VNet gateway | Route to on-premises via VPN/ER |
| VNet | Keep within VNet |
| Internet | Send to internet |
| None | Drop traffic (black hole) |

### Hub-Spoke Routing with Firewall
```
Spoke VNet Route Table:
  0.0.0.0/0  →  Next hop: Azure Firewall private IP (10.0.0.4)
```

### Forced Tunneling
Routes **all internet-bound traffic** from Azure VMs back through on-premises (via VPN/ExpressRoute) for inspection.

- Implemented with a UDR: `0.0.0.0/0 → VPN Gateway`.
- Exceptions can be added for specific prefixes.

---

## 12. Network Watcher & Flow Logs

### Network Watcher Tools
| Tool | Purpose |
|------|---------|
| **IP flow verify** | Test if a specific packet is allowed/denied by NSG |
| **NSG flow logs** | Capture allowed/denied flow info (source/dest IP, port, protocol) |
| **Connection troubleshoot** | Test TCP connectivity from VM to endpoint |
| **Connection monitor** | Continuous monitoring of connectivity between endpoints |
| **Topology** | Visual diagram of VNet resources |
| **Packet capture** | Capture packets on a VM's NIC |

### NSG Flow Logs
- Log to a Storage Account.
- Optionally send to **Log Analytics** for querying with KQL.
- **Traffic Analytics** — uses flow logs to provide visual insights and anomaly detection.

```
Flow log format: version, timestamp, subscription-id, resource-id, mac, category, 
                 rule-name, flow-state (A=Allowed/D=Denied), flow-direction, 
                 protocol, src-ip, dst-ip, src-port, dst-port, packets, bytes
```

---

## Key Exam Points

- [ ] **NSG processing**: Inbound — subnet NSG first, NIC NSG second. Outbound — NIC NSG first, subnet NSG second.
- [ ] **WAF must be in Prevention mode** in production (Detection mode only logs).
- [ ] **DDoS Standard** does not protect against L7 attacks — pair with WAF for complete protection.
- [ ] **AzureBastionSubnet** must be named exactly that and be at least /26.
- [ ] **JIT access** requires Defender for Servers Plan 1 or higher.
- [ ] **Private Endpoints** support on-premises connectivity via VPN/ExpressRoute; Service Endpoints do not.
- [ ] Disabling the **public endpoint** after creating a private endpoint must be done explicitly.
- [ ] **Azure Firewall Premium** (not Standard) provides TLS inspection and IDPS.
- [ ] UDRs with `0.0.0.0/0 → Azure Firewall` implement forced tunneling through the hub firewall.
- [ ] **Threat Intelligence** in Azure Firewall can block traffic from/to known malicious IPs/FQDNs.
