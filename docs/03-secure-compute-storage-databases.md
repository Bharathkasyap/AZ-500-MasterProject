# Domain 3: Secure Compute, Storage, and Databases (20–25%)

> This domain covers securing Azure virtual machines, containers (AKS), Azure Storage, and Azure database services.

---

## Objectives Covered

- Plan and implement advanced security for compute
- Plan and implement security for storage
- Plan and implement security for Azure SQL Database and Azure SQL Managed Instance

---

## 3.1 Virtual Machine Security

### Endpoint Protection & Antimalware
- **Microsoft Antimalware for Azure** is a free real-time protection extension for VMs
- **Microsoft Defender for Endpoint** (Plan 1 / Plan 2) is the enterprise-grade EDR solution, automatically integrated via Defender for Cloud

### Disk Encryption

| Option | Encrypts | Key Management |
|---|---|---|
| Azure Disk Encryption (ADE) | OS + data disks using BitLocker (Windows) or DM-Crypt (Linux) | Keys stored in Azure Key Vault |
| Server-side encryption (SSE) | Data at rest at the storage layer | Platform-managed or customer-managed keys (CMK) |
| Encryption at host | All temp disks and cache at the host level | Platform-managed or CMK |

> ⚠️ **Exam tip:** ADE encrypts at the VM level (inside the OS). SSE encrypts at the storage service level. Both can be applied simultaneously.

```bash
# Enable Azure Disk Encryption on a VM
az vm encryption enable \
  --resource-group myRG \
  --name myVM \
  --disk-encryption-keyvault myKeyVault \
  --volume-type All
```

### Just-in-Time (JIT) VM Access

JIT locks down inbound management ports (RDP 3389, SSH 22, WinRM 5985/5986) by default and opens them on-demand for a limited time.

**How JIT Works:**
1. Defender for Cloud configures an NSG/Azure Firewall rule blocking management ports
2. User requests access (specifies IP, port, duration)
3. Defender for Cloud creates a time-limited allow rule
4. Rule is automatically removed after the duration expires

**Requirements:**
- Microsoft Defender for Servers Plan 2 (or Defender for Cloud enhanced security)
- VM must be associated with an NSG

```bash
# Request JIT access via Azure CLI
az security jit-policy list \
  --resource-group myRG \
  --location eastus

# Initiate JIT access request
az security jit-access-policy initiate \
  --resource-group myRG \
  --location eastus \
  --name default \
  --virtual-machine myVM \
  --ports '[{"number":22,"duration":"PT3H","allowedSourceAddressPrefix":["203.0.113.10"]}]'
```

### VM Security Best Practices
- Disable RDP/SSH public internet access (use JIT, Azure Bastion, or VPN/ExpressRoute)
- Use **Azure Bastion** for browser-based RDP/SSH without public IPs on VMs
- Apply **Azure Policy** to enforce VM configuration standards
- Enable **VM Guest Configuration** (Azure Policy GuestConfiguration) to audit OS settings
- Regularly patch VMs using **Azure Update Manager**

---

## 3.2 Azure Bastion

Azure Bastion provides secure RDP and SSH access to VMs through the Azure Portal over TLS, without exposing VMs to the internet.

| Feature | Basic SKU | Standard SKU |
|---|---|---|
| RDP/SSH via browser | ✅ | ✅ |
| Native client support | ❌ | ✅ |
| Shareable links | ❌ | ✅ |
| IP-based connections | ❌ | ✅ |

> ⚠️ Bastion is deployed into a dedicated subnet named **AzureBastionSubnet** with a minimum size of /26.

---

## 3.3 Container Security (AKS)

### AKS Security Components

| Area | Feature |
|---|---|
| Cluster access | Azure AD integration + Kubernetes RBAC |
| Node security | Node OS auto-upgrade, CIS benchmark hardening |
| Network policy | Calico or Azure Network Policy for pod-level traffic control |
| Image security | Microsoft Defender for Containers (image scanning) |
| Secrets management | Azure Key Vault Provider for Secrets Store CSI Driver |
| Workload identity | Azure Workload Identity (replaces pod-managed identity) |

