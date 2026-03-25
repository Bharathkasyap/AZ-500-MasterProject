#!/usr/bin/env bash
# =============================================================================
# AZ-500 Lab Script: Secure Networking
# Domain 2 — Secure Networking
#
# Creates a hub-and-spoke VNet topology with:
#   - A hub VNet with Azure Firewall
#   - A spoke VNet with peering
#   - NSGs with security rules
#   - A User-Defined Route (UDR) to force traffic through Azure Firewall
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Azure Firewall requires Standard SKU Public IP
#
# Usage:
#   chmod +x setup-networking.sh
#   ./setup-networking.sh
# =============================================================================

set -euo pipefail

# ─── Variables ────────────────────────────────────────────────────────────────
RESOURCE_GROUP="rg-az500-network-lab"
LOCATION="eastus"
HUB_VNET="vnet-hub"
SPOKE_VNET="vnet-spoke"
FIREWALL_NAME="afw-hub"
FIREWALL_POLICY="afwp-hub"
FIREWALL_PIP="pip-firewall"
ROUTE_TABLE="rt-spoke-to-firewall"

echo "============================================================"
echo " AZ-500 Secure Networking Lab Setup"
echo "============================================================"

# ─── 1. Create Resource Group ─────────────────────────────────────────────────
echo "[1/8] Creating resource group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# ─── 2. Create Hub VNet ───────────────────────────────────────────────────────
echo "[2/8] Creating Hub VNet and subnets"

az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$HUB_VNET" \
  --address-prefix "10.0.0.0/16" \
  --subnet-name "AzureFirewallSubnet" \
  --subnet-prefix "10.0.1.0/26" \
  --output none

# Add AzureBastionSubnet to hub
az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$HUB_VNET" \
  --name "AzureBastionSubnet" \
  --address-prefix "10.0.2.0/26" \
  --output none

echo "    Hub VNet '${HUB_VNET}' created (10.0.0.0/16)"

# ─── 3. Create Spoke VNet with NSG ───────────────────────────────────────────
echo "[3/8] Creating Spoke VNet, subnet, and NSG"

az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SPOKE_VNET" \
  --address-prefix "10.1.0.0/16" \
  --subnet-name "snet-workloads" \
  --subnet-prefix "10.1.1.0/24" \
  --output none

# Create NSG for workload subnet
NSG_NAME="nsg-workloads"
az network nsg create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NSG_NAME" \
  --location "$LOCATION" \
  --output none

# Deny RDP from internet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "DenyRdpFromInternet" \
  --priority 100 \
  --source-address-prefixes "Internet" \
  --destination-port-ranges "3389" \
  --protocol "Tcp" \
  --access "Deny" \
  --direction "Inbound" \
  --output none

# Deny SSH from internet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "DenySSHFromInternet" \
  --priority 110 \
  --source-address-prefixes "Internet" \
  --destination-port-ranges "22" \
  --protocol "Tcp" \
  --access "Deny" \
  --direction "Inbound" \
  --output none

# Allow HTTPS from VNet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "AllowHttpsFromVnet" \
  --priority 200 \
  --source-address-prefixes "VirtualNetwork" \
  --destination-port-ranges "443" \
  --protocol "Tcp" \
  --access "Allow" \
  --direction "Inbound" \
  --output none

# Associate NSG with workload subnet
az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$SPOKE_VNET" \
  --name "snet-workloads" \
  --nsg "$NSG_NAME" \
  --output none

echo "    Spoke VNet '${SPOKE_VNET}' created (10.1.0.0/16)"
echo "    NSG '${NSG_NAME}' applied with DenyRDP, DenySSH, AllowHTTPS rules"

# ─── 4. Peer Hub and Spoke ────────────────────────────────────────────────────
echo "[4/8] Creating VNet peerings (Hub <-> Spoke)"

HUB_ID=$(az network vnet show --resource-group "$RESOURCE_GROUP" --name "$HUB_VNET" --query id --output tsv)
SPOKE_ID=$(az network vnet show --resource-group "$RESOURCE_GROUP" --name "$SPOKE_VNET" --query id --output tsv)

# Hub → Spoke peering (allow gateway transit)
az network vnet peering create \
  --resource-group "$RESOURCE_GROUP" \
  --name "peer-hub-to-spoke" \
  --vnet-name "$HUB_VNET" \
  --remote-vnet "$SPOKE_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit \
  --output none

# Spoke → Hub peering (use remote gateways)
az network vnet peering create \
  --resource-group "$RESOURCE_GROUP" \
  --name "peer-spoke-to-hub" \
  --vnet-name "$SPOKE_VNET" \
  --remote-vnet "$HUB_ID" \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --output none

echo "    Peerings created: Hub ↔ Spoke"

