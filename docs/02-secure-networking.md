# Domain 2: Secure Networking (20–25%)

> This domain covers Azure virtual network security including NSGs, Azure Firewall, DDoS Protection, Private Endpoints, and secure connectivity (VPN/ExpressRoute).

---

## Objectives Covered

- Plan and implement security for virtual networks
- Plan and implement security for private access to Azure resources
- Plan and implement security for public access to Azure resources

---

## 2.1 Virtual Network (VNet) Fundamentals

An **Azure Virtual Network (VNet)** is the foundational network isolation boundary in Azure.

### Key Concepts
| Concept | Description |
|---|---|
| Address space | CIDR block(s) assigned to the VNet (e.g., 10.0.0.0/16) |
| Subnets | Subdivisions of the VNet address space |
| VNet peering | Low-latency connection between two VNets (same or different region) |
| Service endpoints | Direct routes from a subnet to an Azure service (e.g., Storage, SQL) |
| Private endpoints | Private IP for an Azure PaaS service inside your VNet |

### VNet Peering Security
- Peering is **non-transitive** by default (A→B, B→C does not imply A→C)
- Can enable **Allow forwarded traffic**, **Allow gateway transit**, and **Use remote gateways**
- Use a **hub-and-spoke** topology with Azure Firewall in the hub for centralized security

---

## 2.2 Network Security Groups (NSGs)

NSGs are **stateful packet filters** applied at the subnet or NIC level.

### NSG Rule Properties
| Property | Description |
|---|---|
| Priority | 100–4096; lower number = higher priority |
| Source / Destination | IP, CIDR, service tag, or application security group |
| Protocol | TCP, UDP, ICMP, or Any |
| Port range | Single port, range, or * |
| Action | Allow or Deny |

### Default Rules (Cannot Be Deleted)
| Priority | Name | Direction | Action |
|---|---|---|---|
| 65000 | AllowVnetInBound | Inbound | Allow |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allow |
| 65500 | DenyAllInBound | Inbound | Deny |
| 65000 | AllowVnetOutBound | Outbound | Allow |
| 65001 | AllowInternetOutBound | Outbound | Allow |
| 65500 | DenyAllOutBound | Outbound | Deny |

> ⚠️ **Exam tip:** NSGs are **stateful** — if inbound traffic is allowed, the corresponding outbound response is automatically allowed.

### Service Tags
Service tags represent a group of IP prefixes for Azure services. Use them instead of hardcoding IP addresses.

| Tag | Represents |
|---|---|
| `Internet` | Public internet address space |
| `AzureCloud` | All Azure datacenter IPs |
| `AzureLoadBalancer` | Azure Load Balancer health probes |
| `VirtualNetwork` | All VNet address spaces |
| `Storage` | Azure Storage IPs (region-specific variant available) |
| `Sql` | Azure SQL Database IPs |
| `AppService` | Azure App Service outbound IPs |

### Application Security Groups (ASGs)
ASGs let you group VMs logically and write NSG rules referencing those groups instead of IPs.

```bash
# Create an ASG for web servers
az network asg create --resource-group myRG --name WebServers

# Associate VM NIC with ASG
az network nic ip-config update \
  --resource-group myRG \
  --nic-name myVM-nic \
  --name ipconfig1 \
  --application-security-groups WebServers

# NSG rule using ASG
az network nsg rule create \
  --resource-group myRG \
  --nsg-name myNSG \
  --name AllowHTTPS \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-asgs WebServers \
  --destination-port-ranges 443 \
  --protocol Tcp \
  --access Allow
```

---

## 2.3 Azure Firewall

Azure Firewall is a **managed, cloud-native, stateful network firewall** providing centralized network security.

### Azure Firewall SKUs

| Feature | Standard | Premium |
|---|---|---|
| L3/L4 filtering | ✅ | ✅ |
| L7 (FQDN, App rules) | ✅ | ✅ |
| TLS inspection | ❌ | ✅ |
| IDPS (Intrusion Detection & Prevention) | ❌ | ✅ |
| URL filtering (full path) | ❌ | ✅ |
| Web categories | Basic | Enhanced |

