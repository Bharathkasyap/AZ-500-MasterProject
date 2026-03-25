#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script — Domain 2: Secure Networking
# Provisions: Hub-spoke VNet topology, Azure Firewall with policy + FQDN rules,
#             NSG with deny rules, UDR forced tunneling
#
# Usage:
#   export SUBSCRIPTION_ID="<your-subscription-id>"
#   chmod +x setup-networking.sh
#   ./setup-networking.sh
#
# Cleanup:
#   az group delete --name az500-networking-rg --yes --no-wait
#
# ⚠️  COST WARNING: Azure Firewall costs ~$1.25/hr. Clean up promptly.
# =============================================================================
set -euo pipefail

# ---------- Configuration ----------------------------------------------------
RESOURCE_GROUP="az500-networking-rg"
LOCATION="${LOCATION:-eastus}"
HUB_VNET="hub-vnet"
SPOKE_VNET="spoke-vnet"
TIMESTAMP=$(date +%s | tail -c 8)

# ---------- Helper ------------------------------------------------------------
log() { echo "[$(date '+%H:%M:%S')] $*"; }

# ---------- Resource Group ---------------------------------------------------
log "Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# ---------- Hub VNet + Subnets -----------------------------------------------
log "Creating Hub VNet (10.0.0.0/16)"
az network vnet create \
  --name "$HUB_VNET" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --address-prefix 10.0.0.0/16 \
  --output none

log "Creating AzureFirewallSubnet (/26)"
az network vnet subnet create \
  --name AzureFirewallSubnet \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$HUB_VNET" \
  --address-prefix 10.0.1.0/26 \
  --output none

log "Creating AzureBastionSubnet (/26)"
az network vnet subnet create \
  --name AzureBastionSubnet \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$HUB_VNET" \
  --address-prefix 10.0.2.0/26 \
  --output none

# ---------- Spoke VNet + Subnets ---------------------------------------------
log "Creating Spoke VNet (10.1.0.0/16)"
az network vnet create \
  --name "$SPOKE_VNET" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --address-prefix 10.1.0.0/16 \
  --output none

log "Creating workload-subnet in Spoke"
az network vnet subnet create \
  --name workload-subnet \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$SPOKE_VNET" \
  --address-prefix 10.1.1.0/24 \
  --output none

# ---------- VNet Peering (Hub ↔ Spoke) ---------------------------------------
log "Creating VNet peering: Hub → Spoke"
az network vnet peering create \
  --name hub-to-spoke \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$HUB_VNET" \
  --remote-vnet "$SPOKE_VNET" \
  --allow-forwarded-traffic \
  --allow-gateway-transit \
  --output none

log "Creating VNet peering: Spoke → Hub"
az network vnet peering create \
  --name spoke-to-hub \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$SPOKE_VNET" \
  --remote-vnet "$HUB_VNET" \
  --allow-forwarded-traffic \
  --output none

# ---------- Azure Firewall ---------------------------------------------------
log "Creating public IP for Azure Firewall"
az network public-ip create \
  --name fw-pip \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --allocation-method Static \
  --sku Standard \
  --output none

log "Creating Azure Firewall Policy"
az network firewall policy create \
  --name lab-fw-policy \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

log "Creating Azure Firewall (this takes 5–10 minutes...)"
az network firewall create \
  --name lab-firewall \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --firewall-policy lab-fw-policy \
  --vnet-name "$HUB_VNET" \
  --output none

log "Adding IP configuration to Firewall"
az network firewall ip-config create \
  --name fw-ipconfig \
  --firewall-name lab-firewall \
  --resource-group "$RESOURCE_GROUP" \
  --public-ip-address fw-pip \
  --vnet-name "$HUB_VNET" \
  --output none

FW_PRIVATE_IP=$(az network firewall show \
  --name lab-firewall \
  --resource-group "$RESOURCE_GROUP" \
  --query 'ipConfigurations[0].privateIPAddress' -o tsv)

log "Firewall private IP: $FW_PRIVATE_IP"

