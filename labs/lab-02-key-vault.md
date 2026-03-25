# Lab 02 — Deploy and Secure Azure Key Vault

> **Estimated time:** 45–60 minutes  
> **Prerequisites:** Azure subscription, Contributor rights on a resource group  
> **Skills practiced:** Domain 3 — Secure Compute, Storage, and Databases

---

## Objectives

By the end of this lab you will be able to:

1. Create an Azure Key Vault with RBAC access model.
2. Store a secret and a key in Key Vault.
3. Assign Key Vault RBAC roles to a user and a managed identity.
4. Restrict Key Vault network access (firewall + private endpoint concept).
5. Enable soft-delete and purge protection.
6. Retrieve a secret from a Virtual Machine using its managed identity.

---

## Architecture

```
Resource Group: rg-az500-lab02
  │
  ├── Key Vault: kv-az500-<suffix>
  │     ├── Secret: db-connection-string
  │     ├── Key: cmk-storage-key
  │     ├── RBAC: testuser → Key Vault Secrets User
  │     ├── RBAC: vm-identity → Key Vault Secrets User
  │     └── Firewall: Allow only lab VM IP + VNet
  │
  └── VM: vm-az500-lab02 (with system-assigned managed identity)
```

---

## Part 1 — Create a Resource Group and Key Vault

### Azure CLI

```bash
# Variables
RG="rg-az500-lab02"
LOCATION="eastus"
KV_NAME="kv-az500-$RANDOM"
VM_NAME="vm-az500-lab02"

# Create resource group
az group create --name $RG --location $LOCATION

# Create Key Vault with RBAC model (not access policies)
az keyvault create \
  --name $KV_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --soft-delete-retention-days 90 \
  --enable-purge-protection true

echo "Key Vault name: $KV_NAME"
```

> **Note:** Once purge protection is enabled, it **cannot be disabled**.

### Verify in Portal
1. Navigate to the Key Vault in the Azure portal.
2. Check **Settings** → **Properties**:
   - Soft delete: Enabled (90 days)
   - Purge protection: Enabled
   - Vault access policy: **Azure role-based access control** ← important

---

## Part 2 — Assign RBAC Roles

### Assign yourself Key Vault Administrator (to manage the vault)

```bash
# Get your user object ID
MY_USER_ID=$(az ad signed-in-user show --query id -o tsv)

# Get Key Vault resource ID
KV_ID=$(az keyvault show --name $KV_NAME --resource-group $RG --query id -o tsv)

# Assign Key Vault Administrator role (full data plane access)
az role assignment create \
  --assignee $MY_USER_ID \
  --role "Key Vault Administrator" \
  --scope $KV_ID
```

### Assign a test user the Secrets User role (read secrets only)

```bash
# Get the test user's object ID (created in Lab 01, or create a new one)
TEST_USER_ID=$(az ad user show --id "az500-testuser@<yourtenant>.onmicrosoft.com" --query id -o tsv)

az role assignment create \
  --assignee $TEST_USER_ID \
  --role "Key Vault Secrets User" \
  --scope "$KV_ID/secrets"  # Scope to secrets only
```

---

## Part 3 — Store a Secret and a Key

### Store a Secret

```bash
# Store a database connection string as a secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "db-connection-string" \
  --value "Server=sql.database.windows.net;Database=mydb;User=admin;Password=S3cur3P@ss;" \
  --description "Production database connection string" \
  --expires "2026-12-31T00:00:00Z"

# Verify
az keyvault secret show \
  --vault-name $KV_NAME \
  --name "db-connection-string" \
  --query "value" -o tsv
```

### Create a Key (for encryption)

```bash
# Create an RSA 2048-bit key
az keyvault key create \
  --vault-name $KV_NAME \
  --name "cmk-storage-key" \
  --kty RSA \
  --size 2048 \
  --protection software \
  --ops encrypt decrypt wrapKey unwrapKey

# List keys
az keyvault key list --vault-name $KV_NAME -o table
```

---

## Part 4 — Configure Key Vault Firewall

### Restrict to Your IP Only

```bash
# Get your current public IP
MY_IP=$(curl -s https://ipinfo.io/ip)
echo "Your IP: $MY_IP"

# Enable Key Vault firewall (deny all by default)
az keyvault update \
  --name $KV_NAME \
  --resource-group $RG \
  --default-action Deny \
  --bypass AzureServices \
  --ip-address $MY_IP/32

# Verify - this should still work (your IP is allowed)
az keyvault secret show \
  --vault-name $KV_NAME \
  --name "db-connection-string" \
  --query "value" -o tsv
```

