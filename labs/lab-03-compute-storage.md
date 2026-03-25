# Lab 03: Secure Compute, Storage, and Databases

> **Estimated Time:** 60–90 minutes  
> **Domain:** 3 — Secure Compute, Storage, and Databases  
> **Prerequisites:** Azure subscription, Azure CLI, Contributor permissions, Microsoft Defender for Servers (for JIT)

---

## Lab Overview

In this lab, you will:
1. Configure a VM with Azure Disk Encryption (ADE)
2. Enable Just-in-Time (JIT) VM Access
3. Deploy a secure Azure Storage account (HTTPS-only, no public access, CMK)
4. Configure Azure SQL Database with Azure AD auth, TDE, and auditing
5. Enable Microsoft Defender for SQL and review vulnerability assessment

---

## Exercise 1: Virtual Machine Security

### Task 1.1: Create a VM and enable Azure Disk Encryption

```bash
RESOURCE_GROUP="rg-az500-compute-lab"
LOCATION="eastus"
KEYVAULT_NAME="kv-ade-$(openssl rand -hex 4)"

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Create Key Vault for ADE keys (requires standard SKU and soft delete)
az keyvault create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$KEYVAULT_NAME" \
  --location "$LOCATION" \
  --sku standard \
  --enable-disk-encryption true \
  --enabled-for-disk-encryption true \
  --enable-purge-protection true

# Create VM
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "vm-ade-lab" \
  --image "Win2022Datacenter" \
  --size Standard_B2s \
  --admin-username "azureadmin" \
  --admin-password "Az500Lab!Password$(openssl rand -hex 4)" \
  --public-ip-address "" \
  --output none

echo "VM created. Enabling Azure Disk Encryption..."

# Enable ADE (encrypts OS and data disks)
az vm encryption enable \
  --resource-group "$RESOURCE_GROUP" \
  --name "vm-ade-lab" \
  --disk-encryption-keyvault "$KEYVAULT_NAME" \
  --volume-type All

# Verify encryption status
az vm encryption show \
  --resource-group "$RESOURCE_GROUP" \
  --name "vm-ade-lab" \
  --query "[osDisk.encryptionSettings, dataDisks]" \
  --output json
```

✅ **Validation:** `osDisk.encryptionSettings.enabled` should be `true`.

### Task 1.2: Enable Azure Bastion (optional — for secure RDP/SSH)

```bash
# Add AzureBastionSubnet to an existing VNet
az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "vnet-lab" \
  --name "AzureBastionSubnet" \
  --address-prefix "10.10.3.0/26"

# Public IP for Bastion
az network public-ip create \
  --resource-group "$RESOURCE_GROUP" \
  --name "pip-bastion" \
  --sku Standard \
  --allocation-method Static

# Create Bastion host
az network bastion create \
  --resource-group "$RESOURCE_GROUP" \
  --name "bastion-lab" \
  --public-ip-address "pip-bastion" \
  --vnet-name "vnet-lab" \
  --location "$LOCATION"
```

> ⚠️ Azure Bastion takes ~5–10 minutes to deploy. After deployment, access VMs via **Azure Portal** → VM → **Connect** → **Bastion**.

---

## Exercise 2: Just-in-Time (JIT) VM Access

### Task 2.1: Enable Defender for Servers (required for JIT)

> ⚠️ Defender for Servers Plan 2 incurs costs. Disable after the lab.

```bash
# Enable Defender for Servers Plan 2
az security pricing create \
  --name "VirtualMachines" \
  --tier "Standard"
```

### Task 2.2: Configure JIT policy via portal

1. Navigate to **Microsoft Defender for Cloud** → **Workload protections** → **Just-in-time VM access**
2. Find `vm-ade-lab` under the **Not Configured** tab → Click **Enable JIT on 1 VM**
3. Review the default ports (22, 3389, 5985, 5986) and configure:
   - **Port:** 22 (SSH)
   - **Protocol:** TCP
   - **Allowed source IPs:** My IP (or On request)
   - **Max request time:** 3 hours
