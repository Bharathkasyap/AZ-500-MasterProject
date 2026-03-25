# Lab 03 — Network Security Groups and Azure Firewall

> **Estimated time:** 60–75 minutes  
> **Prerequisites:** Azure subscription, Contributor rights  
> **Skills practiced:** Domain 2 — Secure Networking

---

## Objectives

By the end of this lab you will be able to:

1. Create a hub-spoke VNet topology.
2. Configure Network Security Groups (NSGs) with custom rules.
3. Deploy Azure Firewall in the hub VNet.
4. Create User-Defined Routes (UDRs) to route spoke traffic through the firewall.
5. Configure Azure Firewall application and network rules.
6. Enable Azure DDoS Protection on the hub VNet.
7. Test traffic flows to verify firewall enforcement.

---

## Architecture

```
Hub VNet (10.0.0.0/16)
  ├── AzureFirewallSubnet (10.0.1.0/26)    ← Azure Firewall
  ├── AzureBastionSubnet (10.0.2.0/26)     ← Azure Bastion
  └── ManagementSubnet (10.0.3.0/24)       ← Jump server

Spoke VNet (10.1.0.0/16)
  ├── WebSubnet (10.1.1.0/24)              ← Web servers (NSG applied)
  └── DataSubnet (10.1.2.0/24)             ← Databases (NSG applied)

VNet Peering: Hub ↔ Spoke (with gateway transit / forwarded traffic)

Route Tables:
  - WebSubnet Route Table: 0.0.0.0/0 → Azure Firewall
  - DataSubnet Route Table: 0.0.0.0/0 → Azure Firewall
```

---

## Part 1 — Create VNet Topology

```bash
# Variables
RG="rg-az500-lab03"
LOCATION="eastus"

# Create resource group
az group create --name $RG --location $LOCATION

# Create Hub VNet
az network vnet create \
  --resource-group $RG \
  --name "vnet-hub" \
  --address-prefix "10.0.0.0/16" \
  --location $LOCATION

# Create Hub subnets
az network vnet subnet create \
  --resource-group $RG \
  --vnet-name "vnet-hub" \
  --name "AzureFirewallSubnet" \
  --address-prefix "10.0.1.0/26"

az network vnet subnet create \
  --resource-group $RG \
  --vnet-name "vnet-hub" \
  --name "AzureBastionSubnet" \
  --address-prefix "10.0.2.0/26"

az network vnet subnet create \
  --resource-group $RG \
  --vnet-name "vnet-hub" \
  --name "ManagementSubnet" \
  --address-prefix "10.0.3.0/24"

# Create Spoke VNet
az network vnet create \
  --resource-group $RG \
  --name "vnet-spoke" \
  --address-prefix "10.1.0.0/16" \
  --location $LOCATION

# Create Spoke subnets
az network vnet subnet create \
  --resource-group $RG \
  --vnet-name "vnet-spoke" \
  --name "WebSubnet" \
  --address-prefix "10.1.1.0/24"

az network vnet subnet create \
  --resource-group $RG \
  --vnet-name "vnet-spoke" \
  --name "DataSubnet" \
  --address-prefix "10.1.2.0/24"

# Create VNet Peering (both directions)
az network vnet peering create \
  --resource-group $RG \
  --name "hub-to-spoke" \
  --vnet-name "vnet-hub" \
  --remote-vnet "vnet-spoke" \
  --allow-forwarded-traffic \
  --allow-gateway-transit

az network vnet peering create \
  --resource-group $RG \
  --name "spoke-to-hub" \
  --vnet-name "vnet-spoke" \
  --remote-vnet "vnet-hub" \
  --allow-forwarded-traffic \
  --use-remote-gateways false
```

---

## Part 2 — Configure NSGs for Spoke Subnets

### Web Subnet NSG

