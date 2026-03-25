# Lab 04: Network Security Groups and Azure Firewall

> **Domain**: Secure Networking | **Difficulty**: Intermediate | **Time**: ~45 minutes

---

## Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed and authenticated

---

## Objectives

By the end of this lab, you will be able to:
- Create and configure Network Security Groups (NSGs) with custom rules
- Verify traffic flow using NSG diagnostics (IP Flow Verify)
- Deploy Azure Firewall with application and network rules
- Configure User-Defined Routes (UDRs) to force traffic through the firewall

---

## Architecture

```
Internet
    │
    ▼
[Azure Firewall] ── AzureFirewallSubnet (10.0.1.0/26)
    │
    ▼ (UDR)
[Workload VM] ── WorkloadSubnet (10.0.2.0/24)  ← NSG applied
```

---

## Part 1: Create Network Security Group

### Step 1.1 — Set Up Environment

```bash
RG="NSGFirewallLabRG"
LOCATION="eastus"
VNET_NAME="LabVNet"
VNET_PREFIX="10.0.0.0/16"

az group create --name $RG --location $LOCATION
```

### Step 1.2 — Create VNet and Subnets

```bash
# Create VNet
az network vnet create \
  --name $VNET_NAME \
  --resource-group $RG \
  --address-prefix $VNET_PREFIX \
  --location $LOCATION

# Create Workload Subnet
az network vnet subnet create \
  --name WorkloadSubnet \
  --vnet-name $VNET_NAME \
  --resource-group $RG \
  --address-prefix 10.0.2.0/24

# Create Azure Firewall Subnet (must be named AzureFirewallSubnet, /26 minimum)
az network vnet subnet create \
  --name AzureFirewallSubnet \
  --vnet-name $VNET_NAME \
  --resource-group $RG \
  --address-prefix 10.0.1.0/26

# Create Bastion Subnet
az network vnet subnet create \
  --name AzureBastionSubnet \
  --vnet-name $VNET_NAME \
  --resource-group $RG \
  --address-prefix 10.0.3.0/27
```

### Step 1.3 — Create and Configure NSG

```bash
# Create NSG
az network nsg create \
  --name WorkloadNSG \
  --resource-group $RG \
  --location $LOCATION

# Rule 1: Deny inbound RDP from internet (security baseline)
az network nsg rule create \
  --nsg-name WorkloadNSG \
  --resource-group $RG \
  --name DenyRDPFromInternet \
  --priority 100 \
  --source-address-prefixes Internet \
  --source-port-ranges "*" \
  --destination-port-ranges 3389 \
  --protocol Tcp \
  --access Deny \
  --direction Inbound \
  --description "Block direct RDP - use Azure Bastion"

# Rule 2: Deny inbound SSH from internet
az network nsg rule create \
  --nsg-name WorkloadNSG \
  --resource-group $RG \
  --name DenySSHFromInternet \
  --priority 110 \
  --source-address-prefixes Internet \
  --source-port-ranges "*" \
  --destination-port-ranges 22 \
  --protocol Tcp \
  --access Deny \
  --direction Inbound \
  --description "Block direct SSH - use Azure Bastion"

# Rule 3: Allow VNet internal traffic
az network nsg rule create \
  --nsg-name WorkloadNSG \
  --resource-group $RG \
  --name AllowVNetInbound \
  --priority 200 \
  --source-address-prefixes VirtualNetwork \
  --source-port-ranges "*" \
  --destination-port-ranges "*" \
  --protocol "*" \
  --access Allow \
  --direction Inbound

# Associate NSG with WorkloadSubnet
az network vnet subnet update \
  --name WorkloadSubnet \
  --vnet-name $VNET_NAME \
  --resource-group $RG \
  --network-security-group WorkloadNSG

echo "NSG created and applied to WorkloadSubnet"
```

### Step 1.4 — Deploy Test VM

```bash
# Create test VM in the workload subnet (no public IP)
az vm create \
  --name WorkloadVM \
  --resource-group $RG \
  --image Ubuntu2204 \
  --vnet-name $VNET_NAME \
  --subnet WorkloadSubnet \
  --nsg "" \
  --public-ip-address "" \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_B1s

echo "Workload VM deployed with private IP only"
```

---

## Part 2: Test NSG Rules with IP Flow Verify

### Step 2.1 — Enable Network Watcher

```bash
# Enable Network Watcher for the region (if not already enabled)
az network watcher configure \
  --resource-group NetworkWatcherRG \
  --locations $LOCATION \
  --enabled true 2>/dev/null || \
az network watcher configure \
  --locations $LOCATION \
  --enabled true
```

### Step 2.2 — Verify NSG Rules with IP Flow Verify

```bash
VM_ID=$(az vm show --name WorkloadVM --resource-group $RG --query id --output tsv)

# Test: Should be DENIED — RDP (port 3389) from internet IP
echo "Testing: RDP from internet (should be DENIED)"
az network watcher test-ip-flow \
  --vm $VM_ID \
  --direction Inbound \
  --local-ip 10.0.2.4 \
  --local-port 3389 \
  --remote-ip 8.8.8.8 \
  --remote-port "*" \
  --protocol TCP \
  --resource-group $RG

# Test: Should be ALLOWED — internal VNet traffic
echo "Testing: Internal VNet traffic (should be ALLOWED)"
az network watcher test-ip-flow \
  --vm $VM_ID \
  --direction Inbound \
  --local-ip 10.0.2.4 \
  --local-port 443 \
  --remote-ip 10.0.1.4 \
  --remote-port "*" \
  --protocol TCP \
  --resource-group $RG
```

