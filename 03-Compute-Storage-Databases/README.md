# Domain 3: Secure Compute, Storage, and Databases

**Exam Weight: 20–25%**

← [Back to Main Guide](../README.md)

---

## Overview

This domain covers how to secure Azure compute resources (VMs, containers, and PaaS), protect data at rest and in transit in storage services, and harden database services. Key Vault is a central topic tying many of these services together.

---

## Table of Contents

1. [Azure Key Vault](#1-azure-key-vault)
2. [Securing Virtual Machines](#2-securing-virtual-machines)
3. [Microsoft Defender for Servers](#3-microsoft-defender-for-servers)
4. [Disk Encryption](#4-disk-encryption)
5. [Azure Container Security (ACI, AKS)](#5-azure-container-security-aci-aks)
6. [Azure App Service Security](#6-azure-app-service-security)
7. [Securing Azure Storage](#7-securing-azure-storage)
8. [Securing Azure SQL Database](#8-securing-azure-sql-database)
9. [Securing Azure Cosmos DB](#9-securing-azure-cosmos-db)
10. [Key Exam Tips](#key-exam-tips)

---

## 1. Azure Key Vault

### What It Is
Azure Key Vault is a cloud service for securely storing and managing secrets, encryption keys, and certificates.

### Object Types
| Type | Description |
|---|---|
| **Secrets** | Passwords, connection strings, API keys |
| **Keys** | Cryptographic keys (RSA, EC) for encryption/signing |
| **Certificates** | X.509 certificates with automatic renewal |

### SKUs
| Feature | Standard | Premium |
|---|---|---|
| Secrets and certificates | ✅ | ✅ |
| Software-protected keys | ✅ | ✅ |
| HSM-protected keys | ❌ | ✅ |
| FIPS 140-2 Level 2 | ✅ | ✅ |
| FIPS 140-2 Level 3 | ❌ | ✅ |

### Access Models
| Model | Description |
|---|---|
| **Vault access policy** | Legacy; permissions per principal per vault |
| **Azure RBAC (recommended)** | Use Azure role assignments for fine-grained control |

### Key RBAC Roles for Key Vault
| Role | Permissions |
|---|---|
| `Key Vault Administrator` | Full control of vault data plane |
| `Key Vault Secrets Officer` | Manage secrets |
| `Key Vault Secrets User` | Read secret values |
| `Key Vault Crypto Officer` | Manage keys |
| `Key Vault Crypto User` | Use keys for operations |
| `Key Vault Certificate Officer` | Manage certificates |

### Networking
- **Public endpoint**: Accessible from internet (restrict with firewall rules/service endpoints)
- **Private Endpoint**: Private IP in VNet; disable public access for maximum security
- **Trusted services**: Some Azure services can bypass firewall if "Allow trusted Microsoft services"

### Soft Delete and Purge Protection
| Feature | Description |
|---|---|
| **Soft delete** | Deleted objects retained for 7–90 days; always on (cannot disable) |
| **Purge protection** | Prevents permanent deletion during retention period; required for CMK scenarios |

### Managed HSM
- Dedicated, single-tenant HSM
- FIPS 140-2 Level 3 validated
- Local RBAC model (independent from Azure RBAC)
- Used for scenarios requiring highest key security

### Exam Tips
- Enable **purge protection** for Key Vault used with Customer-Managed Keys (CMK)
- Use **RBAC authorization** (not access policies) for new deployments — it's the recommended model
- Enable **diagnostic logging** to audit all key vault operations
- **Managed identities** are the preferred way to access Key Vault from Azure resources

---

## 2. Securing Virtual Machines

### VM Security Best Practices
| Control | Description |
|---|---|
| **Patch management** | Use Azure Update Manager or Azure Automation |
| **Endpoint protection** | Microsoft Defender for Endpoint (MDE) integrated with Defender for Cloud |
| **Just-in-time (JIT) VM access** | Open management ports only when needed |
| **Adaptive application controls** | Allowlist applications that can run on VMs |
| **Disable public IP** | Use Bastion or VPN for management access |
| **NSG hardening** | Block RDP (3389) and SSH (22) from internet |

### Just-in-Time (JIT) VM Access
- Feature of **Microsoft Defender for Servers**
- Locks down inbound management ports (RDP 3389, SSH 22, WinRM 5985/5986)
- On demand: user requests access → JIT creates temporary NSG rule → access granted for limited time
- All access is logged in Azure Activity Log

### Azure Disk Encryption vs VM Encryption
| Feature | Description |
|---|---|
| **Azure Disk Encryption (ADE)** | Encrypts OS and data disks using BitLocker (Windows) or dm-crypt (Linux) |
| **Server-Side Encryption (SSE)** | Encrypts data at rest in Azure Storage (transparent, always on) |
| **Encryption at host** | SSE extended to temp disks and cache; bypasses Azure Storage |

### Exam Tips
- **JIT VM Access** requires Defender for Servers (Plan 1 or 2)
- NSG rules created by JIT are temporary and automatically removed
- **Adaptive application controls** use machine learning to recommend allowlists

---

## 3. Microsoft Defender for Servers

### What It Is
Microsoft Defender for Servers is part of Defender for Cloud; it adds threat detection, vulnerability assessment, and security posture management for VMs.

### Plans
| Plan | Features |
|---|---|
| **Plan 1** | MDE integration, JIT VM access |
| **Plan 2** | Everything in Plan 1 + file integrity monitoring, OS vulnerability assessment, network map, adaptive application controls |

### Key Capabilities
| Capability | Description |
|---|---|
| **Microsoft Defender for Endpoint (MDE)** | EDR agent; threat protection, investigation |
| **Vulnerability assessment** | Qualys or Microsoft-powered scanning |
| **File Integrity Monitoring (FIM)** | Detect changes to critical OS files |
| **Adaptive application controls** | ML-based application allowlisting |
| **Threat detection** | Alerts for brute force, unusual processes, fileless attacks |

### Exam Tips
- Defender for Servers Plan 2 includes **FIM** and **OS vulnerability assessment** (not in Plan 1)
- MDE is automatically provisioned on supported VMs when Defender for Servers is enabled
- Alerts from Defender for Servers appear in **Microsoft Defender for Cloud** and **Microsoft Sentinel**

---

## 4. Disk Encryption

### Azure Disk Encryption (ADE)
- Encrypts **VM OS and data disks**
- Windows: Uses **BitLocker**
- Linux: Uses **dm-crypt**
- Keys and secrets stored in **Azure Key Vault**
- Requires Key Vault with **soft delete** and disk encryption enabled

### Server-Side Encryption (SSE)
- Transparent encryption of data in Azure Storage (disks, blobs, etc.)
- Always enabled; cannot be disabled
- Key options:
  - **Platform-managed keys (PMK)**: Azure manages the keys (default)
  - **Customer-managed keys (CMK)**: Your keys in Key Vault or Managed HSM

### Encryption at Host
- Extends SSE to **temporary disks and cache** (OS/data disk cache)
- Data encrypted before leaving the host
- Compatible with CMK
- Must be enabled at **subscription level** (`az feature register --name EncryptionAtHost`)

### Confidential Disk Encryption
- Encrypts OS disk and binds encryption to the VM's TPM
- Only the VM can decrypt — even Azure can't access the content
- Requires **confidential VM SKUs** (DCsv3, ECsv5, etc.)

### Key Comparison
| Feature | ADE | SSE (PMK) | SSE (CMK) | Encryption at Host |
|---|---|---|---|---|
| Encrypts OS disk | ✅ | ✅ | ✅ | ✅ |
| Encrypts temp disk | ✅ (partial) | ❌ | ❌ | ✅ |
| Customer controls keys | ✅ (Key Vault) | ❌ | ✅ (Key Vault) | ✅ (Key Vault) |
| Transparent to VM | ❌ | ✅ | ✅ | ✅ |

### Exam Tips
- **ADE vs SSE**: ADE is VM-level (BitLocker/dm-crypt); SSE is Storage-service-level (transparent)
- SSE is **always on** — you can only choose the key type
- **CMK requires** Key Vault with purge protection enabled
- **Encryption at host** covers temp disks that ADE may miss

---

## 5. Azure Container Security (ACI, AKS)

### Azure Container Instances (ACI)
- Serverless containers; no infrastructure to manage
- Security considerations:
  - Use **managed identity** for access to other services
  - Pull images from **Azure Container Registry (ACR)** with managed identity
  - Enable **VNet integration** to avoid public exposure
  - Use **confidential containers** for sensitive workloads

### Azure Container Registry (ACR)
| Feature | Description |
|---|---|
| **Content trust** | Sign images; only trusted images can be deployed |
| **Defender for Container Registries** | Scan images for vulnerabilities on push and import |
| **Private Endpoint** | Restrict access to ACR from VNet only |
| **RBAC** | Control who can push/pull images |
| **Geo-replication** | Multi-region redundancy |

### Azure Kubernetes Service (AKS)
| Security Area | Best Practice |
|---|---|
| **Authentication** | Azure AD integration (Entra RBAC for Kubernetes) |
| **Authorization** | Kubernetes RBAC + Azure RBAC for AKS |
| **Network policy** | Use Calico or Azure network policies to restrict pod-to-pod traffic |
| **Node security** | Use node pools with OS disk encryption; apply node auto-upgrades |
| **Secret management** | Azure Key Vault Provider for Secrets Store CSI Driver |
| **Image scanning** | Defender for Containers scans images in ACR and at runtime |
| **Pod identity** | Use Workload Identity (OIDC) or AAD Pod Identity for managed identities |
| **Private cluster** | Disable public API server endpoint |
| **Admission control** | Use OPA Gatekeeper / Azure Policy add-on for AKS |

### Microsoft Defender for Containers
- Protects AKS, ACR, and containerized workloads
- Capabilities: image scanning, runtime threat detection, Kubernetes audit log analysis, network threat detection
- Security recommendations surface in Defender for Cloud

### Exam Tips
- **Workload Identity** is the recommended approach for pods to access Azure services (replaces AAD Pod Identity)
- Use **Azure Policy for AKS** to enforce security configurations
- **Defender for Containers** covers both ACR (image scanning) and AKS (runtime)
- Enable **private cluster** for production AKS to prevent public API server access

---

## 6. Azure App Service Security

### Authentication and Authorization
- **Easy Auth**: Built-in authentication module; no code changes needed
- Supports: Microsoft Entra ID, Microsoft Account, Google, Facebook, Twitter
- Integrates with **managed identity** for backend service access

### Network Security
| Feature | Description |
|---|---|
| **Access restrictions** | IP-based allow/deny rules for inbound traffic |
| **Service Endpoints** | Restrict inbound traffic to specific VNets |
| **Private Endpoint** | Private IP for inbound access; disable public access |
| **VNet Integration** | Outbound traffic routed through VNet |
| **Hybrid Connections** | Connect to on-premises resources without VPN |

### TLS and Certificates
- Enforce **HTTPS only** (redirect HTTP to HTTPS)
- Minimum TLS version: enforce **TLS 1.2** or higher
- Upload custom TLS certificates or use App Service Managed Certificate (free)
- Use **Key Vault references** for certificates and secrets in app settings

### Exam Tips
- Use **Key Vault references** in App Service app settings instead of storing secrets directly
- Enable **Managed Identity** for App Service to access Key Vault, Storage, and other services
- **CORS** settings in App Service should be restricted to known origins

---

## 7. Securing Azure Storage

### Authentication Options
| Method | Description |
|---|---|
| **Azure AD / RBAC** | Recommended; use managed identity or user identity |
| **Shared Key (account key)** | Full account access; avoid using directly |
| **SAS tokens** | Scoped, time-limited access |
| **Anonymous access** | Blob public access; should be disabled for most scenarios |

### SAS Token Types
| Type | Description |
|---|---|
| **Account SAS** | Access to services/resources at account level |
| **Service SAS** | Access to specific resource in one service |
| **User delegation SAS** | Signed with Azure AD credentials (most secure) |
| **Stored access policy** | Server-side policy that can be revoked |

### Encryption
| Level | Description |
|---|---|
| **SSE (default)** | Always on; encrypts all data at rest in Azure Storage |
| **CMK** | Customer-managed keys in Key Vault; full key lifecycle control |
| **Client-side encryption** | Encrypt before uploading; Azure never sees plaintext |
| **HTTPS** | Always use HTTPS; enforce via **"Secure transfer required"** setting |

### Network Security
- **Firewall rules**: Allow specific IP ranges or VNets
- **Service Endpoints**: Route traffic from VNet over backbone
- **Private Endpoints**: Private IP in VNet; disable public access
- **Trusted services**: Allow specific Azure services to bypass firewall

### Storage Security Features
| Feature | Description |
|---|---|
| **Soft delete** | Recover deleted blobs, containers, file shares (7–365 days) |
| **Versioning** | Maintain all versions of blobs |
| **Immutable storage (WORM)** | Write-once-read-many; compliance/legal hold |
| **Defender for Storage** | Detect anomalous access, malware, and threats |
| **Shared Access Signature (SAS)** | Delegate limited access to storage |
| **Lifecycle management** | Automatically tier/delete old data |

### Exam Tips
- Disable **Allow Blob Public Access** at storage account level unless needed
- Use **User delegation SAS** (Azure AD-signed) over Account/Service SAS for better security
- Enable **"Secure transfer required"** to enforce HTTPS
- **Stored access policies** allow SAS revocation without regenerating account keys
- **Immutable storage** is used for regulatory compliance (WORM, legal hold)

---

## 8. Securing Azure SQL Database

### Authentication
| Method | Description |
|---|---|
| **SQL Authentication** | Username + password in the database |
| **Azure AD Authentication** | Entra ID users/groups/managed identity — recommended |
| **Azure AD-only mode** | Disable SQL authentication entirely |

### Network Security
| Feature | Description |
|---|---|
| **Server-level firewall rules** | Allow specific IPs to connect |
| **VNet rules (service endpoints)** | Allow traffic from specific VNet subnets |
| **Private Endpoint** | Private IP; disable public network access |
| **Deny public network access** | Block all public connections |

### Data Encryption and Protection
| Feature | Description |
|---|---|
| **TDE (Transparent Data Encryption)** | Encrypts database, backups, logs at rest — always on |
| **TDE with CMK (BYOK)** | Customer-managed key in Key Vault |
| **Always Encrypted** | Client-side encryption; database never sees plaintext |
| **Dynamic Data Masking** | Mask sensitive columns for non-privileged users |
| **Row-Level Security** | Restrict row access based on user identity |

### Advanced Threat Protection
| Feature | Description |
|---|---|
| **Microsoft Defender for SQL** | Detects SQL injection, anomalous access, brute force |
| **SQL Audit** | Log all database events to Storage, Log Analytics, or Event Hub |
| **Vulnerability Assessment** | Scan for misconfigurations and security gaps |
| **Ledger** | Tamper-evident, immutable records for compliance |

### Exam Tips
- **Always Encrypted** protects data from database admins — Azure never sees the plaintext
- **Dynamic Data Masking** does NOT encrypt; it only masks display — admins can still see full data
- **TDE** is transparent to applications — always enabled by default
- Enable **Microsoft Defender for SQL** for threat detection + vulnerability assessment
- Use **Azure AD admin** for SQL Server and set **Azure AD-only authentication** for best security posture

---

## 9. Securing Azure Cosmos DB

### Authentication
| Method | Description |
|---|---|
| **Primary/secondary keys** | Full account access; rotate regularly |
| **Resource tokens** | Scoped access to specific resources |
| **Azure AD / RBAC** | Recommended; use managed identity or data plane RBAC |

### Network Security
- **IP firewall**: Allow specific IP addresses or ranges
- **VNet integration**: Service endpoints or private endpoints
- **Private Endpoints**: Disable public network access for production

### Encryption
- TDE encrypted at rest by default (AES-256)
- CMK support for customer-managed keys
- Always uses TLS in transit

### Defender for Cosmos DB
- Detects: SQL injection, anomalous access patterns, privilege escalation attempts
- Part of Microsoft Defender for Cloud

### Exam Tips
- Prefer **Azure AD RBAC** over primary keys for access control
- **Resource tokens** are useful for granting users access to specific documents/collections
- Enable **Private Endpoints** and disable public access for production workloads

---

## Key Exam Tips

1. **Key Vault RBAC > access policies** — use Azure RBAC for new Key Vault deployments
2. **Purge protection** is required when Key Vault is used for CMK (Customer-Managed Keys)
3. **JIT VM access** reduces exposure of management ports — enabled via Defender for Servers
4. **ADE vs SSE**: ADE is OS/VM level (BitLocker/dm-crypt); SSE is transparent storage-level encryption
5. **Always Encrypted** is the only option where even database admins/Azure can't see data
6. **Dynamic Data Masking** ≠ encryption — privileged users still see unmasked data
7. **User delegation SAS** is the most secure SAS type (uses Azure AD credentials)
8. **Workload Identity** is the modern, recommended approach for AKS pod access to Azure services
9. Disable public access + use Private Endpoints for PaaS services in production
10. Enable **Defender for Cloud** plans (Defender for Servers, Storage, SQL, Containers) for comprehensive protection

---

← [Domain 2: Secure Networking](../02-Secure-Networking/README.md) | [Back to Main Guide](../README.md) | [Domain 4: Security Operations →](../04-Security-Operations/README.md)
