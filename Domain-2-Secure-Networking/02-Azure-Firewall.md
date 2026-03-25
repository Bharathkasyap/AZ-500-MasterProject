# Azure Firewall

## 📌 What is Azure Firewall?

**Azure Firewall** is a managed, cloud-native, stateful network security service that provides threat protection for Azure Virtual Network resources. Unlike NSGs (which filter by IP/port), Azure Firewall adds:

- FQDN (fully qualified domain name) filtering
- Application-layer (Layer 7) inspection
- Built-in threat intelligence
- Centralized management across multiple VNets (via Firewall Manager)
- TLS inspection (Premium SKU)

---

## 🏢 Azure Firewall SKUs

| Feature | Standard | Premium |
|---------|----------|---------|
| **Stateful firewall** | ✅ | ✅ |
| **Network rules** | ✅ | ✅ |
| **Application rules** | ✅ | ✅ |
| **NAT rules (DNAT)** | ✅ | ✅ |
| **Threat intelligence** | Alert & Deny | Alert & Deny |
| **TLS inspection** | ❌ | ✅ |
| **IDPS (Intrusion Detection & Prevention)** | ❌ | ✅ |
| **URL filtering** | ❌ | ✅ |
| **Web categories** | Limited | Full |
| **Cost** | Lower | Higher |

> 💡 **Exam Note**: Azure Firewall **Premium** is required for IDPS, TLS inspection, and full URL filtering — key security capabilities.

---

## 🏗️ Deployment Architecture

```
Internet
   ↓
Azure Firewall (in AzureFirewallSubnet — must be /26 or larger)
   ↓
Hub VNet
   ↓
Peered Spoke VNets (UDR routes traffic through firewall)
```

### Required Subnet
- Azure Firewall must be in a subnet named **AzureFirewallSubnet**
- Minimum subnet size: **/26** (64 addresses)

### User Defined Routes (UDR)
- Spoke VNets need a UDR to route traffic through the firewall
- Default route (0.0.0.0/0) → Next hop = Firewall private IP

```bash
# Create UDR route table
az network route-table create --resource-group MyRG --name FW-Route-Table

# Add default route to firewall
az network route-table route create \
  --resource-group MyRG \
  --route-table-name FW-Route-Table \
  --name Default-To-Firewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address 10.0.0.4  # Firewall private IP

# Associate with subnet
az network vnet subnet update \
  --resource-group MyRG \
  --vnet-name SpokeVNet \
  --name WorkloadSubnet \
  --route-table FW-Route-Table
```

---

## 📋 Rule Collection Types

### 1. DNAT Rules (Destination Network Address Translation)

Translate inbound internet traffic to internal resources:

```
Inbound public IP:port → Internal private IP:port
Use case: Expose internal VM RDP/SSH via firewall (not recommended — use Bastion instead)
```

### 2. Network Rules

Filter traffic by IP, port, and protocol (Layer 3/4):

```
Example:
Source: 10.0.1.0/24 (spoke subnet)
Destination: 10.0.2.0/24 (another spoke)
Port: 1433
Protocol: TCP
Action: Allow
```

### 3. Application Rules

Filter HTTP/HTTPS traffic by FQDN (Layer 7):

```
Example:
Source: 10.0.0.0/16
Target FQDN: *.microsoft.com, *.windowsupdate.com
Protocol: HTTPS:443
Action: Allow
```

