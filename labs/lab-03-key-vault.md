# Lab 03: Azure Key Vault

> **Domain**: Compute, Storage & Databases | **Difficulty**: Intermediate | **Time**: ~35 minutes

---

## Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed and authenticated

---

## Objectives

By the end of this lab, you will be able to:
- Create an Azure Key Vault with RBAC authorization
- Add secrets, keys, and certificates
- Configure Key Vault network access restrictions
- Access Key Vault secrets using a managed identity
- Enable diagnostic logging for Key Vault

---

## Part 1: Create Key Vault

### Step 1.1 — Create Resource Group and Key Vault

```bash
# Variables
RG="KeyVaultLabRG"
LOCATION="eastus"
KV_NAME="kvlab$RANDOM"  # Must be globally unique

# Create resource group
az group create --name $RG --location $LOCATION

# Create Key Vault with RBAC authorization and secure settings
az keyvault create \
  --name $KV_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --soft-delete-retention-days 7 \
  --enable-purge-protection true

echo "Key Vault created: $KV_NAME"
KV_ID=$(az keyvault show --name $KV_NAME --resource-group $RG --query id --output tsv)
echo "Key Vault Resource ID: $KV_ID"
```

### Step 1.2 — Assign Key Vault Administrator Role to Yourself

```bash
# Get your current user's object ID
MY_USER_ID=$(az ad signed-in-user show --query id --output tsv)

# Assign Key Vault Administrator role
az role assignment create \
  --assignee $MY_USER_ID \
  --role "Key Vault Administrator" \
  --scope $KV_ID

echo "Role assigned: Key Vault Administrator"
```

---

## Part 2: Manage Secrets, Keys, and Certificates

### Step 2.1 — Create and Retrieve a Secret

```bash
# Create a secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "DatabaseConnectionString" \
  --value "Server=myserver.database.windows.net;Database=mydb;User=admin;Password=P@ssw0rd!"

# Create a secret with expiration (expires in 1 year)
EXPIRY_DATE=$(date -d "+1 year" --utc +%Y-%m-%dT%H:%MZ)
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "APIKey" \
  --value "my-super-secret-api-key-12345" \
  --expires $EXPIRY_DATE

# List secrets
az keyvault secret list \
  --vault-name $KV_NAME \
  --output table

# Retrieve secret value
SECRET_VALUE=$(az keyvault secret show \
  --vault-name $KV_NAME \
  --name "DatabaseConnectionString" \
  --query value --output tsv)
echo "Secret retrieved successfully (masked): ${SECRET_VALUE:0:10}..."
```

### Step 2.2 — Create an Encryption Key

```bash
# Create RSA 2048 key
az keyvault key create \
  --vault-name $KV_NAME \
  --name "MyEncryptionKey" \
  --kty RSA \
  --size 2048

# Create EC key (Elliptic Curve)
az keyvault key create \
  --vault-name $KV_NAME \
  --name "MySigningKey" \
  --kty EC \
  --curve P-256

# List keys
az keyvault key list \
  --vault-name $KV_NAME \
  --output table

# Get key attributes
az keyvault key show \
  --vault-name $KV_NAME \
  --name "MyEncryptionKey" \
  --query "{name:name, enabled:attributes.enabled, keyType:keyType, keySize:key.n}"
```

### Step 2.3 — Create a Self-Signed Certificate

```bash
# Create a certificate policy file
cat > /tmp/cert-policy.json << 'EOF'
{
  "issuerParameters": {
    "name": "Self"
  },
  "keyProperties": {
    "exportable": true,
    "keySize": 2048,
    "keyType": "RSA",
    "reuseKey": false
  },
  "lifetimeActions": [
    {
      "action": {
        "actionType": "AutoRenew"
      },
      "trigger": {
        "daysBeforeExpiry": 30
      }
    }
  ],
  "secretProperties": {
    "contentType": "application/x-pkcs12"
  },
  "x509CertificateProperties": {
    "subject": "CN=myapp.contoso.com",
    "validityInMonths": 12
  }
}
EOF

# Create the certificate
az keyvault certificate create \
  --vault-name $KV_NAME \
  --name "MyAppCertificate" \
  --policy @/tmp/cert-policy.json

# Check certificate creation status
az keyvault certificate show \
  --vault-name $KV_NAME \
  --name "MyAppCertificate" \
  --query "{name:name, status:properties.status, subject:cer[0].subject}"
```

---

## Part 3: Configure Network Access Restrictions

### Step 3.1 — Create a VNet and Subnet

```bash
# Create VNet
az network vnet create \
  --name KVLabVNet \
  --resource-group $RG \
  --address-prefix 10.0.0.0/16 \
  --subnet-name default \
  --subnet-prefix 10.0.0.0/24

# Enable Key Vault service endpoint on subnet
az network vnet subnet update \
  --name default \
  --vnet-name KVLabVNet \
  --resource-group $RG \
  --service-endpoints Microsoft.KeyVault
```

