# Lab 03 — Secure Compute, Storage, and Databases

**Estimated Time:** 90–120 minutes  
**Prerequisite:** Azure subscription with Contributor or Owner role; Defender for Cloud enabled  
**Mapped Exam Domain:** Domain 3 — Secure Compute, Storage, and Databases

---

## Learning Objectives

- Enable and test Just-in-Time (JIT) VM access
- Configure Azure Disk Encryption on a Linux VM
- Create and compare SAS token types for Azure Blob Storage
- Configure Azure SQL with Always Encrypted and Dynamic Data Masking
- Enable Defender for SQL (Advanced Threat Protection)

---

## Part 1 — Virtual Machine with JIT Access

### Step 1.1 — Deploy a VM

```bash
RG="lab-compute-rg"
LOCATION="eastus"
VM_NAME="lab-linux-vm"

az group create --name $RG --location $LOCATION

# Create VM (no public IP needed — Bastion/JIT only)
az vm create \
  --resource-group $RG \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --nsg "" \
  --assign-identity

VM_PIP=$(az vm show --resource-group $RG --name $VM_NAME \
  --show-details --query publicIps -o tsv)

echo "VM deployed. Public IP: $VM_PIP"
```

### Step 1.2 — Enable Defender for Servers (required for JIT)

```bash
az security pricing create \
  --name VirtualMachines \
  --tier Standard

echo "Defender for Servers enabled"
```

### Step 1.3 — Enable JIT Access via Defender for Cloud

**Portal steps:**
1. Navigate to **Defender for Cloud** → **Workload Protections** → **Just-in-time VM access**
2. Go to the **Not configured** tab
3. Select `lab-linux-vm` → Click **Enable JIT on 1 VM**
4. Default ports configured: 22 (SSH), 3389 (RDP), 5985, 5986

**CLI (create JIT policy):**
```bash
SUB_ID=$(az account show --query id -o tsv)
VM_ID="/subscriptions/$SUB_ID/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/$VM_NAME"

az security jit-policy create \
  --name default \
  --resource-group $RG \
  --virtual-machines "[{
    \"id\": \"$VM_ID\",
    \"ports\": [
      {\"number\": 22, \"protocol\": \"TCP\",
       \"allowedSourceAddressPrefix\": \"*\",
       \"maxRequestAccessDuration\": \"PT3H\"}
    ]
  }]"

echo "JIT policy created"
```

### Step 1.4 — Request JIT Access

**Portal:**
1. Go to **Defender for Cloud** → **Just-in-time VM access** → **Configured** tab
2. Select `lab-linux-vm` → **Request access**
3. Enter your IP address and 1-hour window
4. Click **Open ports**

**Validation check:** Verify the NSG has a temporary inbound rule for your IP on port 22:
```bash
az network nsg rule list \
  --nsg-name $(az network nic show \
    --ids $(az vm show -g $RG -n $VM_NAME --query 'networkProfile.networkInterfaces[0].id' -o tsv) \
    --query 'networkSecurityGroup.id' -o tsv | xargs basename) \
  --resource-group $RG \
  --output table
```

---

## Part 2 — Azure Disk Encryption

### Step 2.1 — Create Key Vault for ADE

```bash
KV_NAME="lab-ade-kv-$(date +%s | tail -c 6)"

az keyvault create \
  --name $KV_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --enabled-for-disk-encryption true \
  --enable-soft-delete true

echo "Key Vault for ADE: $KV_NAME"
```

### Step 2.2 — Enable ADE on the VM

```bash
az vm encryption enable \
  --resource-group $RG \
  --name $VM_NAME \
  --disk-encryption-keyvault $KV_NAME \
  --volume-type All

echo "ADE encryption initiated (may take 5–10 minutes)"
```

> ⚠️ ADE will restart the VM. Wait for completion before proceeding.

### Step 2.3 — Verify Encryption Status

```bash
az vm encryption show \
  --resource-group $RG \
  --name $VM_NAME \
  --output table
```

**Expected output:** `OsVolumeEncryptionSettings.enabled: True`, `DataVolumesEncrypted: True`

---

## Part 3 — Azure Blob Storage SAS Tokens

### Step 3.1 — Create Storage Account and Container

```bash
SA_NAME="labstore$(date +%s | tail -c 6)"

az storage account create \
  --name $SA_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard_LRS \
  --https-only true \
  --min-tls-version TLS1_2 \
  --default-action Allow \
  --allow-blob-public-access false

az storage container create \
  --name labcontainer \
  --account-name $SA_NAME \
  --auth-mode login

# Upload a test blob
echo "AZ-500 Lab Test File" > /tmp/test.txt
az storage blob upload \
  --file /tmp/test.txt \
  --container-name labcontainer \
  --name test.txt \
  --account-name $SA_NAME \
  --auth-mode login

echo "Storage account and test blob created"
```

### Step 3.2 — Generate a Service SAS (Account Key Signed)

