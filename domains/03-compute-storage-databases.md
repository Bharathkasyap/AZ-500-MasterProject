# Domain 3 — Secure Compute, Storage, and Databases (20–25%)

## Overview

This domain covers the security controls for Azure's core infrastructure services — virtual machines, containers, storage accounts, and database services — as well as the foundational secret management service, Azure Key Vault.

---

## 3.1 Azure Key Vault

Azure Key Vault centralizes the storage and management of cryptographic keys, secrets, and certificates.

### Key Vault Object Types

| Type | Description | Example |
|------|-------------|---------|
| **Secrets** | Passwords, connection strings, API keys | `db-password = P@ssw0rd!` |
| **Keys** | Cryptographic keys (RSA, EC) | Used for encryption/signing |
| **Certificates** | X.509 certificates | TLS certificates |

### Vault Tiers

| Tier | Description |
|------|-------------|
| **Standard** | Software-protected keys |
| **Premium** | HSM-backed keys (FIPS 140-2 Level 2) |
| **Managed HSM** | Single-tenant, FIPS 140-2 Level 3; no shared infrastructure |

### Access Models

| Model | How it Works |
|-------|-------------|
| **Vault Access Policy** | Legacy model; per-object type (keys/secrets/certs) permissions |
| **Azure RBAC** | Recommended; standard IAM role assignments on the vault |

> **Exam Tip**: The new recommended model is **Azure RBAC**. Know both models.

#### Key RBAC Roles for Key Vault

| Role | Permissions |
|------|-------------|
| Key Vault Administrator | Full control (manage policies, keys, secrets, certs) |
| Key Vault Secrets Officer | Create, read, update, delete secrets |
| Key Vault Secrets User | Read secret values only |
| Key Vault Crypto Officer | Manage keys |
| Key Vault Crypto User | Use keys for crypto operations |
| Key Vault Reader | View metadata only (no secret values) |

### Key Vault Security Features

| Feature | Description |
|---------|-------------|
| **Soft Delete** | Deleted vault/objects retained for 7–90 days (now on by default) |
| **Purge Protection** | Prevents permanent deletion during retention period |
| **Private Endpoint** | Access vault via private IP only |
| **Firewall / VNet rules** | Restrict access to specific IPs / VNets |
| **RBAC** | Granular access per user/identity |
| **Logging** | Diagnostic logs → Log Analytics / Storage |

### Bring Your Own Key (BYOK)
- Import HSM-protected keys into Key Vault Premium or Managed HSM
- Key material never leaves the HSM in plaintext
- Used for compliance requirements (e.g., FIPS 140-2 Level 3)

---

## 3.2 Virtual Machine Security

### Disk Encryption Options

| Option | Encryption Layer | Key Storage |
|--------|----------------|-------------|
| **Azure Disk Encryption (ADE)** | OS & data disks (BitLocker/dm-crypt) | Azure Key Vault |
| **Server-Side Encryption (SSE)** | Storage service (platform-managed or CMK) | Azure Key Vault or PMK |
| **Encryption at host** | Temp disks, caches, SSE flows through host | Azure Key Vault |
| **Confidential disk encryption** | OS disk tied to vTPM (confidential VMs) | Key released on attestation |

> **ADE vs SSE**: ADE encrypts the OS from inside the VM; SSE encrypts at the storage layer.
> Use **ADE** when you need OS-level encryption visible to the guest OS.

### Trusted Launch (Generation 2 VMs)
- **Secure Boot**: Prevents loading unsigned bootloaders/drivers
- **vTPM**: Virtual TPM 2.0; enables BitLocker key sealing
- **Integrity Monitoring**: Detects changes to firmware/boot sequence

### Just-in-Time (JIT) VM Access
- Closes management ports (RDP 3389, SSH 22) by default
- Opens temporarily on request, for a specific IP, for a defined time window
- Managed by **Microsoft Defender for Servers**
- Requires **Azure Firewall** or **NSG** on the VM's subnet/NIC

### VM Extensions for Security
| Extension | Purpose |
|-----------|---------|
| Microsoft Antimalware | Real-time protection, scheduled scans |
| Log Analytics Agent (MMA/AMA) | Send logs to Log Analytics workspace |
| Azure Monitor Agent (AMA) | Replaces MMA; DCR-based collection |
| Guest Configuration | Audit/enforce OS settings via Azure Policy |

---

## 3.3 Container Security

### Azure Container Registry (ACR)

| Security Feature | Description |
|----------------|-------------|
| **Private Link** | Access ACR via private IP |
| **Content Trust** | Image signing (Notary v1) |
| **Defender for Containers** | Vulnerability scanning of images |
| **RBAC** | `AcrPull`, `AcrPush`, `AcrDelete` roles |
| **Admin account** | Disabled by default; use RBAC instead |
| **Geo-replication** | High availability with zone redundancy |

### Azure Kubernetes Service (AKS) Security

| Control | Description |
|---------|-------------|
| **Azure AD integration** | Use Azure AD identities for cluster authentication |
| **Kubernetes RBAC** | Role-based access within the cluster |
| **Azure RBAC for Kubernetes** | Manage Kubernetes RBAC via Azure AD |
| **Network Policy** | Pod-to-pod traffic control (Calico or Azure CNI) |
| **Private cluster** | API server exposed only on private IP |
| **Node pool OS hardening** | Minimal OS image, auto-patching |
| **Workload Identity** | Federated identity for pods (replaces Pod Identity) |
| **Defender for Containers** | Runtime threat detection, behavioral analysis |
| **Azure Policy add-on** | Enforce Kubernetes admission policies |

