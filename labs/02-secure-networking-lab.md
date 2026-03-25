# Lab 02 — Secure Networking

**Estimated Time:** 90–120 minutes  
**Prerequisite:** Azure subscription with Contributor or Owner role  
**Mapped Exam Domain:** Domain 2 — Secure Networking

---

## Learning Objectives

- Deploy a hub-spoke virtual network topology
- Configure Azure Firewall with network and application rules
- Apply NSG rules with Application Security Groups
- Force all internet traffic through Azure Firewall using UDRs
- Deploy and test a Private Endpoint for Azure Storage

---

## Part 1 — Hub-Spoke VNet Topology

### Step 1.1 — Create Resource Group and VNets

```bash
# Variables
RG="lab-networking-rg"
LOCATION="eastus"
HUB_VNET="hub-vnet"
SPOKE_VNET="spoke-vnet"

az group create --name $RG --location $LOCATION

# Hub VNet (10.0.0.0/16)
az network vnet create \
  --name $HUB_VNET \
  --resource-group $RG \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16

# Subnets in Hub
az network vnet subnet create \
  --name AzureFirewallSubnet \
  --resource-group $RG \
  --vnet-name $HUB_VNET \
  --address-prefix 10.0.1.0/26

az network vnet subnet create \
  --name AzureBastionSubnet \
  --resource-group $RG \
  --vnet-name $HUB_VNET \
  --address-prefix 10.0.2.0/26

# Spoke VNet (10.1.0.0/16)
az network vnet create \
  --name $SPOKE_VNET \
  --resource-group $RG \
  --location $LOCATION \
  --address-prefix 10.1.0.0/16

# Workload subnet in spoke
az network vnet subnet create \
  --name workload-subnet \
  --resource-group $RG \
  --vnet-name $SPOKE_VNET \
  --address-prefix 10.1.1.0/24

echo "VNets and subnets created"
```

### Step 1.2 — VNet Peering (Hub ↔ Spoke)

```bash
# Peer Hub → Spoke
az network vnet peering create \
  --name hub-to-spoke \
  --resource-group $RG \
  --vnet-name $HUB_VNET \
  --remote-vnet $SPOKE_VNET \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Peer Spoke → Hub
az network vnet peering create \
  --name spoke-to-hub \
  --resource-group $RG \
  --vnet-name $SPOKE_VNET \
  --remote-vnet $HUB_VNET \
  --allow-forwarded-traffic \
  --use-remote-gateways false

echo "VNet peering configured"
```

**Validation check:**
```bash
az network vnet peering list --vnet-name $HUB_VNET --resource-group $RG --output table
```

---

## Part 2 — Azure Firewall Deployment

### Step 2.1 — Create Azure Firewall Public IP and Firewall

```bash
# Public IP for Firewall
az network public-ip create \
  --name fw-pip \
  --resource-group $RG \
  --location $LOCATION \
  --allocation-method Static \
  --sku Standard

# Create Firewall Policy
az network firewall policy create \
  --name lab-fw-policy \
  --resource-group $RG \
  --location $LOCATION

# Create Azure Firewall
az network firewall create \
  --name lab-firewall \
  --resource-group $RG \
  --location $LOCATION \
  --firewall-policy lab-fw-policy \
  --vnet-name $HUB_VNET

# Add IP configuration
az network firewall ip-config create \
  --name fw-ipconfig \
  --firewall-name lab-firewall \
  --resource-group $RG \
  --public-ip-address fw-pip \
  --vnet-name $HUB_VNET

# Get Firewall private IP
FW_PRIVATE_IP=$(az network firewall show \
  --name lab-firewall \
  --resource-group $RG \
  --query 'ipConfigurations[0].privateIPAddress' -o tsv)

echo "Firewall Private IP: $FW_PRIVATE_IP"
```

### Step 2.2 — Add Firewall Rules

```bash
# Create rule collection group
az network firewall policy rule-collection-group create \
  --name lab-rcg \
  --policy-name lab-fw-policy \
  --resource-group $RG \
  --priority 100

# Allow HTTPS to Microsoft sites (application rule)
az network firewall policy rule-collection-group collection add-filter-collection \
  --name allow-microsoft-https \
  --collection-priority 100 \
  --policy-name lab-fw-policy \
  --resource-group $RG \
  --rule-collection-group-name lab-rcg \
  --action Allow \
  --rule-type ApplicationRule \
  --rule-name allow-mslearn \
  --protocols Https=443 \
  --fqdn-tags WindowsUpdate MicrosoftActiveProtectionService \
  --source-addresses 10.1.0.0/16

# Allow DNS outbound (network rule)
az network firewall policy rule-collection-group collection add-filter-collection \
  --name allow-dns \
  --collection-priority 200 \
  --policy-name lab-fw-policy \
  --resource-group $RG \
  --rule-collection-group-name lab-rcg \
  --action Allow \
  --rule-type NetworkRule \
  --rule-name allow-dns-out \
  --protocols UDP \
  --destination-ports 53 \
  --source-addresses 10.1.0.0/16 \
  --destination-addresses '*'

echo "Firewall rules configured"
```

---

## Part 3 — Forced Tunneling via UDR

### Step 3.1 — Create Route Table and Assign to Spoke Subnet