4. Click **Save**

### Task 2.3: Request JIT access

```bash
# Get VM resource ID
VM_ID=$(az vm show -g "$RESOURCE_GROUP" -n "vm-ade-lab" --query id -o tsv)

# Request JIT access (replace with your public IP)
MY_IP=$(curl -s https://api.ipify.org)

az security jit-access-policy initiate \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --name "default" \
  --virtual-machine "$VM_ID" \
  --ports "[{\"number\":22,\"duration\":\"PT3H\",\"allowedSourceAddressPrefix\":[\"${MY_IP}\"]}]"
```

✅ **Validation:** After the request, an NSG rule allowing SSH from your IP is created with an expiry time. Check the VM's NSG in the portal.

---

## Exercise 3: Secure Azure Storage Account

### Task 3.1: Create a storage account with security best practices

```bash
STORAGE_NAME="staz500sec$(openssl rand -hex 4)"

az storage account create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$STORAGE_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --default-action Deny \
  --allow-shared-key-access false
```

> 💡 `--allow-shared-key-access false` disables storage account key access — all access must use Azure AD identities. This is the most secure configuration.

### Task 3.2: Generate a User Delegation SAS

```bash
# Grant yourself Blob Data Contributor first
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
MY_OID=$(az ad signed-in-user show --query id -o tsv)

az role assignment create \
  --assignee "$MY_OID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_NAME"

# Create a container
az storage container create \
  --account-name "$STORAGE_NAME" \
  --name "secure-container" \
  --auth-mode login

# Generate a User Delegation SAS (valid for 1 hour)
az storage blob generate-sas \
  --account-name "$STORAGE_NAME" \
  --container-name "secure-container" \
  --name "sample.txt" \
  --permissions "rw" \
  --expiry "$(date -u -d '+1 hour' '+%Y-%m-%dT%H:%MZ')" \
  --auth-mode login \
  --as-user
```

