# Lab 02 — Deploy and Manage Azure Key Vault

## Objective

By the end of this lab you will be able to:
- Create an Azure Key Vault with RBAC authorization
- Store and retrieve a secret
- Enable soft delete and purge protection
- Configure a Private Endpoint to remove public access
- Enable diagnostic logging to a Log Analytics workspace

---

## Prerequisites

- An Azure subscription
- Owner or Contributor role on a resource group
- Azure CLI installed (or use Azure Cloud Shell)

---

## Part 1 — Create a Resource Group and Key Vault

### Using Azure CLI

```bash
# Variables
RESOURCE_GROUP="rg-keyvault-lab"
LOCATION="eastus"
KEY_VAULT_NAME="kv-az500lab-$RANDOM"   # must be globally unique
LOG_WORKSPACE="law-az500lab"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Key Vault with RBAC authorization (recommended)
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --soft-delete-retention-days 90 \
  --enable-purge-protection true \
  --sku standard

echo "Key Vault created: $KEY_VAULT_NAME"
```

> **Note**: Once `--enable-purge-protection` is set to `true`, it **cannot be disabled**. Be aware of this in lab environments.

---

## Part 2 — Assign RBAC Role for Key Vault Secrets

```bash
# Get your own object ID
MY_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

# Get Key Vault resource ID
KV_ID=$(az keyvault show --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)

# Assign Key Vault Secrets Officer role
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee-object-id $MY_OBJECT_ID \
  --assignee-principal-type User \
  --scope $KV_ID

echo "RBAC role assigned"
```

---

## Part 3 — Create, Retrieve, and Update a Secret

```bash
# Create a secret
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password" \
  --value "P@ssw0rd!SuperSecret123"

# Retrieve the secret value
az keyvault secret show \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password" \
  --query value \
  --output tsv

# Create a new version of the secret
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password" \
  --value "NewP@ssw0rd!456"

# List secret versions
az keyvault secret list-versions \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password" \
  --query "[].{Version:id, Created:attributes.created, Enabled:attributes.enabled}" \
  --output table
```

---

## Part 4 — Create a Key and Encrypt Data

```bash
# Create an RSA key
az keyvault key create \
  --vault-name $KEY_VAULT_NAME \
  --name "my-rsa-key" \
  --kty RSA \
  --size 2048

# List keys
az keyvault key list \
  --vault-name $KEY_VAULT_NAME \
  --output table

# Get key details
az keyvault key show \
  --vault-name $KEY_VAULT_NAME \
  --name "my-rsa-key"
```

---

## Part 5 — Configure a Private Endpoint

This removes public internet access to the Key Vault.

```bash
# Create a VNet and subnet for the private endpoint
VNET_NAME="vnet-lab"
SUBNET_NAME="snet-private-endpoints"

az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --address-prefix 10.0.1.0/24

# Disable network policies on the subnet (required for private endpoints)
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --disable-private-endpoint-network-policies true

# Create private endpoint
az network private-endpoint create \
  --name pe-keyvault \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --private-connection-resource-id $KV_ID \
  --group-id vault \
  --connection-name conn-keyvault

# Create private DNS zone
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name "privatelink.vaultcore.azure.net"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name "privatelink.vaultcore.azure.net" \
  --name link-keyvault-vnet \
  --virtual-network $VNET_NAME \
  --registration-enabled false

# Create DNS zone group (auto-registers PE DNS records)
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-keyvault \
  --name default \
  --private-dns-zone "privatelink.vaultcore.azure.net" \
  --zone-name "privatelink.vaultcore.azure.net"

echo "Private Endpoint configured"
```

### Disable Public Network Access

```bash
az keyvault update \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --public-network-access Disabled

echo "Public network access disabled — vault is now accessible only via Private Endpoint"
```

---

## Part 6 — Enable Diagnostic Logging

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_WORKSPACE \
  --location $LOCATION

LOG_WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_WORKSPACE \
  --query id -o tsv)

# Enable diagnostics for Key Vault
az monitor diagnostic-settings create \
  --name kv-diagnostics \
  --resource $KV_ID \
  --workspace $LOG_WORKSPACE_ID \
  --logs '[{"category":"AuditEvent","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}]' \
  --metrics '[{"category":"AllMetrics","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}]'

echo "Diagnostic settings configured"
```

---

## Part 7 — Test Soft Delete

```bash
# Delete the secret
az keyvault secret delete \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password"

# Show deleted secrets (soft-deleted, not yet purged)
az keyvault secret list-deleted \
  --vault-name $KEY_VAULT_NAME \
  --output table

# Recover the deleted secret
az keyvault secret recover \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password"

# Verify recovery
az keyvault secret show \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password" \
  --query value \
  --output tsv
```

---

## Cleanup

```bash
# Delete the resource group (removes all resources)
az group delete --name $RESOURCE_GROUP --yes --no-wait
echo "Cleanup initiated"
```

> **Important**: Due to **purge protection**, the Key Vault will remain in a "deleted" state for 90 days (the soft-delete retention period) before it is permanently removed.

---

## Key Takeaways

- **RBAC authorization** is the recommended (and more granular) access model for Key Vault.
- **Soft delete + Purge Protection** prevent accidental or malicious permanent deletion.
- **Private Endpoint** eliminates public internet exposure — the DNS must also be updated.
- **Diagnostic logging** to Log Analytics enables Sentinel and Defender for Key Vault alerts.
- All Key Vault operations are logged in the `AuditEvent` log category.
