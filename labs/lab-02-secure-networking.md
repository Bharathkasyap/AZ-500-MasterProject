# Lab 02: Secure Networking

> **Estimated Time:** 60–90 minutes  
> **Domain:** 2 — Secure Networking  
> **Prerequisites:** Azure subscription, Azure CLI, Owner or Network Contributor permissions

---

## Lab Overview

In this lab, you will:
1. Create a hub-and-spoke VNet topology with peering
2. Configure Network Security Groups (NSGs) with custom rules
3. Deploy Azure Firewall and configure application/network rules
4. Create a Private Endpoint for an Azure Storage account
5. Configure a User-Defined Route (UDR) to force traffic through Azure Firewall

---

## Exercise 1: Create Hub-and-Spoke VNet Topology

### Task 1.1: Create the Hub VNet

```bash
RESOURCE_GROUP="rg-az500-network-lab"
LOCATION="eastus"

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Hub VNet with Azure Firewall subnet (must be named AzureFirewallSubnet)
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "vnet-hub" \
  --address-prefix "10.0.0.0/16" \
  --subnet-name "AzureFirewallSubnet" \
  --subnet-prefix "10.0.1.0/26"
```

### Task 1.2: Create the Spoke VNet

```bash
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "vnet-spoke" \
  --address-prefix "10.1.0.0/16" \
  --subnet-name "snet-workloads" \
  --subnet-prefix "10.1.1.0/24"
```

### Task 1.3: Create VNet Peering

```bash
HUB_ID=$(az network vnet show -g "$RESOURCE_GROUP" -n "vnet-hub" --query id -o tsv)
SPOKE_ID=$(az network vnet show -g "$RESOURCE_GROUP" -n "vnet-spoke" --query id -o tsv)

# Hub → Spoke
az network vnet peering create \
  --resource-group "$RESOURCE_GROUP" \
  --name "hub-to-spoke" \
  --vnet-name "vnet-hub" \
  --remote-vnet "$SPOKE_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic

# Spoke → Hub
az network vnet peering create \
  --resource-group "$RESOURCE_GROUP" \
  --name "spoke-to-hub" \
  --vnet-name "vnet-spoke" \
  --remote-vnet "$HUB_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic
```

✅ **Validation:** Check peering state is `Connected`:
```bash
az network vnet peering list \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "vnet-hub" \
  --query "[].{Name:name, State:peeringState}" \
  --output table
```

---

## Exercise 2: Network Security Groups

### Task 2.1: Create an NSG with security rules

```bash
# Create NSG
az network nsg create \
  --resource-group "$RESOURCE_GROUP" \
  --name "nsg-workloads"

# Block all inbound RDP from internet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "nsg-workloads" \
  --name "Deny-RDP-Internet" \
  --priority 100 \
  --source-address-prefixes "Internet" \
  --destination-port-ranges "3389" \
  --protocol "Tcp" \
  --access "Deny" \
  --direction "Inbound"

# Block all inbound SSH from internet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "nsg-workloads" \
  --name "Deny-SSH-Internet" \
  --priority 110 \
  --source-address-prefixes "Internet" \
  --destination-port-ranges "22" \
  --protocol "Tcp" \
  --access "Deny" \
  --direction "Inbound"

# Allow HTTPS inbound from VNet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "nsg-workloads" \
  --name "Allow-HTTPS-VNet" \
  --priority 200 \
  --source-address-prefixes "VirtualNetwork" \
  --destination-port-ranges "443" \
  --protocol "Tcp" \
  --access "Allow" \
  --direction "Inbound"
```

### Task 2.2: Associate NSG with subnet

```bash
az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "vnet-spoke" \
  --name "snet-workloads" \
  --nsg "nsg-workloads"
```

### Task 2.3: View effective security rules

```bash
# Create a test VM to view effective rules (optional)
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "vm-test" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name "vnet-spoke" \
  --subnet "snet-workloads" \
  --public-ip-address "" \
  --output none

# View effective NSG rules on the VM's NIC
az network nic show-effective-nsg \
  --resource-group "$RESOURCE_GROUP" \
  --name "$(az network nic list -g "$RESOURCE_GROUP" --query "[0].name" -o tsv)" \
  --output table
```

✅ **Validation:** Verify that `Deny-RDP-Internet` and `Deny-SSH-Internet` rules appear with Deny action at priority 100 and 110.

---

## Exercise 3: Azure Firewall

### Task 3.1: Create Azure Firewall

> ⚠️ Azure Firewall takes ~5 minutes to deploy and incurs hourly charges. Remember to delete after the lab.

```bash
# Public IP for Firewall
az network public-ip create \
  --resource-group "$RESOURCE_GROUP" \
  --name "pip-firewall" \
  --sku Standard \
  --allocation-method Static

# Firewall Policy
az network firewall policy create \
  --resource-group "$RESOURCE_GROUP" \
  --name "afwp-hub" \
  --location "$LOCATION" \
  --sku Standard \
  --threat-intel-mode Alert

# Deploy Azure Firewall
az network firewall create \
  --resource-group "$RESOURCE_GROUP" \
  --name "afw-hub" \
  --location "$LOCATION" \
  --sku AZFW_VNet \
  --vnet-name "vnet-hub" \
  --public-ip "pip-firewall" \
  --firewall-policy "afwp-hub"

# Get private IP
FIREWALL_IP=$(az network firewall show \
  -g "$RESOURCE_GROUP" -n "afw-hub" \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

echo "Firewall private IP: $FIREWALL_IP"
```