✅ **Validation:** The SAS token starts with `sv=...&sr=b&sig=...&se=...&skoid=...` (the `skoid` parameter indicates it's a user delegation SAS).

### Task 3.3: Enable blob soft delete

```bash
az storage blob service-properties delete-policy update \
  --account-name "$STORAGE_NAME" \
  --enable true \
  --days-retained 14 \
  --auth-mode login
```

✅ **Validation:** In portal → Storage account → **Data protection** — Soft delete for blobs should show 14 days.

---

## Exercise 4: Azure SQL Database Security

### Task 4.1: Create Azure SQL with Azure AD admin

```bash
SQL_SERVER="sql-az500-$(openssl rand -hex 4)"
SQL_DB="az500db"
SQL_ADMIN="sqladmin"
SQL_PASS="Az500Lab!$(openssl rand -hex 6)"

# Create SQL Server
az sql server create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER" \
  --location "$LOCATION" \
  --admin-user "$SQL_ADMIN" \
  --admin-password "$SQL_PASS"

# Set Azure AD admin
MY_UPN=$(az account show --query user.name -o tsv)
MY_OID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || \
         az ad user show --id "$MY_UPN" --query id -o tsv)

az sql server ad-admin create \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --display-name "AZ500 Admin" \
  --object-id "$MY_OID"

# Create database
az sql db create \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name "$SQL_DB" \
  --service-objective S1

# Disable public network access
az sql server update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER" \
  --set publicNetworkAccess=Disabled
```

### Task 4.2: Enable TDE with Customer-Managed Key (CMK)

```bash
# Create Key Vault for SQL CMK (must allow key management)
KV_CMK_NAME="kv-sql-cmk-$(openssl rand -hex 4)"

az keyvault create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$KV_CMK_NAME" \
  --enable-purge-protection true \
  --enable-rbac-authorization true

# Create RSA key for TDE
az keyvault key create \
  --vault-name "$KV_CMK_NAME" \
  --name "sql-tde-key" \
  --kty RSA \
  --size 2048

KEY_ID=$(az keyvault key show \
  --vault-name "$KV_CMK_NAME" \
  --name "sql-tde-key" \
  --query key.kid -o tsv)

# Grant SQL Server's system-assigned identity access to the key
SQL_IDENTITY=$(az sql server show \
  -g "$RESOURCE_GROUP" -n "$SQL_SERVER" \
  --query identity.principalId -o tsv 2>/dev/null || echo "")

# Enable system-assigned identity on SQL Server if not present
az sql server update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER" \
  --assign-identity

SQL_IDENTITY=$(az sql server show \
  -g "$RESOURCE_GROUP" -n "$SQL_SERVER" \
  --query identity.principalId -o tsv)

az role assignment create \
  --assignee "$SQL_IDENTITY" \
  --role "Key Vault Crypto Service Encryption User" \
  --scope "$(az keyvault show --name $KV_CMK_NAME --query id -o tsv)"

# Configure TDE with CMK
az sql server tde-key set \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --server-key-type AzureKeyVault \
  --kid "$KEY_ID"

echo "TDE configured with CMK: $KEY_ID"
```

### Task 4.3: Enable SQL Auditing

```bash
az sql server audit-policy update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER" \
  --state Enabled \
  --storage-account "$STORAGE_NAME" \
  --retention-days 90
```

### Task 4.4: Enable Microsoft Defender for SQL

```bash
# Enable Defender for SQL
az security pricing create \
  --name "SqlServers" \
  --tier "Standard"

# Enable on the SQL server
az sql server threat-policy update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER" \
  --state Enabled \
  --email-account-admins true
```

### Task 4.5: Review Dynamic Data Masking

1. Navigate to **Azure Portal** → SQL Database (`az500db`) → **Security** → **Dynamic Data Masking**
2. Masked columns are automatically suggested based on data sensitivity
3. Click **+ Add rule** to manually mask a column:
   - **Schema:** dbo
   - **Table:** (create a test table or use existing)
   - **Column:** email
   - **Masking field format:** Email (xxxx@xxxx.com)
4. Click **Save**

✅ **Validation:** Non-admin users querying the masked column see `xxxx@xxxx.com` instead of real email addresses.

---

## Exercise 5: SQL Vulnerability Assessment

### Task 5.1: Run a vulnerability assessment

1. In Azure Portal, navigate to SQL Database → **Microsoft Defender for Cloud** → **Vulnerability assessment**
2. Click **Scan** to run an assessment
3. Review findings — each finding shows:
   - **Severity** (High/Medium/Low)
   - **Rule description** (what was checked)
   - **Current result** (failed check)
   - **Expected result** (what should be configured)
4. For finding "Auditing should be set to On":
   - Click **Remediate** → Follow the remediation guidance (already done in Task 4.3)
5. After remediation, run a new scan and verify the finding is resolved

✅ **Validation:** Severity "High" and "Medium" findings should decrease after applying remediations.

---

## Lab Cleanup

```bash
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

# Disable Defender plans (to stop charges)
az security pricing create --name "VirtualMachines" --tier "Free"
az security pricing create --name "SqlServers" --tier "Free"
```

---

## Lab Summary

| Concept | What You Practiced |
|---|---|
| Azure Disk Encryption | ADE with Key Vault key encryption key (KEK) |
| Just-in-Time access | JIT policy, access request, NSG rule verification |
| Azure Bastion | Secure RDP/SSH without public IPs |
| Storage security | HTTPS-only, no public blob access, User Delegation SAS, soft delete |
| SQL security | Azure AD admin, CMK TDE, auditing, Defender for SQL, DDM |
| Vulnerability Assessment | Running and remediating SQL vulnerabilities |

---

*Previous: [Lab 02 — Secure Networking ←](lab-02-secure-networking.md) | Next: [Lab 04 — Security Operations →](lab-04-security-operations.md)*