### Rule Types
| Rule Type | Scope | Example |
|---|---|---|
| DNAT rules | Inbound | Translate public IP:port to private IP:port |
| Network rules | L3/L4 | Allow TCP from 10.0.0.0/24 to 10.1.0.0/24:443 |
| Application rules | L7 FQDN | Allow HTTPS to *.microsoft.com |

### Azure Firewall vs NSG Decision Guide

> Use **NSGs** for intra-VNet traffic filtering at the subnet/NIC level.
> Use **Azure Firewall** for centralized east-west and north-south traffic control, FQDN filtering, and threat intelligence.

### Forced Tunneling
Route all internet-bound traffic through an on-premises firewall:
```bash
# Associate a route table that sends 0.0.0.0/0 to the Azure Firewall private IP
az network route-table route create \
  --resource-group myRG \
  --route-table-name myRouteTable \
  --name DefaultRoute \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address 10.0.1.4  # Azure Firewall private IP
```

---

## 2.4 Azure DDoS Protection

### DDoS Protection Plans

| Plan | Features | Cost |
|---|---|---|
| **Basic (Infrastructure)** | Automatic mitigation for Azure platform | Free |
| **Standard (Network Protection)** | Adaptive tuning, attack analytics, rapid response, cost protection guarantee | Per month per DDoS plan |
| **IP Protection** | Per-IP protection without requiring DDoS plan | Per protected IP |

### What DDoS Standard Protects Against
- **Volumetric attacks:** Flood the network bandwidth
- **Protocol attacks:** Exploit weaknesses in L3/L4 protocols (SYN floods, Smurf attacks)
- **Resource layer attacks:** Target web application vulnerabilities (L7 — requires WAF)

> ⚠️ **Exam tip:** DDoS Standard (Network Protection) protects Public IP addresses in a VNet. It does **not** automatically protect against L7 application attacks — use **Azure Web Application Firewall (WAF)** for that.

---

## 2.5 Azure Web Application Firewall (WAF)

WAF provides centralized protection for web applications against common exploits.

### WAF Deployment Options
| Service | Use Case |
|---|---|
| Azure Application Gateway WAF | Regional; HTTP/HTTPS inspection; session affinity |
| Azure Front Door WAF | Global; CDN-integrated; geo-filtering |
| Azure CDN WAF | Static content protection |

### OWASP Core Rule Set (CRS)
- WAF uses OWASP CRS (3.2 recommended) to detect:
  - SQL Injection
  - Cross-Site Scripting (XSS)
  - Local/Remote File Inclusion
  - Command Injection
  - HTTP protocol violations

### WAF Modes
| Mode | Behavior |
|---|---|
| Detection | Log threats, do not block |
| Prevention | Log and block threats |

---

## 2.6 Private Endpoints & Private Link

**Azure Private Link** allows you to access Azure PaaS services over a private IP address within your VNet.

### Components
| Component | Description |
|---|---|
| Private endpoint | A NIC with a private IP connected to a PaaS resource |
| Private Link service | Expose your own service via Private Link |
| Private DNS zone | Resolves the service's FQDN to the private IP |

### Key Benefits
- Eliminates exposure to the public internet
- Traffic stays on the Microsoft backbone
- Prevents data exfiltration (service accepts connections only from your VNet)

### Service Endpoints vs Private Endpoints

| Feature | Service Endpoints | Private Endpoints |
|---|---|---|
| Traffic path | Microsoft backbone | Microsoft backbone |
| Source IP | VNet public IP | Private IP |
| Cost | Free | Per hour + data processed |
| Firewall restrictions | Source VNet | Target resource level |
| DNS override required | No | Yes (private DNS zone) |