# ─── 5. Create Azure Firewall ─────────────────────────────────────────────────
echo "[5/8] Creating Azure Firewall (this takes ~5 minutes)..."

# Public IP for Firewall
az network public-ip create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$FIREWALL_PIP" \
  --sku Standard \
  --allocation-method Static \
  --output none

# Firewall Policy
az network firewall policy create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$FIREWALL_POLICY" \
  --location "$LOCATION" \
  --sku Standard \
  --threat-intel-mode Alert \
  --output none

# Azure Firewall
az network firewall create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$FIREWALL_NAME" \
  --location "$LOCATION" \
  --sku AZFW_VNet \
  --vnet-name "$HUB_VNET" \
  --public-ip "$FIREWALL_PIP" \
  --firewall-policy "$FIREWALL_POLICY" \
  --output none

# Get Firewall private IP
FIREWALL_PRIVATE_IP=$(az network firewall show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$FIREWALL_NAME" \
  --query "ipConfigurations[0].privateIPAddress" \
  --output tsv)

echo "    Azure Firewall '${FIREWALL_NAME}' created"
echo "    Firewall private IP: $FIREWALL_PRIVATE_IP"

# ─── 6. Add Firewall Application Rule (Allow HTTPS to Microsoft) ─────────────
echo "[6/8] Adding Firewall application rules"

az network firewall policy rule-collection-group create \
  --resource-group "$RESOURCE_GROUP" \
  --policy-name "$FIREWALL_POLICY" \
  --name "DefaultRuleCollectionGroup" \
  --priority 300 \
  --output none

az network firewall policy rule-collection-group collection add-filter-collection \
  --resource-group "$RESOURCE_GROUP" \
  --policy-name "$FIREWALL_POLICY" \
  --rule-collection-group-name "DefaultRuleCollectionGroup" \
  --name "AllowMicrosoftFQDNs" \
  --collection-priority 100 \
  --action Allow \
  --rule-name "AllowMicrosoftUpdate" \
  --rule-type ApplicationRule \
  --protocols "Https=443" \
  --source-addresses "10.1.0.0/16" \
  --target-fqdns "*.microsoft.com" "*.windows.net" "*.azure.com" \
  --output none

echo "    Application rule: Allow HTTPS to *.microsoft.com, *.windows.net, *.azure.com"

# ─── 7. Create User-Defined Route (Force traffic through Firewall) ────────────
echo "[7/8] Creating route table to force spoke traffic through Firewall"

az network route-table create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ROUTE_TABLE" \
  --location "$LOCATION" \
  --disable-bgp-route-propagation \
  --output none

az network route-table route create \
  --resource-group "$RESOURCE_GROUP" \
  --route-table-name "$ROUTE_TABLE" \
  --name "DefaultToFirewall" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type "VirtualAppliance" \
  --next-hop-ip-address "$FIREWALL_PRIVATE_IP" \
  --output none

# Associate route table with spoke workload subnet
az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$SPOKE_VNET" \
  --name "snet-workloads" \
  --route-table "$ROUTE_TABLE" \
  --output none

echo "    UDR: 0.0.0.0/0 → $FIREWALL_PRIVATE_IP (Azure Firewall)"

# ─── 8. Enable DDoS Protection (Standard) on Hub VNet ───────────────────────
echo "[8/8] Note: DDoS Network Protection requires a DDoS Protection Plan (paid)"
echo "    Skipping DDoS plan creation to avoid charges in lab environment."
echo "    To enable: az network ddos-protection create + az network vnet update --ddos-protection true"

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Lab Setup Complete!"
echo "============================================================"
echo " Resource Group:      $RESOURCE_GROUP"
echo " Hub VNet:            $HUB_VNET (10.0.0.0/16)"
echo " Spoke VNet:          $SPOKE_VNET (10.1.0.0/16)"
echo " Azure Firewall:      $FIREWALL_NAME ($FIREWALL_PRIVATE_IP)"
echo " NSG:                 $NSG_NAME (DenyRDP, DenySSH from Internet)"
echo " Route Table:         $ROUTE_TABLE (0.0.0.0/0 → Firewall)"
echo ""
echo " AZ-500 Exam Concepts Demonstrated:"
echo "   ✅ Hub-and-spoke VNet topology"
echo "   ✅ VNet peering (hub ↔ spoke)"
echo "   ✅ NSG rules (deny management ports from internet)"
echo "   ✅ Azure Firewall with Firewall Policy"
echo "   ✅ Threat Intelligence mode (Alert)"
echo "   ✅ Application rules (FQDN-based)"
echo "   ✅ User-Defined Routes (forced tunneling through Firewall)"
echo ""
echo " To clean up: az group delete --name $RESOURCE_GROUP --yes --no-wait"