### Kubernetes RBAC + Azure AD Integration
```yaml
# K8s RBAC — bind an Azure AD group to the cluster-admin ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: azure-ad-cluster-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: <Azure-AD-Group-Object-ID>
```

### Network Policies (Kubernetes)
```yaml
# Deny all ingress to a namespace by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

### Microsoft Defender for Containers
- Agentless vulnerability assessment of container images in ACR
- Run-time threat detection for AKS clusters
- Kubernetes control plane audit log analysis

---

## 3.4 Azure Storage Security

### Storage Account Access Control

| Method | Description | Recommended Use |
|---|---|---|
| Storage account key | Full administrative access | Avoid; use for emergency/automation |
| Shared Access Signature (SAS) | Time-limited, scoped token | Delegating limited access |
| Azure AD RBAC (Entra ID) | Identity-based access | Recommended for user/app access |
| Anonymous public access | No auth required for blobs | Disable unless required (public data) |

### Shared Access Signature (SAS) Types

| SAS Type | Signed By | Scope |
|---|---|---|
| Account SAS | Storage account key | Entire account; multiple services |
| Service SAS | Storage account key | Single service (Blob/Queue/Table/File) |
| User Delegation SAS | Azure AD credentials | Blob/Data Lake only — **most secure** |

> ⚠️ **Exam tip:** A **User Delegation SAS** is the most secure because it is signed by Azure AD credentials, not the storage account key. If the key is rotated, user delegation SAS tokens remain valid (until their expiry or the delegation key expires).

```bash
# Generate a User Delegation SAS (requires Storage Blob Data Contributor)
az storage blob generate-sas \
  --account-name myStorage \
  --container-name myContainer \
  --name myblob.txt \
  --permissions r \
  --expiry 2026-12-31 \
  --auth-mode login \
  --as-user
```

### Storage Account Firewall & Network Rules
```bash
# Deny all public access, allow specific VNet
az storage account update \
  --resource-group myRG \
  --name myStorage \
  --default-action Deny

az storage account network-rule add \
  --resource-group myRG \
  --account-name myStorage \
  --vnet-name myVNet \
  --subnet mySubnet
```

### Storage Encryption

| Type | Default | Customer-Managed Key |
|---|---|---|
| Encryption at rest | ✅ Enabled (256-bit AES) | Optional; keys in Key Vault or Managed HSM |
| Encryption in transit | ✅ HTTPS enforced by default | Require secure transfer |
| Double encryption | ❌ Optional | Infrastructure encryption (second layer) |

```bash
# Require HTTPS only (secure transfer)
az storage account update \
  --resource-group myRG \
  --name myStorage \
  --https-only true
```

### Soft Delete & Data Protection
- **Blob soft delete:** Retain deleted blobs for a configurable period (1–365 days)
- **Container soft delete:** Protect deleted containers
- **Blob versioning:** Automatically maintain previous versions
- **Azure Backup for Storage:** Policy-based backup of blob data

---

## 3.5 Azure SQL Database Security

### Authentication Methods
| Method | Description |
|---|---|
| SQL authentication | Username + password stored in the database |
| Azure AD authentication | Azure AD users, groups, managed identities |
| Azure AD MFA | Azure AD authentication with MFA enforcement |

> ⚠️ **Exam tip:** Disable SQL authentication where possible and use **Azure AD-only authentication** to eliminate password-based SQL logins.

### Data Encryption

| Feature | Description |
|---|---|
| TDE (Transparent Data Encryption) | Encrypts data at rest (database, backups, logs) — **enabled by default** |
| Always Encrypted | Client-side column-level encryption; even DBAs cannot see plaintext |
| Dynamic Data Masking | Obfuscates data for non-privileged users in query results |

```sql
-- Enable Dynamic Data Masking on email column
ALTER TABLE Customers
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
```

### Network Security for Azure SQL

| Control | Description |
|---|---|
| Server-level firewall rules | IP-based allow rules |
| Virtual Network service endpoints | Route traffic from VNet subnet to SQL |
| Private endpoints | Full private access via private IP |
| Deny public network access | Block all internet access |

### Microsoft Defender for SQL

- **SQL Vulnerability Assessment:** Scans for misconfigurations and overly permissive permissions
- **Advanced Threat Protection (ATP):** Detects anomalous database activities (SQL injection, brute force, unusual access patterns)

```bash
# Enable Defender for SQL on a logical server
az sql server threat-policy update \
  --resource-group myRG \
  --server mySqlServer \
  --state Enabled \
  --email-addresses "secteam@company.com" \
  --email-account-admins true
