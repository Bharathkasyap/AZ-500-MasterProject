# Domain 3 — Secure Compute, Storage, and Databases

> **Weight: 20–25% of the AZ-500 Exam**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Azure Key Vault](#azure-key-vault)
- [Virtual Machine Security](#virtual-machine-security)
- [Container Security](#container-security)
- [App Service Security](#app-service-security)
- [Azure Storage Security](#azure-storage-security)
- [Azure SQL Database Security](#azure-sql-database-security)
- [Microsoft Defender for Cloud — Workload Protection](#microsoft-defender-for-cloud--workload-protection)
- [Key Exam Points](#key-exam-points)

---

## Overview

Domain 3 covers securing Azure compute, storage, and database workloads. Key tools include Azure Key Vault for credential management, Microsoft Defender for Cloud for threat protection, and service-specific encryption and access controls.

**Key Theme:** *Encrypt everything, minimize credentials, apply least privilege at every layer.*

---

## Azure Key Vault

Azure Key Vault is the central service for managing **secrets**, **keys**, and **certificates** in Azure.

### Key Vault Object Types
| Type | Description | Example |
|------|-------------|---------|
| **Secrets** | Arbitrary key-value pairs | Connection strings, passwords, API keys |
| **Keys** | Cryptographic keys for encryption | RSA, EC keys for Azure Disk Encryption, TDE |
| **Certificates** | X.509 certificates with lifecycle management | SSL/TLS certificates for web apps |

### Key Vault Tiers
| Tier | Hardware Protection | Use Case |
|------|-------------------|---------|
| **Standard** | Software-protected keys | Most workloads |
| **Premium** | HSM-protected keys (FIPS 140-2 Level 2) | Compliance-required workloads |
| **Managed HSM** | HSM-protected (FIPS 140-2 Level 3) | Dedicated HSM; highest security |

### Access Models
| Model | Description | Recommended |
|-------|-------------|-------------|
| **Vault access policy** | Legacy; permissions at vault level | No (legacy) |
| **Azure RBAC** | Fine-grained at secret/key/cert level | **Yes** |

### Important RBAC Roles for Key Vault
| Role | Permissions |
|------|-------------|
| **Key Vault Administrator** | All operations on secrets, keys, certificates |
| **Key Vault Secrets Officer** | Create, get, list, set, delete secrets |
| **Key Vault Secrets User** | Get/list secrets (read only) |
| **Key Vault Crypto Officer** | Create, delete, manage keys |
| **Key Vault Crypto User** | Use keys for crypto operations (encrypt/decrypt) |
| **Key Vault Certificate Officer** | Manage certificates |
| **Key Vault Reader** | Read metadata; cannot read secret values |

### Data Plane vs. Management Plane
| Plane | Actions | Controlled By |
|-------|---------|--------------|
| **Management plane** | Create/delete vault, configure policies | Azure RBAC (ARM) |
| **Data plane** | Read/write secrets, keys, certificates | Key Vault access policy OR Azure RBAC |

### Soft Delete & Purge Protection
| Feature | Description |
|---------|-------------|
| **Soft delete** | Deleted objects retained for 7–90 days (default 90); enabled by default since 2020 |
| **Purge protection** | Prevents permanent deletion during retention period; cannot be disabled once enabled |

> **Exam tip:** Soft delete is enabled by default on new vaults and cannot be disabled. Purge protection is optional but once enabled, cannot be disabled. Always enable both for production.

### Key Vault Networking
- **Public endpoint**: Access from anywhere (restrict with firewall rules)
- **Service endpoints**: Restrict to specific VNets
- **Private endpoints**: Access only via private IP in VNet
- **Firewall rules**: Allow specific IPs or VNets; optionally allow Azure services

### Certificate Management
- Key Vault can generate certificates (self-signed or via CA integration)
- Integrated CAs: DigiCert, GlobalSign
- Automatic renewal before expiry
- Certificate contains key + certificate object (linked)

### Key Rotation
- **Automatic rotation**: Configure rotation policy (by days or on expiry)
- **Event-driven rotation**: Azure Event Grid → Function App → rotation logic
- Best practice: Rotate application secrets at least every 90 days

---

## Virtual Machine Security

### Azure Disk Encryption (ADE)
- Encrypts VM OS and data disks using **BitLocker** (Windows) or **dm-crypt** (Linux)
- Keys stored in Azure Key Vault (BEK - BitLocker Encryption Key, KEK - Key Encryption Key)
- **BEK**: Actual encryption key (wrapped by KEK)
- **KEK**: Key that protects BEK (optional but recommended)

### Server-Side Encryption (SSE)
- All Azure Managed Disks are encrypted at rest by default
- Uses **platform-managed keys** (PMK) or **customer-managed keys** (CMK)
- CMK keys stored in Azure Key Vault
- Encryption happens at storage layer; data is already encrypted when ADE is applied

> **Key difference:** SSE = encryption at rest at storage layer (always on). ADE = encryption within the OS (BitLocker/dm-crypt).

### Just-in-Time (JIT) VM Access
- Part of Microsoft Defender for Cloud
- Locks down management ports (RDP 3389, SSH 22) by default
- NSG rule added temporarily when user requests access
- Request includes: source IP, time duration (1–8 hours), destination port

**JIT Workflow:**
```
User requests JIT access →
  Defender for Cloud validates RBAC permission →
  NSG inbound rule added (source IP, port, time-limited) →
  User connects →
  Rule automatically removed at expiry
```

### VM Vulnerability Assessment
- Integrated with Microsoft Defender for servers
- Powered by Qualys (embedded in Defender; no separate license)
- Scans for OS and application vulnerabilities
- Recommendations surfaced in Defender for Cloud

### Endpoint Protection
- Microsoft Defender for Cloud recommends Microsoft Defender for Endpoint (MDE) on all VMs
- MDE auto-provisioned on Windows Server VMs with Defender for Servers plan
- Linux VMs: MDE installed via deployment script

### Update Management
- Azure Update Manager: Manage OS patches across Azure and Arc-enabled VMs
- Assess compliance, schedule patches, deploy on-demand

---

## Container Security

### Azure Container Registry (ACR)

| Feature | Description |
|---------|-------------|
| **Private registry** | Images stored in your Azure subscription |
| **Geo-replication** | Replicate images to multiple regions |
| **Content trust** | Sign images; only deploy signed images |
| **Quarantine** | Scan before images made available |
| **Encryption** | Customer-managed keys option |
| **Private Endpoints** | Pull images over private network |

### ACR Access Control
| Method | Description |
|--------|-------------|
| **ACR RBAC** | Assign AcrPull, AcrPush, AcrDelete, Owner roles |
| **Admin account** | Single account with username/password; disabled by default; avoid in production |
| **Service principal** | Grant AcrPull for AKS service principal (use Managed Identity instead) |
| **Managed Identity** | Recommended for AKS to pull from ACR |

### Image Vulnerability Scanning
- **Defender for Containers**: Scans ACR images for vulnerabilities
- Scans on push and on schedule
- Results in Defender for Cloud recommendations

### Azure Kubernetes Service (AKS) Security

#### Cluster Security
| Feature | Description |
|---------|-------------|
| **API server RBAC** | Kubernetes RBAC + Azure RBAC integration |
| **Network policies** | Pod-to-pod traffic control (Calico or Azure CNI) |
| **Private cluster** | API server has private IP only |
| **Authorized IP ranges** | Restrict API server access to specific IPs |
| **AAD integration** | Entra ID authentication for `kubectl` |
| **Workload Identity** | Managed Identity for pods (replaces pod identity) |

#### Node Security
- OS hardening (CIS benchmarks)
- Automatic OS security patches (node image upgrades)
- No SSH access by default; use Bastion or kubectl exec
- Node pools can use dedicated system node pool for system pods

#### Pod Security
- **Pod security admission**: Enforce security contexts (privileged/restricted namespaces)
- **Network policies**: Restrict pod-to-pod and pod-to-external communication
- **Secrets management**: Azure Key Vault Provider for Secrets Store CSI Driver

---

## App Service Security

### Authentication / Authorization (Easy Auth)
- Built-in authentication without code changes
- Supported providers: Microsoft (Entra ID), Google, Facebook, Twitter, GitHub, custom OIDC
- **Token store**: Tokens stored and refreshed automatically
- **Unauthenticated requests**: Redirect to login or return HTTP 401/403

### Managed Identities for App Service
- System-assigned: Automatically created when enabled; deleted with app
- User-assigned: Pre-created; can be reused
- Use to authenticate to Key Vault, Storage, SQL, etc. without secrets in config

### Network Security for App Service
| Feature | Description |
|---------|-------------|
| **Access restrictions** | IP-based or Service Tag-based firewall rules |
| **Service endpoints** | Restrict backend App Service access to specific VNets |
| **Private endpoints** | App Service accessible only via private IP |
| **VNet Integration** | App Service can reach resources in VNet (outbound) |

### App Service Certificates & TLS
- Upload custom TLS certificates or use App Service Managed Certificates (free)
- Enforce HTTPS-only (redirect HTTP to HTTPS)
- Minimum TLS version: 1.0, 1.1, 1.2 (1.2 recommended)
- Client certificate authentication: Require client certs for mutual TLS

### App Service Environment (ASE)
- Fully isolated, dedicated App Service deployment within your VNet
- No public inbound access required
- Use Internal Load Balancer (ILB) ASE for fully private deployment

---

## Azure Storage Security

### Storage Account Access Methods
| Method | Description | Use Case |
|--------|-------------|---------|
| **Access keys** | Full access; 2 keys per account | Avoid; store in Key Vault |
| **SAS (Shared Access Signature)** | Time-limited, scoped access | Third-party access |
| **Azure AD / RBAC** | Identity-based access | Recommended for users/apps |
| **Anonymous access** | Public blob access | Public website assets only |

### Shared Access Signature (SAS) Types
| Type | Scope |
|------|-------|
| **Account SAS** | Storage account level; multiple services |
| **Service SAS** | Single service (Blob, Queue, Table, File) |
| **User delegation SAS** | Backed by Entra ID credentials (most secure) |

### SAS Parameters
- Signed services (blob, queue, table, file)
- Signed resource types (service, container, object)
- Signed permissions (read, write, delete, list, add, create, update, process)
- Start/expiry time
- Allowed IP ranges
- Allowed protocols (HTTPS only recommended)

### Storage Encryption
| Type | Description |
|------|-------------|
| **Encryption at rest** | AES-256; always enabled; cannot be disabled |
| **Infrastructure encryption** | Double encryption (additional layer); optional |
| **Customer-managed keys (CMK)** | Bring your own key via Key Vault |
| **Encryption in transit** | HTTPS enforcement (disable HTTP in storage settings) |

### Storage Firewall & Network Rules
- Default: Allow all networks
- Configure: Deny all → Add exceptions (VNet service endpoints, IP ranges)
- Bypass: Azure trusted services (Backup, Defender, Monitor, etc.)
- **Best practice:** Enable "Require secure transfer" (HTTPS only) + firewall rules

### Storage Threat Protection
- **Microsoft Defender for Storage**: Detect anomalous access, malware in blobs
- Features: Activity monitoring, malware scanning (on upload), sensitive data threat detection
- Uses ML to detect unusual patterns (exfiltration, suspicious access from Tor)

### Immutable Blob Storage
- **WORM** (Write Once, Read Many) for compliance
- Types: Time-based retention or legal hold
- Locked policies cannot be deleted until expiry

---

## Azure SQL Database Security

### Authentication
| Method | Description |
|--------|-------------|
| **SQL Authentication** | Username/password; stored in SQL; legacy |
| **Microsoft Entra Authentication** | Use Entra ID users/groups/Managed Identities; recommended |

### Network Security
- **Service endpoints**: Restrict to specific VNets
- **Private endpoints**: Access via private IP only
- **SQL Firewall rules**: Allow specific IPs or IP ranges
- **Server-level vs. database-level firewall**: Server applies to all DBs; database-level is per DB

### Transparent Data Encryption (TDE)
- Encrypts database files at rest
- **Enabled by default** for all new Azure SQL databases
- Keys managed by: Service-managed keys (default) or Customer-managed keys (CMK) in Key Vault

### SQL Auditing
- Logs all database activities (logins, queries, stored procedures, DDL, DML)
- Storage destination: Log Analytics Workspace, Azure Storage, or Event Hub
- Retention: Configure in storage account or Log Analytics
- **Server-level auditing** covers all databases on the server

### Advanced Threat Protection (ATP) / Defender for SQL
- Detects anomalous database activities:
  - SQL injection attempts
  - Unusual access from new location
  - Unusual data export
  - Brute force attacks
- Part of **Microsoft Defender for SQL** (included in Defender for Cloud)

### Dynamic Data Masking
- Masks sensitive data in query results (not stored data)
- Examples: Email → `aXX@XXXX.com`, SSN → `XXX-XX-XXXX`
- Configured at column level
- Bypassed by: db_owner, schema_owner, or explicitly excluded users

### Always Encrypted
- Client-side encryption; data encrypted before sending to SQL Server
- Server and DBAs **cannot see plaintext data**
- Keys managed by client application (stored in Windows Certificate Store, Key Vault, or HSM)
- Use case: Highly sensitive columns (SSN, credit card numbers)
- **Always Encrypted vs TDE**: TDE protects data at rest at the file level; Always Encrypted protects data from privileged insiders (including DBAs)

### Row-Level Security (RLS)
- Restrict which rows users can see/modify
- Implemented as security policies with predicates (filter functions)
- Transparent to the application

### Azure SQL Database Roles
| Role | Permissions |
|------|-------------|
| `db_owner` | Full control over database |
| `db_securityadmin` | Manage roles and permissions |
| `db_datareader` | Read all data |
| `db_datawriter` | Write all data |
| `db_ddladmin` | Create/modify database objects |

---

## Microsoft Defender for Cloud — Workload Protection

### Defender Plans (Workload Protections)
| Plan | Protects |
|------|---------|
| **Defender for Servers** | VMs (Azure, on-prem, multicloud) |
| **Defender for App Service** | Azure App Service web apps |
| **Defender for Storage** | Azure Storage accounts |
| **Defender for SQL** | Azure SQL, SQL on VMs, Synapse |
| **Defender for Containers** | AKS, ACR, container registries |
| **Defender for Key Vault** | Azure Key Vault |
| **Defender for Resource Manager** | Azure management operations |
| **Defender for DNS** | Azure DNS queries |
| **Defender for APIs** | API Management |
| **Defender for DevOps** | CI/CD pipelines (GitHub, Azure DevOps) |

### Defender for Servers Features
- **Microsoft Defender for Endpoint** integration (EDR)
- **Vulnerability assessment** (Qualys or Defender built-in)
- **Just-in-Time VM access**
- **File integrity monitoring (FIM)**
- **Adaptive application controls** (allowlisting)
- **Network map** and **adaptive network hardening**

---

## Key Exam Points

### Encryption Decision Guide
| Scenario | Solution |
|----------|---------|
| Encrypt VM disk | Azure Disk Encryption (ADE) |
| Encrypt SQL database at rest | TDE (enabled by default) |
| Prevent DBAs from reading data | Always Encrypted |
| Mask sensitive columns in query results | Dynamic Data Masking |
| Encrypt storage blobs | SSE (always on) + customer-managed keys for CMK |
| Store app secrets securely | Azure Key Vault |
| Encrypt Key Vault keys with HSM | Key Vault Premium tier |

### Key Vault Common Exam Scenarios
- **"App needs to access Key Vault without credentials in code"** → Managed Identity + Key Vault RBAC
- **"Ensure deleted secrets can be recovered"** → Soft delete + purge protection
- **"Audit all Key Vault access"** → Enable Key Vault diagnostic logs → Log Analytics
- **"Ensure keys cannot be exported from Key Vault"** → Non-exportable key policy

---

📖 [Detailed Study Notes →](study-notes.md) | [Practice Questions →](../../practice-questions/domain3-compute-storage.md)
