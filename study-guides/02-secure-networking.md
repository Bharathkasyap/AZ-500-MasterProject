# Domain 2: Secure Networking (20–25%)

> **Back to [README](../README.md)**

---

## Overview

Securing Azure networking involves configuring network security groups, Azure Firewall, DDoS protection, private endpoints, VPNs, and monitoring network traffic. This domain tests your ability to implement network perimeter and segment controls.

---

## 2.1 Plan and Implement Security for Virtual Networks

### Virtual Network (VNet) Architecture

An Azure Virtual Network is an isolated network in Azure. Key components:

| Component | Description |
|---|---|
| **VNet** | Isolated private network space in Azure |
| **Subnet** | Subdivision of a VNet — scope for applying NSGs and route tables |
| **Network Interface (NIC)** | VM's connection point to a subnet |
| **Public IP** | Publicly routable IP address |
| **Private IP** | Internal address within the VNet |

### Network Security Groups (NSGs)

NSGs filter inbound and outbound traffic using **security rules**.

#### NSG Rule Properties

| Property | Description |
|---|---|
| **Priority** | Lower number = higher priority (100–4096) |
| **Source/Destination** | IP address, CIDR, service tag, or ASG |
| **Protocol** | TCP, UDP, ICMP, or Any |
| **Port** | Single port, range, or * |
| **Action** | Allow or Deny |

#### Default NSG Rules

| Priority | Name | Direction | Action | Description |
|---|---|---|---|---|
| 65000 | AllowVnetInBound | Inbound | Allow | VNet to VNet traffic |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allow | Azure LB health probes |
| 65500 | DenyAllInBound | Inbound | Deny | Block all other inbound |
| 65000 | AllowVnetOutBound | Outbound | Allow | VNet outbound |
| 65001 | AllowInternetOutBound | Outbound | Allow | Internet outbound |
| 65500 | DenyAllOutBound | Outbound | Deny | Block all other outbound |

#### Create and Apply an NSG — Azure CLI

```bash
# Create NSG
az network nsg create \
  --name myNSG \
  --resource-group myRG \
  --location eastus

# Add inbound rule to deny SSH from internet (priority 200)
az network nsg rule create \
  --nsg-name myNSG \
  --resource-group myRG \
  --name DenySSHFromInternet \
  --priority 200 \
  --source-address-prefixes Internet \
  --destination-port-ranges 22 \
  --protocol Tcp \
  --access Deny \
  --direction Inbound

# Associate NSG with a subnet
az network vnet subnet update \
  --name mySubnet \
  --vnet-name myVNet \
  --resource-group myRG \
  --network-security-group myNSG
```

### Application Security Groups (ASGs)

ASGs allow you to group VMs logically and apply NSG rules to the group — without managing individual IPs.

```bash
# Create ASG
az network asg create --name webServers --resource-group myRG

# Reference ASG in NSG rule
az network nsg rule create \
  --nsg-name myNSG \
  --resource-group myRG \
  --name AllowWebToApp \
  --priority 100 \
  --source-asgs webServers \
  --destination-asgs appServers \
  --destination-port-ranges 8080 \
  --protocol Tcp \
  --access Allow \
  --direction Inbound
```

---

## 2.2 Plan and Implement Security for Private Access to Azure Resources

### Azure Private Link & Private Endpoints

**Private Endpoint**: A network interface in your VNet that provides a private IP address for an Azure PaaS service (Storage, SQL, Key Vault, etc.).

**Private Link**: The service that powers private endpoints.

```bash
# Create private endpoint for a Storage Account
az network private-endpoint create \
  --name myStoragePE \
  --resource-group myRG \
  --vnet-name myVNet \
  --subnet mySubnet \
  --private-connection-resource-id \
    "/subscriptions/<sub-id>/resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/mystorageacct" \
  --group-id blob \
  --connection-name myConnection
```

**Private DNS Zone**: Required to resolve the private endpoint's hostname to its private IP.

```bash
# Create private DNS zone
az network private-dns zone create \
  --name "privatelink.blob.core.windows.net" \
  --resource-group myRG

# Link to VNet
az network private-dns link vnet create \
  --zone-name "privatelink.blob.core.windows.net" \
  --resource-group myRG \
  --name myDnsLink \
  --virtual-network myVNet \
  --registration-enabled false
```

### Service Endpoints

