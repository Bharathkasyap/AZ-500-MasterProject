# Domain 3: Secure Compute, Storage, and Databases (20–25%)

> This domain covers security for Azure VMs, containers, App Service, storage accounts, Azure SQL, and more. Expect 8–15 questions.

---

## Table of Contents

1. [Virtual Machine Security](#1-virtual-machine-security)
2. [Azure Disk Encryption](#2-azure-disk-encryption)
3. [Azure Container Security](#3-azure-container-security)
4. [Azure Kubernetes Service (AKS) Security](#4-azure-kubernetes-service-aks-security)
5. [Azure App Service Security](#5-azure-app-service-security)
6. [Azure Storage Security](#6-azure-storage-security)
7. [Azure SQL Database Security](#7-azure-sql-database-security)
8. [Azure Key Vault](#8-azure-key-vault)
9. [Key Exam Topics Checklist](#9-key-exam-topics-checklist)

---

## 1. Virtual Machine Security

### Just-in-Time (JIT) VM Access

JIT VM Access (Microsoft Defender for Cloud feature) locks down inbound traffic to VMs and opens ports only when needed, for the approved duration.

| Feature | Details |
|---------|---------|
| **Default ports** | RDP (3389), SSH (22), WinRM (5985/5986) |
| **How it works** | NSG rules block ports by default; JIT adds a time-bound Allow rule on request |
| **Approved IPs** | Access can be restricted to the requester's IP only |
| **Max time** | Admin configures maximum access duration (e.g., 3 hours) |
| **Audit trail** | All JIT requests are logged in the Activity Log |

```bash
# Enable JIT on a VM using Azure CLI
az security jit-policy create \
  --name default \
  --resource-group MyRG \
  --location eastus \
  --virtual-machines '[{"id": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/MyVM","ports": [{"number": 22, "protocol": "TCP", "allowedSourceAddressPrefix": "*", "maxRequestAccessDuration": "PT3H"}]}]'
```

### VM Security Hardening

| Control | Implementation |
|---------|---------------|
| **No public IP** | Use Azure Bastion for management access |
| **OS updates** | Azure Update Manager or Automation (patch management) |
| **Endpoint protection** | Microsoft Defender for Endpoint (integrated with Defender for Cloud) |
| **Vulnerability assessment** | Defender for Cloud built-in Qualys scanner or Defender for Endpoint |
| **Guest configuration** | Azure Policy guest configuration to enforce OS-level settings |
| **Trusted launch** | Secure Boot + vTPM for Gen2 VMs (protects against boot-level malware) |

### Azure Dedicated Hosts

- Physical servers dedicated to a single organization
- No sharing with other Azure customers (compliance/isolation requirement)
- Full control over maintenance windows
- Higher cost but required for certain regulated workloads

### VM Disk Snapshot and Export Security

- Snapshots can be exported to public URIs — secure with SAS tokens
- Use **disk access objects** to restrict snapshot/disk export to specific VNets via private endpoints

### Key Exam Points — VM Security
- **JIT VM Access** requires **Microsoft Defender for Servers Plan 2**
- JIT works by modifying **NSG rules** temporarily
- Trusted launch (Secure Boot + vTPM) protects against UEFI malware and rootkits
- Use **Azure Bastion** instead of public IPs + JIT for highest security
- VM vulnerability assessment is included in **Defender for Servers**

---

## 2. Azure Disk Encryption

### Overview
Azure provides multiple layers of encryption for VM disks.

### Encryption Options Comparison

| Method | Encryption Type | Key Management | OS/Data Disks |
|--------|----------------|---------------|---------------|
| **Azure Disk Encryption (ADE)** | Guest-OS-level (BitLocker/dm-crypt) | Customer-managed keys in Key Vault | Both |
| **Server-Side Encryption (SSE) with PMK** | Platform-managed (Microsoft manages keys) | Microsoft-managed | Both |
| **SSE with CMK** | Platform-managed (customer manages keys in Key Vault or Managed HSM) | Customer-managed (stored in Key Vault) | Both |
| **Encryption at host** | Encrypts host-level temp disks and cache | Customer-managed or platform-managed | Temp disk + cache |
| **Confidential disk encryption** | SEV-SNP (hardware-level) | Customer-managed in vTPM | OS disk |

### Azure Disk Encryption (ADE) — Exam Focus

- Uses **BitLocker** on Windows and **dm-crypt** on Linux
- Keys and secrets stored in **Azure Key Vault**
- VM must have access to Key Vault (network and RBAC)
- Supports disk encryption sets for CMK with SSE

```bash
# Create a Key Vault for ADE
az keyvault create \
  --name MyADEKeyVault \
  --resource-group MyRG \
  --location eastus \
  --enabled-for-disk-encryption true

# Enable ADE on a VM
az vm encryption enable \
  --name MyVM \
  --resource-group MyRG \
  --disk-encryption-keyvault MyADEKeyVault
```

### Disk Encryption Sets (CMK with SSE)

```bash
# Create a key in Key Vault for CMK
az keyvault key create \
  --vault-name MyCMKVault \
  --name MyDiskKey \
  --protection software

# Create disk encryption set
az disk-encryption-set create \
  --name MyDiskEncryptionSet \
  --resource-group MyRG \
  --location eastus \
  --key-url https://MyCMKVault.vault.azure.net/keys/MyDiskKey/<version> \
  --source-vault MyCMKVault
```

### Key Exam Points — Disk Encryption
- **ADE** encrypts at the OS level (inside the VM); **SSE** encrypts at the storage level (outside the VM)
- ADE requires Key Vault to have `--enabled-for-disk-encryption` set
- **Encryption at host** extends CMK encryption to temp disks (ADE doesn't cover temp disks by default)
- You cannot use ADE and SSE with CMK simultaneously on the same disk (ADE takes precedence)
- Managed disks support SSE with CMK using **Disk Encryption Sets**

---

## 3. Azure Container Security

### Azure Container Registry (ACR) Security

| Feature | Description |
|---------|-------------|
| **Private endpoints** | Access ACR only from VNet (disable public access) |
| **Managed identity** | Pull images using managed identity (no credentials) |
| **Content trust** | Sign images with Notary v2; only signed images can be deployed |
| **Vulnerability scanning** | Microsoft Defender for Containers scans images on push |
| **Geo-replication** | Replicate images to multiple regions (not strictly security, but availability) |
| **Token-based access** | Scoped tokens for CI/CD pipelines (repository-level access) |

### ACR Authentication Methods

| Method | Use Case |
|--------|----------|
| **Managed identity** | Azure services pulling images (recommended) |
| **Service principal** | CI/CD pipelines, external systems |
| **Admin account** | Not recommended; single credential for all access |
| **Individual Entra ID identity** | Development/testing; interactive users |

```bash
# Disable admin account on ACR
az acr update --name MyRegistry --resource-group MyRG --admin-enabled false

# Create token with repository-scoped permissions
az acr token create \
  --name ci-token \
  --registry MyRegistry \
  --resource-group MyRG \
  --repository myapp content/read
```

### Container Instance Security

- Azure Container Instances (ACI) run as single containers or container groups
- Inject secrets using **Key Vault references** or environment variables (least preferred)
- Use **managed identities** for Key Vault access
- Deploy into a **VNet** to restrict network access (VNet integration)

### Key Exam Points — Container Security
- **Admin account** on ACR is disabled by default in new registries — keep it disabled
- Use **managed identities** for container workloads to pull images and access secrets
- **Defender for Containers** scans ACR images for vulnerabilities and runtime threats
- Enable **Content Trust** to ensure only signed images are deployed

---

## 4. Azure Kubernetes Service (AKS) Security

### AKS Security Layers

| Layer | Controls |
|-------|---------|
| **API server** | Private cluster, Authorized IP ranges |
| **Node security** | OS hardening, auto-upgrades, Defender for Containers agent |
| **Network** | Network policies (Calico/Azure), kubenet vs Azure CNI |
| **Workload identity** | Workload Identity (Entra ID pod identity replacement) |
| **Secrets** | Key Vault CSI driver (Azure Key Vault Provider) |
| **Registry** | Pull from private ACR with managed identity |
| **RBAC** | Kubernetes RBAC + Entra ID integration |

### AKS Cluster Authentication and Authorization

| Feature | Description |
|---------|-------------|
| **Local accounts** | Username/password for cluster admin (disable in production) |
| **Entra ID integration** | Use Entra ID groups for Kubernetes RBAC |
| **Kubernetes RBAC** | Roles and RoleBindings within cluster namespaces |
| **Azure RBAC for Kubernetes** | Use Azure RBAC to control Kubernetes access (requires Entra ID integration) |

```bash
# Create private AKS cluster with Entra ID integration
az aks create \
  --name MyAKS \
  --resource-group MyRG \
  --enable-private-cluster \
  --enable-aad \
  --enable-azure-rbac \
  --network-plugin azure \
  --network-policy azure \
  --disable-local-accounts
```

### Azure Key Vault CSI Driver for AKS

- Mount Key Vault secrets/certs/keys directly as Kubernetes volumes
- Uses **Workload Identity** for authentication (no stored credentials in pods)
- Secrets sync to Kubernetes secrets (optional)

### AKS Network Policies

| Policy | Engine | Features |
|--------|--------|---------|
| **Azure network policies** | Built into Azure CNI | Simple L4 policies, Azure-native |
| **Calico** | Open source (works with kubenet and Azure CNI) | Rich L4/L7 policies, more complex |

### Key Exam Points — AKS Security
- **Private cluster** hides the API server from the internet — access requires VPN/ExpressRoute or jump box
- **Entra ID integration** replaces local accounts for cluster access
- **Disable local accounts** (`--disable-local-accounts`) to enforce Entra ID authentication only
- **Workload Identity** is the modern replacement for AAD Pod Identity (deprecated)
- **Azure Key Vault CSI Driver** injects secrets without storing them as plain Kubernetes secrets
- **Network policies** control pod-to-pod traffic within the cluster

---

## 5. Azure App Service Security

### App Service Authentication (Easy Auth)

- Built-in authentication/authorization for web apps without code changes
- Supports: Microsoft (Entra ID), Google, Facebook, Twitter, GitHub, Apple
- Token store: App Service caches and manages tokens
- Token refresh: Automatic for supported providers

### App Service Network Security

| Feature | Description |
|---------|-------------|
| **Access restrictions** | IP-based allow/deny rules for inbound traffic |
| **Service endpoint** | Restrict access to VNet subnets only |
| **Private endpoint** | Access App Service only via private IP from VNet |
| **VNet integration** | App Service can access VNet resources (outbound) |
| **IP-based SSL** | Dedicated IP for SSL certificate binding |

### App Service TLS/SSL

```bash
# Enforce HTTPS only
az webapp update --name MyWebApp --resource-group MyRG --https-only true

# Set minimum TLS version
az webapp config set --name MyWebApp --resource-group MyRG --min-tls-version 1.2
```

### Managed Certificates

- App Service provides free managed TLS certificates for custom domains
- Auto-renewed 45 days before expiration
- Stored in the App Service Certificate store (backed by Key Vault)

### App Service Secrets — Best Practices

```bash
# Store connection string as App Setting (Key Vault reference)
az webapp config appsettings set \
  --name MyWebApp \
  --resource-group MyRG \
  --settings "DB_CONNECTION_STRING=@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/dbconn/)"
```

### Key Exam Points — App Service Security
- Use **Key Vault references** in App Settings instead of storing secrets directly
- **Easy Auth** adds authentication without modifying application code
- Enforce **HTTPS only** and minimum **TLS 1.2** in App Service configuration
- Use **VNet integration** (outbound) and **Private Endpoints** (inbound) for full VNet isolation
- Managed identities allow App Service to authenticate to other Azure services without credentials

---

## 6. Azure Storage Security

### Storage Account Security Controls

| Control | Description |
|---------|-------------|
| **Shared Key (Storage Account Key)** | Full administrative access; avoid in production; rotate regularly |
| **Shared Access Signatures (SAS)** | Delegated access with limited permissions and expiry |
| **Entra ID + RBAC** | Fine-grained, auditable access; recommended for new workloads |
| **Anonymous access** | Public blob access; disabled by default; keep disabled |
| **Infrastructure encryption** | Double encryption (SSE + platform encryption) |
| **Encryption scope** | Encrypt specific containers with different keys |

### Shared Access Signatures (SAS) Types

| SAS Type | Description |
|----------|-------------|
| **Account SAS** | Access to multiple services in a storage account |
| **Service SAS** | Access to a single service (Blob, Queue, Table, File) |
| **User Delegation SAS** | Signed with Entra ID credentials (more secure than account key SAS) |

```bash
# Generate a User Delegation SAS (most secure)
EXPIRY=$(date -u -d "1 hour" +"%Y-%m-%dT%H:%MZ")
az storage blob generate-sas \
  --account-name MyStorage \
  --container-name mycontainer \
  --name myfile.txt \
  --permissions r \
  --expiry $EXPIRY \
  --auth-mode login \
  --as-user
```

### Storage Firewall and Network Rules

```bash
# Deny public access by default
az storage account update \
  --name MyStorage \
  --resource-group MyRG \
  --default-action Deny

# Allow access from specific VNet subnet
az storage account network-rule add \
  --account-name MyStorage \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --subnet MySubnet

# Allow access from trusted Azure services
az storage account update \
  --name MyStorage \
  --resource-group MyRG \
  --bypass AzureServices Logging Metrics
```

### Azure Storage Encryption

| Encryption | Details |
|-----------|---------|
| **Encryption at rest** | Automatic; AES-256; cannot be disabled |
| **Microsoft-managed keys (MMK)** | Default; Microsoft manages keys |
| **Customer-managed keys (CMK)** | Customer manages keys in Key Vault; supports key rotation |
| **Encryption scope** | Per-container or per-blob CMK |
| **Infrastructure encryption** | Double encryption; required for some compliance frameworks |

### Storage Immutability (WORM)

- **Time-based retention policy**: Files cannot be modified or deleted for a specified period
- **Legal hold**: Files locked until the hold is removed (used during litigation)
- Use for compliance: FINRA, SEC, CFTC
- Applies to Blob storage (Block blobs in containers)

```bash
# Enable immutable storage with time-based retention
az storage container immutability-policy create \
  --account-name MyStorage \
  --container-name compliance-data \
  --resource-group MyRG \
  --period 365  # days
```

### Azure Storage Soft Delete

- Deleted blobs/containers are retained for a configurable period (1–365 days)
- Protects against accidental deletion
- Enabled by default on new storage accounts for blobs (7-day retention)

### Azure Storage Defender (Defender for Storage)

- Detects anomalous access patterns and potential threats
- Alerts on: unusual data exfiltration, access from TOR exit nodes, unusual IP addresses
- Activity-based pricing (per transaction) or per-storage-account pricing

### Key Exam Points — Storage Security
- **User Delegation SAS** is more secure than Account SAS (uses Entra ID, auditable)
- Disable **anonymous public access** on all storage accounts
- Use **Entra ID + RBAC** (Storage Blob Data Reader/Contributor) instead of access keys for apps
- **Storage Account Keys** provide full access — rotate them and avoid sharing them
- **Customer-managed keys** (CMK) in Key Vault support bring-your-own-key (BYOK) compliance
- Enable **soft delete** to protect against accidental data loss
- **Immutable storage** (WORM) satisfies SEC Rule 17a-4 and similar compliance requirements

---

## 7. Azure SQL Database Security

### SQL Database Security Layers

| Layer | Control |
|-------|---------|
| **Network** | Firewall rules, VNet service endpoints, Private Endpoints |
| **Authentication** | SQL authentication, Entra ID authentication |
| **Authorization** | Database roles, column/row-level security, Dynamic Data Masking |
| **Threat detection** | Microsoft Defender for SQL (formerly Advanced Threat Protection) |
| **Auditing** | SQL Auditing to Log Analytics, Storage, or Event Hubs |
| **Encryption** | TDE (at rest), Always Encrypted (in use), TLS (in transit) |

### Authentication Methods

| Method | Description |
|--------|-------------|
| **SQL authentication** | Username + password stored in SQL; avoid for production |
| **Entra ID authentication** | Recommended; supports MFA, managed identities, Conditional Access |
| **Entra ID-only authentication** | Disables SQL authentication entirely; highest security |

```bash
# Set Entra ID admin for SQL server
az sql server ad-admin create \
  --server-name MySQLServer \
  --resource-group MyRG \
  --display-name "SQL Admins Group" \
  --object-id <entra-group-object-id>

# Disable local SQL authentication
az sql server update \
  --name MySQLServer \
  --resource-group MyRG \
  --enable-public-network false
```

### Transparent Data Encryption (TDE)

- Encrypts SQL database files at rest automatically (AES-256)
- Enabled by default on all Azure SQL databases
- Uses **Database Encryption Key (DEK)** protected by a TDE protector
- TDE protector: Service-managed key (default) or **customer-managed key (BYOK)** in Key Vault

### Always Encrypted

- Encrypts sensitive columns at the **client side** — data is never decrypted on the server
- Database engine never sees plaintext data
- Use for: SSNs, credit card numbers, medical records
- Key types: Column Master Key (CMK) in Key Vault, Column Encryption Key (CEK) in database

### Dynamic Data Masking (DDM)

- Masks data in query results for non-privileged users
- Data is **not encrypted** — it's masked at the query output level
- Masking formats: Default, Email, Random, Custom string, Credit card

```sql
-- Add a masking rule
ALTER TABLE Customer
ALTER COLUMN SSN ADD MASKED WITH (FUNCTION = 'default()');

-- Privileged users see the real data; others see: XXXX
```

### Row-Level Security (RLS)

```sql
-- Create a security policy to restrict row access by user
CREATE FUNCTION dbo.fn_SecurityPredicate(@TenantId INT)
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN SELECT 1 AS fn_result
WHERE @TenantId = CAST(SESSION_CONTEXT(N'TenantId') AS INT);

CREATE SECURITY POLICY TenantFilter
ADD FILTER PREDICATE dbo.fn_SecurityPredicate(TenantId) ON dbo.Orders;
```

### SQL Auditing

- Records database events to: Azure Storage, Log Analytics, or Event Hubs
- Audit events: Logins, queries, schema changes, permission changes
- Required by many compliance frameworks (PCI DSS, HIPAA)
- **Server-level** audit applies to all databases; **database-level** audit applies to a specific database

### Microsoft Defender for SQL

- Detects: SQL injection attempts, anomalous access patterns, unusual locations
- Alerts sent to: Defender for Cloud, email, Azure Monitor
- Includes Vulnerability Assessment (scans for misconfigurations)

### Key Exam Points — SQL Security
- **TDE** is enabled by default on all Azure SQL databases
- **Always Encrypted** protects data in use — server never sees plaintext
- **Dynamic Data Masking** does NOT encrypt data — it only hides it in query results
- Use **Entra ID authentication** instead of SQL authentication; consider Entra-only mode
- **Vulnerability Assessment** in Defender for SQL identifies security misconfigurations
- SQL **Auditing** is required for many compliance frameworks; enable at server level minimum

---

## 8. Azure Key Vault

### Overview
Azure Key Vault securely stores and controls access to secrets, keys, and certificates. It is central to the entire Azure security ecosystem.

### Key Vault Object Types

| Type | Description | Examples |
|------|-------------|---------|
| **Secrets** | Arbitrary string values | Passwords, connection strings, API keys |
| **Keys** | Cryptographic keys | RSA, EC keys for encryption/signing |
| **Certificates** | X.509 certificates | TLS/SSL certificates, code signing certs |

### Key Vault Tiers

| Tier | Key Protection | Hardware |
|------|---------------|----------|
| **Standard** | Software-protected keys | No HSM |
| **Premium** | HSM-protected keys | Shared HSM |
| **Managed HSM** | HSM-protected keys | Dedicated single-tenant HSM (FIPS 140-2 Level 3) |

### Access Models

| Model | Description |
|-------|-------------|
| **Vault access policy** | Legacy model; per-principal permissions for secrets/keys/certs |
| **Azure RBAC** | Recommended; fine-grained role assignments; supports JIT and PIM |

**Recommended RBAC roles for Key Vault:**

| Role | Permissions |
|------|-------------|
| **Key Vault Administrator** | Full control over all vault objects |
| **Key Vault Secrets Officer** | Create, read, update, delete secrets |
| **Key Vault Secrets User** | Read secret values only |
| **Key Vault Crypto Officer** | Manage keys |
| **Key Vault Crypto User** | Cryptographic operations with keys |
| **Key Vault Certificate Officer** | Manage certificates |

### Key Vault Networking

```bash
# Restrict Key Vault to private endpoint only
az keyvault update \
  --name MyKeyVault \
  --resource-group MyRG \
  --default-action Deny \
  --bypass AzureServices

# Create private endpoint for Key Vault
az network private-endpoint create \
  --name MyKVPrivateEndpoint \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --subnet MySubnet \
  --private-connection-resource-id /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/MyKeyVault \
  --group-id vault \
  --connection-name MyKVConnection
```

### Key Vault Soft Delete and Purge Protection

| Feature | Description |
|---------|-------------|
| **Soft delete** | Deleted objects are retained for 7–90 days (default 90); can be recovered; **enabled by default** |
| **Purge protection** | Prevents permanent deletion during soft-delete period; required for CMK scenarios |

```bash
# Enable purge protection (cannot be disabled once enabled)
az keyvault update \
  --name MyKeyVault \
  --resource-group MyRG \
  --enable-purge-protection true
```

### Key Rotation

```bash
# Configure automatic key rotation policy
az keyvault key rotation-policy update \
  --vault-name MyKeyVault \
  --name MyKey \
  --value @rotation-policy.json
```

```json
{
  "lifetimeActions": [
    {
      "trigger": {"timeAfterCreate": "P90D"},
      "action": {"type": "Rotate"}
    },
    {
      "trigger": {"timeBeforeExpiry": "P30D"},
      "action": {"type": "Notify"}
    }
  ],
  "attributes": {
    "expiryTime": "P1Y"
  }
}
```

### Key Vault Diagnostics

```bash
# Send Key Vault audit logs to Log Analytics
az monitor diagnostic-settings create \
  --name MyKVDiagnostics \
  --resource /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/MyKeyVault \
  --workspace MyLogAnalyticsWorkspace \
  --logs '[{"category": "AuditEvent", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'
```

### Key Exam Points — Key Vault
- Use **Azure RBAC** model (not vault access policy) for new Key Vaults
- **Soft delete** is enabled by default and cannot be disabled for vaults created after 2021
- **Purge protection** must be enabled for CMK disk encryption and SQL TDE BYOK scenarios
- Key Vault private DNS zone: `privatelink.vaultcore.azure.net`
- **Managed HSM** provides dedicated single-tenant FIPS 140-2 Level 3 HSM
- Enable **diagnostic logging** to capture all secret access (AuditEvent category)
- For managed identities, assign the **Key Vault Secrets User** role (least privilege)
- Key rotation should be **automated** using Key Vault rotation policies

---

## 9. Key Exam Topics Checklist

### Must-Know for Domain 3

- [ ] JIT VM Access — what it does, requires Defender for Servers Plan 2
- [ ] ADE vs SSE vs encryption at host differences
- [ ] Disable ACR admin account; use managed identities for image pull
- [ ] AKS private cluster + Entra ID integration + disable local accounts
- [ ] App Service Key Vault references for secrets in app settings
- [ ] Storage SAS types: User Delegation SAS is most secure
- [ ] Disable anonymous public blob access on storage accounts
- [ ] SQL TDE (enabled by default), Always Encrypted (client-side), DDM (not encryption)
- [ ] Entra ID-only authentication for SQL Server
- [ ] Key Vault: RBAC model preferred over access policies
- [ ] Key Vault soft delete (enabled by default) and purge protection
- [ ] Key Vault private DNS zone: `privatelink.vaultcore.azure.net`
- [ ] Managed HSM for FIPS 140-2 Level 3 dedicated HSM requirements
- [ ] Storage immutability (WORM) for compliance (SEC Rule 17a-4)
- [ ] Enable Key Vault audit logging (AuditEvent) for compliance

---

## 📖 Microsoft Learn Resources

- [Azure Disk Encryption for VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview)
- [Azure Key Vault documentation](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
- [Azure SQL Database security overview](https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview)
- [Azure Storage security guide](https://learn.microsoft.com/en-us/azure/storage/common/storage-security-guide)
- [AKS security concepts](https://learn.microsoft.com/en-us/azure/aks/concepts-security)
- [Azure Container Registry authentication](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication)

---

*← [Domain 2: Secure Networking](02-secure-networking.md) | [Domain 4: Security Operations →](04-security-operations.md)*
