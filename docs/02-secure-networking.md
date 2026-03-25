# Domain 2: Secure Networking
## AZ-500 Microsoft Azure Security Technologies Study Guide

**Exam Weight: 20–25%**

---

## Table of Contents

1. [Virtual Network Security](#1-virtual-network-security)
2. [Azure Firewall](#2-azure-firewall)
3. [Azure DDoS Protection](#3-azure-ddos-protection)
4. [Azure VPN Gateway and ExpressRoute Security](#4-azure-vpn-gateway-and-expressroute-security)
5. [Web Application Firewall (WAF)](#5-web-application-firewall-waf)
6. [Network Monitoring and Diagnostics](#6-network-monitoring-and-diagnostics)
7. [Azure Bastion](#7-azure-bastion)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AZURE NETWORK SECURITY LAYERS                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Internet Traffic                                                            │
│       │                                                                      │
│       ▼                                                                      │
│  ┌──────────┐    ┌──────────────────┐    ┌────────────────────┐             │
│  │  DDoS    │    │   WAF (Front     │    │   WAF (App         │             │
│  │Protection│    │   Door / CDN)    │    │   Gateway v2)      │             │
│  └────┬─────┘    └────────┬─────────┘    └──────────┬─────────┘             │
│       │                   │                          │                       │
│       └───────────────────┴──────────────────────────┘                      │
│                                    │                                         │
│                                    ▼                                         │
│                         ┌──────────────────┐                                │
│                         │  Azure Firewall  │  (central egress/ingress)       │
│                         │  (Premium/Std)   │                                │
│                         └────────┬─────────┘                                │
│                                  │                                           │
│              ┌───────────────────┼───────────────────┐                      │
│              │                   │                   │                       │
│              ▼                   ▼                   ▼                       │
│       ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│       │  VNet A     │    │  VNet B     │    │  VNet C     │                 │
│       │  (Hub)      │◄──►│  (Spoke 1)  │    │  (Spoke 2)  │                 │
│       │  ┌───────┐  │    │  ┌───────┐  │    │  ┌───────┐  │                 │
│       │  │  NSG  │  │    │  │  NSG  │  │    │  │  NSG  │  │                 │
│       │  └───────┘  │    │  └───────┘  │    │  └───────┘  │                 │
│       └─────────────┘    └─────────────┘    └─────────────┘                 │
│                                  │                                           │
│                         ┌────────┴────────┐                                 │
│                         │  Azure Bastion  │  (secure RDP/SSH)               │
│                         └─────────────────┘                                 │
│                                                                              │
│  On-Premises ◄──────── VPN Gateway / ExpressRoute ──────────────────────►  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Virtual Network Security

### 1.1 Network Security Groups (NSGs)

NSGs are stateful packet filters that control inbound and outbound traffic to Azure resources. They can be applied to **subnets** and/or **individual NICs** (Network Interface Cards).

#### NSG Rule Components

| Field | Description |
|---|---|
| Priority | 100–4096; lower number = higher priority; first match wins |
| Name | Unique identifier within the NSG |
| Protocol | TCP, UDP, ICMP, ESP, AH, or Any |
| Direction | Inbound or Outbound |
| Source | IP address, CIDR, Service Tag, or ASG |
| Source Port Ranges | Specific port(s) or * for all |
| Destination | IP address, CIDR, Service Tag, or ASG |
| Destination Port Ranges | Specific port(s) or * for all |
| Action | Allow or Deny |

#### Default NSG Rules (Cannot be deleted, priority 65000+)

**Default Inbound Rules:**

| Priority | Name | Source | Destination | Port | Action |
|---|---|---|---|---|---|
| 65000 | AllowVnetInBound | VirtualNetwork | VirtualNetwork | Any | Allow |
| 65001 | AllowAzureLoadBalancerInBound | AzureLoadBalancer | Any | Any | Allow |
| 65500 | DenyAllInBound | Any | Any | Any | **Deny** |

**Default Outbound Rules:**

| Priority | Name | Source | Destination | Port | Action |
|---|---|---|---|---|---|
| 65000 | AllowVnetOutBound | VirtualNetwork | VirtualNetwork | Any | Allow |
| 65001 | AllowInternetOutBound | Any | Internet | Any | Allow |
| 65500 | DenyAllOutBound | Any | Any | Any | **Deny** |

> **📝 Exam Tip:** Default rules **cannot be deleted** but can be overridden by creating rules with a **lower priority number** (higher priority). The `DenyAllInBound` rule at 65500 means all inbound traffic is blocked unless explicitly allowed.

> **📝 Exam Trap:** NSGs are **stateful** — if you allow inbound traffic on port 443, the return traffic is automatically allowed even without an explicit outbound rule. You do NOT need separate inbound and outbound rules for the same connection.

#### Service Tags

Service Tags represent groups of IP address prefixes for Azure services, reducing rule complexity.

| Service Tag | Represents |
|---|---|
| `VirtualNetwork` | All VNet address spaces, peered VNets, connected on-prem |
| `AzureLoadBalancer` | Azure load balancer health probe IPs |
| `Internet` | All public IP addresses (outside VirtualNetwork) |
| `AzureCloud` | All Azure datacenter IPs |
| `Storage` | Azure Storage service IPs |
| `Sql` | Azure SQL Database / Synapse IPs |
| `AppService` | Azure App Service outbound IPs |
| `AzureMonitor` | Log Analytics, App Insights, etc. |
| `GatewayManager` | Azure Gateway Manager (needed for VPN/App Gateway) |

**NSG Management Commands:**

```bash
# Create an NSG
az network nsg create \
  --name "myNSG" \
  --resource-group "myRG" \
  --location "eastus"

# Add an inbound rule to allow HTTPS
az network nsg rule create \
  --name "AllowHTTPS" \
  --nsg-name "myNSG" \
  --resource-group "myRG" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "*" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 443

# Associate NSG with a subnet
az network vnet subnet update \
  --name "mySubnet" \
  --vnet-name "myVNet" \
  --resource-group "myRG" \
  --network-security-group "myNSG"

# Associate NSG with a NIC
az network nic update \
  --name "myNIC" \
  --resource-group "myRG" \
  --network-security-group "myNSG"

# View effective security rules for a NIC
az network nic show-effective-nsg \
  --name "myNIC" \
  --resource-group "myRG"
```

```powershell
# Create NSG with rules
$httpsRule = New-AzNetworkSecurityRuleConfig `
  -Name "AllowHTTPS" `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 100 `
  -SourceAddressPrefix "*" `
  -SourcePortRange "*" `
  -DestinationAddressPrefix "*" `
  -DestinationPortRange 443 `
  -Access Allow

$nsg = New-AzNetworkSecurityGroup `
  -Name "myNSG" `
  -ResourceGroupName "myRG" `
  -Location "eastus" `
  -SecurityRules $httpsRule

# Get effective NSG rules for a VM NIC
Get-AzEffectiveNetworkSecurityGroup `
  -NetworkInterfaceName "myNIC" `
  -ResourceGroupName "myRG"
```

### 1.2 Application Security Groups (ASGs)

ASGs allow you to group VMs by application role and write NSG rules referencing those groups instead of specific IP addresses. This eliminates hard-coded IPs in rules.

```
Without ASGs:                    With ASGs:
Allow TCP 1433 from              Allow TCP 1433 from
  10.0.1.4 (web1)                 [WebServers ASG]
  10.0.1.5 (web2)                 to [DatabaseServers ASG]
  10.0.1.6 (web3)
  to 10.0.2.10 (db1)
  to 10.0.2.11 (db2)
```

```bash
# Create ASGs
az network asg create --name "WebServers" --resource-group "myRG" --location "eastus"
az network asg create --name "DatabaseServers" --resource-group "myRG" --location "eastus"

# Create NSG rule using ASGs
az network nsg rule create \
  --name "AllowWebToDb" \
  --nsg-name "myNSG" \
  --resource-group "myRG" \
  --priority 200 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-asgs "WebServers" \
  --source-port-ranges "*" \
  --destination-asgs "DatabaseServers" \
  --destination-port-ranges 1433

# Assign a NIC to an ASG
az network nic ip-config update \
  --name "ipconfig1" \
  --nic-name "webVM1-NIC" \
  --resource-group "myRG" \
  --application-security-groups "WebServers"
```

> **📝 Exam Tip:** ASG members must be in the **same VNet** as the ASG. A NIC can belong to multiple ASGs. ASGs work within the same region.

### 1.3 Service Endpoints vs Private Endpoints

| Feature | Service Endpoints | Private Endpoints |
|---|---|---|
| Traffic routing | Stays on Azure backbone, exits VNet | All within VNet (RFC 1918 IP) |
| Service IP | Still public IP of the service | Private IP from your VNet |
| DNS changes needed | No | Yes (private DNS zone) |
| Network Policies | NSG not applied to endpoint | NSG can be applied (with policy enabled) |
| Cost | Free | Per-hour + data processing charge |
| Granularity | Per service type | Per specific resource instance |
| Accessible from on-prem | ❌ | ✅ (via VPN/ExpressRoute) |
| Exfiltration protection | Limited | Strong (access specific resource only) |

```bash
# Enable Service Endpoint for Azure Storage on a subnet
az network vnet subnet update \
  --name "mySubnet" \
  --vnet-name "myVNet" \
  --resource-group "myRG" \
  --service-endpoints "Microsoft.Storage"

# Create a Private Endpoint for a Storage Account
az network private-endpoint create \
  --name "myStoragePE" \
  --resource-group "myRG" \
  --vnet-name "myVNet" \
  --subnet "mySubnet" \
  --private-connection-resource-id "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/mystorage" \
  --group-ids "blob" \
  --connection-name "myStorageConnection"

# Create Private DNS Zone for the endpoint
az network private-dns zone create \
  --name "privatelink.blob.core.windows.net" \
  --resource-group "myRG"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --name "myDNSLink" \
  --resource-group "myRG" \
  --zone-name "privatelink.blob.core.windows.net" \
  --virtual-network "myVNet" \
  --registration-enabled false

# Create DNS record for the private endpoint
az network private-endpoint dns-zone-group create \
  --name "myZoneGroup" \
  --endpoint-name "myStoragePE" \
  --resource-group "myRG" \
  --private-dns-zone "privatelink.blob.core.windows.net" \
  --zone-name "privatelink.blob.core.windows.net"
```

> **📝 Exam Tip:** **Private Endpoints** are preferred over Service Endpoints for maximum security because:
> 1. Traffic uses a private IP (never leaves VNet via public IP)
> 2. Accessible from on-premises (via VPN/ExpressRoute)
> 3. Provides data exfiltration prevention (only the specific resource is accessible)

> **📝 Exam Trap:** After creating a Private Endpoint, you must configure **Private DNS** — otherwise DNS resolution still returns the public IP. The `privatelink.*` DNS zones must be linked to the VNet.

### 1.4 VNet Peering Security Considerations

VNet peering connects two VNets at the Azure backbone level — traffic does NOT go through the public internet.

**Peering Properties:**

| Property | Description | Default |
|---|---|---|
| Allow virtual network access | Allows traffic between the VNets | Enabled |
| Allow forwarded traffic | Accepts traffic forwarded from (not originating in) remote VNet | Disabled |
| Allow gateway transit | Remote VNet can use this VNet's VPN gateway | Disabled |
| Use remote gateways | Connect through remote VNet's gateway | Disabled |

```bash
# Create VNet peering (must create peering in BOTH directions)
# Peer from VNet-A to VNet-B
az network vnet peering create \
  --name "VNetA-to-VNetB" \
  --resource-group "myRG" \
  --vnet-name "VNet-A" \
  --remote-vnet "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Network/virtualNetworks/VNet-B" \
  --allow-vnet-access true \
  --allow-forwarded-traffic false

# Peer from VNet-B to VNet-A (required for bidirectional)
az network vnet peering create \
  --name "VNetB-to-VNetA" \
  --resource-group "myRG" \
  --vnet-name "VNet-B" \
  --remote-vnet "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Network/virtualNetworks/VNet-A" \
  --allow-vnet-access true
```

> **📝 Exam Trap:** VNet peering is **non-transitive** by default. If VNet-A is peered with VNet-B, and VNet-B is peered with VNet-C, traffic from VNet-A **cannot** reach VNet-C directly. To enable transitive routing, use **Azure Firewall** or **Network Virtual Appliance (NVA)** as a hub.

### 1.5 Azure Virtual Network Manager

Azure Virtual Network Manager (AVNM) provides centralized management of VNet connectivity and security policies at scale.

```
AVNM Components:
  ├── Network Groups (logical grouping of VNets)
  ├── Connectivity Configurations
  │     ├── Hub-and-Spoke topology
  │     └── Mesh topology
  └── Security Admin Rules
        ├── Always Allowed (high-priority allow rules, cannot be overridden by NSG)
        ├── Always Denied (high-priority deny rules, cannot be overridden by NSG)
        └── Applied before/after NSG rules
```

> **📝 Exam Tip:** AVNM **Security Admin Rules** can be set to **Always Allow** or **Always Deny**, which **override NSG rules**. This is useful for enforcing organization-wide security policies that cannot be circumvented at the individual NSG level.

---

## 2. Azure Firewall

Azure Firewall is a managed, cloud-native, stateful firewall service with built-in HA and unlimited cloud scalability.

### 2.1 Azure Firewall Standard vs Premium

| Feature | Standard | Premium |
|---|---|---|
| DNAT rules | ✅ | ✅ |
| Network rules | ✅ | ✅ |
| Application rules (FQDN filtering) | ✅ | ✅ |
| Threat Intelligence | ✅ (Alert/Deny mode) | ✅ (Alert/Deny mode) |
| IDPS (Intrusion Detection & Prevention) | ❌ | ✅ |
| TLS Inspection | ❌ | ✅ |
| URL Filtering | ❌ | ✅ |
| Web Categories | ❌ | ✅ |
| Certificate authority integration | ❌ | ✅ |

> **📝 Exam Tip:** If the exam asks about **IDPS**, **TLS inspection**, or **URL filtering** — that's **Azure Firewall Premium**. Standard only does FQDN filtering in Application rules (not full URL path inspection).

### 2.2 Rule Types and Processing Order

```
Rule Processing Order:
  1. DNAT Rules      → Translate inbound public IPs to internal
  2. Network Rules   → L3/L4 allow/deny (IP, port, protocol)
  3. Application Rules → FQDN-based filtering (HTTP/HTTPS/MSSQL)

Within each rule collection:
  ├── Rule Collections have a Priority (lower = higher priority)
  ├── First matching rule wins
  └── Default deny if no rule matches
```

#### DNAT Rules (Destination Network Address Translation)

Used to forward inbound internet traffic to internal resources.

```
Example: Translate inbound traffic on firewall public IP:3389
         to internal VM at 10.0.1.4:3389

Rule:
  Name: AllowRDPToWebVM
  Source: * (or specific IP)
  Protocol: TCP
  Destination ports: 3389
  Translated Address: 10.0.1.4
  Translated Port: 3389
```

#### Network Rules

L3/L4 rules applied to all traffic not matched by DNAT rules.

```bash
# Add a network rule collection to an Azure Firewall Policy
az network firewall policy rule-collection-group collection add-filter-collection \
  --name "NetworkRules" \
  --collection-priority 100 \
  --policy-name "myFirewallPolicy" \
  --resource-group "myRG" \
  --rcg-name "DefaultNetworkRuleCollectionGroup" \
  --action Allow \
  --rule-name "AllowDNS" \
  --rule-type NetworkRule \
  --source-addresses "10.0.0.0/16" \
  --destination-addresses "8.8.8.8" "8.8.4.4" \
  --ip-protocols UDP \
  --destination-ports 53
```

#### Application Rules

FQDN-based rules for outbound HTTP/HTTPS and MSSQL traffic.

```bash
# Add an application rule collection
az network firewall policy rule-collection-group collection add-filter-collection \
  --name "AppRules" \
  --collection-priority 200 \
  --policy-name "myFirewallPolicy" \
  --resource-group "myRG" \
  --rcg-name "DefaultApplicationRuleCollectionGroup" \
  --action Allow \
  --rule-name "AllowWindowsUpdate" \
  --rule-type ApplicationRule \
  --source-addresses "10.0.0.0/16" \
  --protocols Http=80 Https=443 \
  --target-fqdns "*.windowsupdate.microsoft.com" "*.update.microsoft.com"
```

### 2.3 Azure Firewall Manager and Policies

**Firewall Policies** separate rule management from the firewall instances, enabling consistent policies across multiple firewalls.

```
Firewall Policy Hierarchy:
  Parent Policy (base rules: org-wide)
      └── Child Policy (department-specific rules)
              └── Azure Firewall Instance(s)

Child policy INHERITS all rules from parent.
Child can ADD additional rules but CANNOT override parent rules.
```

```bash
# Create a Firewall Policy
az network firewall policy create \
  --name "myFirewallPolicy" \
  --resource-group "myRG" \
  --location "eastus" \
  --sku "Premium" \
  --threat-intel-mode "Deny"

# Create Azure Firewall using the policy
az network firewall create \
  --name "myFirewall" \
  --resource-group "myRG" \
  --location "eastus" \
  --sku AZFW_VNet \
  --tier Premium \
  --firewall-policy "myFirewallPolicy" \
  --vnet-name "myHubVNet"
```

### 2.4 Threat Intelligence-Based Filtering

Azure Firewall integrates with Microsoft's Threat Intelligence feed to alert on or block traffic from/to known malicious IP addresses and FQDNs.

| Mode | Behavior |
|---|---|
| Off | Disabled |
| Alert only | Log when matching known bad IPs/FQDNs |
| Alert and Deny | Block AND log known bad IPs/FQDNs |

> **📝 Exam Tip:** Threat Intelligence operates at the **highest priority** in Azure Firewall — it is processed **before** all rule collections. This means it can block traffic even if an explicit allow rule exists.

### 2.5 IDPS (Azure Firewall Premium)

IDPS monitors network traffic for malicious activity using signature-based detection.

```
IDPS Modes:
  ├── Off
  ├── Alert — Detect and log, but allow traffic
  └── Alert and Deny — Detect, log, and block traffic

IDPS Profile (sensitivity):
  ├── Low — Fewer false positives, higher miss rate
  ├── Medium — Balanced
  └── High — More detections, higher false positive risk
```

```bash
# Configure IDPS on Firewall Premium Policy
az rest --method PATCH \
  --uri "https://management.azure.com/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Network/firewallPolicies/myFirewallPolicy?api-version=2023-04-01" \
  --body '{
    "properties": {
      "intrusionDetection": {
        "mode": "Deny",
        "configuration": {
          "signatureOverrides": [],
          "bypassTrafficSettings": []
        }
      }
    }
  }'
```

### 2.6 Forced Tunneling

Forced tunneling routes all internet-bound traffic through Azure Firewall (or on-premises) for inspection and logging.

```
Default (no forced tunneling):
  VM → Internet (direct, bypasses firewall for Azure services)

With forced tunneling:
  VM → Azure Firewall (inspect/log all traffic) → Internet

UDR (User-Defined Route) required:
  Route: 0.0.0.0/0 → Next hop: Azure Firewall private IP
```

```bash
# Create a route table for forced tunneling through Azure Firewall
az network route-table create \
  --name "ForceTunnelRT" \
  --resource-group "myRG" \
  --location "eastus" \
  --disable-bgp-route-propagation false

# Add default route pointing to Azure Firewall
az network route-table route create \
  --name "ForceTunnelToFirewall" \
  --route-table-name "ForceTunnelRT" \
  --resource-group "myRG" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address "10.0.1.4"  # Azure Firewall private IP

# Associate route table with subnet
az network vnet subnet update \
  --name "WorkloadSubnet" \
  --vnet-name "myVNet" \
  --resource-group "myRG" \
  --route-table "ForceTunnelRT"
```

> **📝 Exam Trap:** When using Azure Firewall with forced tunneling, the firewall needs a **dedicated management subnet** named `AzureFirewallManagementSubnet` — this allows management traffic to bypass the forced tunnel and reach Azure management endpoints.

---

## 3. Azure DDoS Protection

### 3.1 DDoS Protection Tiers

| Feature | DDoS Network Protection (Standard) | DDoS IP Protection | Infrastructure (Free) |
|---|---|---|---|
| Always-on monitoring | ✅ | ✅ | ✅ (basic) |
| Automatic attack mitigation | ✅ | ✅ | ✅ (basic) |
| Adaptive tuning | ✅ | ✅ | ❌ |
| Attack mitigation reports | ✅ | ✅ | ❌ |
| Metrics and alerts | ✅ | ✅ | ❌ |
| DDoS Rapid Response (DRR) | ✅ | ❌ | ❌ |
| Cost protection (service credit) | ✅ | ❌ | ❌ |
| Scope | All public IPs in VNet | Per public IP | All Azure |
| Cost | ~$2,944/month per VNet + data | ~$199/month per IP | Free |

> **📝 Exam Tip:** The **free DDoS Infrastructure Protection** is always on for all Azure customers but provides only basic layer 3/4 protection. **DDoS Network Protection** (formerly "Standard") adds adaptive policies, detailed telemetry, DRR access, and SLA-backed cost protection.

> **📝 Exam Trap:** DDoS Protection does **NOT** protect at the application layer (Layer 7) — that's the job of **WAF**. DDoS protects against volumetric and protocol attacks; WAF protects against application-layer attacks (SQL injection, XSS, etc.).

### 3.2 Protected Resources

DDoS Network Protection protects all public IP addresses in the associated VNets:
- Azure VM public IPs
- Azure Load Balancer public IPs
- Azure Application Gateway public IPs
- Azure Firewall public IPs
- Azure VPN Gateway public IPs
- Azure Front Door (has separate DDoS protection)

```bash
# Create a DDoS Protection Plan
az network ddos-protection create \
  --name "myDDoSPlan" \
  --resource-group "myRG" \
  --location "eastus"

# Associate VNet with DDoS Protection Plan
az network vnet update \
  --name "myVNet" \
  --resource-group "myRG" \
  --ddos-protection true \
  --ddos-protection-plan "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Network/ddosProtectionPlans/myDDoSPlan"
```

```powershell
# Create DDoS Protection Plan
$ddosPlan = New-AzDdosProtectionPlan `
  -Name "myDDoSPlan" `
  -ResourceGroupName "myRG" `
  -Location "eastus"

# Enable DDoS Protection on VNet
$vnet = Get-AzVirtualNetwork -Name "myVNet" -ResourceGroupName "myRG"
$vnet.DdosProtectionPlan = New-Object Microsoft.Azure.Commands.Network.Models.PSResourceId
$vnet.DdosProtectionPlan.Id = $ddosPlan.Id
$vnet.EnableDdosProtection = $true
Set-AzVirtualNetwork -VirtualNetwork $vnet
```

### 3.3 DDoS Alerts and Metrics

Key metrics available with DDoS Network Protection:

| Metric | Description |
|---|---|
| Under DDoS attack or not | Binary indicator — attack detected |
| Inbound packets dropped DDoS | Packets blocked during mitigation |
| Inbound TCP packets to trigger DDoS mitigation | TCP traffic threshold |
| Inbound UDP packets to trigger DDoS mitigation | UDP traffic threshold |
| TCP bytes dropped DDoS | Volume of dropped TCP traffic |

```bash
# Create an alert for DDoS attack detection
az monitor metrics alert create \
  --name "DDoSAttackAlert" \
  --resource-group "myRG" \
  --scopes "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Network/publicIPAddresses/myPublicIP" \
  --condition "avg ifUnderDDoSAttack > 0" \
  --description "Alert when DDoS attack is detected" \
  --evaluation-frequency 5m \
  --window-size 5m \
  --severity 1 \
  --action "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Insights/actionGroups/SecurityTeam"
```

### 3.4 DDoS Rapid Response (DRR)

Available with **DDoS Network Protection** — Microsoft's DDoS expert team can be engaged during an active attack.

- Available 24/7 via support ticket
- Provides attack analysis and recommendations
- Helps fine-tune mitigation policies
- Not available with DDoS IP Protection or free tier

---

## 4. Azure VPN Gateway and ExpressRoute Security

### 4.1 VPN Gateway SKUs

| SKU | Throughput | BGP | Zone Redundant | Active-Active | Use Case |
|---|---|---|---|---|---|
| Basic | 100 Mbps | ❌ | ❌ | ❌ | Dev/test only |
| VpnGw1 | 650 Mbps | ✅ | ❌ | ✅ | Small production |
| VpnGw2 | 1 Gbps | ✅ | ❌ | ✅ | Medium production |
| VpnGw3 | 1.25 Gbps | ✅ | ❌ | ✅ | Large production |
| VpnGw1AZ | 650 Mbps | ✅ | ✅ | ✅ | Zone-redundant |
| VpnGw2AZ | 1 Gbps | ✅ | ✅ | ✅ | Zone-redundant |
| VpnGw3AZ | 1.25 Gbps | ✅ | ✅ | ✅ | Zone-redundant |

> **📝 Exam Tip:** The **Basic SKU** does not support BGP, IKEv2, or custom IPsec policies. Do NOT use it for production. For zone resiliency, use `*AZ` SKUs deployed in Availability Zones.

### 4.2 VPN Connection Types

#### Site-to-Site (S2S)

Connects on-premises network to Azure VNet over an encrypted IPsec/IKE tunnel.

```bash
# Create VPN Gateway (simplified)
az network vnet-gateway create \
  --name "myVPNGateway" \
  --resource-group "myRG" \
  --location "eastus" \
  --vnet "myVNet" \
  --gateway-type Vpn \
  --vpn-type RouteBased \
  --sku VpnGw2 \
  --public-ip-address "myGatewayPIP"

# Create Local Network Gateway (represents on-prem)
az network local-gateway create \
  --name "myOnPremGateway" \
  --resource-group "myRG" \
  --location "eastus" \
  --gateway-ip-address "203.0.113.10" \
  --address-prefixes "192.168.0.0/24"

# Create the VPN connection
az network vpn-connection create \
  --name "myVPNConnection" \
  --resource-group "myRG" \
  --vnet-gateway1 "myVPNGateway" \
  --location "eastus" \
  --shared-key "MyS3cur3Preshared!Key" \
  --local-gateway2 "myOnPremGateway"
```

#### Point-to-Site (P2S)

Connects individual client machines to Azure VNet. Used for remote workers.

**Authentication Methods:**

| Method | Certificate Type | Notes |
|---|---|---|
| Azure certificate | Client certificate | Most common; cert installed on each client |
| RADIUS | External RADIUS server | Integrates with on-prem NPS/AD |
| Azure AD (Entra ID) | OIDC/OAuth tokens | Supports Conditional Access; Windows/Mac/Linux |

```bash
# Configure P2S with Azure AD authentication
az network vnet-gateway update \
  --name "myVPNGateway" \
  --resource-group "myRG" \
  --vpn-auth-type AAD \
  --aad-tenant "https://login.microsoftonline.com/{tenant-id}" \
  --aad-audience "41b23e61-6c1e-4545-b367-cd054e0ed4b4" \
  --aad-issuer "https://sts.windows.net/{tenant-id}/"
```

> **📝 Exam Tip:** P2S with **Azure AD authentication** supports **Conditional Access** — you can require compliant devices or MFA before the VPN tunnel is established.

### 4.3 IPsec/IKE Policy

Custom IPsec policies allow you to enforce specific encryption algorithms (important for compliance).

```bash
# Create a custom IPsec policy
az network vpn-connection ipsec-policy add \
  --connection-name "myVPNConnection" \
  --resource-group "myRG" \
  --ike-encryption AES256 \
  --ike-integrity SHA256 \
  --ike-dh-group DHGroup14 \
  --ipsec-encryption AES256 \
  --ipsec-integrity SHA256 \
  --pfs-group PFS2048 \
  --sa-lifetime 27000 \
  --sa-max-size 102400000
```

### 4.4 ExpressRoute Security

ExpressRoute provides a private, dedicated connection to Azure — traffic DOES NOT traverse the public internet.

```
ExpressRoute Architecture:
  On-Premises ──────── Partner Edge ──────── Microsoft Edge
  (your network)   (circuit provider)     (Azure backbone)

Peering Types:
  ├── Private Peering → Connect to Azure VNets (RFC 1918 space)
  └── Microsoft Peering → Connect to Microsoft 365 and Azure PaaS services
```

**ExpressRoute Security Considerations:**

| Concern | Solution |
|---|---|
| Data in transit encryption | **MACsec** at Layer 2 (on ExpressRoute Direct) or **IPsec over ExpressRoute** |
| Private connectivity | ExpressRoute itself is private (no internet transit) |
| Redundancy | Two circuits (primary + secondary) recommended |
| BGP security | MD5 authentication on BGP sessions |

```bash
# Add IPsec over ExpressRoute (encrypt traffic on private connection)
az network vpn-connection create \
  --name "IPsecOverExpressRoute" \
  --resource-group "myRG" \
  --vnet-gateway1 "myVPNGateway" \
  --express-route-circuit2 "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Network/expressRouteCircuits/myCircuit" \
  --routing-weight 0
```

> **📝 Exam Trap:** ExpressRoute provides **network-level privacy** but traffic is **NOT encrypted by default**. To encrypt traffic over ExpressRoute, you must use **IPsec over ExpressRoute** or **MACsec** (on ExpressRoute Direct).

### 4.5 Forced Tunneling with VPN Gateway

Forces all internet traffic from VMs through the on-premises network (for inspection/filtering).

```
Normal routing:    VM → Internet (direct)
Forced tunneling:  VM → VPN Gateway → On-Premises → Internet

Implementation:
  ├── Custom route: 0.0.0.0/0 → VPN Gateway
  └── Default site configured on VPN connection

Note: Split tunneling allows some traffic to go directly to internet
      while routing specific traffic through VPN.
```

---

## 5. Web Application Firewall (WAF)

WAF protects web applications from common exploits (OWASP Top 10) at Layer 7.

### 5.1 WAF on Application Gateway vs Azure Front Door

| Feature | WAF on App Gateway | WAF on Azure Front Door |
|---|---|---|
| Deployment type | Regional | Global (CDN edge) |
| Latency impact | Minimal (same region) | Near-zero (edge PoP) |
| Backend type | IaaS/PaaS (any) | Any public endpoint |
| Custom rules | ✅ | ✅ |
| OWASP rules | CRS 3.0, 3.1, 3.2 | CRS 3.1, 3.2 (default ruleset) |
| Rate limiting | ❌ (in WAF) | ✅ |
| Geo-filtering | ❌ (in WAF) | ✅ |
| Bot protection | ✅ | ✅ |
| Per-rule exclusions | ✅ | ✅ |
| Request size limit | ✅ | ✅ |

### 5.2 WAF Modes

| Mode | Behavior | Logging |
|---|---|---|
| **Detection** | Inspect and LOG matches; do NOT block | Logs all detected threats |
| **Prevention** | Inspect, LOG, and **BLOCK** matches | Logs all detected and blocked threats |

> **📝 Exam Tip:** Always start WAF in **Detection mode** to monitor traffic patterns and tune rules before switching to **Prevention mode**. Switching directly to Prevention mode can cause false positives and block legitimate traffic.

### 5.3 OWASP Core Rule Sets (CRS)

| Rule Set | OWASP Version | Notes |
|---|---|---|
| CRS 3.0 | OWASP 3.0 | Legacy; still available on App Gateway |
| CRS 3.1 | OWASP 3.1 | Previous default |
| CRS 3.2 | OWASP 3.2 | Current recommended; reduced false positives |

**Key Rule Groups in OWASP CRS:**

| Rule Group ID | Protects Against |
|---|---|
| REQUEST-931-APPLICATION-ATTACK-RFI | Remote File Inclusion |
| REQUEST-932-APPLICATION-ATTACK-RCE | Remote Code Execution |
| REQUEST-933-APPLICATION-ATTACK-PHP | PHP Injection |
| REQUEST-941-APPLICATION-ATTACK-XSS | Cross-Site Scripting (XSS) |
| REQUEST-942-APPLICATION-ATTACK-SQLI | SQL Injection |
| REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION | Session Fixation |
| REQUEST-944-APPLICATION-ATTACK-JAVA | Java attacks |

### 5.4 WAF Custom Rules

Custom rules are processed **before** managed rule sets, with lower rule number = higher priority.

```bash
# Create WAF policy with custom rule (App Gateway)
az network application-gateway waf-policy create \
  --name "myWAFPolicy" \
  --resource-group "myRG" \
  --location "eastus"

# Add custom rule to block specific IP
az network application-gateway waf-policy custom-rule create \
  --name "BlockBadIP" \
  --policy-name "myWAFPolicy" \
  --resource-group "myRG" \
  --priority 10 \
  --rule-type MatchRule \
  --action Block \
  --match-conditions '[{
    "matchVariables": [{"variableName": "RemoteAddr"}],
    "operator": "IPMatch",
    "matchValues": ["198.51.100.0/24"]
  }]'

# Add custom rule to allow specific user agent (allow before block rules)
az network application-gateway waf-policy custom-rule create \
  --name "AllowGoodBot" \
  --policy-name "myWAFPolicy" \
  --resource-group "myRG" \
  --priority 5 \
  --rule-type MatchRule \
  --action Allow \
  --match-conditions '[{
    "matchVariables": [{"variableName": "RequestHeaders", "selector": "User-Agent"}],
    "operator": "Contains",
    "matchValues": ["GoogleBot"]
  }]'
```

**PowerShell — WAF Policy:**

```powershell
# Create WAF Policy for App Gateway
$wafPolicy = New-AzApplicationGatewayFirewallPolicy `
  -Name "myWAFPolicy" `
  -ResourceGroupName "myRG" `
  -Location "eastus"

# Get WAF policy and update managed rules to CRS 3.2
$ruleSet = New-AzApplicationGatewayFirewallPolicyManagedRuleSet `
  -RuleSetType "OWASP" `
  -RuleSetVersion "3.2"

$managedRules = New-AzApplicationGatewayFirewallPolicyManagedRule `
  -ManagedRuleSet $ruleSet

Set-AzApplicationGatewayFirewallPolicy `
  -InputObject $wafPolicy `
  -ManagedRule $managedRules
```

### 5.5 WAF Exclusions

Exclusions allow specific request elements to bypass WAF rules (used to reduce false positives).

```bash
# Add WAF exclusion for a specific request header that triggers false positives
az network application-gateway waf-policy managed-rule exclusion add \
  --policy-name "myWAFPolicy" \
  --resource-group "myRG" \
  --match-variable "RequestHeaderNames" \
  --selector-match-operator "Equals" \
  --selector "X-Custom-Auth-Header"
```

> **📝 Exam Trap:** WAF exclusions bypass WAF rules entirely for the matched elements. Use **per-rule exclusions** (available in newer CRS versions) instead of global exclusions to minimize the attack surface. Global exclusions exclude the matched element from ALL rules.

---

## 6. Network Monitoring and Diagnostics

### 6.1 Azure Network Watcher

Network Watcher is a regional service providing network monitoring, diagnostics, and logging tools.

**Key Capabilities:**

| Tool | Purpose |
|---|---|
| **IP Flow Verify** | Check if traffic is allowed/denied by NSG rules |
| **NSG Diagnostic** | Which NSG and rule is allowing/denying traffic |
| **Next Hop** | Determine the next hop for traffic from a VM |
| **Effective Security Rules** | View all NSG rules effective on a NIC |
| **VPN Troubleshoot** | Diagnose VPN gateway and connection issues |
| **Packet Capture** | Capture packets to/from a VM NIC |
| **Connection Monitor** | Continuously monitor connectivity between endpoints |
| **NSG Flow Logs** | Log all traffic flows through an NSG |
| **Traffic Analytics** | Visualize and analyze NSG flow log data |

```bash
# Enable Network Watcher in a region
az network watcher configure \
  --resource-group "NetworkWatcherRG" \
  --locations "eastus" \
  --enabled true

# Check if traffic is allowed (IP Flow Verify)
az network watcher test-ip-flow \
  --vm "myVM" \
  --resource-group "myRG" \
  --direction Inbound \
  --protocol TCP \
  --local-ip "10.0.1.4" \
  --local-port 80 \
  --remote-ip "203.0.113.100" \
  --remote-port 12345

# Get next hop for a packet
az network watcher show-next-hop \
  --vm "myVM" \
  --resource-group "myRG" \
  --source-ip "10.0.1.4" \
  --dest-ip "8.8.8.8"

# Start a packet capture
az network watcher packet-capture create \
  --name "myCapture" \
  --resource-group "myRG" \
  --vm "myVM" \
  --storage-account "mystorage" \
  --time-limit 300 \
  --filters '[{"protocol":"TCP","remoteIPAddress":"203.0.113.0/24","localPort":"80"}]'
```

### 6.2 NSG Flow Logs

NSG Flow Logs record all traffic flows (allowed and denied) through an NSG. Stored in Azure Storage and optionally processed by Traffic Analytics.

**Flow Log Format (Version 2):**

```json
{
  "time": "2024-01-15T10:30:00Z",
  "systemId": "...",
  "category": "NetworkSecurityGroupFlowEvent",
  "resourceId": "/SUBSCRIPTIONS/{sub-id}/RESOURCEGROUPS/myRG/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/myNSG",
  "operationName": "NetworkSecurityGroupFlowEvents",
  "properties": {
    "flows": [{
      "rule": "AllowHTTPS",
      "flows": [{
        "mac": "000D3A123456",
        "flowTuples": [
          "1705312200,203.0.113.100,10.0.1.4,52345,443,T,I,A,B,,,"
          //              ^src IP    ^dst IP  ^ports  ^proto ^dir ^action ^state
        ]
      }]
    }]
  }
}
```

```bash
# Enable NSG Flow Logs (v2)
az network watcher flow-log create \
  --name "myNSGFlowLog" \
  --resource-group "myRG" \
  --nsg "myNSG" \
  --storage-account "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/mystorage" \
  --enabled true \
  --format JSON \
  --log-version 2 \
  --retention 30

# Enable Traffic Analytics
az network watcher flow-log update \
  --name "myNSGFlowLog" \
  --resource-group "myRG" \
  --nsg "myNSG" \
  --workspace "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.OperationalInsights/workspaces/myWorkspace" \
  --traffic-analytics true \
  --interval 10
```

> **📝 Exam Tip:** NSG Flow Logs require a **Storage Account** for raw log storage. **Traffic Analytics** additionally requires a **Log Analytics Workspace**. Traffic Analytics provides visual dashboards and KQL query capabilities.

### 6.3 Connection Monitor

Connection Monitor provides end-to-end monitoring of network connections with multi-endpoint support.

```bash
# Create a Connection Monitor
az network watcher connection-monitor create \
  --name "myConnectionMonitor" \
  --resource-group "myRG" \
  --location "eastus" \
  --test-groups '[{
    "name": "WebApp-DB",
    "sources": [{
      "name": "WebVM",
      "type": "AzureVM",
      "resourceId": "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/WebVM"
    }],
    "destinations": [{
      "name": "DbServer",
      "type": "AzureVM",
      "resourceId": "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/DbServer"
    }],
    "testConfigurations": [{
      "name": "TCPTest",
      "protocol": "TCP",
      "tcpConfiguration": {"port": 1433}
    }]
  }]'
```

### 6.4 Traffic Analytics

Traffic Analytics processes NSG Flow Logs to provide insights through:
- Geo-map of traffic sources
- Blocked flows by NSG rules
- Top talkers
- Open ports exposed to internet
- Malicious traffic detection (based on Microsoft threat intelligence)

```
Traffic Analytics KQL Queries (Log Analytics):

// Top blocked traffic sources
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog" and FlowType_s == "MaliciousFlow"
| summarize BlockedFlows = count() by SrcIP_s
| top 10 by BlockedFlows

// Open ports exposed to internet
AzureNetworkAnalytics_CL
| where SubType_s == "Topology"
| where IsPublic_s == "true"
| project VMName_s, PublicIPAddress_s, DestPort_d
```

---

## 7. Azure Bastion

Azure Bastion provides secure, browser-based RDP and SSH access to VMs **without exposing public IPs or opening ports** to the internet.

### 7.1 Architecture

```
Traditional Access (INSECURE):               Azure Bastion (SECURE):
  Internet → NSG (port 3389/22 open)           Internet → Azure Portal/Browser
  → VM (public IP required)                    → Azure Bastion (HTTPS 443 only)
                                               → VM (NO public IP required)
                                               → RDP/SSH over private VNet
```

### 7.2 Bastion Tiers

| Feature | Basic | Standard |
|---|---|---|
| Browser-based RDP/SSH | ✅ | ✅ |
| No public IP on VM | ✅ | ✅ |
| NSG on BastionSubnet | ✅ | ✅ |
| Native client support | ❌ | ✅ |
| Shareable links | ❌ | ✅ |
| IP-based connection | ❌ | ✅ |
| File transfer | ❌ | ✅ (upload only) |
| Multi-monitor (RDP) | ❌ | ✅ |
| Kerberos auth | ❌ | ✅ |
| Host scaling | Fixed (2 instances) | 2–50 instances |
| Concurrent connections | ~25 | Up to 40/instance |

> **📝 Exam Tip:** **Native client support** (Standard only) allows using the native Windows RDP client or SSH client through Bastion — not just the browser. This is required for scenarios like file transfer or advanced RDP features.

### 7.3 Bastion Subnet Requirements

Azure Bastion requires a dedicated subnet named exactly **`AzureBastionSubnet`** — with minimum size **/27** (supports 2 instances); **/26** or larger recommended for scaling.

```bash
# Create Bastion subnet (must be named AzureBastionSubnet)
az network vnet subnet create \
  --name "AzureBastionSubnet" \
  --resource-group "myRG" \
  --vnet-name "myVNet" \
  --address-prefixes "10.0.100.0/26"

# Create public IP for Bastion (must be Standard SKU, Static)
az network public-ip create \
  --name "myBastionPIP" \
  --resource-group "myRG" \
  --location "eastus" \
  --sku Standard \
  --allocation-method Static

# Create Azure Bastion
az network bastion create \
  --name "myBastion" \
  --resource-group "myRG" \
  --location "eastus" \
  --vnet-name "myVNet" \
  --public-ip-address "myBastionPIP" \
  --sku Standard \
  --scale-units 4

# Connect to a VM via Bastion (native client)
az network bastion ssh \
  --name "myBastion" \
  --resource-group "myRG" \
  --target-resource-id "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM" \
  --auth-type password \
  --username "azureuser"

# RDP via Bastion native client
az network bastion rdp \
  --name "myBastion" \
  --resource-group "myRG" \
  --target-resource-id "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM"
```

**PowerShell:**

```powershell
# Create Azure Bastion
New-AzBastion `
  -ResourceGroupName "myRG" `
  -Name "myBastion" `
  -PublicIpAddressRgName "myRG" `
  -PublicIpAddressName "myBastionPIP" `
  -VirtualNetworkRgName "myRG" `
  -VirtualNetworkName "myVNet" `
  -Sku "Standard" `
  -ScaleUnit 4
```

### 7.4 Bastion NSG Requirements

The `AzureBastionSubnet` needs specific NSG rules to function:

**Inbound Rules Required:**

| Priority | Source | Port | Purpose |
|---|---|---|---|
| 100 | Internet | 443 | Allow HTTPS from internet (user browser access) |
| 110 | GatewayManager | 443 | Azure Bastion management traffic |
| 120 | AzureLoadBalancer | 443 | Health probes |

**Outbound Rules Required:**

| Priority | Destination | Port | Purpose |
|---|---|---|---|
| 100 | VirtualNetwork | 3389, 22 | RDP/SSH to target VMs |
| 110 | AzureCloud | 443 | Diagnostic logs to Azure |

> **📝 Exam Trap:** Do **NOT** put NSG rules blocking port 3389/22 on the **AzureBastionSubnet** — Bastion needs outbound 3389/22 to the VirtualNetwork to reach target VMs. However, the **target VM's subnet NSG** should block port 3389/22 from the internet (Bastion connects over the private VNet, not the internet).

### 7.5 JIT VM Access (Integration with Defender for Cloud)

Just-In-Time VM Access (from Microsoft Defender for Cloud) temporarily opens NSG ports only when needed.

```
Without JIT:     NSG allows RDP (3389) from Internet permanently
With JIT:        NSG blocks RDP (3389) by default
                 User requests access → Policy evaluated
                 NSG rule temporarily opened for specific IP and time
                 Rule automatically removed after time expires
```

```bash
# Enable JIT on a VM via Azure CLI
az security jit-policy update \
  --name "myJITPolicy" \
  --resource-group "myRG" \
  --location "eastus" \
  --vm-policies '[{
    "id": "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM",
    "ports": [{
      "number": 3389,
      "protocol": "TCP",
      "allowedSourceAddressPrefix": "*",
      "maxRequestAccessDuration": "PT3H"
    }, {
      "number": 22,
      "protocol": "TCP",
      "allowedSourceAddressPrefix": "*",
      "maxRequestAccessDuration": "PT3H"
    }]
  }]'

# Request JIT access
az security jit-policy initiate \
  --name "myJITPolicy" \
  --resource-group "myRG" \
  --vm-requests '[{
    "id": "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM",
    "ports": [{
      "number": 3389,
      "duration": "PT1H",
      "allowedSourceAddressPrefix": "203.0.113.100"
    }]
  }]'
```

> **📝 Exam Tip:** JIT VM Access requires **Microsoft Defender for Servers** (Plan 1 or Plan 2). When combined with **Azure Bastion**, JIT is less necessary since Bastion eliminates the need to open RDP/SSH ports publicly. Use JIT when Bastion isn't available but you need on-demand port access.

---

## Quick Reference: Key Exam Topics

### Network Security Decision Tree

```
Need to filter traffic between VMs in same VNet?
  └── NSG (attach to subnets or NICs)

Need application-layer FQDN filtering for all egress?
  └── Azure Firewall (with Application Rules)

Need to protect against DDoS at scale?
  └── DDoS Network Protection Plan (attach to VNets)

Need to protect web apps from OWASP attacks?
  └── WAF on Application Gateway (regional) OR
      WAF on Azure Front Door (global)

Need secure private access to VMs without public IPs?
  └── Azure Bastion

Need on-demand port access with time limits?
  └── JIT VM Access (requires Defender for Servers)

Need to connect on-prem securely to Azure?
  └── VPN Gateway (internet-based, encrypted) OR
      ExpressRoute (private dedicated circuit)

Need to monitor all traffic flows?
  └── NSG Flow Logs + Traffic Analytics

Need to diagnose connectivity issues?
  └── Network Watcher (IP Flow Verify, Next Hop, etc.)
```

### Service Endpoint vs Private Endpoint vs Firewall

| Scenario | Recommended Solution |
|---|---|
| Azure PaaS accessible only from specific VNet | Service Endpoint |
| Azure PaaS accessible from on-prem via VPN | Private Endpoint |
| Maximum data exfiltration protection | Private Endpoint |
| Centralized outbound filtering for all VNets | Azure Firewall |
| Free, quick VNet-scoped access restriction | Service Endpoint |

### Common Exam Scenarios

**Scenario 1:** "Block all RDP traffic from the internet to VMs, but allow IT admins to RDP when needed."
→ **Answer:** Remove port 3389 from public access in NSG. Enable **JIT VM Access** via Defender for Cloud, OR deploy **Azure Bastion** for browser-based access without opening 3389.

**Scenario 2:** "Company needs to inspect all outbound traffic from VMs to the internet for malicious URLs and block them."
→ **Answer:** Deploy **Azure Firewall Premium** with Application Rules (FQDN filtering) and **Threat Intelligence** in Deny mode. Use UDR to route 0.0.0.0/0 to Azure Firewall.

**Scenario 3:** "Protect a public-facing web application from SQL injection and XSS attacks."
→ **Answer:** Deploy **WAF on Application Gateway v2** (regional) or **WAF on Azure Front Door** (global) in **Prevention mode** with **OWASP CRS 3.2**.

**Scenario 4:** "Azure Storage account must be accessible from your VNet but not from the internet. Minimize cost."
→ **Answer:** Enable **Service Endpoint** for `Microsoft.Storage` on the subnet, then configure the Storage Account firewall to allow only that VNet. (Private Endpoint is more secure but has cost; Service Endpoint is free.)

**Scenario 5:** "Monitor which traffic is being blocked by NSGs across all subscriptions."
→ **Answer:** Enable **NSG Flow Logs v2** and configure **Traffic Analytics** with a Log Analytics Workspace. Use built-in dashboards or KQL queries.

**Scenario 6:** "A VNet-peered architecture isn't routing traffic between spoke VNets. What's wrong?"
→ **Answer:** VNet peering is **non-transitive**. Traffic between spoke VNets cannot route through the hub VNet without a **Network Virtual Appliance** or **Azure Firewall** in the hub acting as a router, with appropriate **UDRs** in each spoke.

**Scenario 7:** "Detect and automatically block network-level intrusions in real-time on Azure Firewall."
→ **Answer:** Use **Azure Firewall Premium** with **IDPS** configured in **Alert and Deny** mode.

**Scenario 8:** "Enforce a company-wide rule that no one can block Azure Monitor traffic, regardless of individual NSG settings."
→ **Answer:** Use **Azure Virtual Network Manager** Security Admin Rules with an **Always Allow** rule for the `AzureMonitor` service tag at a high priority.

### Port Reference for NSG Scenarios

| Protocol | Port | Service |
|---|---|---|
| TCP | 22 | SSH |
| TCP | 80 | HTTP |
| TCP | 443 | HTTPS |
| TCP | 3389 | RDP |
| TCP | 1433 | SQL Server |
| TCP/UDP | 53 | DNS |
| TCP | 8080 | HTTP alternate |
| UDP | 500, 4500 | IKE/IPsec (VPN) |
| TCP | 179 | BGP |
| TCP | 5671, 5672 | AMQP (Service Bus) |

---

*Previous: [Domain 1 — Identity and Access ←](./01-identity-and-access.md)*