> **Exam tip:** `--bypass AzureServices` allows trusted Microsoft services (like Azure Backup, Azure Monitor) to access the vault even when the firewall is active.

---

## Part 5 — Use Managed Identity to Access Key Vault

### Create a VM with System-Assigned Managed Identity

```bash
# Create VM with managed identity
az vm create \
  --resource-group $RG \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size Standard_B1ms \
  --admin-username azureuser \
  --generate-ssh-keys \
  --assign-identity "[system]" \
  --public-ip-sku Standard

# Get the VM's managed identity principal ID
VM_IDENTITY=$(az vm show \
  --resource-group $RG \
  --name $VM_NAME \
  --query "identity.principalId" -o tsv)

echo "VM Identity Principal ID: $VM_IDENTITY"
```

### Assign Key Vault Secrets User to VM Identity

```bash
# Allow VM identity to read secrets
az role assignment create \
  --assignee $VM_IDENTITY \
  --role "Key Vault Secrets User" \
  --scope "$KV_ID/secrets"

# Add VM's subnet to Key Vault network rules
VM_NIC=$(az vm show --resource-group $RG --name $VM_NAME --query "networkProfile.networkInterfaces[0].id" -o tsv)
VM_SUBNET=$(az network nic show --ids $VM_NIC --query "ipConfigurations[0].subnet.id" -o tsv)

# Enable service endpoint on the subnet (if needed)
VNET_RG=$(az network nic show --ids $VM_NIC --query "resourceGroup" -o tsv)
VNET_NAME=$(az network vnet list --resource-group $VNET_RG --query "[0].name" -o tsv)
SUBNET_NAME=$(az network vnet subnet list --resource-group $VNET_RG --vnet-name $VNET_NAME --query "[0].name" -o tsv)

az network vnet subnet update \
  --resource-group $VNET_RG \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --service-endpoints Microsoft.KeyVault

# Add subnet to Key Vault network rules
az keyvault network-rule add \
  --name $KV_NAME \
  --resource-group $RG \
  --subnet $VM_SUBNET
```

### Test — Retrieve Secret from the VM

```bash
# SSH into the VM
ssh azureuser@$(az vm list-ip-addresses --resource-group $RG --name $VM_NAME --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)

# Inside the VM — get an access token for Key Vault
TOKEN=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=https://vault.azure.net' -H 'Metadata: true' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Use the token to retrieve the secret
curl -s "https://<KV_NAME>.vault.azure.net/secrets/db-connection-string?api-version=7.4" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```

> **Expected result:** The secret value is returned. The VM authenticated using its managed identity — **no credentials were needed**.

---

## Part 6 — Key Vault Diagnostic Logging

```bash
# Create a Log Analytics workspace
LA_WORKSPACE="law-az500-lab02"
az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name $LA_WORKSPACE \
  --location $LOCATION

LA_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name $LA_WORKSPACE \
  --query id -o tsv)

# Enable diagnostic settings for Key Vault
az monitor diagnostic-settings create \
  --name "kv-diagnostics" \
  --resource $KV_ID \
  --workspace $LA_ID \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
```

### Query Key Vault Audit Logs in Log Analytics

```kql
AzureDiagnostics
| where ResourceType == "VAULTS"
| where TimeGenerated > ago(1h)
| project TimeGenerated, OperationName, ResultType, CallerIPAddress, identity_claim_oid_g
| order by TimeGenerated desc
```

---

## Cleanup

```bash
# Delete the resource group (removes everything)
az group delete --name $RG --yes --no-wait
```

> **Warning:** Deleted Key Vaults with purge protection can still be recovered during the soft-delete retention period. They appear in **Deleted vaults** in the portal.

---

## Key Takeaways

- **RBAC model** for Key Vault is preferred over access policies for new deployments.
- **Managed identities** eliminate the need for storing credentials — the identity is managed by Azure.
- **Scope role assignments** as narrowly as possible (e.g., only to `/secrets`, not the entire vault).
- **Purge protection** prevents permanent deletion even by administrators — important for compliance.
- **Key Vault Diagnostic Logs** provide an audit trail of all secret/key access events.
- The Key Vault **firewall** must explicitly allow the VM's subnet or IP — just having an RBAC role is not enough.
