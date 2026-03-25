# Domain 3 — Secure Compute, Storage, and Databases (20–25%)

---

## 3.1 Azure Disk Encryption vs Server-Side Encryption

### Server-Side Encryption (SSE)

- Encrypts data **at rest on the Azure storage backend** — transparent to the VM.
- Always enabled; cannot be disabled.
- Key options:

| Key Type | Who Manages | Use Case |
|---|---|---|
| **PMK** — Platform Managed Key | Microsoft | Default, no management overhead |
| **CMK** — Customer Managed Key | Customer (stored in Key Vault / Managed HSM) | Compliance, bring-your-own-key |

- CMK requires **Key Vault** or **Managed HSM** + disk encryption set.

### Azure Disk Encryption (ADE)

- Encrypts the **OS and data disks at the OS level** using **BitLocker** (Windows) or **DM-Crypt** (Linux).
- Keys and passphrases stored in **Azure Key Vault**.
- Use ADE when OS-level encryption is a compliance requirement (e.g., PCI DSS disk encryption mandates).
- Requires Key Vault in the **same region** as the VM.

### Comparison

| Aspect | SSE (PMK/CMK) | ADE (BitLocker/DM-Crypt) |
|---|---|---|
| Encryption layer | Storage backend | OS-level |
| Key location | Azure internal / Key Vault | Key Vault |
| Transparent to VM | ✅ | ❌ (VM must be running) |
| VM restart needed | ❌ | ✅ (initial enable) |
| Double encryption | Combine SSE CMK + ADE | — |

> 💡 **Exam tip** — ADE is the answer when the question requires encryption *"within the operating system"* or *"BitLocker"*.

---

## 3.2 Just-in-Time (JIT) VM Access

> Requires **Defender for Servers Plan 2**.

### How JIT Works

1. Admin **enables JIT** on a VM in Defender for Cloud.
2. Defender creates NSG rules that **deny RDP (3389) and SSH (22) inbound by default**.
3. When access is needed, user **requests access** (via portal, CLI, or API) specifying source IP and duration.
4. Defender **temporarily opens the NSG rule** for the approved time window.
5. Rule automatically **reverts to deny** when the window expires.

### Benefits

- Eliminates permanently open management ports.
- Provides an audit trail of who accessed what and when.
- Reduces attack surface for brute-force attacks.

### CLI Example

```bash
# Request JIT access on a VM
az security jit-policy create \
  --name default \
  --resource-group myRG \
  --virtual-machines '[{
    "id": "/subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM",
    "ports": [{"number": 22, "protocol": "TCP", "allowedSourceAddressPrefix": "*", "maxRequestAccessDuration": "PT3H"}]
  }]'
```

---

## 3.3 Azure Bastion

