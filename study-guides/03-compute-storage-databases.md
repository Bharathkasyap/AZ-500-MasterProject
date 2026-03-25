# Domain 3: Secure Compute, Storage, and Databases (20–25%)

> **Back to [README](../README.md)**

---

## Overview

This domain covers securing Azure compute workloads (VMs, containers, serverless), storage accounts, and databases. Key services include Azure Key Vault, disk encryption, container security, and database threat protection.

---

## 3.1 Plan and Implement Advanced Security for Compute

### Azure Virtual Machine Security

#### Securing VMs — Best Practices

| Practice | Implementation |
|---|---|
| **Disk Encryption** | Azure Disk Encryption (ADE) with Key Vault |
| **Patch Management** | Azure Update Manager / Azure Automation |
| **Endpoint Protection** | Microsoft Defender for Endpoint integration |
| **Access Control** | RBAC, JIT VM Access, Azure Bastion |
| **Network Segmentation** | NSGs, Private IPs, no public IPs |
| **Trusted Launch** | Secure Boot, vTPM, Integrity Monitoring |

#### Azure Disk Encryption (ADE)

ADE encrypts VM OS and data disks using **BitLocker** (Windows) or **DM-Crypt** (Linux), with keys stored in Azure Key Vault.

```bash
# Enable ADE on a VM
az vm encryption enable \
  --resource-group myRG \
  --name myVM \
  --disk-encryption-keyvault myKeyVault \
  --volume-type All

# Check encryption status
az vm encryption show \
  --resource-group myRG \
  --name myVM
```

#### Server-Side Encryption (SSE) for Managed Disks

SSE is enabled by default for all managed disks using **platform-managed keys (PMK)**.  
You can use **customer-managed keys (CMK)** stored in Key Vault for more control.

```bash
# Create disk encryption set (for CMK)
az disk-encryption-set create \
  --name myDiskEncryptionSet \
  --resource-group myRG \
  --location eastus \
  --key-url "https://mykeyvault.vault.azure.net/keys/myKey/version" \
  --source-vault myKeyVault
```

### Microsoft Defender for Servers

Defender for Servers (Plan 1 or Plan 2) provides:
- **Threat detection** for Windows and Linux VMs
- **Vulnerability assessment** (integrated or Qualys)
- **JIT VM access**
- **Adaptive application controls**
- **File integrity monitoring (FIM)**
- **Endpoint detection and response (EDR)**

```
Defender for Cloud → Environment Settings → Subscription → Defender plans
  → Servers → Plan 1 or Plan 2 → On
```

### Secure Containers

#### Azure Kubernetes Service (AKS) Security

| Area | Recommendation |
|---|---|
| **Authentication** | Microsoft Entra ID integration |
| **Authorization** | Kubernetes RBAC + Azure RBAC |
| **Network** | Network policies (Calico), private cluster, Azure CNI |
| **Image Security** | Microsoft Defender for Containers, ACR tasks |
| **Secrets** | Azure Key Vault Provider for Secrets Store CSI Driver |
| **Node Security** | CIS-hardened node images, auto-upgrade |

```bash
# Create private AKS cluster with Entra integration
az aks create \
  --resource-group myRG \
  --name myAKS \
  --enable-aad \
  --enable-azure-rbac \
  --enable-private-cluster \
  --network-plugin azure \
  --network-policy azure
```

#### Azure Container Registry (ACR) Security

```bash
# Enable admin account (discouraged — use RBAC)
# Instead, assign AcrPull role to managed identity
az role assignment create \
  --assignee <managed-identity-object-id> \
  --role AcrPull \
  --scope /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.ContainerRegistry/registries/myACR

# Enable content trust (signed images only)
az acr config content-trust update \
  --name myACR \
  --status enabled

# Run vulnerability scan
az acr task run \
  --registry myACR \
  --name vulnerabilityScan
```

### Serverless Security

#### Azure Functions

| Control | Implementation |
|---|---|
| **Authentication** | Easy Auth (built-in), Entra ID tokens |
| **Secrets** | Key Vault references in app settings |
| **Network** | VNet integration, private endpoints |
| **Access Keys** | Function keys — rotate regularly |

```json
// Key Vault reference in Function App settings
{
  "name": "ConnectionString",
  "value": "@Microsoft.KeyVault(SecretUri=https://mykeyvault.vault.azure.net/secrets/mySecret/)"
}
```

---

## 3.2 Plan and Implement Security for Azure Storage

### Azure Storage Account Security

#### Storage Security Layers