# ---------- Firewall Rules ---------------------------------------------------
log "Creating rule collection group"
az network firewall policy rule-collection-group create \
  --name lab-rcg \
  --policy-name lab-fw-policy \
  --resource-group "$RESOURCE_GROUP" \
  --priority 100 \
  --output none

log "Adding application rule: Allow HTTPS to WindowsUpdate"
az network firewall policy rule-collection-group collection add-filter-collection \
  --name allow-microsoft-update \
  --collection-priority 100 \
  --policy-name lab-fw-policy \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name lab-rcg \
  --action Allow \
  --rule-type ApplicationRule \
  --rule-name allow-windows-update \
  --protocols Https=443 \
  --fqdn-tags WindowsUpdate \
  --source-addresses 10.1.0.0/16 \
  --output none

log "Adding network rule: Allow DNS outbound"
az network firewall policy rule-collection-group collection add-filter-collection \
  --name allow-dns \
  --collection-priority 200 \
  --policy-name lab-fw-policy \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name lab-rcg \
  --action Allow \
  --rule-type NetworkRule \
  --rule-name allow-dns-out \
  --protocols UDP \
  --destination-ports 53 \
  --source-addresses 10.1.0.0/16 \
  --destination-addresses '*' \
  --output none

# ---------- UDR — Forced Tunneling -------------------------------------------
log "Creating route table for forced tunneling"
az network route-table create \
  --name spoke-udr \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

log "Adding default route → Azure Firewall"
az network route-table route create \
  --route-table-name spoke-udr \
  --resource-group "$RESOURCE_GROUP" \
  --name default-to-firewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address "$FW_PRIVATE_IP" \
  --output none

log "Associating route table with spoke workload subnet"
az network vnet subnet update \
  --name workload-subnet \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$SPOKE_VNET" \
  --route-table spoke-udr \
  --output none

# ---------- NSG with Deny Rules ----------------------------------------------
log "Creating ASGs (web and db tiers)"
az network asg create \
  --name asg-web \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

az network asg create \
  --name asg-db \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

log "Creating NSG with deny-by-default rules"
az network nsg create \
  --name workload-nsg \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

log "Adding NSG rule: allow web → db on 1433"
az network nsg rule create \
  --name allow-web-to-db \
  --nsg-name workload-nsg \
  --resource-group "$RESOURCE_GROUP" \
  --priority 100 \
  --protocol Tcp \
  --source-asg asg-web \
  --destination-asg asg-db \
  --destination-port-ranges 1433 \
  --access Allow \
  --direction Inbound \
  --output none

log "Adding NSG rule: deny all to db (catch-all)"
az network nsg rule create \
  --name deny-all-to-db \
  --nsg-name workload-nsg \
  --resource-group "$RESOURCE_GROUP" \
  --priority 4000 \
  --protocol '*' \
  --source-address-prefixes '*' \
  --destination-asg asg-db \
  --destination-port-ranges '*' \
  --access Deny \
  --direction Inbound \
  --output none

log "Associating NSG with workload subnet"
az network vnet subnet update \
  --name workload-subnet \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$SPOKE_VNET" \
  --nsg workload-nsg \
  --output none

# ---------- Summary -----------------------------------------------------------
cat <<EOF

=============================================================================
 AZ-500 Networking Lab — Provisioning Complete
=============================================================================
 Resource Group  : $RESOURCE_GROUP
 Hub VNet        : $HUB_VNET (10.0.0.0/16)
 Spoke VNet      : $SPOKE_VNET (10.1.0.0/16)
 Peering         : hub ↔ spoke (bidirectional)
 Azure Firewall  : lab-firewall (private IP: $FW_PRIVATE_IP)
   - Application rule: Allow HTTPS to WindowsUpdate from spoke
   - Network rule    : Allow DNS outbound from spoke
 UDR             : 0.0.0.0/0 → $FW_PRIVATE_IP on workload-subnet
 NSG             : workload-nsg
   - Allow web ASG → db ASG on TCP/1433
   - Deny all → db ASG (catchall)

 ⚠️  COST NOTICE: Azure Firewall costs ~$1.25/hr + data fees.
 🧹  CLEANUP:
     az group delete --name $RESOURCE_GROUP --yes --no-wait
=============================================================================
EOF