### Step 3.2 — Restrict Key Vault Network Access

```bash
# Get subnet ID
SUBNET_ID=$(az network vnet subnet show \
  --name default \
  --vnet-name KVLabVNet \
  --resource-group $RG \
  --query id --output tsv)

# Add VNet rule
az keyvault network-rule add \
  --name $KV_NAME \
  --resource-group $RG \
  --subnet $SUBNET_ID

# Set default action to Deny and allow Azure services
az keyvault update \
  --name $KV_NAME \
  --resource-group $RG \
  --default-action Deny \
  --bypass AzureServices

echo "Network restrictions applied: only VNet subnet and Azure services can access Key Vault"

# Note: Your current IP is now blocked. To re-enable access for testing:
MY_IP=$(curl -s ifconfig.me)
az keyvault network-rule add \
  --name $KV_NAME \
  --resource-group $RG \
  --ip-address $MY_IP
```

---

## Part 4: Access Key Vault with Managed Identity

### Step 4.1 — Create a VM with Managed Identity

```bash
# Create VM with system-assigned managed identity
az vm create \
  --name KVLabVM \
  --resource-group $RG \
  --image Ubuntu2204 \
  --vnet-name KVLabVNet \
  --subnet default \
  --assign-identity \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_B1s

# Get VM's managed identity object ID
VM_IDENTITY=$(az vm show \
  --name KVLabVM \
  --resource-group $RG \
  --query "identity.principalId" --output tsv)
echo "VM Managed Identity Object ID: $VM_IDENTITY"
```

### Step 4.2 — Grant Managed Identity Access to Key Vault

```bash
# Assign Key Vault Secrets User role to the VM's managed identity
az role assignment create \
  --assignee $VM_IDENTITY \
  --role "Key Vault Secrets User" \
  --scope $KV_ID

echo "Key Vault Secrets User role assigned to VM managed identity"
```

### Step 4.3 — Test Access from VM

```bash
# SSH into the VM and run these commands:
# (Replace <VM_PUBLIC_IP> with the actual public IP)
ssh azureuser@<VM_PUBLIC_IP>

# On the VM, retrieve the secret using the managed identity token:
# Get access token from Instance Metadata Service (IMDS)
TOKEN=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' \
  -H 'Metadata: true' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Use token to retrieve secret
curl -s "https://$KV_NAME.vault.azure.net/secrets/DatabaseConnectionString?api-version=7.4" \
  -H "Authorization: Bearer $TOKEN" | python3 -c "import sys,json; print(json.load(sys.stdin)['value'])"
```

---

## Part 5: Enable Diagnostic Logging

### Step 5.1 — Create Log Analytics Workspace and Enable Logs

```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name KVLabWorkspace \
  --location $LOCATION

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name KVLabWorkspace \
  --query id --output tsv)

# Enable diagnostic settings for Key Vault
az monitor diagnostic-settings create \
  --name KVAuditLogs \
  --resource $KV_ID \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "AuditEvent", "enabled": true, "retentionPolicy": {"enabled": true, "days": 90}},
    {"category": "AzurePolicyEvaluationDetails", "enabled": true, "retentionPolicy": {"enabled": true, "days": 90}}
  ]'

echo "Diagnostic logging enabled for Key Vault"
```

### Step 5.2 — Query Key Vault Audit Logs

```bash
# After some operations, query the logs (may take 5-10 minutes to appear)
az monitor log-analytics query \
  --workspace $WORKSPACE_ID \
  --analytics-query "AzureDiagnostics | where ResourceType == 'VAULTS' | where TimeGenerated > ago(1h) | project TimeGenerated, OperationName, CallerIPAddress, ResultType | take 20" \
  --output table
```

---

## Cleanup

```bash
# Delete resource group (deletes all resources)
az group delete --name $RG --yes --no-wait

echo "Resources scheduled for deletion"
```

> ⚠️ **Note**: Key Vault with purge protection enabled cannot be immediately deleted. It will be soft-deleted for the retention period (7 days).

---

## ✅ Verification Checklist

- [ ] Key Vault created with RBAC authorization
- [ ] Soft delete and purge protection enabled
- [ ] Secret, key, and certificate created
- [ ] Network access restricted to VNet subnet
- [ ] VM with system-assigned managed identity created
- [ ] Managed identity granted `Key Vault Secrets User` role
- [ ] Secret successfully retrieved from VM using managed identity token
- [ ] Diagnostic logging enabled to Log Analytics

---

> ⬅️ [Lab 02: RBAC](./lab-02-rbac-assignments.md) | ➡️ [Lab 04: NSG & Azure Firewall](./lab-04-nsg-afd.md)