```bash
# Create a private endpoint for a storage account
az network private-endpoint create \
  --name myStoragePE \
  --resource-group myRG \
  --vnet-name myVNet \
  --subnet mySubnet \
  --private-connection-resource-id /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/myStorage \
  --group-id blob \
  --connection-name myStorageConnection
```

---

## 2.7 VPN Gateway Security

### VPN Gateway Types
| Type | Use Case |
|---|---|
| Route-based VPN | Most scenarios; supports IKEv2; required for P2S |
| Policy-based VPN | Legacy; static routing; IKEv1 only |

### Point-to-Site (P2S) Authentication Methods
- Azure Certificate authentication
- Azure AD authentication (OpenVPN only)
- RADIUS authentication (on-premises NPS)

### Site-to-Site (S2S) Security
- Uses **IPsec/IKE** tunnels
- Configure custom IPsec/IKE policies to enforce stronger algorithms:
  - IKE: AES256, SHA256, DHGroup14+
  - IPsec: AES256, SHA256, PFS14+

---

## 2.8 ExpressRoute Security

| Feature | Description |
|---|---|
| Private peering | Azure IaaS resources; not encrypted by default |
| Microsoft peering | Azure PaaS and Microsoft 365; not encrypted by default |
| ExpressRoute + IPsec | Add encryption over private peering |
| MACSec | Layer 2 encryption between your edge router and Microsoft edge |

> ⚠️ **Exam tip:** ExpressRoute connections are **not encrypted by default**. If encryption is required, implement **MACsec** (L2) or run **IPsec over ExpressRoute** (L3).

---

## 🔬 Practice Questions

**Q1.** Your web application is hosted on Azure VMs in a subnet. You need to allow inbound HTTPS (port 443) from the internet while blocking all other inbound traffic. You also need to allow all outbound traffic. What is the minimum NSG configuration required?

> **Answer:** Add an inbound rule with priority < 65500, Source = Internet, Destination = *, Port = 443, Protocol = TCP, Action = Allow. The default `DenyAllInBound` rule at priority 65500 handles blocking everything else. No changes needed for outbound (default allows VNet + Internet).

**Q2.** You need to inspect all outbound internet traffic from your Azure VNets for malicious FQDNs using threat intelligence. Which Azure service should you use?

> **Answer:** **Azure Firewall** with Threat Intelligence mode set to **Alert and Deny**. NSGs cannot perform FQDN or threat intelligence filtering.

**Q3.** A storage account currently has a public endpoint. You need to ensure that the storage account is only accessible from within your VNet and not exposed to the public internet. What should you implement?

> **Answer:** Create a **Private Endpoint** for the storage account within the VNet, and configure the storage account to deny public network access. Create a **Private DNS zone** (`privatelink.blob.core.windows.net`) to resolve the storage FQDN to the private IP.

**Q4.** You are designing DDoS protection for a public-facing web application running on Azure. The application needs protection against both network-layer (L3/L4) and application-layer (L7) attacks. What combination of services should you use?

> **Answer:** **Azure DDoS Network Protection** for L3/L4 volumetric and protocol attacks, plus **Azure Web Application Firewall (WAF)** on Application Gateway or Front Door for L7 attacks.

**Q5.** An NSG rule has Priority 100 allowing TCP port 22 (SSH) from 10.0.0.0/8, and a rule with Priority 200 denying TCP port 22 from any source. A user at IP 10.1.2.3 tries to SSH. What happens?

> **Answer:** The connection is **allowed**. Priority 100 (lower number = higher priority) matches first and allows the traffic. Rule evaluation stops at the first match.

---

## 📚 Further Reading

- [Network security groups overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Firewall documentation](https://learn.microsoft.com/en-us/azure/firewall/)
- [Azure DDoS Protection overview](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)
- [Azure Private Link documentation](https://learn.microsoft.com/en-us/azure/private-link/)
- [WAF on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview)

---

*Previous: [Domain 1 — Manage Identity and Access ←](01-manage-identity-access.md) | Next: [Domain 3 — Secure Compute, Storage, and Databases →](03-secure-compute-storage-databases.md)*