See also [Domain 2 — Section 2.8](02-secure-networking.md#28-azure-bastion) for SKU comparison.

### Security Benefits vs Public IP RDP/SSH

| With Public IP | With Bastion |
|---|---|
| VM exposed to internet | VM has no public IP |
| Open port 3389/22 inbound | Port 3389/22 never opened |
| Session traffic over internet | Session traffic over Azure backbone |
| No session recording (native) | Session recording (Standard SKU) |

---

## 3.4 AKS Security

### Network Policies

| Policy Engine | Scope | Notes |
|---|---|---|
| **Azure CNI Network Policy** | Azure-native | Requires Azure CNI plugin |
| **Calico** | Open-source | Works with Kubenet or Azure CNI |

Network policies control pod-to-pod traffic (L3/L4) using **Kubernetes NetworkPolicy** objects.

### RBAC Integration

- **Azure RBAC for Kubernetes** — Use Entra ID groups to control kubectl access.
- **Pod Identity (Workload Identity)** — Pods use managed identities instead of embedded credentials.

### Image Security

- Use **Azure Container Registry (ACR)** with private endpoint.
- Enable **Microsoft Defender for Containers** for image vulnerability scanning.
- Use **Azure Policy for AKS** to enforce admission controls (e.g., no privileged containers).

### Key Vault Integration

- AKS nodes can mount Key Vault secrets as volumes using the **Secrets Store CSI Driver**.
- Requires **Workload Identity** or managed identity for the CSI driver pod.

---

## 3.5 Azure Storage Security

### Storage Account Security Layers

| Control | Description |
|---|---|
| **Require HTTPS** | Enforce secure transfer; disable HTTP |
| **Minimum TLS version** | Set to TLS 1.2 minimum |
| **Allow/Deny public blob access** | Disable anonymous read access |
| **Network default action** | Deny all; add VNet/IP exceptions |
| **Service Endpoints** | Route traffic through VNet |
| **Private Endpoints** | Private IP for storage in VNet |
| **Microsoft Defender for Storage** | Detect anomalous access, malware upload scanning |

### SAS Token Types

| Type | Signed By | Revoke Without Rotation |
|---|---|---|
| **Account SAS** | Storage account key | ❌ Must rotate key |
| **Service SAS** | Storage account key | ❌ Must rotate key |
| **User Delegation SAS** | Entra ID OAuth token | ✅ Revoke Entra ID token / invalidate UDK |

> 💡 **Exam tip** — User Delegation SAS is the most secure SAS type because it's backed by Entra ID credentials, not storage account keys.

### Stored Access Policies

- Attach a **Stored Access Policy** to a Service SAS to enable server-side revocation without key rotation.
- Useful for Service SAS when User Delegation SAS cannot be used.

### Immutable Blob Storage (WORM)

- **Time-based retention** — Blobs cannot be modified/deleted for the specified period.
- **Legal hold** — Blobs cannot be modified/deleted until the hold is cleared.
- Useful for compliance (SEC 17a-4, CFTC, FINRA).

---

## 3.6 Azure SQL Database Security

### Authentication Methods

| Method | Description |
|---|---|
| **SQL Authentication** | Username + password (legacy) |
| **Entra ID Authentication** | Recommended; supports MFA, managed identities |
| **Entra ID — Managed Identity** | No credentials; ideal for Azure-hosted apps |

### Always Encrypted

- Encrypts **specific columns** in the database.
- Encryption/decryption happens **in the client driver** — SQL Server/Azure SQL never sees plaintext.
- Keys:
  - **Column Encryption Key (CEK)** — Encrypts column data; stored in DB (encrypted).
  - **Column Master Key (CMK)** — Encrypts the CEK; stored in Key Vault or certificate store.
- SQL DBA cannot see the plaintext data even with full DB admin access.

### Dynamic Data Masking (DDM)

- Masks data **in query results** for non-privileged users.
- Underlying data is stored in plaintext.
- Privileged users (db_owner, sysadmin) always see unmasked data.
- Masking functions: `default`, `email`, `random`, `custom string`, `datetime`.

> ⚠️ **DDM does NOT protect data at rest or in transit — it only masks query results.**

### Transparent Data Encryption (TDE)

- Encrypts the entire database at rest (data files, log files, backups).
- Enabled by default on Azure SQL.
- Can use service-managed key or customer-managed key (CMK in Key Vault).

### Microsoft Defender for SQL (ATP)

- Detects anomalous SQL access patterns (SQL injection, unusual login locations).
- Generates **security alerts** in Defender for Cloud.
- Covers: Azure SQL, SQL Managed Instance, SQL on VMs, Azure Synapse.

### SQL Auditing

- Logs all database events to **Log Analytics**, **Event Hub**, or **Azure Storage**.
- Required for compliance frameworks.
- Enable at server level (inherits to all databases) or individual database level.

### Advanced Data Security — Private Endpoint

- Deploy a **Private Endpoint** for Azure SQL to remove public internet access.
- Combine with Entra ID authentication to eliminate SQL credentials.

---

## 3.7 Architecture Decision Guidance

| Requirement | Solution |
|---|---|
| Encrypt VM disks at OS level for PCI DSS | ADE (BitLocker/DM-Crypt) |
| Encrypt storage at rest with customer key | SSE with CMK (disk encryption set) |
| Restrict SSH/RDP access, enable audit trail | JIT VM Access (Defender for Servers P2) |
| Secure browser-based RDP to VMs without public IP | Azure Bastion |
| Prevent SQL injection data theft | Microsoft Defender for SQL + Private Endpoint |
| Hide sensitive column data from app developers | Dynamic Data Masking |
| Protect specific columns even from DBAs | Always Encrypted |
| Prevent blob deletion for regulatory compliance | Immutable Blob Storage (WORM) |
| Secure SAS token without key rotation on revoke | User Delegation SAS |

---

## 3.8 CLI Quick Reference

```bash
# Enable ADE on a Linux VM
az vm encryption enable \
  --resource-group myRG \
  --name myVM \
  --disk-encryption-keyvault myKV \
  --volume-type All

# Show ADE status
az vm encryption show --name myVM --resource-group myRG

# Enable JIT policy via Defender for Cloud
az security jit-policy create --name default \
  --resource-group myRG \
  --virtual-machines "[{\"id\":\"/subscriptions/<sub>/resourceGroups/myRG/providers/Microsoft.Compute/virtualMachines/myVM\",\"ports\":[{\"number\":22,\"protocol\":\"TCP\",\"allowedSourceAddressPrefix\":\"*\",\"maxRequestAccessDuration\":\"PT3H\"}]}]"

# Create storage account with secure defaults
az storage account create \
  --name mystorage \
  --resource-group myRG \
  --https-only true \
  --min-tls-version TLS1_2 \
  --default-action Deny \
  --allow-blob-public-access false

# Enable Defender for Storage
az security pricing create \
  --name StorageAccounts \
  --tier Standard
```

---

## 3.9 Practice Questions

**Q1.** A compliance requirement states that encryption keys for Azure VM disks must be managed by the company and stored outside Azure infrastructure. Which solution meets this requirement?

- A. Enable Azure Disk Encryption with Azure-managed keys  
- B. Use Server-Side Encryption with Platform Managed Keys (PMK)  
- C. Use Server-Side Encryption with Customer Managed Keys (CMK) stored in Azure Key Vault Managed HSM  
- D. Enable BitLocker using a password stored in the VM  

<details><summary>Answer</summary>
**C** — SSE with CMK stored in a customer-controlled Key Vault Managed HSM gives the company full key ownership and control outside standard Azure storage infrastructure.
</details>

---

**Q2.** A developer needs to grant temporary read access to a specific blob container to an external partner. The access should automatically expire and be revocable without rotating the storage account key. Which option satisfies both requirements?

- A. Account SAS with an expiry date  
- B. Service SAS backed by a Stored Access Policy  
- C. User Delegation SAS  
- D. Shared storage account key  

<details><summary>Answer</summary>
**B** — A Service SAS backed by a Stored Access Policy can be revoked server-side by modifying or deleting the policy, without rotating the account key. User Delegation SAS (C) would also work for revocation but requires Entra ID authentication.
</details>

---

**Q3.** An organisation wants to ensure that even the database administrator cannot see the values in the `CreditCardNumber` column of an Azure SQL database. Which feature provides this protection?

- A. Dynamic Data Masking  
- B. Transparent Data Encryption  
- C. Always Encrypted  
- D. Row-Level Security  

<details><summary>Answer</summary>
**C** — Always Encrypted performs encryption/decryption in the client driver. The database engine (and DBA) never has access to plaintext values.
</details>

---

**Q4.** A company needs to restrict RDP access to Azure VMs to approved source IPs only during a defined maintenance window, with all access logged. Which Defender for Cloud feature should they use?

- A. Microsoft Defender for Servers — Vulnerability Assessment  
- B. Just-in-Time (JIT) VM Access  
- C. Adaptive Application Controls  
- D. Azure Bastion with Standard SKU  

<details><summary>Answer</summary>
**B** — JIT VM Access restricts management ports (RDP/SSH) by default and temporarily opens them only when explicitly requested and approved, with full audit logging.
</details>

---

**Q5.** Which Azure SQL feature logs all database activities (SELECT, INSERT, DELETE, login failures) to a storage account for compliance review?

- A. Microsoft Defender for SQL  
- B. SQL Auditing  
- C. Dynamic Data Masking  
- D. Transparent Data Encryption  

<details><summary>Answer</summary>
**B** — SQL Auditing records database events (reads, writes, schema changes, logins) to a configured audit log destination (Storage, Log Analytics, Event Hub).
</details>
