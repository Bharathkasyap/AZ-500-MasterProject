# Domain 3: Secure Compute, Storage, and Databases (20–25%)

> **Back to:** [README](../README.md) | **Previous:** [Domain 2 — Secure Networking](02-secure-networking.md)

---

## Table of Contents

1. [Virtual Machine Security](#1-virtual-machine-security)
2. [Container Security](#2-container-security)
3. [Azure App Service Security](#3-azure-app-service-security)
4. [Azure Storage Security](#4-azure-storage-security)
5. [Azure SQL Database Security](#5-azure-sql-database-security)
6. [Azure Cosmos DB Security](#6-azure-cosmos-db-security)
7. [Azure Key Vault](#7-azure-key-vault)
8. [Microsoft Defender for Cloud — Compute Recommendations](#8-microsoft-defender-for-cloud--compute-recommendations)
9. [Key Exam Tips](#key-exam-tips)

---

## 1. Virtual Machine Security

### VM Disk Encryption
**Azure Disk Encryption (ADE):**
- Encrypts OS and data disks using BitLocker (Windows) or DM-Crypt (Linux)
- Keys stored in Azure Key Vault
- Integrates with Key Vault for key management and auditing
- Supports Key Encryption Key (KEK) for additional protection of the disk encryption key

**Server-side encryption (SSE) / Platform-managed encryption:**
- Enabled by default on all Azure managed disks
- Azure manages the encryption keys (no user action required)
- Can use customer-managed keys (CMK) stored in Key Vault or managed HSM

| Encryption Type | Key Owner | Use Case |
|----------------|-----------|---------|
| Platform-managed keys (PMK) | Microsoft | Default; minimal management |
| Customer-managed keys (CMK) | You (Key Vault) | Compliance requiring key control |
| Azure Disk Encryption (ADE) | You (Key Vault) | Encryption within guest OS (BitLocker/DM-Crypt); defense-in-depth |

### VM Security Best Practices
- **Endpoint protection:** Deploy Microsoft Defender for Endpoint (MDE) via Defender for Servers
- **Patch management:** Azure Update Manager + automatic VM guest patching
- **Vulnerability assessment:** Defender for Servers integrates Qualys or Defender VA
- **Security baselines:** Apply Azure Security Benchmark / CIS benchmarks via Guest Configuration
- **No public IPs:** Use Azure Bastion or VPN for management access
- **JIT VM access:** Lock down management ports (see Domain 2)
- **Accelerated networking:** Does NOT affect security but is a common distractor

### Trusted Launch for Azure VMs
A security improvement for Generation 2 VMs:
- **Secure Boot:** Ensures only signed OS and drivers load
- **vTPM:** Virtual TPM for attestation and key storage
- **Integrity monitoring:** Alerts on unexpected changes to the boot chain

### Dedicated Hosts and Isolated VMs
| Feature | Description |
|---------|-------------|
| **Azure Dedicated Host** | Physical host reserved for your organization; full control, compliance, isolation |
| **Isolated VM sizes** | Single-tenant hypervisor; no other customer workloads on the same physical host |

---

## 2. Container Security

### Azure Container Registry (ACR)
A managed Docker container registry for storing and managing container images.

**Security features:**
| Feature | Description |
|---------|-------------|
| **Private endpoint** | Expose ACR via private IP; disable public access |
| **RBAC** | `AcrPull`, `AcrPush`, `AcrDelete` roles for granular access |
| **Microsoft Defender for Containers** | Image vulnerability scanning for images pushed to ACR |
| **Content trust** | Sign images with Docker Content Trust; only signed images can be pulled |
| **Geo-replication** | Replicate registry to multiple regions for redundancy |
| **Customer-managed keys** | Encrypt registry using CMK in Key Vault |
| **Service endpoint / Private endpoint** | Restrict network access |

**Image vulnerability scanning:**
- Defender for Containers scans images on push and continuously for new vulnerabilities
- Results visible in Defender for Cloud recommendations

### Azure Kubernetes Service (AKS) Security

**Control plane security:**
- Managed by Microsoft; API server endpoint can be private (private cluster)
- Private cluster: API server accessible only from within VNet or via Private Endpoint
- Authorized IP ranges: restrict API server access to known IP ranges (less secure than private cluster)

**Authentication and authorization:**
| Method | Description |
|--------|-------------|
| **Entra ID integration** | Use Entra ID identities to authenticate to the Kubernetes API |
| **Kubernetes RBAC** | ClusterRole/ClusterRoleBinding for Kubernetes resources |
| **Azure RBAC for Kubernetes** | Use Azure RBAC roles to authorize Kubernetes API calls (replaces Kubernetes RBAC) |

**Node security:**
- Node pools run on Azure VMs — apply NSGs, system-assigned managed identity
- Regularly update node image versions (automatic upgrade channels)
- Node OS disk encryption with CMK supported

**Pod security:**
| Feature | Description |
|---------|-------------|
| **Pod Identity / Workload Identity** | Assign managed identity to pods (preferred: Workload Identity Federation) |
| **Secrets Store CSI Driver** | Mount Key Vault secrets directly into pods as files/env vars |
| **Network policies** | Kubernetes network policies (Calico/Azure) to restrict pod-to-pod traffic |
| **Pod Security Admission** | Enforce pod security standards (restricted/baseline/privileged) |
| **Image pull from ACR** | Use AcrPull role on the AKS managed identity |

**Microsoft Defender for Containers:**
- Vulnerability assessment for running images
- Real-time workload protection (runtime threat detection)
- Kubernetes audit log analytics
- Alert on suspicious container behavior

### Azure Container Instances (ACI)
- Run containers without managing infrastructure
- Security: VNet integration for private networking, managed identity support
- Defender for Containers covers ACI threat detection

---

## 3. Azure App Service Security

### Authentication and Authorization (Easy Auth)
App Service built-in authentication middleware:
- Supports providers: Microsoft (Entra ID), Google, Facebook, Twitter, GitHub, OpenID Connect
- No code changes required in the application
- Token store: stores tokens server-side and injects them as request headers

### Network Security
| Feature | Description |
|---------|-------------|
| **VNet Integration** | Outbound traffic from the app goes through a VNet |
| **Private Endpoint** | Inbound access only from VNet (no public access) |
| **Access restrictions** | IP-based allow/deny rules for inbound traffic |
| **Service endpoints** | Allow App Service to access VNet-secured resources |

### TLS/SSL
- Enforce HTTPS only: redirect all HTTP to HTTPS
- Minimum TLS version: enforce TLS 1.2 or higher
- Custom domains with SSL/TLS certificates (App Service Managed Certificate — free)
- Client certificates: mutual TLS authentication for API clients

### App Service Managed Identity
- System-assigned or user-assigned managed identity
- Use to authenticate to Key Vault, Storage, SQL without storing credentials

### Security Best Practices
- Always enable "HTTPS Only" setting
- Set minimum TLS version to 1.2
- Use Private Endpoint for production apps
- Store connection strings and secrets in Key Vault (not app settings)
- Enable Defender for App Service

---

## 4. Azure Storage Security

### Storage Account Security Layers
```
Storage Account
├── Network (Firewalls + Private Endpoints)
├── Authentication (Keys, SAS, Entra ID / RBAC)
├── Encryption (SSE + optional CMK, TDE)
└── Advanced Threat Protection (Defender for Storage)
```

### Authentication Methods
| Method | Description | Security Level |
|--------|-------------|---------------|
| **Storage account keys** | Full-access master keys; 2 keys per account | Low (rotate regularly) |
| **Shared Access Signatures (SAS)** | Delegated, time-limited, scoped access tokens | Medium (depends on configuration) |
| **Entra ID + Azure RBAC** | Token-based; no keys needed | High (recommended) |
| **Anonymous access** | Public blobs without authentication | Very Low (disable unless required) |

### Shared Access Signatures (SAS)
| SAS Type | Description |
|----------|-------------|
| **Account SAS** | Access to one or more storage services with account-level control |
| **Service SAS** | Access to a specific service resource (blob, queue, table, file) |
| **User Delegation SAS** | Signed with Entra ID credentials instead of account key — most secure |

**SAS components:**
- Service: blob, file, queue, table
- Permissions: read, write, delete, list, add, create, update, process
- Start/expiry time
- Allowed IP ranges
- Allowed protocols: HTTPS only (always specify)
- Signed key (account key or user delegation key)

**Best practices:**
- Use User Delegation SAS whenever possible
- Always use `https` only
- Set the shortest expiry time needed
- Specify the minimum required permissions
- Revoke by rotating the signing key (or revoking user delegation key)

### Storage Network Isolation
| Control | Description |
|---------|-------------|
| **Firewalls and virtual networks** | Allow access from specific VNet subnets (service endpoints) or IP ranges |
| **Private Endpoint** | Private IP in VNet; disable public endpoint |
| **Trusted Microsoft services** | Allow Azure services like Backup, Site Recovery, Defender to bypass firewall |

**Disable public access:** In storage account firewall settings, select "Disabled" to block all public internet access — only private endpoints allowed.

### Encryption
- **At rest:** All data encrypted by default using SSE (AES-256)
- **In transit:** Enforce HTTPS-only (`Secure transfer required` setting)
- **Customer-managed keys (CMK):** Store encryption keys in Key Vault or managed HSM
- **Scope encryption:** Different CMKs for different encryption scopes within a storage account
- **Infrastructure encryption:** Double encryption — platform + customer keys (for highly sensitive data)

### Soft Delete
Protect against accidental or malicious deletion:
- **Blob soft delete:** Deleted blobs retained for a configurable period (1–365 days)
- **Container soft delete:** Deleted containers retained for a configurable period
- **Share soft delete:** For Azure Files
- Can be re-enabled within retention period

### Microsoft Defender for Storage
- Detects anomalous access patterns (unusual data exfiltration, suspicious access from Tor exit nodes)
- Detects malware uploads (hash reputation analysis and sensitive data threat detection)
- Alerts appear in Defender for Cloud and can be exported to Sentinel

---

## 5. Azure SQL Database Security

### Authentication
| Method | Description |
|--------|-------------|
| **SQL Authentication** | Username/password stored in database — legacy; avoid for new deployments |
| **Entra ID Authentication** | Modern auth; supports MFA, managed identities, conditional access |
| **Managed Identity** | Allow Azure services (App Service, Functions) to authenticate without credentials |

**Best practice:** Disable SQL authentication where possible; use Entra ID authentication.

### Network Security
| Control | Description |
|---------|-------------|
| **Server firewall rules** | IP-based rules at the server level |
| **Virtual network rules** | Allow specific VNet subnets (service endpoint) |
| **Private Endpoint** | Private IP; disable public endpoint |
| **Deny public network access** | Block all public internet connections |

### Transparent Data Encryption (TDE)
- Encrypts SQL database, log files, and backups at rest
- Enabled by default on all new Azure SQL databases
- Uses a Database Encryption Key (DEK) encrypted by a TDE protector
- **Service-managed TDE:** Microsoft manages the TDE protector key
- **Customer-managed TDE (BYOK):** TDE protector key stored in Key Vault — you control it

### Always Encrypted
Protects sensitive data in columns (SSN, credit card numbers) — the data is **encrypted at the client** and never decrypted on the server or in transit.

| Key | Description |
|-----|-------------|
| **Column Encryption Key (CEK)** | Encrypts specific column data |
| **Column Master Key (CMK)** | Encrypts the CEK; stored in Key Vault or Windows Certificate Store |

**Key types:**
- Deterministic encryption: same plaintext → same ciphertext; supports equality comparison and indexes
- Randomized encryption: same plaintext → different ciphertext each time; more secure but no equality comparison

### Azure SQL Auditing
- Tracks database events and writes to Azure Storage, Log Analytics, or Event Hubs
- Captures: logins, queries, schema changes, access errors
- **Server-level auditing** applies to all databases on the server
- Retention: configure retention period or use Log Analytics for long-term storage

### Advanced Threat Protection (ATP) for SQL
- Detects anomalous database activities: SQL injection, unusual access patterns, brute force
- Part of Microsoft Defender for SQL
- Alerts in Defender for Cloud; integrated with Sentinel

### Dynamic Data Masking
Limits exposure of sensitive data to non-privileged users by masking it in query results:
| Mask Type | Example |
|-----------|---------|
| Default | Replaces with `XXXX` (text) or `0` (numbers) |
| Email | `aXXXXXXX@XXXX.com` |
| Random number | Random number in a specified range |
| Custom text | Expose first/last N characters with custom padding |

### Row-Level Security (RLS)
Control which rows users can access based on their identity:
```sql
CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE dbo.fn_securitypredicate(SalesRep)
ON dbo.Sales
WITH (STATE = ON);
```

### Vulnerability Assessment for SQL
- Scans for misconfigurations, excessive permissions, exposed sensitive data
- Provides a baseline and tracks deviations
- Part of Defender for SQL; findings in Defender for Cloud

---

## 6. Azure Cosmos DB Security

### Authentication and Authorization
| Method | Description |
|--------|-------------|
| **Primary/secondary keys** | Master keys for full access |
| **Resource tokens** | Scoped, time-limited tokens for specific resources |
| **Entra ID + RBAC** | Modern auth; use built-in or custom Cosmos DB RBAC roles |
| **Managed identity** | App Service / Functions accessing Cosmos DB without keys |

**Built-in Cosmos DB RBAC roles:**
- `Cosmos DB Built-in Data Reader` — read-only data plane
- `Cosmos DB Built-in Data Contributor` — read/write data plane

### Network Security
- IP-based firewall rules
- Virtual network (service endpoints) or Private Endpoints
- Disable public network access

### Encryption
- All data encrypted at rest by default (AES-256)
- Customer-managed keys (CMK) supported via Key Vault
- All data in transit encrypted with TLS 1.2+

### Backup and Restore
- Continuous backup mode with point-in-time restore (PITR)
- Periodic backup mode (default): stored in Azure Storage, geo-redundant

---

## 7. Azure Key Vault

### What it is
A centralized cloud service for securely storing and managing:
- **Secrets:** Connection strings, API keys, passwords
- **Keys:** Cryptographic keys for encryption (RSA, EC, AES)
- **Certificates:** X.509 certificates with automated renewal

### Key Vault Tiers
| Tier | HSM | Use Case |
|------|-----|---------|
| **Standard** | Software-protected | General secrets/keys/certs |
| **Premium** | HSM-protected | Keys that must never leave HSM; FIPS 140-2 Level 2 |
| **Managed HSM** | Dedicated HSM cluster | Single-tenant HSM; FIPS 140-2 Level 3; highest compliance |

### Access Models
**Two access models (mutually exclusive per vault):**

| Model | Description |
|-------|-------------|
| **Vault access policies** | Legacy; grant permissions per principal per object type |
| **Azure RBAC** | Recommended; use Azure RBAC roles on the vault; supports PIM |

**Key RBAC roles for Key Vault:**
| Role | Permissions |
|------|------------|
| Key Vault Administrator | Full data plane (secrets + keys + certs) |
| Key Vault Secrets Officer | Create, read, update, delete secrets |
| Key Vault Secrets User | Read (get) secrets |
| Key Vault Crypto Officer | Manage keys |
| Key Vault Crypto User | Perform crypto operations (sign, verify, encrypt, decrypt) |
| Key Vault Certificate Officer | Manage certificates |
| Key Vault Reader | View metadata only (no secret values) |

### Network Security
- Disable public access; use Private Endpoints
- Service endpoint support for VNet-based access
- Trusted Microsoft services bypass (Azure Disk Encryption, Azure Backup, etc.)

### Soft Delete and Purge Protection
| Feature | Description |
|---------|-------------|
| **Soft Delete** | Deleted vaults/secrets/keys retained for 7–90 days (configurable) |
| **Purge Protection** | Prevents permanent deletion during retention period; cannot be disabled once enabled |

**Compliance requirement:** Enable both soft delete AND purge protection for any Key Vault storing encryption keys used by Azure services (required by Defender for Cloud).

### Key Rotation
- **Manual rotation:** Create new key version; update references
- **Automatic rotation:** Configure rotation policy (based on time or days before expiry)
- **Near-expiry alerts:** Event Grid events or Key Vault alerts when a secret/key is near expiry

### Key Vault Logging
- Enable diagnostic logs: `AuditEvent` logs all access (who accessed what, when, from where)
- Send to: Log Analytics, Storage Account, Event Hubs
- Used for compliance auditing and anomaly detection

### Key Vault Firewall Example (Azure CLI)
```bash
# Disable public access
az keyvault update \
  --name myKeyVault \
  --resource-group myRG \
  --default-action Deny \
  --bypass AzureServices

# Allow a specific VNet subnet
az keyvault network-rule add \
  --name myKeyVault \
  --resource-group myRG \
  --vnet-name myVNet \
  --subnet mySubnet
```

---

## 8. Microsoft Defender for Cloud — Compute Recommendations

### Defender for Cloud Plans (for Compute/Storage/DB)
| Plan | Protects |
|------|---------|
| **Defender for Servers Plan 1** | JIT VM access, Defender for Endpoint integration |
| **Defender for Servers Plan 2** | + Vulnerability assessment, file integrity monitoring, adaptive application controls |
| **Defender for Storage** | Anomaly detection, malware scanning, sensitive data threat detection |
| **Defender for SQL** | ATP for Azure SQL and SQL Server on VMs/Arc |
| **Defender for Containers** | ACR scanning, AKS runtime protection, Kubernetes audit analytics |
| **Defender for App Service** | Threat detection for App Service workloads |
| **Defender for Key Vault** | Anomalous access detection to Key Vault |

### Secure Score
- Quantifies your security posture (0–100%)
- Calculated from security recommendations
- Higher score = better security posture
- Recommendations grouped by security controls (each control has a max score contribution)

### Security Recommendations
- Each recommendation has: severity, score impact, description, remediation steps
- Quick Fix: one-click remediation for supported recommendations
- Exempt: dismiss a recommendation for a specific resource with justification
- Enforce: automatically apply the recommendation to new resources via Azure Policy

### Adaptive Application Controls
- Machine learning-based allowlisting of applications running on VMs
- Alerts on unusual processes not in the baseline
- Available with Defender for Servers Plan 2

### File Integrity Monitoring (FIM)
- Monitors changes to critical OS files, registry keys, and application files
- Alerts on unexpected changes (tamper detection)
- Available with Defender for Servers Plan 2

---

## Key Exam Tips

1. **Always Encrypted protects data in use** — it's encrypted in client memory; the server never sees plaintext. Other encryption (TDE, CMK) protects data at rest but the server processes plaintext.

2. **TDE is enabled by default** on all new Azure SQL databases. If asked what protects SQL data at rest without any configuration, TDE is the answer.

3. **Key Vault RBAC vs. Access Policies:** New deployments should use RBAC (supports PIM, more granular). Access policies are legacy.

4. **Purge protection on Key Vault** — once enabled, you cannot disable it. Enable it proactively in compliance scenarios.

5. **User Delegation SAS** is more secure than Account SAS because it uses Entra ID credentials to sign the token — no need to share account keys.

6. **Defender for Storage** detects malware and anomalous access (including sensitive data threat detection). Use this instead of building custom alerting on storage accounts.

7. **Managed Identities** are the preferred way for Azure services to authenticate to other Azure services. Always choose over service principals with secrets.

8. **AKS private cluster** = API server has no public IP. "Authorized IP ranges" restricts access but the API server still has a public IP — they are NOT equivalent from a security perspective.

9. **Soft delete vs. Purge Protection:** Soft delete recovers deleted items. Purge protection prevents permanent deletion DURING the retention period. Both should be enabled together.

10. **CMK vs. ADE:** CMK encrypts the managed disk key in Key Vault (Azure-managed encryption). ADE encrypts within the guest OS using BitLocker/DM-Crypt. For VMs, use ADE for defense-in-depth (in-guest encryption).

---

> **Previous:** [Domain 2 — Secure Networking](02-secure-networking.md) | **Next:** [Domain 4 — Security Operations →](04-security-operations.md)