| Layer | Controls |
|---|---|
| **Authentication** | Azure AD (RBAC), SAS tokens, Storage keys |
| **Authorization** | RBAC roles (Storage Blob Data Reader/Contributor/Owner) |
| **Encryption at rest** | AES-256, PMK by default; CMK supported |
| **Encryption in transit** | Enforce HTTPS only (`supportsHttpsTrafficOnly: true`) |
| **Network access** | Firewall rules, VNet service endpoints, Private endpoints |
| **Advanced Threat Protection** | Microsoft Defender for Storage |

#### Shared Access Signatures (SAS)

| SAS Type | Scope |
|---|---|
| **Account SAS** | Access to multiple services and operations |
| **Service SAS** | Single service (Blob, Queue, Table, File) |
| **User Delegation SAS** | Backed by Entra ID credentials (preferred) |

```bash
# Generate a User Delegation SAS (recommended — uses Entra credentials)
# Step 1: Get delegation key
az storage account generate-sas \
  --account-name mystorageacct \
  --expiry 2024-12-31T00:00Z \
  --permissions r \
  --resource-types o \
  --services b \
  --auth-mode login

# Always set expiration and minimum permissions
# Avoid Account SAS — use Service or User Delegation SAS
```

#### Storage Account Best Practices

```bash
# Require HTTPS only
az storage account update \
  --name mystorageacct \
  --resource-group myRG \
  --https-only true

# Disable anonymous blob access
az storage account update \
  --name mystorageacct \
  --resource-group myRG \
  --allow-blob-public-access false

# Disable storage account key access (enforce Entra AD only)
az storage account update \
  --name mystorageacct \
  --resource-group myRG \
  --allow-shared-key-access false

# Set minimum TLS version
az storage account update \
  --name mystorageacct \
  --resource-group myRG \
  --min-tls-version TLS1_2
```

### Microsoft Defender for Storage

Detects anomalous activity such as:
- Unusual access patterns
- Access from Tor exit nodes
- Potential malware uploads (hash reputation analysis)
- Suspicious data exfiltration

```
Defender for Cloud → Environment Settings → Storage accounts → Defender for Storage: On
```

### Azure Storage Soft Delete and Versioning

```bash
# Enable blob soft delete (retain deleted blobs for 7 days)
az storage blob service-properties delete-policy update \
  --account-name mystorageacct \
  --enable true \
  --days-retained 7

# Enable versioning
az storage account blob-service-properties update \
  --account-name mystorageacct \
  --resource-group myRG \
  --enable-versioning true
```

---

## 3.3 Plan and Implement Security for Azure SQL Database and Managed Instances

### Azure SQL Security Features

| Feature | Description |
|---|---|
| **Microsoft Defender for SQL** | Advanced threat protection + vulnerability assessment |
| **Transparent Data Encryption (TDE)** | Encryption at rest (enabled by default) |
| **Always Encrypted** | Column-level encryption; data never exposed to DB engine |
| **Dynamic Data Masking (DDM)** | Obscure sensitive data for non-privileged users |
| **Row-Level Security (RLS)** | Filter rows based on user context |
| **Auditing** | Log all database events to Storage/Event Hub/Log Analytics |
| **Advanced Threat Protection** | Detects SQL injection, unusual access patterns |
| **Firewall Rules** | IP-based access control |
| **Private Endpoint** | Private connectivity to Azure SQL |

#### Enable Microsoft Defender for SQL

```bash
az sql server advanced-threat-protection-setting update \
  --resource-group myRG \
  --server mySQLServer \
  --state Enabled
```

#### Transparent Data Encryption (TDE)

```bash
# Verify TDE is enabled (on by default for Azure SQL)
az sql db tde show \
  --resource-group myRG \
  --server mySQLServer \
  --database myDB

# Enable CMK for TDE
az sql server tde-key set \
  --resource-group myRG \
  --server mySQLServer \
  --server-key-type AzureKeyVault \
  --kid "https://mykeyvault.vault.azure.net/keys/myKey/version"
```

#### Dynamic Data Masking

```sql
-- Mask email column (only show first letter and domain)
ALTER TABLE Customers
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

-- Mask credit card (show last 4 digits)
ALTER TABLE Payments
ALTER COLUMN CardNumber ADD MASKED WITH (FUNCTION = 'partial(0,"XXXX-XXXX-XXXX-",4)');

-- Grant unmask permission to privileged users
GRANT UNMASK TO PrivilegedUser;
```

#### SQL Auditing

```bash
az sql db audit-policy update \
  --resource-group myRG \
  --server mySQLServer \
  --name myDB \
  --state Enabled \
  --storage-account mystorageacct \
  --retention-days 90
```