Service endpoints extend VNet identity to Azure services over the Azure backbone (traffic stays on Azure network, but the service's public IP is used).

> **Note**: Private Endpoints are preferred over Service Endpoints for stronger isolation.

```bash
az network vnet subnet update \
  --name mySubnet \
  --vnet-name myVNet \
  --resource-group myRG \
  --service-endpoints Microsoft.Storage Microsoft.KeyVault
```

### VNet Integration for App Services

Azure App Services can be integrated with a VNet to access private resources:
- **Regional VNet Integration**: App can access resources in the same region's VNet
- **Gateway-required VNet Integration**: Access resources in different regions or classic VNets

---

## 2.3 Plan and Implement Security for Public Access to Azure Resources

### Azure Firewall

Azure Firewall is a managed, cloud-native network security service providing stateful inspection.

| Feature | Description |
|---|---|
| **FQDN Filtering** | Allow/deny traffic based on fully qualified domain names |
| **Application Rules** | Layer 7 HTTP/HTTPS/MSSQL filtering |
| **Network Rules** | Layer 4 IP/port/protocol filtering |
| **NAT Rules** | DNAT for inbound traffic to private resources |
| **Threat Intelligence** | Block known malicious IPs and domains |
| **DNS Proxy** | Resolve FQDNs via custom DNS servers |
| **IDPS** (Premium) | Intrusion Detection and Prevention System |
| **TLS Inspection** (Premium) | Inspect encrypted HTTPS traffic |

#### Deploy Azure Firewall — Azure CLI

```bash
# Create Firewall subnet (must be named AzureFirewallSubnet)
az network vnet subnet create \
  --name AzureFirewallSubnet \
  --vnet-name myVNet \
  --resource-group myRG \
  --address-prefix 10.0.1.0/26

# Create public IP for firewall
az network public-ip create \
  --name myFWPublicIP \
  --resource-group myRG \
  --sku Standard \
  --allocation-method Static

# Create firewall
az network firewall create \
  --name myFirewall \
  --resource-group myRG \
  --location eastus \
  --sku AZFW_VNet \
  --tier Standard
```

### Azure Firewall Policy vs Classic Rules

| | Firewall Policy | Classic Rules |
|---|---|---|
| **Management** | Centralized (Firewall Manager) | Per firewall |
| **Hierarchy** | Parent/child policies | None |
| **Recommended for** | New deployments | Legacy deployments |

### Azure Web Application Firewall (WAF)

WAF protects web applications from common exploits (OWASP Top 10).

| Deployment | Description |
|---|---|
| **WAF on Azure Application Gateway** | Regional protection, SSL termination |
| **WAF on Azure Front Door** | Global protection, CDN integration |
| **WAF on Azure CDN** | Edge-based protection (Microsoft CDN) |

#### WAF Modes

| Mode | Behavior |
|---|---|
| **Detection** | Log threats but do not block |
| **Prevention** | Log and block threats |

```bash
# Create WAF policy
az network application-gateway waf-policy create \
  --name myWAFPolicy \
  --resource-group myRG \
  --location eastus

# Set WAF policy to Prevention mode
az network application-gateway waf-policy policy-setting update \
  --policy-name myWAFPolicy \
  --resource-group myRG \
  --mode Prevention \
  --state Enabled
```

### Azure DDoS Protection

| Plan | Description |
|---|---|
| **DDoS Network Protection** | Enhanced mitigation, cost protection, attack analytics, expert support |
| **DDoS IP Protection** | Pay-per-protected-IP, subset of Network Protection features |
| **Basic (Free)** | Automatically enabled for all Azure resources (limited protection) |

```bash
# Create DDoS Protection Plan
az network ddos-protection create \
  --name myDDoSPlan \
  --resource-group myRG \
  --location eastus

# Enable on a VNet
az network vnet update \
  --name myVNet \
  --resource-group myRG \
  --ddos-protection-plan myDDoSPlan \
  --ddos-protection true
```

---

## 2.4 Plan and Implement Advanced Network Security

### Azure Bastion

Azure Bastion provides secure RDP/SSH to VMs **without exposing public IPs**.

```bash
# Deploy Bastion (subnet must be named AzureBastionSubnet, /27 or larger)
az network bastion create \
  --name myBastion \
  --public-ip-address myBastionIP \
  --resource-group myRG \
  --vnet-name myVNet \
  --location eastus \
  --sku Standard
```

> **Exam Tip**: Azure Bastion protects against port scanning from the internet and eliminates the need to manage jump boxes.

### Just-in-Time (JIT) VM Access

JIT (via Microsoft Defender for Cloud) opens management ports (RDP/SSH) only when requested, for a limited time.

```
Defender for Cloud → Workload protections → Just-in-time VM access
  → Select VM → Enable JIT
  → Configure: ports (22, 3389), max duration, allowed source IPs
```

### User-Defined Routes (UDRs) — Force Tunneling

Force internet-bound traffic through Azure Firewall (or on-premises via VPN):

```bash
# Create route table
az network route-table create \
  --name myRouteTable \
  --resource-group myRG

# Add route to send all traffic through firewall
az network route-table route create \
  --route-table-name myRouteTable \
  --resource-group myRG \
  --name ForceToFirewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address 10.0.1.4   # Firewall private IP

# Associate with subnet
az network vnet subnet update \
  --name mySubnet \
  --vnet-name myVNet \
  --resource-group myRG \
  --route-table myRouteTable
```

### VPN Gateway Security

| Type | Description |
|---|---|
| **Site-to-Site (S2S) VPN** | Connect on-premises network to Azure via IPsec/IKE tunnel |
| **Point-to-Site (P2S) VPN** | Individual client connections to Azure VNet |
| **ExpressRoute** | Private, dedicated circuit to Azure (not over public internet) |

```bash
# Create VPN Gateway (takes 30-45 minutes)
az network vnet-gateway create \
  --name myVPNGateway \
  --resource-group myRG \
  --vnet myVNet \
  --gateway-type Vpn \
  --vpn-type RouteBased \
  --sku VpnGw1 \
  --public-ip-addresses myGatewayIP
```

---

## 2.5 Monitor and Troubleshoot Network Security

### Network Watcher

Azure Network Watcher provides tools to monitor, diagnose, and analyze network traffic.

| Tool | Purpose |
|---|---|
| **IP Flow Verify** | Check if traffic is allowed/denied by NSG rules |
| **NSG Diagnostics** | Analyze all NSG rules affecting a flow |
| **Connection Monitor** | End-to-end connectivity monitoring |
| **Packet Capture** | Capture VM network traffic for analysis |
| **Next Hop** | Determine next routing hop for a packet |
| **Flow Logs** | Log all IP traffic flowing through an NSG |

```bash
# Enable NSG flow logs
az network watcher flow-log create \
  --resource-group myRG \
  --name myFlowLog \
  --nsg myNSG \
  --storage-account mystorageacct \
  --enabled true \
  --format JSON \
  --log-version 2
```

### Azure Monitor — Network Insights

Azure Monitor Network Insights provides a unified view of network topology, connectivity, and traffic.

---

## 📝 Exam Tips — Domain 2

1. **NSG vs Azure Firewall**: NSGs are stateful and operate at L3/L4. Azure Firewall adds L7 (FQDN filtering, application rules, IDPS).
2. **Private Endpoint vs Service Endpoint**: Private Endpoint assigns a private IP in your VNet (stronger isolation). Service Endpoint routes traffic over Azure backbone but still uses public IPs.
3. **Azure Bastion**: Eliminates need for public IPs on VMs and jump boxes. Requires dedicated `/27` subnet named `AzureBastionSubnet`.
4. **DDoS Basic vs Standard/Network Protection**: Basic is free and always on; Network Protection adds telemetry, rapid response, and cost guarantees.
5. **Force Tunneling**: Use UDR with `0.0.0.0/0 → Azure Firewall` to inspect all outbound internet traffic.
6. **JIT Access**: Available with Defender for Servers Plan 2. Opens ports only on demand for a limited time.
7. **WAF Modes**: Start in **Detection** mode to baseline, then switch to **Prevention** mode.

---

## 🔗 References

- [Azure Network Security Documentation](https://learn.microsoft.com/en-us/azure/networking/security/)
- [NSG Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Firewall Documentation](https://learn.microsoft.com/en-us/azure/firewall/)
- [Azure DDoS Protection](https://learn.microsoft.com/en-us/azure/ddos-protection/)
- [Azure Private Link](https://learn.microsoft.com/en-us/azure/private-link/)

---

> ⬅️ [Domain 1: Identity and Access](./01-identity-and-access.md) | ➡️ [Domain 3: Compute, Storage & Databases](./03-compute-storage-databases.md)