```bash
SA_KEY=$(az storage account keys list \
  --account-name $SA_NAME \
  --resource-group $RG \
  --query '[0].value' -o tsv)

SERVICE_SAS=$(az storage blob generate-sas \
  --account-name $SA_NAME \
  --account-key $SA_KEY \
  --container-name labcontainer \
  --name test.txt \
  --permissions r \
  --expiry $(date -u -d '+1 hour' +%Y-%m-%dT%H:%MZ) \
  --output tsv)

echo "Service SAS URL:"
echo "https://$SA_NAME.blob.core.windows.net/labcontainer/test.txt?$SERVICE_SAS"
```

### Step 3.3 — Generate a User Delegation SAS (Entra ID Signed)

```bash
# Get user delegation key (valid 1 hour)
START=$(date -u +%Y-%m-%dT%H:%MZ)
END=$(date -u -d '+1 hour' +%Y-%m-%dT%H:%MZ)

USER_DELEGATION_SAS=$(az storage blob generate-sas \
  --account-name $SA_NAME \
  --container-name labcontainer \
  --name test.txt \
  --permissions r \
  --expiry $END \
  --auth-mode login \
  --as-user \
  --output tsv)

echo "User Delegation SAS URL:"
echo "https://$SA_NAME.blob.core.windows.net/labcontainer/test.txt?$USER_DELEGATION_SAS"
```

> 💡 **Key difference** — The User Delegation SAS includes `skoid` (signed key object ID) and `sktid` (signed key tenant ID) parameters, proving it was issued using Entra ID credentials.

**Validation check:** Open either SAS URL in a browser or use curl:
```bash
curl -s "https://$SA_NAME.blob.core.windows.net/labcontainer/test.txt?$USER_DELEGATION_SAS"
```

---

## Part 4 — Azure SQL Security

### Step 4.1 — Deploy Azure SQL Server and Database

```bash
SQL_SERVER="lab-sql-$(date +%s | tail -c 6)"
SQL_DB="labsecuritydb"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="SqlAdmin@2024!"

az sql server create \
  --name $SQL_SERVER \
  --resource-group $RG \
  --location $LOCATION \
  --admin-user $SQL_ADMIN \
  --admin-password $SQL_PASSWORD

az sql db create \
  --name $SQL_DB \
  --resource-group $RG \
  --server $SQL_SERVER \
  --edition GeneralPurpose \
  --compute-model Serverless \
  --family Gen5 \
  --capacity 2

echo "SQL Server: $SQL_SERVER"
```

### Step 4.2 — Enable Advanced Threat Protection

```bash
az sql server threat-policy update \
  --resource-group $RG \
  --server $SQL_SERVER \
  --state Enabled \
  --storage-account $SA_NAME

echo "Advanced Threat Protection enabled"
```

### Step 4.3 — Enable SQL Auditing

```bash
# Get storage account endpoint
SA_ENDPOINT="https://$SA_NAME.blob.core.windows.net"

az sql server audit-policy update \
  --resource-group $RG \
  --name $SQL_SERVER \
  --state Enabled \
  --blob-auditing-policy Enabled \
  --storage-account $SA_NAME

echo "SQL Auditing enabled"
```

### Step 4.4 — Configure Dynamic Data Masking (Portal)

1. Navigate to your SQL Database in the Azure portal
2. Go to **Security** → **Dynamic Data Masking**
3. Click **+ Add mask**
4. Configure:
   - Schema: `dbo`
   - Table: `[create a test table first]`
   - Column: `EmailAddress`
   - Masking function: `Email` (shows `aXXX@XXXX.com`)
5. Click **Add** → **Save**

### Step 4.5 — Set Entra ID Admin on SQL Server

```bash
MY_UPN=$(az ad signed-in-user show --query userPrincipalName -o tsv)
MY_OID=$(az ad signed-in-user show --query id -o tsv)

az sql server ad-admin create \
  --resource-group $RG \
  --server-name $SQL_SERVER \
  --display-name "AZ500 Admin" \
  --object-id $MY_OID

echo "Entra ID admin set for SQL Server"
```

---

## Checklist

- [ ] Linux VM deployed with system-assigned managed identity
- [ ] Defender for Servers Plan 2 enabled
- [ ] JIT VM Access policy configured for port 22
- [ ] JIT access requested and temporary NSG rule verified
- [ ] Key Vault for ADE created with disk encryption enabled
- [ ] ADE enabled on VM (OS and data volumes)
- [ ] Storage account created with HTTPS-only and no public blob access
- [ ] Service SAS generated and tested
- [ ] User Delegation SAS generated and tested
- [ ] Azure SQL Server deployed
- [ ] Advanced Threat Protection (Defender for SQL) enabled
- [ ] SQL Auditing enabled to storage account
- [ ] Entra ID admin configured on SQL Server

---

## Cleanup

```bash
az group delete --name lab-compute-rg --yes --no-wait
echo "Resource group deletion initiated"
```

---

## Key Takeaways

1. JIT VM Access closes management ports by default — access is temporary and fully audited.
2. ADE uses BitLocker/DM-Crypt to encrypt at the OS layer; SSE encrypts at the storage backend.
3. User Delegation SAS is the most secure SAS type — backed by Entra ID, revocable without key rotation.
4. Always Encrypted and DDM serve different purposes: AE protects from DBAs; DDM hides from app users.
5. Always enable an Entra ID admin on SQL Server and disable SQL authentication where possible.