---

## 3.4 Plan and Implement Security for Azure Key Vault

### Azure Key Vault Overview

Azure Key Vault securely stores and manages:
- **Secrets**: Connection strings, passwords, API keys
- **Keys**: Cryptographic keys (RSA, EC) for encryption
- **Certificates**: TLS/SSL certificates with lifecycle management

### Key Vault Access Models

| Model | Description |
|---|---|
| **Vault Access Policy** | Legacy model — grants access to secrets/keys/certs independently |
| **Azure RBAC** (Recommended) | Standard RBAC with fine-grained data plane roles |

#### Create Key Vault and Add Secrets — Azure CLI

```bash
# Create Key Vault
az keyvault create \
  --name myKeyVault \
  --resource-group myRG \
  --location eastus \
  --sku Standard \
  --enable-rbac-authorization true   # Use RBAC model

# Add a secret
az keyvault secret set \
  --vault-name myKeyVault \
  --name "DatabasePassword" \
  --value "P@ssw0rd!"

# Retrieve a secret
az keyvault secret show \
  --vault-name myKeyVault \
  --name "DatabasePassword" \
  --query value --output tsv
```

#### Key Vault RBAC Roles

| Role | Access |
|---|---|
| **Key Vault Administrator** | Full data plane access (all secrets, keys, certs) |
| **Key Vault Secrets Officer** | Full secrets CRUD |
| **Key Vault Secrets User** | Read secrets |
| **Key Vault Crypto Officer** | Full keys CRUD |
| **Key Vault Crypto User** | Sign, verify, encrypt, decrypt |
| **Key Vault Certificate Officer** | Full certificates CRUD |
| **Key Vault Reader** | Read metadata (not secret values) |

#### Key Vault Security Settings

```bash
# Enable soft delete (prevents accidental deletion — 90 days default)
az keyvault update \
  --name myKeyVault \
  --resource-group myRG \
  --enable-soft-delete true

# Enable purge protection (prevents permanent delete during soft-delete period)
az keyvault update \
  --name myKeyVault \
  --resource-group myRG \
  --enable-purge-protection true

# Restrict network access (only allow specific VNet)
az keyvault network-rule add \
  --name myKeyVault \
  --resource-group myRG \
  --vnet-name myVNet \
  --subnet mySubnet

# Set default action to Deny
az keyvault update \
  --name myKeyVault \
  --resource-group myRG \
  --default-action Deny \
  --bypass AzureServices
```

#### Key Vault Diagnostic Logging

```bash
az monitor diagnostic-settings create \
  --name myKVLogs \
  --resource /subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.KeyVault/vaults/myKeyVault \
  --workspace myLogAnalyticsWorkspace \
  --logs '[{"category": "AuditEvent", "enabled": true}]'
```

### Hardware Security Modules (HSMs)

| Service | Description |
|---|---|
| **Key Vault Standard** | Software-protected keys |
| **Key Vault Premium** | HSM-backed keys (FIPS 140-2 Level 2) |
| **Dedicated HSM** | Dedicated HSM hardware (FIPS 140-2 Level 3) |
| **Managed HSM** | Fully managed HSM pool (FIPS 140-2 Level 3) |

---

## 📝 Exam Tips — Domain 3

1. **ADE vs SSE**: SSE is automatic (always on, platform-managed). ADE encrypts OS/data disks at the OS level using BitLocker/dm-crypt.
2. **SAS tokens**: Always use User Delegation SAS (backed by Entra credentials, more secure than Account SAS with storage keys).
3. **Key Vault soft delete + purge protection**: Both are needed to prevent accidental or malicious deletion. Soft delete alone can be overridden by purge; purge protection prevents that.
4. **Always Encrypted vs TDE**: TDE encrypts at rest (transparent to app). Always Encrypted encrypts data before it leaves the client — the database engine never sees plaintext.
5. **Dynamic Data Masking**: Does NOT encrypt data — it only masks display output. Privileged users can still see real data.
6. **Defender for Storage**: Detects malware uploads using hash reputation — does not scan file content.
7. **Key Vault RBAC**: Enable `--enable-rbac-authorization` for new vaults instead of using access policies.

---

## 🔗 References

- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Azure Storage Security Guide](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations)
- [Azure SQL Security](https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview)
- [Azure Disk Encryption](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview)
- [Defender for Cloud Compute Protection](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-servers-introduction)

---

> ⬅️ [Domain 2: Secure Networking](./02-secure-networking.md) | ➡️ [Domain 4: Security Operations](./04-security-operations.md)