---

## Part 3: Deploy Azure Firewall

### Step 3.1 — Create Firewall Public IP and Firewall

```bash
# Create public IP for Azure Firewall
az network public-ip create \
  --name FWPublicIP \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard \
  --allocation-method Static

FW_PUBLIC_IP=$(az network public-ip show \
  --name FWPublicIP \
  --resource-group $RG \
  --query ipAddress --output tsv)
echo "Firewall Public IP: $FW_PUBLIC_IP"

# Create Firewall Policy
az network firewall policy create \
  --name LabFWPolicy \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard \
  --threat-intel-mode Alert

# Deploy Azure Firewall (takes 10-15 minutes)
echo "Deploying Azure Firewall (this takes 10-15 minutes)..."
az network firewall create \
  --name LabFirewall \
  --resource-group $RG \
  --location $LOCATION \
  --sku AZFW_VNet \
  --tier Standard \
  --firewall-policy LabFWPolicy

# Add firewall to VNet
az network firewall ip-config create \
  --firewall-name LabFirewall \
  --resource-group $RG \
  --name FWIPConfig \
  --vnet-name $VNET_NAME \
  --public-ip-address FWPublicIP

# Get Firewall private IP
FW_PRIVATE_IP=$(az network firewall show \
  --name LabFirewall \
  --resource-group $RG \
  --query "ipConfigurations[0].privateIPAddress" --output tsv)
echo "Firewall Private IP: $FW_PRIVATE_IP"
```

### Step 3.2 — Add Firewall Rules

```bash
# Create Rule Collection Group
az network firewall policy rule-collection-group create \
  --name LabRuleCollectionGroup \
  --policy-name LabFWPolicy \
  --resource-group $RG \
  --priority 100

# Add Application Rule: Allow HTTPS to specific FQDNs only
az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group $RG \
  --policy-name LabFWPolicy \
  --rule-collection-group-name LabRuleCollectionGroup \
  --name AllowedWebsites \
  --collection-priority 100 \
  --action Allow \
  --rule-type ApplicationRule \
  --rule-name AllowMicrosoftUpdates \
  --source-addresses "10.0.2.0/24" \
  --protocols "Https=443" \
  --fqdn-tags "WindowsUpdate" "MicrosoftActiveProtectionService"

# Add Network Rule: Allow DNS
az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group $RG \
  --policy-name LabFWPolicy \
  --rule-collection-group-name LabRuleCollectionGroup \
  --name AllowDNS \
  --collection-priority 200 \
  --action Allow \
  --rule-type NetworkRule \
  --rule-name AllowDNSOutbound \
  --source-addresses "10.0.0.0/16" \
  --destination-addresses "168.63.129.16" \
  --destination-ports 53 \
  --ip-protocols UDP TCP
```

### Step 3.3 — Create Route Table to Force Traffic Through Firewall

```bash
# Create route table
az network route-table create \
  --name WorkloadRouteTable \
  --resource-group $RG \
  --location $LOCATION

# Add route: all internet traffic goes through Azure Firewall
az network route-table route create \
  --route-table-name WorkloadRouteTable \
  --resource-group $RG \
  --name ForceToFirewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $FW_PRIVATE_IP

# Associate route table with workload subnet
az network vnet subnet update \
  --name WorkloadSubnet \
  --vnet-name $VNET_NAME \
  --resource-group $RG \
  --route-table WorkloadRouteTable

echo "UDR configured: all outbound traffic from WorkloadSubnet routes through Azure Firewall"
```

---

## Part 4: View Firewall Logs

### Step 4.1 — Enable Diagnostic Logging

```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name FWLogWorkspace \
  --location $LOCATION

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name FWLogWorkspace \
  --query id --output tsv)

FW_ID=$(az network firewall show \
  --name LabFirewall \
  --resource-group $RG \
  --query id --output tsv)

# Enable diagnostic settings
az monitor diagnostic-settings create \
  --name FWDiagnostics \
  --resource $FW_ID \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "AzureFirewallApplicationRule", "enabled": true},
    {"category": "AzureFirewallNetworkRule", "enabled": true},
    {"category": "AzureFirewallDnsProxy", "enabled": true},
    {"category": "AzureFirewallThreatIntelLog", "enabled": true}
  ]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'
```

---

## Cleanup

```bash
az group delete --name $RG --yes --no-wait
echo "Resource group scheduled for deletion"
```

---

## ✅ Verification Checklist

- [ ] VNet with Workload, Firewall, and Bastion subnets created
- [ ] NSG with deny RDP/SSH rules created and applied to WorkloadSubnet
- [ ] IP Flow Verify confirms RDP denied, VNet traffic allowed
- [ ] Azure Firewall deployed with Standard policy
- [ ] Application rules added to allow specific FQDNs
- [ ] Network rules added to allow DNS
- [ ] Route table configured to send all outbound traffic through firewall
- [ ] Diagnostic logging enabled for firewall

---

> ⬅️ [Lab 03: Key Vault](./lab-03-key-vault.md) | ➡️ [Lab 05: Defender for Cloud](./lab-05-defender-for-cloud.md)