```bash
# Create NSG for Web tier
az network nsg create \
  --resource-group $RG \
  --name "nsg-web" \
  --location $LOCATION

# Allow HTTP and HTTPS from Internet
az network nsg rule create \
  --resource-group $RG \
  --nsg-name "nsg-web" \
  --name "Allow-HTTP-Inbound" \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --source-address-prefixes Internet \
  --destination-port-ranges 80 443 \
  --access Allow

# Allow SSH from Azure Bastion subnet only
az network nsg rule create \
  --resource-group $RG \
  --nsg-name "nsg-web" \
  --name "Allow-SSH-From-Bastion" \
  --priority 110 \
  --direction Inbound \
  --protocol Tcp \
  --source-address-prefixes "10.0.2.0/26" \
  --destination-port-ranges 22 \
  --access Allow

# Deny all other inbound
az network nsg rule create \
  --resource-group $RG \
  --nsg-name "nsg-web" \
  --name "Deny-All-Inbound" \
  --priority 4000 \
  --direction Inbound \
  --protocol "*" \
  --source-address-prefixes "*" \
  --destination-port-ranges "*" \
  --access Deny

# Associate NSG with WebSubnet
az network vnet subnet update \
  --resource-group $RG \
  --vnet-name "vnet-spoke" \
  --name "WebSubnet" \
  --network-security-group "nsg-web"
```

### Data Subnet NSG

```bash
# Create NSG for Data tier
az network nsg create \
  --resource-group $RG \
  --name "nsg-data" \
  --location $LOCATION

# Allow SQL from Web subnet only
az network nsg rule create \
  --resource-group $RG \
  --nsg-name "nsg-data" \
  --name "Allow-SQL-From-Web" \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --source-address-prefixes "10.1.1.0/24" \
  --destination-port-ranges 1433 \
  --access Allow

# Deny all other inbound traffic
az network nsg rule create \
  --resource-group $RG \
  --nsg-name "nsg-data" \
  --name "Deny-All-Inbound" \
  --priority 4000 \
  --direction Inbound \
  --protocol "*" \
  --source-address-prefixes "*" \
  --destination-port-ranges "*" \
  --access Deny

# Associate with DataSubnet
az network vnet subnet update \
  --resource-group $RG \
  --vnet-name "vnet-spoke" \
  --name "DataSubnet" \
  --network-security-group "nsg-data"
```

---

## Part 3 — Deploy Azure Firewall

```bash
# Create Public IP for Azure Firewall
az network public-ip create \
  --resource-group $RG \
  --name "pip-azfw" \
  --sku Standard \
  --allocation-method Static \
  --location $LOCATION

# Create Azure Firewall Policy
az network firewall policy create \
  --resource-group $RG \
  --name "afwpolicy-lab03" \
  --location $LOCATION \
  --threat-intel-mode Alert

# Deploy Azure Firewall (this takes ~10 minutes)
az network firewall create \
  --resource-group $RG \
  --name "azfw-hub" \
  --location $LOCATION \
  --vnet-name "vnet-hub" \
  --firewall-policy "afwpolicy-lab03" \
  --public-ip "pip-azfw"

# Get the Firewall's private IP
FIREWALL_PRIVATE_IP=$(az network firewall show \
  --resource-group $RG \
  --name "azfw-hub" \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

echo "Firewall Private IP: $FIREWALL_PRIVATE_IP"
```

---

## Part 4 — Configure Firewall Rules

### Create a Rule Collection Group

```bash
# Create rule collection group
az network firewall policy rule-collection-group create \
  --resource-group $RG \
  --policy-name "afwpolicy-lab03" \
  --name "RCG-Production" \
  --priority 100
```

### Add Network Rules (Layer 4)

```bash
# Allow web VMs to reach Azure DNS and NTP
az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group $RG \
  --policy-name "afwpolicy-lab03" \
  --rule-collection-group-name "RCG-Production" \
  --name "Allow-Infrastructure" \
  --collection-priority 100 \
  --action Allow \
  --rule-type NetworkRule \
  --rule-name "Allow-DNS" \
  --protocols UDP \
  --source-addresses "10.1.0.0/16" \
  --destination-addresses "168.63.129.16" \
  --destination-ports 53

# Allow SQL between web and data subnets
az network firewall policy rule-collection-group collection rule add \
  --resource-group $RG \
  --policy-name "afwpolicy-lab03" \
  --rule-collection-group-name "RCG-Production" \
  --collection-name "Allow-Infrastructure" \
  --name "Allow-SQL" \
  --rule-type NetworkRule \
  --protocols TCP \
  --source-addresses "10.1.1.0/24" \
  --destination-addresses "10.1.2.0/24" \
  --destination-ports 1433
```

### Add Application Rules (Layer 7 — FQDN)