### Task 3.2: Add an application rule (allow specific FQDNs)

```bash
# Create rule collection group
az network firewall policy rule-collection-group create \
  --resource-group "$RESOURCE_GROUP" \
  --policy-name "afwp-hub" \
  --name "DefaultRCG" \
  --priority 300

# Add application rule collection
az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group "$RESOURCE_GROUP" \
  --policy-name "afwp-hub" \
  --rule-collection-group-name "DefaultRCG" \
  --name "AllowMicrosoftFQDNs" \
  --collection-priority 100 \
  --action Allow \
  --rule-name "AllowWindowsUpdate" \
  --rule-type ApplicationRule \
  --protocols "Https=443" \
  --source-addresses "10.1.0.0/16" \
  --target-fqdns "*.microsoft.com" "*.windowsupdate.com" "*.azure.com"
```

### Task 3.3: Add a network rule (allow DNS)

```bash
az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group "$RESOURCE_GROUP" \
  --policy-name "afwp-hub" \
  --rule-collection-group-name "DefaultRCG" \
  --name "AllowDNS" \
  --collection-priority 200 \
  --action Allow \
  --rule-name "AllowDNS-UDP" \
  --rule-type NetworkRule \
  --protocols "UDP" \
  --source-addresses "10.1.0.0/16" \
  --destination-addresses "168.63.129.16" \
  --destination-ports "53"
```

✅ **Validation:** Review Firewall Policy rules in the portal: **Firewall Policy** → **Rule collections**.

---

## Exercise 4: User-Defined Route (Force Tunneling)

### Task 4.1: Create a route table and force spoke traffic through Firewall

```bash
# Create route table
az network route-table create \
  --resource-group "$RESOURCE_GROUP" \
  --name "rt-spoke" \
  --disable-bgp-route-propagation

# Add default route to Firewall
az network route-table route create \
  --resource-group "$RESOURCE_GROUP" \
  --route-table-name "rt-spoke" \
  --name "DefaultToFirewall" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address "$FIREWALL_IP"

# Associate with spoke workload subnet
az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "vnet-spoke" \
  --name "snet-workloads" \
  --route-table "rt-spoke"
```

✅ **Validation:**
```bash
az network route-table route list \
  --resource-group "$RESOURCE_GROUP" \
  --route-table-name "rt-spoke" \
  --output table
```
You should see: `DefaultToFirewall | 0.0.0.0/0 | VirtualAppliance | <Firewall IP>`

---

## Exercise 5: Private Endpoint for Storage Account

### Task 5.1: Create a storage account and private endpoint

```bash
# Add private endpoint subnet
az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "vnet-spoke" \
  --name "snet-private-endpoints" \
  --address-prefix "10.1.2.0/24"

# Create storage account
STORAGE_NAME="stpvtlab$(openssl rand -hex 4)"
az storage account create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$STORAGE_NAME" \
  --sku Standard_LRS \
  --https-only true \
  --default-action Deny \
  --allow-blob-public-access false

STORAGE_ID=$(az storage account show -g "$RESOURCE_GROUP" -n "$STORAGE_NAME" --query id -o tsv)

# Create private endpoint
az network private-endpoint create \
  --resource-group "$RESOURCE_GROUP" \
  --name "pe-storage" \
  --vnet-name "vnet-spoke" \
  --subnet "snet-private-endpoints" \
  --private-connection-resource-id "$STORAGE_ID" \
  --group-id blob \
  --connection-name "storage-connection"
```

### Task 5.2: Create Private DNS Zone for Storage

```bash
# Create private DNS zone
az network private-dns zone create \
  --resource-group "$RESOURCE_GROUP" \
  --name "privatelink.blob.core.windows.net"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --zone-name "privatelink.blob.core.windows.net" \
  --name "dns-link-spoke" \
  --virtual-network "vnet-spoke" \
  --registration-enabled false

# Create DNS record for private endpoint
PRIVATE_IP=$(az network private-endpoint show \
  -g "$RESOURCE_GROUP" -n "pe-storage" \
  --query "customDnsConfigs[0].ipAddresses[0]" -o tsv)

az network private-dns record-set a add-record \
  --resource-group "$RESOURCE_GROUP" \
  --zone-name "privatelink.blob.core.windows.net" \
  --record-set-name "$STORAGE_NAME" \
  --ipv4-address "$PRIVATE_IP"
```

✅ **Validation:** From within the VNet, the storage FQDN should resolve to the private IP:
```bash
# From a VM inside vnet-spoke:
nslookup ${STORAGE_NAME}.blob.core.windows.net
# Expected: should resolve to 10.1.2.x (private IP)
```

---

## Lab Cleanup

```bash
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
```

> ⚠️ Azure Firewall is expensive (~$1.25/hour). Ensure it is deleted promptly after the lab.

---

## Lab Summary

| Concept | What You Practiced |
|---|---|
| VNet topology | Hub-and-spoke with VNet peering |
| NSG rules | Deny RDP/SSH from internet, allow HTTPS from VNet |
| Azure Firewall | Deployment, application rules (FQDN), network rules, Threat Intelligence |
| User-Defined Routes | Force all outbound traffic through Azure Firewall |
| Private Endpoints | Storage blob private endpoint with DNS zone |

---

*Previous: [Lab 01 — Identity and Access ←](lab-01-identity-access.md) | Next: [Lab 03 — Compute, Storage and Databases →](lab-03-compute-storage.md)*