```bash
# Create route table
az network route-table create \
  --name spoke-udr \
  --resource-group $RG \
  --location $LOCATION

# Add default route through Firewall
az network route-table route create \
  --route-table-name spoke-udr \
  --resource-group $RG \
  --name force-to-firewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $FW_PRIVATE_IP

# Associate route table with spoke workload subnet
az network vnet subnet update \
  --name workload-subnet \
  --resource-group $RG \
  --vnet-name $SPOKE_VNET \
  --route-table spoke-udr

echo "Forced tunneling UDR applied to spoke workload subnet"
```

**Validation check:**
```bash
az network route-table route list \
  --route-table-name spoke-udr \
  --resource-group $RG \
  --output table
```

---

## Part 4 — NSG with Application Security Groups

### Step 4.1 — Create ASGs

```bash
# ASG for web servers
az network asg create \
  --name asg-web \
  --resource-group $RG \
  --location $LOCATION

# ASG for database servers
az network asg create \
  --name asg-db \
  --resource-group $RG \
  --location $LOCATION
```

### Step 4.2 — Create and Configure NSG

```bash
# Create NSG
az network nsg create \
  --name workload-nsg \
  --resource-group $RG \
  --location $LOCATION

# Allow web tier to DB on port 1433
az network nsg rule create \
  --name allow-web-to-db \
  --nsg-name workload-nsg \
  --resource-group $RG \
  --priority 100 \
  --protocol Tcp \
  --source-asg asg-web \
  --destination-asg asg-db \
  --destination-port-ranges 1433 \
  --access Allow \
  --direction Inbound

# Deny all other inbound to DB
az network nsg rule create \
  --name deny-all-to-db \
  --nsg-name workload-nsg \
  --resource-group $RG \
  --priority 200 \
  --protocol '*' \
  --source-address-prefixes '*' \
  --destination-asg asg-db \
  --destination-port-ranges '*' \
  --access Deny \
  --direction Inbound

# Associate NSG with workload subnet
az network vnet subnet update \
  --name workload-subnet \
  --resource-group $RG \
  --vnet-name $SPOKE_VNET \
  --nsg workload-nsg

echo "NSG with ASG rules applied"
```

**Validation check:**
```bash
az network nsg rule list \
  --nsg-name workload-nsg \
  --resource-group $RG \
  --output table
```

---

## Part 5 — Private Endpoint for Storage

### Step 5.1 — Create Storage Account and Private Endpoint

```bash
SA_NAME="labstorage$(date +%s | tail -c 6)"

# Create storage account (deny public access)
az storage account create \
  --name $SA_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard_LRS \
  --https-only true \
  --default-action Deny \
  --allow-blob-public-access false

SA_ID=$(az storage account show --name $SA_NAME --resource-group $RG --query id -o tsv)

# Disable private endpoint network policies on the subnet
az network vnet subnet update \
  --name workload-subnet \
  --resource-group $RG \
  --vnet-name $SPOKE_VNET \
  --disable-private-endpoint-network-policies true

# Create Private Endpoint
az network private-endpoint create \
  --name storage-pe \
  --resource-group $RG \
  --location $LOCATION \
  --vnet-name $SPOKE_VNET \
  --subnet workload-subnet \
  --private-connection-resource-id $SA_ID \
  --group-id blob \
  --connection-name storage-pe-connection

echo "Private Endpoint created for storage account"
```

### Step 5.2 — Private DNS Zone

```bash
# Create private DNS zone for blob
az network private-dns zone create \
  --resource-group $RG \
  --name "privatelink.blob.core.windows.net"

# Link DNS zone to Hub VNet
az network private-dns link vnet create \
  --resource-group $RG \
  --zone-name "privatelink.blob.core.windows.net" \
  --name hub-dns-link \
  --virtual-network $HUB_VNET \
  --registration-enabled false

# Create DNS zone group on the private endpoint
az network private-endpoint dns-zone-group create \
  --resource-group $RG \
  --endpoint-name storage-pe \
  --name storage-dns-group \
  --private-dns-zone "privatelink.blob.core.windows.net" \
  --zone-name "privatelink.blob.core.windows.net"

echo "Private DNS zone configured for storage private endpoint"
```

**Validation check:**
```bash
az network private-endpoint show \
  --name storage-pe \
  --resource-group $RG \
  --query 'customDnsConfigs' -o table
```

---

## Checklist

- [ ] Hub VNet with AzureFirewallSubnet and AzureBastionSubnet created
- [ ] Spoke VNet with workload-subnet created
- [ ] VNet peering configured (hub ↔ spoke)
- [ ] Azure Firewall deployed and configured with application and network rules
- [ ] UDR forcing 0.0.0.0/0 through Firewall applied to spoke subnet
- [ ] ASGs created for web and db tiers
- [ ] NSG rule allowing only web-tier to db-tier on port 1433
- [ ] Storage account with public access denied
- [ ] Private Endpoint created for blob storage
- [ ] Private DNS Zone configured

---

## Cleanup

```bash
az group delete --name lab-networking-rg --yes --no-wait
echo "Resource group deletion initiated (runs in background)"
```

---

## Key Takeaways

1. Hub-spoke topology centralises security controls (Firewall, Bastion, VPN gateway).
2. UDR + Azure Firewall implements forced tunneling without extra costs on spoke VNets.
3. ASGs make NSG rules workload-aware and low-maintenance.
4. Private Endpoints provide the strongest isolation for PaaS services — no public internet traversal.
5. Private DNS Zones are required for correct DNS resolution of private endpoints.