```bash
# Allow web servers to access Windows Update and Azure services
az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group $RG \
  --policy-name "afwpolicy-lab03" \
  --rule-collection-group-name "RCG-Production" \
  --name "Allow-Web-Egress" \
  --collection-priority 200 \
  --action Allow \
  --rule-type ApplicationRule \
  --rule-name "Allow-WindowsUpdate" \
  --protocols "Http=80" "Https=443" \
  --source-addresses "10.1.1.0/24" \
  --fqdn-tags WindowsUpdate

az network firewall policy rule-collection-group collection rule add \
  --resource-group $RG \
  --policy-name "afwpolicy-lab03" \
  --rule-collection-group-name "RCG-Production" \
  --collection-name "Allow-Web-Egress" \
  --name "Allow-AzureServices" \
  --rule-type ApplicationRule \
  --protocols "Https=443" \
  --source-addresses "10.1.0.0/16" \
  --target-fqdns "*.azure.com" "*.microsoft.com"
```

---

## Part 5 — Create User-Defined Routes

```bash
# Create route table for Spoke subnets
az network route-table create \
  --resource-group $RG \
  --name "rt-spoke" \
  --location $LOCATION \
  --disable-bgp-route-propagation true

# Add default route via Azure Firewall (forced tunneling through firewall)
az network route-table route create \
  --resource-group $RG \
  --route-table-name "rt-spoke" \
  --name "Default-Via-Firewall" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $FIREWALL_PRIVATE_IP

# Associate route table with both spoke subnets
az network vnet subnet update \
  --resource-group $RG \
  --vnet-name "vnet-spoke" \
  --name "WebSubnet" \
  --route-table "rt-spoke"

az network vnet subnet update \
  --resource-group $RG \
  --vnet-name "vnet-spoke" \
  --name "DataSubnet" \
  --route-table "rt-spoke"
```

---

## Part 6 — Enable Azure DDoS Protection

```bash
# Create DDoS Protection Plan (Note: ~$2,944/month — use briefly for lab)
az network ddos-protection create \
  --resource-group $RG \
  --name "ddos-plan-lab03" \
  --location $LOCATION

# Enable on Hub VNet
az network vnet update \
  --resource-group $RG \
  --name "vnet-hub" \
  --ddos-protection true \
  --ddos-protection-plan "ddos-plan-lab03"
```

> **⚠️ Cost Warning:** DDoS Network Protection is expensive. Delete it after the lab.

---

## Part 7 — Verify Firewall Logging

```bash
# Create Log Analytics workspace for firewall logs
az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name "law-az500-lab03" \
  --location $LOCATION

LA_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name "law-az500-lab03" \
  --query id -o tsv)

FIREWALL_ID=$(az network firewall show \
  --resource-group $RG \
  --name "azfw-hub" \
  --query id -o tsv)

# Enable diagnostic settings
az monitor diagnostic-settings create \
  --name "azfw-diagnostics" \
  --resource $FIREWALL_ID \
  --workspace $LA_ID \
  --logs '[{"category":"AzureFirewallApplicationRule","enabled":true},{"category":"AzureFirewallNetworkRule","enabled":true}]'
```

### Query Firewall Logs

```kql
// See all firewall network rule actions
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| project TimeGenerated, msg_s
| parse msg_s with Protocol " request from " SourceIP ":" SourcePort " to " DestIP ":" DestPort ". Action: " Action
| project TimeGenerated, Protocol, SourceIP, SourcePort, DestIP, DestPort, Action
| order by TimeGenerated desc

// See all firewall application rule actions
AzureDiagnostics
| where Category == "AzureFirewallApplicationRule"
| project TimeGenerated, msg_s
| order by TimeGenerated desc
```

---

## Cleanup

```bash
# Remove DDoS protection first (expensive)
az network vnet update \
  --resource-group $RG \
  --name "vnet-hub" \
  --ddos-protection false

az network ddos-protection delete \
  --resource-group $RG \
  --name "ddos-plan-lab03"

# Delete everything else
az group delete --name $RG --yes --no-wait
```

---

## Key Takeaways

- **NSGs** provide subnet-level L4 filtering; they evaluate the **lowest priority** deny rule first.
- **Hub-spoke topology** centralizes firewall inspection — spokes route through the hub firewall.
- **UDRs with `0.0.0.0/0 → VirtualAppliance`** force all outbound traffic through Azure Firewall.
- **Application rules** operate at L7 and can filter by FQDN — they require the Azure Firewall to act as proxy.
- **DDoS Network Protection** protects all public IPs in the VNet from volumetric attacks.
- Both **NSG** and **Azure Firewall** are stateful — return traffic is automatically allowed.
