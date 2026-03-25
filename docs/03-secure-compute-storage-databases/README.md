# Domain 3: Secure Compute, Storage, and Databases (20–25%)

← [Back to main README](../../README.md)

This domain covers security for Azure **virtual machines, containers, storage accounts, databases, and Azure Key Vault**. It accounts for **20–25%** of the AZ-500 exam.

---

## Table of Contents

1. [Microsoft Defender for Cloud](#1-microsoft-defender-for-cloud)
2. [Azure Virtual Machine Security](#2-azure-virtual-machine-security)
3. [Container Security — Azure Container Registry (ACR)](#3-container-security--azure-container-registry-acr)
4. [Container Security — Azure Kubernetes Service (AKS)](#4-container-security--azure-kubernetes-service-aks)
5. [Azure Key Vault](#5-azure-key-vault)
6. [Azure Storage Security](#6-azure-storage-security)
7. [Azure SQL Database Security](#7-azure-sql-database-security)
8. [Azure Disk Encryption](#8-azure-disk-encryption)
9. [Key Exam Tips for Domain 3](#key-exam-tips-for-domain-3)

---

## 1. Microsoft Defender for Cloud

### What Defender for Cloud Does

Microsoft Defender for Cloud (formerly Azure Security Center + Azure Defender) is a **Cloud Security Posture Management (CSPM)** and **Cloud Workload Protection Platform (CWPP)** service.

Two primary functions:
1. **CSPM**: Assess your security posture; provide a Secure Score; give recommendations
2. **Workload protection**: Detect and respond to threats on specific Azure resource types

### Secure Score

A numeric representation of your security posture:
- Range: 0–100%
- Based on completing **security recommendations**
- Grouped into **security controls** (clusters of related recommendations)
- Higher score = better security posture

### Defender Plans (Paid Workload Protection)

| Defender Plan | What It Protects |
|---|---|
| Defender for Servers | VMs (Windows & Linux); integrates with MDE |
| Defender for App Service | Azure App Service apps |
| Defender for Storage | Azure Blob/File Storage; detects malicious uploads, anomalous access |
| Defender for SQL | Azure SQL, SQL on VMs, Arc-enabled SQL |
| Defender for Containers | AKS, ACR, Kubernetes on other clouds |
| Defender for Key Vault | Detects unusual access to Key Vault |
| Defender for DNS | Detects DNS-based attacks (requires no agent) |
| Defender for Resource Manager | Detects suspicious management plane operations |
| Defender for Open-Source Relational DBs | PostgreSQL, MySQL, MariaDB |

### Security Alerts vs Recommendations

| Type | Description |
|---|---|
| **Recommendation** | An action to improve security posture (e.g., "Enable MFA for accounts with read permissions") |
| **Security Alert** | An active threat detected (e.g., "Suspicious PowerShell activity detected on VM") |

### Regulatory Compliance Dashboard

- Maps your resources against compliance frameworks (e.g., **NIST SP 800-53**, **ISO 27001**, **PCI DSS**, **CIS Benchmarks**)
- Shows percentage of compliant controls
- Built-in and custom compliance standards supported

### Microsoft Defender for Servers

Two plans:
- **Plan 1**: VM endpoint detection with Microsoft Defender for Endpoint (MDE)
- **Plan 2**: Plan 1 + vulnerability assessment, just-in-time VM access, adaptive application controls, file integrity monitoring

### Just-in-Time (JIT) VM Access

Reduces attack surface by:
1. Blocking management ports (RDP 3389, SSH 22, WinRM 5985/5986) in NSG by default
2. When access needed, user requests access → NSG rule temporarily opened for their IP for a limited time (e.g., 3 hours)
3. NSG rule automatically removed when time expires

> **Exam Tip**: JIT requires **Microsoft Defender for Servers Plan 2**. It's one of the most exam-tested features in Domain 3.

### Adaptive Application Controls

Machine learning-based **application allowlisting** for VMs:
- Defender for Cloud analyzes running processes and recommends allow rules
- Alerts when unauthorized applications run
- Works on both Windows (AppLocker) and Linux

### File Integrity Monitoring (FIM)

Monitors **critical OS files, registry keys, and application files** for unexpected changes:
- Windows: Registry hives, system files, application files
- Linux: Critical files (e.g., /etc/passwd, /etc/shadow, binary files)

---

## 2. Azure Virtual Machine Security

### Update Management

- **Azure Update Manager** — Assess and deploy OS patches for Windows/Linux VMs
- Configure maintenance windows to control when patches are applied
- Azure Automation Update Management (legacy) — being replaced by Azure Update Manager

### VM Vulnerability Assessment

Two providers in Defender for Cloud:
- **Microsoft Defender Vulnerability Management** (built-in; recommended for Defender for Servers P2)
- **Qualys** (integrated scanner for Defender for Servers P1/P2)

Scans for known CVEs in OS and installed applications.

### Endpoint Protection

- **Microsoft Defender for Endpoint (MDE)** — Integrated with Defender for Servers
- Auto-provisioned on supported Windows Server 2019+ VMs
- Provides EDR, behavioral analysis, threat intelligence

### VM Secure Configuration

| Best Practice | Implementation |
|---|---|
| Disable RDP/SSH from internet | NSG deny rules + Azure Bastion + JIT |
| Use managed disks | Automatic server-side encryption |
| Enable Azure Disk Encryption | Customer-managed BitLocker/DM-Crypt keys in Key Vault |
| Use managed identities | No credentials stored in VM |
| Enable boot diagnostics | Capture VM console output for troubleshooting |
| Use Azure Trusted Launch | vTPM, Secure Boot, Integrity Monitoring for Gen2 VMs |

---

## 3. Container Security — Azure Container Registry (ACR)

### ACR Authentication Methods

| Method | Use Case |
|---|---|
| **Admin user** | Testing only; disabled by default; not recommended for production |
| **Service principal** | CI/CD pipelines; granular roles (AcrPull, AcrPush, AcrDelete, etc.) |
| **Managed identity** | Azure compute (AKS, App Service, VM) accessing ACR |
| **Azure AD token** | `az acr login` uses current Azure AD identity |

### ACR Roles

| Role | Permissions |
|---|---|
| AcrPull | Pull images |
| AcrPush | Pull and push images |
| AcrDelete | Delete images |
| AcrImageSigner | Sign images (Content Trust) |
| Owner/Contributor | Full registry management |

### ACR Security Features

| Feature | Description |
|---|---|
| **Content Trust (Notary)** | Sign images; only signed images can be pulled (requires Docker Notary) |
| **Defender for Containers** | Vulnerability scanning of images pushed to ACR |
| **Private endpoint** | Connect ACR via private IP (disable public access) |
| **Geo-replication** | Replicate registry to multiple regions |
| **Customer-managed keys** | Encrypt registry data with keys stored in Key Vault |
| **Network rules** | Restrict access by IP or VNet service endpoint |
| **Retention policies** | Auto-delete untagged manifests |

### Container Image Scanning

Defender for Containers scans container images:
- On push to ACR
- On pull (recently pushed images)
- Periodically on images in the registry

Reports CVE findings with severity levels.

> **Exam Tip**: Disabling the admin account in ACR is a security best practice. Admin credentials are username/password and cannot be restricted by role.

---

## 4. Container Security — Azure Kubernetes Service (AKS)

### AKS Security Layers

```
AKS Security
├── Cluster infrastructure security
│   ├── API server access (private cluster / authorized IP ranges)
│   ├── Node security (managed nodes, auto-upgrade, Defender for Containers)
│   └── Network policy (Calico / Azure Network Policy)
├── Identity and access
│   ├── Azure AD integration + RBAC (Kubernetes RBAC mapped to Azure AD)
│   └── Workload Identity (pod managed identities)
├── Container security
│   ├── Image scanning (Defender for Containers + ACR)
│   ├── Azure Policy for AKS (deny non-compliant pods via OPA Gatekeeper)
│   └── Container sandboxing (kata containers, gVisor)
└── Data protection
    ├── etcd encryption at rest (managed)
    └── Persistent volume encryption
```

### AKS API Server Access Controls

| Option | Description |
|---|---|
| **Authorized IP ranges** | Whitelist specific IP ranges that can reach the Kubernetes API |
| **Private cluster** | API server only reachable from within a VNet (no public endpoint) |

### AKS Network Policies

Control pod-to-pod traffic:
- **Azure Network Policy** (Windows and Linux nodes)
- **Calico** (Linux only; more advanced policies)

### Azure Policy for AKS

Uses **OPA Gatekeeper** to enforce policies at pod admission:
- Block privileged containers
- Require read-only root filesystem
- Enforce resource limits
- Restrict host network access
- Limit container images to approved registries

### AKS Workload Identity

Replace pod-level service account tokens with **Azure Workload Identity**:
- Each pod gets a federated credential mapped to a managed identity
- No secrets stored in cluster; token is short-lived

---

## 5. Azure Key Vault

### What Key Vault Stores

| Object Type | Description | Examples |
|---|---|---|
| **Secrets** | Arbitrary text values | Connection strings, passwords, API keys |
| **Keys** | Cryptographic keys | RSA, EC keys for signing, encryption |
| **Certificates** | X.509 certificates | TLS/SSL certificates with lifecycle management |

### Key Vault Tiers

| Tier | Hardware Protection | Notes |
|---|---|---|
| **Standard** | Software-protected keys | Lower cost |
| **Premium** | HSM-backed keys (FIPS 140-2 Level 2) | Higher cost; required for compliance requiring HSM |
| **Managed HSM** | Dedicated HSM (FIPS 140-2 Level 3) | Highest security; single-tenant HSM |

### Access Control Models

#### Vault Access Policy (Legacy)
- Permissions set per identity at the vault level
- Granular permissions: `get`, `list`, `set`, `delete`, `backup`, `restore`, `recover`, `purge`
- All objects (secrets, keys, certs) managed under same policy

#### Azure RBAC (Recommended)
- Role assignments at vault, secret, key, or certificate scope
- Integrates with Azure standard RBAC
- More granular than vault access policies

| RBAC Role | Permissions |
|---|---|
| Key Vault Administrator | Full management of vault and all objects |
| Key Vault Secrets Officer | Create, delete, update secrets |
| Key Vault Secrets User | Read secret values |
| Key Vault Crypto Officer | Create, delete, update keys |
| Key Vault Crypto User | Encrypt/decrypt/sign/verify with keys |
| Key Vault Reader | Read metadata only (no values) |

> **Exam Tip**: Know which role allows **reading secret values** — `Key Vault Secrets User`. The `Reader` role only allows reading metadata, not values.

### Soft Delete and Purge Protection

| Feature | Description | Default |
|---|---|---|
| **Soft delete** | Deleted objects retained for 7–90 days | Enabled (cannot disable) |
| **Purge protection** | Prevents permanent deletion during retention period | Optional; recommended |

With purge protection enabled:
- Objects cannot be permanently deleted during the retention period
- Protects against accidental deletion and ransomware/insider threats

### Key Rotation

- **Manual**: Rotate keys and update application configuration
- **Automatic**: Key Vault can auto-rotate keys on schedule or near expiry
- Use **Key Vault Event Grid integration** to trigger app updates when a key is rotated

### Private Endpoint for Key Vault

- Assign a private IP to Key Vault from your VNet
- Disable public network access
- Configure private DNS zone: `privatelink.vaultcore.azure.net`

### Managed HSM

- Dedicated, single-tenant HSM pool
- FIPS 140-2 Level 3 validated
- Full key lifecycle management
- Required for some regulatory frameworks (e.g., FedRAMP High, CJIS)

---

## 6. Azure Storage Security

### Storage Account Encryption

**At rest:**
- All Azure Storage data encrypted at rest using **AES-256**
- Encryption is **automatic and cannot be disabled**
- Key options:
  - **Microsoft-managed keys (MMK)**: Default; Microsoft handles key management
  - **Customer-managed keys (CMK)**: Your keys in Azure Key Vault; you control rotation
  - **Customer-provided keys**: You provide the key per-request (for Blob only)

**In transit:**
- Enforce HTTPS with "Secure transfer required" setting (enabled by default in new accounts)
- Minimum TLS version can be set (recommend TLS 1.2+)

### Storage Account Access Control

| Method | Description |
|---|---|
| **Storage account keys** | Full root access; avoid for applications; rotate regularly |
| **Azure AD + RBAC** | Recommended for Blob, Queue, Table; use data-plane roles |
| **Shared Access Signatures (SAS)** | Delegated, time-limited, scoped access tokens |
| **Anonymous access** | Blob-level or container-level; disabled by default |

### Shared Access Signatures (SAS) Types

| SAS Type | Description |
|---|---|
| **Account SAS** | Access to multiple storage services (blob, file, queue, table) |
| **Service SAS** | Access to a single service |
| **User Delegation SAS** | Signed with Azure AD credentials instead of storage key; most secure |

> **Exam Tip**: **User Delegation SAS** is the most secure type — it uses Azure AD credentials and doesn't expose the storage account key.

### Storage Firewall and Virtual Networks

- Restrict access to specific VNets (service endpoints) or IP ranges
- **Trusted Azure services**: Allow Azure services like Defender for Cloud, Backup to bypass the firewall

### Blob Access Tiers and Immutability

**Immutable Blob Storage:**
- **Time-based retention policy**: Objects cannot be modified or deleted until retention period expires
- **Legal hold**: Objects locked indefinitely; released when legal hold is explicitly cleared
- Used for WORM (Write Once, Read Many) compliance scenarios

### Microsoft Defender for Storage

Detects:
- Anomalous data access (unusual location, unusual user agent)
- Malicious file upload (known malware hash)
- Public exposure of sensitive data
- Phishing content hosted in storage

---

## 7. Azure SQL Database Security

### Authentication Methods

| Method | Description |
|---|---|
| **SQL Authentication** | Username/password in the database; legacy; avoid if possible |
| **Azure AD Authentication** | Azure AD users, groups, managed identities; recommended |
| **Active Directory Integrated** | Federated Windows identity |

> **Exam Tip**: Configure an **Azure AD admin** for the SQL server. This is required to enable Azure AD authentication.

### SQL Firewall Rules

- **Server-level**: Apply to all databases on the server
- **Database-level**: Apply to a specific database
- Configure to allow only known IP ranges; block all others

### Advanced Data Security Features

| Feature | Description |
|---|---|
| **Advanced Threat Protection** | Detects anomalous SQL queries (SQL injection, brute force, unusual access) |
| **Data Discovery & Classification** | Labels sensitive columns with sensitivity and information type labels |
| **Vulnerability Assessment** | Scans for misconfigurations; compares against security baselines |

### Transparent Data Encryption (TDE)

- Encrypts database files at rest
- Enabled by default on Azure SQL
- Key options:
  - **Service-managed keys**: Default; Microsoft-managed
  - **Bring Your Own Key (BYOK)**: Customer-managed key in Azure Key Vault

### Dynamic Data Masking

- Obfuscates sensitive data in query results for non-privileged users
- Policies applied at column level (e.g., email, credit card, SSN)
- Data in database is unchanged; masking applied in query results only
- Privileged users (db_owner, sysadmin) always see unmasked data

### Always Encrypted

- Client-side encryption — data encrypted **before** it leaves the client
- Database server never sees plaintext data
- Keys stored in client-side key stores (Windows Certificate Store, Azure Key Vault, or hardware security modules)
- Two key types: **Column Master Key (CMK)** and **Column Encryption Key (CEK)**

### Row-Level Security (RLS)

- Restricts which rows users can read or modify using a predicate function
- Transparent to the application
- Use case: Multi-tenant databases where each tenant sees only their own data

### Azure SQL Auditing

- Records SQL events to Azure Storage, Log Analytics, or Event Hubs
- Required for compliance in most regulatory frameworks
- Includes: Login events, schema changes, data access, stored procedure executions

---

## 8. Azure Disk Encryption

### Encryption Types Comparison

| Type | Technology | Key Storage | Scope |
|---|---|---|---|
| **Azure Disk Encryption (ADE)** | BitLocker (Windows) / DM-Crypt (Linux) | Azure Key Vault | OS + data disks |
| **Server-Side Encryption (SSE)** | AES-256 at storage layer | Platform or CMK in Key Vault | All managed disks (default) |
| **Encryption at Host** | SSE applied at VM host before data written to storage | Platform or CMK | Temp disk + cache |
| **Confidential Disk Encryption** | Bound to vTPM; prevents host OS/hypervisor access | vTPM | OS disk |

### ADE (Azure Disk Encryption) Details

- Uses **Azure Key Vault** to store disk encryption keys (DEKs) and key encryption keys (KEKs)
- Supports Windows (BitLocker) and Linux (DM-Crypt/LUKS)
- Encrypts OS disk and data disks
- VM must have access to Key Vault (via managed identity or service principal)
- **Does not work on Basic tier VMs or Ultra Disks**

### Server-Side Encryption (SSE)

- **Default**: Enabled automatically for all Azure managed disks
- **Platform-managed keys**: Microsoft manages the keys
- **Customer-managed keys**: Keys in Azure Key Vault; more control but more management overhead
- **Disk Encryption Sets**: Azure resource that maps managed disks to CMK in Key Vault

---

## Key Exam Tips for Domain 3

1. **JIT VM access**: Requires Defender for Servers Plan 2. Opens NSG port temporarily for a specific IP. Does NOT require a VPN.
2. **Key Vault access models**: Vault access policies (legacy) vs RBAC (recommended). Know the key RBAC roles, especially `Key Vault Secrets User` for reading values.
3. **Soft delete vs Purge protection**: Soft delete is now always on; purge protection prevents deletion during retention. Enable purge protection for ransomware/insider threat protection.
4. **User Delegation SAS**: Most secure SAS type; uses Azure AD credentials; doesn't expose storage account key.
5. **TDE BYOK**: Enables customer-controlled encryption for SQL; keys in Azure Key Vault. If CMK is deleted/disabled, DB becomes inaccessible.
6. **Always Encrypted**: Client-side encryption; server never sees plaintext. Different from TDE (which encrypts at rest at the server).
7. **Dynamic Data Masking**: Masks data IN QUERY RESULTS only; underlying data is unchanged. db_owner bypasses masking.
8. **ACR admin account**: Disabled by default; should NOT be enabled in production. Use managed identities or service principals instead.
9. **AKS private cluster**: API server accessible only from VNet; use this for production workloads.
10. **Azure Disk Encryption vs SSE**: ADE uses BitLocker/DM-Crypt with keys in Key Vault; SSE is storage-level encryption that's always on. ADE provides defense-in-depth.