---

## 3.4 Azure Storage Security

### Storage Account Access Methods

| Method | Description |
|--------|-------------|
| **Account keys** | Full access; treat as root password — avoid in production |
| **SAS (Shared Access Signature)** | Scoped, time-limited tokens |
| **Azure AD / RBAC** | Recommended for Blob and Queue |
| **Anonymous public access** | Disabled by default; enable only when necessary |

### SAS Token Types

| Type | Scope |
|------|-------|
| **Account SAS** | Multiple services and resource types |
| **Service SAS** | Single service (Blob, Queue, Table, File) |
| **User Delegation SAS** | Signed with Azure AD credentials (most secure) |

> **Exam Tip**: **User Delegation SAS** is the most secure SAS type because it uses Azure AD credentials instead of the storage account key.

### Storage Encryption

| Layer | Default | Options |
|-------|---------|---------|
| **Encryption at rest** | Always on (AES-256) | PMK or CMK (via Key Vault) |
| **Encryption in transit** | Require HTTPS (`supportsHttpsTrafficOnly`) | TLS 1.2+ minimum |
| **Double encryption** | Optional | Infrastructure encryption + SSE |

### Storage Firewall & Network Rules
- **Allow all networks** (default) — publicly accessible
- **Selected networks** — allow specific VNets (service endpoints) or IP ranges
- **Private endpoint only** — most restrictive; no public access

### Immutable Storage (WORM)
- **Time-based retention policy**: Objects locked for a defined period
- **Legal hold**: Objects locked until hold is explicitly removed
- Used for compliance (FINRA, SEC Rule 17a-4)

### Azure Defender for Storage
- Detects: access from Tor exit nodes, unusual data exfiltration, malicious file uploads
- Integrates with Microsoft Defender for Cloud

---

## 3.5 Azure SQL Database Security

### Authentication Methods

| Method | Description |
|--------|-------------|
| **SQL Authentication** | Username/password in the database |
| **Azure AD Authentication** | Recommended; supports MFA, service principals |
| **Windows Authentication** | Azure AD Kerberos (for hybrid scenarios) |

### Encryption

| Type | Description |
|------|-------------|
| **TDE (Transparent Data Encryption)** | Encrypts database files at rest; on by default |
| **Always Encrypted** | Client-side encryption; server never sees plaintext |
| **Dynamic Data Masking** | Mask sensitive data in query results for non-privileged users |

#### TDE Key Options
- **Service-managed key (default)**: Microsoft manages the key
- **Customer-managed key (BYOK)**: Key stored in Azure Key Vault

#### Always Encrypted Column Master Key (CMK) Storage
- Azure Key Vault (recommended)
- Windows Certificate Store

### Network Security

| Control | Description |
|---------|-------------|
| **Server-level firewall rules** | Allow specific IPs or Azure service IPs |
| **VNet service endpoints** | Route SQL traffic over Azure backbone |
| **Private Endpoint** | Private IP access from VNet (recommended) |
| **Deny public network access** | Block all public internet access |

### Advanced Threat Protection (Defender for SQL)

| Detection | Description |
|-----------|-------------|
| SQL Injection | Detect malicious SQL injection attempts |
| SQL Injection vulnerability | Identify injectable parameters |
| Anomalous access | Access from unusual location or principal |
| Brute force | Detect repeated failed login attempts |

### Auditing
- Log to: Azure Storage, Log Analytics, or Event Hubs
- Required for compliance (PCI DSS, ISO 27001, etc.)
- Audit log includes: query text, principal, IP, database

### Row-Level Security (RLS)
- Filter rows based on the executing user's identity
- Implemented via security predicates (table-valued functions)

### Microsoft Defender for SQL (Vulnerability Assessment)
- Scan databases for misconfigurations
- Track findings over time, export reports
- Requires Defender for SQL enabled per server

---

## 3.6 Azure SQL Managed Instance Security

- Fully isolated VNet deployment (no public endpoint by default)
- Supports SQL Agent, linked servers, CLR, cross-database queries
- Same TDE, Always Encrypted, and Advanced Threat Protection as Azure SQL DB
- **Azure AD-only authentication**: Enforce Azure AD auth, disable SQL auth

---

## 🎯 Exam Focus Points — Domain 3

1. **Key Vault access models** — RBAC vs. Access Policies; know the key roles.
2. **Soft delete + Purge Protection** — when are they required; how they prevent accidental data loss.
3. **ADE vs. SSE** — different layers; ADE is guest-OS visible encryption.
4. **JIT VM Access** — how it works; what ports it protects; requires Defender for Servers.
5. **User Delegation SAS** — why it's more secure than Account SAS.
6. **Always Encrypted vs. TDE vs. Dynamic Data Masking** — each protects a different scenario.
7. **Private Endpoint for storage/SQL** — most secure network path; disables public access.
8. **Defender for SQL** — threat detection categories (injection, anomalous, brute force).
9. **Customer-managed keys (CMK/BYOK)** — where keys are stored and why.
10. **AKS security** — private cluster, Workload Identity, network policies, Defender for Containers.
