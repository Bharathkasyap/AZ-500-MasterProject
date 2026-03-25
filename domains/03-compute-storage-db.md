# Domain 3 — Secure Compute, Storage, and Databases (20–25%)

> **Exam weight:** 20–25% of the total score (~12–15 questions out of 60)

---

## Table of Contents

1. [Azure Key Vault](#1-azure-key-vault)
2. [Virtual Machine Security](#2-virtual-machine-security)
3. [Azure Disk Encryption (ADE)](#3-azure-disk-encryption-ade)
4. [Container Security (ACR & AKS)](#4-container-security-acr--aks)
5. [Azure App Service Security](#5-azure-app-service-security)
6. [Azure Storage Security](#6-azure-storage-security)
7. [Azure SQL Database Security](#7-azure-sql-database-security)
8. [Cosmos DB Security](#8-cosmos-db-security)
9. [Key Exam Points](#key-exam-points)

---

## 1. Azure Key Vault

Azure Key Vault is a cloud service for securely storing and accessing **secrets, keys, and certificates**.

### Object Types
| Type | Examples | Use Case |
|------|---------|---------|
| **Secrets** | API keys, passwords, connection strings | Application configuration |
| **Keys** | RSA, EC keys (2048–4096-bit) | Encryption, signing (Bring Your Own Key) |
| **Certificates** | TLS/SSL certificates | App authentication, TLS termination |

### SKUs
| SKU | HSM-backed Keys | Price |
|-----|----------------|-------|
| **Standard** | ❌ (software-backed) | Lower |
| **Premium** | ✅ (FIPS 140-2 Level 2) | Higher |

### Access Models
| Model | Description | Recommended For |
|-------|-------------|----------------|
| **Access Policies** | Legacy model; grant per-principal permissions to secrets/keys/certs | Existing workloads |
| **RBAC** (data plane) | Use Azure RBAC roles like "Key Vault Secrets User" | New workloads (recommended) |

> **Exam tip:** You must configure **both** a Key Vault access policy/RBAC role **and** network access (firewall). By default, Key Vault is accessible from all networks.

### Key Vault Firewall & Network Rules
- Allow specific VNet subnets (service endpoints required on subnet).
- Allow specific IP ranges.
- Allow trusted Microsoft services.
- Private Endpoint — fully private access.

### Soft-Delete & Purge Protection
| Feature | Description | Default |
|---------|-------------|---------|
| **Soft-delete** | Deleted objects retained for 7–90 days (configurable) | Enabled (cannot be disabled) |
| **Purge Protection** | Prevents permanent deletion during retention period | Disabled (opt-in) |

> **Exam tip:** Enable **purge protection** to prevent ransomware attacks from permanently deleting keys/secrets.

### Managed HSM
- FIPS 140-2 Level 3 validated HSMs.
- Single-tenant, fully managed.
- Key operations performed only within the HSM boundary.
- Uses RBAC only (no access policies).

### Key Rotation
```bash
# Create a key rotation policy
az keyvault key rotation-policy update \
  --vault-name <vault> \
  --name <key-name> \
  --value @rotation-policy.json
```

Key rotation policies can be:
- Time-based (rotate every 90 days)
- Expiry-based (rotate 30 days before expiry)
- Event-driven (via Event Grid → Logic App/Function)

---

## 2. Virtual Machine Security

### Security Baselines
- **Azure Security Benchmark** — Microsoft's security recommendations for Azure.
- **Guest Configuration** (Azure Policy) — audits VM OS settings.
- **Defender for Endpoint** (MDE) integration — endpoint detection and response.

### Update Management
- **Azure Update Manager** — patch VMs at scale, track compliance.
- **Automatic Guest Patching** — automatically install critical/security patches.

### VM Image Security
- **Azure Compute Gallery** — share and version VM images.
- **Trusted Launch** — Secure Boot + vTPM for Gen2 VMs; prevents rootkits/bootkits.
- **Confidential VMs** — hardware-level memory encryption (AMD SEV-SNP).

### Endpoint Protection
```bash
# Enable Microsoft Antimalware on a VM
az vm extension set \
  --resource-group <rg> \
  --vm-name <vm> \
  --name IaaSAntimalware \
  --publisher Microsoft.Azure.Security \
  --version 1.3
```

---

## 3. Azure Disk Encryption (ADE)

ADE encrypts OS and data disks of Azure VMs using:
- **Windows**: BitLocker
- **Linux**: DM-Crypt

### Architecture
```
VM Disk (encrypted at rest)
  ↓
Encryption Key (BEK — Block Encryption Key)
  ↓ wrapped by
Key Encryption Key (KEK — RSA key in Key Vault)
  ↓ stored in
Azure Key Vault
```

### Enabling ADE
```bash
az vm encryption enable \
  --resource-group <rg> \
  --name <vm-name> \
  --disk-encryption-keyvault <vault-resource-id> \
  --key-encryption-key <kek-key-id> \
  --volume-type All
```

### ADE vs. Server-Side Encryption (SSE)
| Feature | ADE | SSE with CMK |
|---------|-----|-------------|
| Encrypts | OS + Data disks | Data at rest (storage layer) |
| Key stored in | Key Vault | Key Vault / Managed HSM |
| Guest OS visible | Yes (BitLocker/dm-crypt) | No (transparent) |
| Encryption scope | VM-level | Disk/snapshot |
| Requirement | Key Vault | Disk Encryption Set + Key Vault |

> **Exam tip:** SSE with platform-managed keys (PMK) is enabled **by default** on all managed disks. ADE adds **guest OS-level encryption** on top for defence in depth.

---

## 4. Container Security (ACR & AKS)

### Azure Container Registry (ACR)

#### Authentication Options
| Method | Use Case |
|--------|---------|
| Admin account | Dev/test only (not recommended for production) |
| Service principal | CI/CD pipelines |
| Managed identity | AKS, Container Apps, Functions |
| RBAC roles | AcrPull, AcrPush, AcrDelete, Owner |

#### Image Security
- **Microsoft Defender for Container Registries** — scans images for vulnerabilities on push and pull.
- **Content Trust** (Docker Notary v1) — sign and verify images.
- **Azure Policy** — enforce trusted registries and signed images.
- **Private Endpoint** — restrict registry access to VNet only.

### Azure Kubernetes Service (AKS)

#### Authentication & Authorization
| Layer | Options |
|-------|---------|
| Cluster authentication | Entra ID integration (recommended) |
| Authorization | Kubernetes RBAC + Azure RBAC |
| Pod identity | Workload Identity (federated credentials) |

#### Network Security
```yaml
# Network Policy (Calico or Azure CNI) example
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

#### Security Hardening
- **Private cluster** — API server accessible only within VNet.
- **Authorized IP ranges** — restrict API server access to specific IPs.
- **Azure Policy add-on** — enforce pod security standards.
- **Defender for Containers** — runtime threat detection, image scanning.
- **Secrets Store CSI Driver** — mount Key Vault secrets into pods as volumes.

---

## 5. Azure App Service Security

### Authentication (Easy Auth)
Built-in authentication/authorization module supports:
- Microsoft Entra ID
- Facebook, Google, Twitter
- Any OpenID Connect provider

### Network Isolation
| Feature | Description |
|---------|-------------|
| **VNet Integration** | App can connect to resources in a VNet (outbound) |
| **Private Endpoints** | Inbound access only from VNet (no public exposure) |
| **App Service Environment (ASE)** | Fully isolated, dedicated compute in your VNet |
| **Access Restrictions** | IP/CIDR or service tag allow/deny list |

### TLS/SSL
- Minimum TLS version enforced (1.2 recommended).
- HTTPS-only setting — auto-redirects HTTP to HTTPS.
- Managed certificates — free, auto-renewing TLS certs.
- Custom certificates — stored in Key Vault.

### Managed Identity for App Service
```json
// App setting to reference Key Vault secret
{
  "name": "ConnectionString",
  "value": "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/myconn/)"
}
```

---

## 6. Azure Storage Security

### Encryption at Rest
- All Azure Storage is encrypted at rest by default using **AES-256**.
- **Platform-managed keys (PMK)**: Microsoft manages keys (default).
- **Customer-managed keys (CMK)**: Keys stored in Key Vault; you control rotation and lifecycle.
- **Customer-provided keys (CPK)**: Keys provided per-request; not stored by Azure.

### Authentication Options
| Method | Use Case | Security Level |
|--------|---------|----------------|
| Account key (access key) | Legacy; admin access | Lowest — full access |
| Shared Access Signature (SAS) | Delegated, scoped, time-limited access | Medium |
| Azure AD (RBAC) | Role-based access to blob/queue data | Highest (recommended) |
| Anonymous public access | Public containers/blobs | None — disable unless required |

### Shared Access Signatures (SAS)
| Type | Scope | Key Used |
|------|-------|---------|
| **Account SAS** | Storage account, service, or resource | Storage account key |
| **Service SAS** | Single service (blob, queue, file, table) | Storage account key |
| **User Delegation SAS** | Blob/Data Lake only | Entra ID user context |

> **Exam tip:** **User Delegation SAS** is the most secure SAS type because it uses Entra ID credentials, not storage account keys.

### Storage Firewall
- Allow specific VNets (via service endpoints or private endpoints).
- Allow specific IP ranges.
- Allow trusted Azure services (e.g., Azure Backup, Azure Site Recovery).

### Immutable Storage
- **Time-based retention policy**: Objects cannot be modified/deleted for a specified period.
- **Legal hold**: Objects retained indefinitely until the hold is cleared.
- **Use case**: WORM (Write Once, Read Many) compliance.

### Blob Soft Delete & Versioning
| Feature | Protects Against |
|---------|-----------------|
| Blob soft delete | Accidental delete/overwrite (retention 1–365 days) |
| Container soft delete | Accidental container deletion |
| Versioning | Previous versions retained automatically |
| Point-in-time restore | Restore to any point within retention period |

### Secure Transfer Required
- Enforces HTTPS only — all HTTP requests are rejected.
- Enabled by default on new storage accounts.

---

## 7. Azure SQL Database Security

### Network Security
| Feature | Description |
|---------|-------------|
| Server-level firewall | Allow specific IPs/ranges |
| VNet rules (service endpoints) | Allow specific VNet subnets |
| Private Endpoint | Fully private access via VNet |
| Deny public network access | Block all public connectivity |

### Authentication
| Method | Description |
|--------|-------------|
| SQL authentication | Username/password stored in the database |
| **Azure AD authentication** | Recommended; supports MFA, managed identities |
| Azure AD-only mode | Disables SQL authentication entirely |

### Transparent Data Encryption (TDE)
- Encrypts the database file on disk (AES-256).
- Enabled by default for all new Azure SQL databases.
- Supports **Bring Your Own Key (BYOK)** via Key Vault — Customer-managed TDE protector.

### Always Encrypted
- Client-side encryption — data is encrypted **before** it reaches SQL Server.
- SQL Server/Azure SQL never sees plaintext data.
- Keys stored in Windows Certificate Store, Azure Key Vault, or Hardware Security Module.
- Use cases: Sensitive columns (SSNs, credit card numbers).

### Dynamic Data Masking (DDM)
- Masks sensitive data in query results for non-privileged users.
- Does not encrypt — data is still stored in plaintext.
- Policy-based: select columns and masking function.

### Microsoft Defender for SQL
- **Advanced Threat Protection (ATP)**: Detects SQL injection, anomalous access patterns.
- **Vulnerability Assessment**: Scans for misconfigurations and missing patches.
- Integrated with Microsoft Defender for Cloud.

### SQL Auditing
- Logs database events to Storage Account, Log Analytics, or Event Hub.
- Audit log includes: date/time, server name, statement type, success/failure, client IP.

### Row-Level Security (RLS)
```sql
-- Only allow users to see their own rows
CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE Security.fn_securitypredicate(SalesRep)
ON Sales.Orders;
```

---

## 8. Cosmos DB Security

### Network Security
- IP firewall rules.
- VNet service endpoints.
- Private Endpoints (recommended).

### Authentication
- **Primary/secondary keys** — full admin access.
- **Resource tokens** — scoped, time-limited tokens for specific collections/documents.
- **Azure AD (preview/GA varies)** — RBAC for control and data plane.

### Encryption
- Data encrypted at rest by default (AES-256).
- Customer-managed keys supported via Key Vault.
- Data encrypted in transit (TLS 1.2).

### Microsoft Defender for Cosmos DB
- Detects SQL injection attempts in Cosmos queries.
- Anomalous access pattern detection.

---

## Key Exam Points

- [ ] **Key Vault Purge Protection** must be enabled to prevent ransomware from permanently deleting keys.
- [ ] **User Delegation SAS** is more secure than Account/Service SAS because it uses Entra ID credentials.
- [ ] **TDE** encrypts the database file; **Always Encrypted** encrypts data before it leaves the client.
- [ ] **Dynamic Data Masking** does **not** encrypt data — it only masks it in query results.
- [ ] **Soft-delete** on Key Vault is now always-on and cannot be disabled for new vaults.
- [ ] **ADE** provides guest OS-level encryption on top of SSE (defense in depth).
- [ ] **Managed identities** should be used for AKS to ACR authentication (not admin accounts or service principals).
- [ ] **Azure Policy add-on for AKS** enforces pod security admission controls at scale.
- [ ] Know the difference between Key Vault **access policies** vs. **Azure RBAC** access model.
- [ ] **Deny public network access** on Azure SQL prevents all connections, even from Azure services, unless using private endpoints.