> 💡 **Rule processing order**: DNAT rules → Network rules → Application rules (if network rules don't match)

---

## 🔥 Rule Collection Groups and Policy

**Azure Firewall Policy** (recommended management method):
- Hierarchical: Parent policy → Child policy (inheritance)
- Supports **Rule Collection Groups** with priorities
- Managed via **Azure Firewall Manager**

```
Firewall Policy
├── Rule Collection Group (Priority: 100)
│   ├── DNAT Collection
│   ├── Network Collection
│   └── Application Collection
└── Rule Collection Group (Priority: 200)
    └── ...
```

### Classic Rules vs Firewall Policy

| Feature | Classic Rules | Firewall Policy |
|---------|--------------|-----------------|
| **Management** | Per-firewall | Centralized |
| **Inheritance** | No | Yes (parent/child) |
| **Firewall Manager** | Limited | Full support |
| **Recommendation** | Legacy | Use this |

---

## 🛡️ Threat Intelligence

Azure Firewall can alert and deny traffic from/to known malicious IPs and FQDNs (Microsoft Threat Intelligence feed):

| Mode | Behavior |
|------|----------|
| **Off** | Disabled |
| **Alert only** | Log but allow |
| **Alert and deny** | Log and block |

> ⚠️ **Exam Note**: Threat Intelligence is enabled by default in **Alert only** mode. Change to **Alert and deny** for production.

---

## 🔍 Azure Firewall Premium Features

### IDPS (Intrusion Detection and Prevention System)
- **Alert mode**: Detect and log intrusions, allow traffic
- **Alert and deny mode**: Detect, log, and block intrusions
- Based on signature-based detection
- 58,000+ signatures covering 50+ categories

### TLS Inspection
- Decrypt, inspect, and re-encrypt HTTPS traffic
- Requires an **intermediate CA certificate** deployed to Azure Firewall
- Certificate stored in Azure Key Vault

### URL Filtering
- More granular than FQDN — filter specific URLs (not just domains)
- Example: Allow `microsoft.com/download` but block `microsoft.com/forums`

---

## 🌐 Azure Firewall Manager

**Firewall Manager** provides centralized security management for:
- Multiple Azure Firewalls across regions and subscriptions
- Firewall policies (with inheritance)
- **Secured Virtual Hubs** (Azure Virtual WAN integration)
- **Hub Virtual Networks** (traditional hub-spoke)
- Integration with third-party security providers (Zscaler, Check Point, iboss)

---

## 🔗 CLI Commands

```bash
# Create Azure Firewall
az network firewall create \
  --resource-group MyRG \
  --name MyFirewall \
  --location eastus \
  --sku-name AZFW_VNet \
  --tier Premium  # or Standard

# Create Firewall Policy
az network firewall policy create \
  --resource-group MyRG \
  --name MyFWPolicy \
  --sku Premium

# Add application rule collection
az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group MyRG \
  --policy-name MyFWPolicy \
  --rule-collection-group-name DefaultApplicationRuleCollectionGroup \
  --name AllowMicrosoftUpdates \
  --collection-priority 100 \
  --action Allow \
  --rule-name AllowWindowsUpdate \
  --rule-type ApplicationRule \
  --source-addresses 10.0.0.0/16 \
  --protocols Https=443 \
  --fqdn-tags WindowsUpdate
```

---

## ❓ Practice Questions

1. You need Azure Firewall to inspect encrypted HTTPS traffic for malware. Which Azure Firewall SKU and feature is required?
   - A) Standard SKU with Threat Intelligence
   - **B) Premium SKU with TLS inspection** ✅
   - C) Standard SKU with Application rules
   - D) Premium SKU with IDPS in Alert mode only

2. You deploy Azure Firewall in a hub VNet. Traffic from spoke VNets is not reaching the firewall. What must you configure?
   - A) VNet peering with gateway transit
   - B) Azure Bastion in spoke VNets
   - **C) User Defined Routes (UDR) in spoke subnets pointing to the firewall** ✅
   - D) NSG rules to forward traffic

3. Which Azure Firewall rule type would you use to allow VMs to access only *.microsoft.com over HTTPS?
   - A) DNAT rules
   - B) Network rules
   - **C) Application rules** ✅
   - D) Threat Intelligence rules

4. What is the minimum subnet size for the AzureFirewallSubnet?
   - A) /28
   - B) /27
   - **C) /26** ✅
   - D) /24

---

## 📚 References

- [Azure Firewall Documentation](https://learn.microsoft.com/en-us/azure/firewall/overview)
- [Azure Firewall Premium](https://learn.microsoft.com/en-us/azure/firewall/premium-features)
- [Azure Firewall Manager](https://learn.microsoft.com/en-us/azure/firewall-manager/overview)
- [Azure Firewall Threat Intelligence](https://learn.microsoft.com/en-us/azure/firewall/threat-intel)