```

### Azure SQL Auditing
```bash
# Enable auditing to a Storage Account
az sql server audit-policy update \
  --resource-group myRG \
  --name mySqlServer \
  --state Enabled \
  --storage-account myAuditStorage \
  --retention-days 90
```

---

## 3.6 Azure SQL Managed Instance Security

SQL Managed Instance is deployed **inside a VNet subnet** — it has no public endpoint by default (can be optionally enabled with TLS).

| Feature | SQL Database | SQL Managed Instance |
|---|---|---|
| VNet deployment | No | Yes — fully isolated |
| Public endpoint | Optional | Disabled by default |
| SQL Agent | No | Yes |
| Always Encrypted | Yes | Yes |
| Instance-level features | No | Yes (linked servers, CLR, etc.) |

---

## 3.7 Azure Cosmos DB Security

| Security Feature | Description |
|---|---|
| Authentication | Primary/secondary keys, Resource tokens, Azure AD RBAC |
| Encryption at rest | 256-bit AES; automatic |
| Network access | IP firewall, VNet service endpoints, Private endpoints |
| Advanced Threat Protection | Detects unusual data access patterns |

> ⚠️ Use **Azure AD RBAC** for control plane access and **resource tokens** for fine-grained data plane access in Cosmos DB.

---

## 🔬 Practice Questions

**Q1.** A developer needs to allow a third-party application to read blobs from a storage container for the next 24 hours. The storage account key must not be shared. What should the developer generate?

<details>
<summary>Show Answer &amp; Explanation</summary>

> **Answer:** A **User Delegation SAS** or a **Service SAS** (Blob service) scoped to the container with Read permission and 24-hour expiry. User Delegation SAS is preferred as it doesn't expose the account key.

</details>

**Q2.** You need to ensure that sensitive columns in an Azure SQL Database (e.g., credit card numbers) cannot be read by database administrators in plaintext. Which feature should you enable?

<details>
<summary>Show Answer &amp; Explanation</summary>

> **Answer:** **Always Encrypted** — encryption and decryption happen on the client side; the database engine (and DBAs) never see plaintext data.

</details>

**Q3.** A security review finds that Azure VMs in your environment are accessible via RDP from the internet (port 3389 open in NSGs). What is the recommended remediation?

<details>
<summary>Show Answer &amp; Explanation</summary>

> **Answer:** Remove the public internet RDP NSG rule and enable **Just-in-Time (JIT) VM Access** via Microsoft Defender for Cloud, or deploy **Azure Bastion** for browser-based RDP without requiring public IP or open RDP ports.

</details>

**Q4.** You have an AKS cluster and need to ensure that pods in the `production` namespace cannot communicate with pods in the `development` namespace. What should you implement?

<details>
<summary>Show Answer &amp; Explanation</summary>

> **Answer:** **Kubernetes Network Policies** — configure a NetworkPolicy in each namespace to deny cross-namespace traffic. The AKS cluster must have network policies enabled (Calico or Azure NPM).

</details>

**Q5.** Azure SQL Database TDE is enabled. An attacker gains access to the raw backup files stored in Azure Storage. Can they read the data?

<details>
<summary>Show Answer &amp; Explanation</summary>

> **Answer:** **No** — TDE encrypts the data at rest, including backups. Without the TDE protector key (stored in Key Vault), the backup files are unreadable.

</details>

---

## 📚 Further Reading

- [Just-in-time VM access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)
- [Azure Disk Encryption](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview)
- [Azure Storage security guide](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations)
- [Azure SQL security overview](https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview)
- [AKS security concepts](https://learn.microsoft.com/en-us/azure/aks/concepts-security)
- [Always Encrypted documentation](https://learn.microsoft.com/en-us/sql/relational-databases/security/encryption/always-encrypted-database-engine)

---

*Previous: [Domain 2 — Secure Networking ←](02-secure-networking.md) | Next: [Domain 4 — Manage Security Operations →](04-manage-security-operations.md)*
