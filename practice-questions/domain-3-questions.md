# Domain 3 — Practice Questions: Secure Compute, Storage, and Databases

> **Instructions**: Choose the best answer(s) for each question. Answers and explanations are at the bottom of the file.

---

## Questions

### Q1
A developer accidentally deleted an Azure Key Vault that contained production secrets. The vault had soft delete enabled with a 90-day retention period, but purge protection was NOT enabled. What is the risk?

A) The secrets are permanently gone — soft delete only protects for 7 days  
B) An administrator can permanently purge the vault before the 90-day period ends  
C) The vault is automatically recovered because soft delete is enabled  
D) The secrets are moved to an Azure Backup vault

---

### Q2
An application needs to read secrets from Azure Key Vault. The security team wants to use the most secure access model. Which approach should they use?

A) Create an access policy granting the application service principal Get permission on secrets  
B) Assign the **Key Vault Secrets User** RBAC role to the application's managed identity  
C) Store the Key Vault access keys in Azure App Settings  
D) Enable public network access to the Key Vault for the application's IP range

---

### Q3
A company needs to encrypt Azure VM disks so that encryption is visible to the guest OS and supports BitLocker. Which encryption solution should they use?

A) Server-Side Encryption (SSE) with platform-managed keys  
B) Azure Disk Encryption (ADE)  
C) Encryption at host  
D) Confidential disk encryption

---

### Q4
An organization stores financial records in Azure Blob Storage. They need to ensure that records cannot be modified or deleted for a minimum of 7 years for regulatory compliance. Which feature should they use?

A) Azure Storage soft delete  
B) Geo-redundant storage (GRS) replication  
C) Immutable storage with a time-based retention policy  
D) Azure Backup for Blob Storage

---

### Q5
A SQL developer is querying an Azure SQL Database that contains Social Security Numbers (SSNs). Non-privileged users should see `XXX-XX-XXXX` instead of the actual values. Which feature achieves this WITHOUT requiring changes to the application code?

A) Always Encrypted  
B) Transparent Data Encryption (TDE)  
C) Dynamic Data Masking  
D) Row-Level Security

---

### Q6
An operations team needs to temporarily access VMs for maintenance. The VMs have public IPs. Management ports 3389 and 22 are currently open. The security team wants to close these ports by default and open them only when needed. What is the BEST solution?

A) Use NSG rules with time-based expiry  
B) Enable Just-in-Time (JIT) VM access in Defender for Servers  
C) Deploy Azure Bastion and remove all NSG rules  
D) Use Azure Policy to deny port 3389 and 22 globally

---

### Q7
A company wants to ensure that all secrets and keys used in their Azure workloads are protected by a Hardware Security Module (HSM). Which Key Vault tier should they use?

A) Standard  
B) Premium  
C) Managed HSM  
D) Either B or C

---

### Q8
An Azure SQL Database is exposed to the public internet. The security team wants to ensure it is only accessible from within a specific Azure VNet using a private IP address. Which solution should they implement?

A) Configure a Server-level firewall rule for the VNet's IP range  
B) Enable VNet service endpoint on the subnet and create a VNet rule on the SQL server  
C) Create a Private Endpoint for the Azure SQL Server and disable public network access  
D) Enable Azure AD authentication only (no SQL authentication)

---

### Q9
A developer reports that when querying a column with Always Encrypted enabled, the application retrieves encrypted (ciphertext) values instead of plaintext. What is the MOST likely cause?

A) The SQL Server TDE key is expired  
B) The application connection string does not include `Column Encryption Setting=Enabled`  
C) The user lacks a Dynamic Data Masking bypass permission  
D) The Column Master Key is not in Azure Key Vault

---

### Q10
A company generates an Account SAS token that allows full access (read, write, delete) to all blob containers in a storage account, with an expiry of 365 days. A security audit flags this as a high-risk finding. What are the TWO main reasons? *(Select 2)*

A) SAS tokens cannot be used for blob storage  
B) The token has excessive permissions (full access is not needed)  
C) SAS tokens expire too quickly  
D) The token validity period (365 days) is too long, providing excessive exposure if leaked  
E) The token was signed with the account key, not with Azure AD credentials

---

### Q11
An AKS cluster handles sensitive healthcare data. The security team wants to ensure that only container images from a specific Azure Container Registry (ACR) can run in the cluster. Which solution should they use?

A) Configure a Kubernetes NetworkPolicy to block external image pulls  
B) Use Azure Policy with the **Kubernetes cluster containers should only use allowed images** built-in policy  
C) Set an NSG rule to block outbound traffic to Docker Hub  
D) Enable Content Trust on the ACR and configure image signing

---

### Q12
A company uses Azure Disk Encryption (ADE) to encrypt VM OS disks. The encryption keys are stored in Azure Key Vault. They want to prevent the Key Vault from being purged accidentally. Which features should they enable on the Key Vault? *(Select 2)*

A) Soft delete  
B) Key rotation policy  
C) Purge protection  
D) Private endpoint  
E) Azure AD Conditional Access

---

### Q13
Which Azure SQL Database security feature encrypts data at rest, including the database, backups, and transaction logs, and is enabled by DEFAULT?

A) Always Encrypted  
B) Dynamic Data Masking  
C) Transparent Data Encryption (TDE)  
D) Advanced Threat Protection

---

### Q14
A team wants to build a container-based application on AKS. They want pods to access Azure Key Vault secrets without hardcoding credentials. What is the BEST approach?

A) Store the Key Vault URL and access key in Kubernetes Secrets  
B) Use AKS Workload Identity to federate a Kubernetes service account with an Azure AD managed identity  
C) Embed the Key Vault client secret in the container image as an environment variable  
D) Use a Key Vault access policy granting access to the AKS node pool's IP range

---

### Q15
An Azure Storage account is configured to **allow all networks** (public access is on). A security recommendation in Defender for Cloud flags this. What is the MOST secure configuration change the team should make?

A) Enable geo-redundant storage (GRS)  
B) Enable soft delete for blobs  
C) Configure the storage firewall to **Selected networks** or **Disabled** and use Private Endpoints  
D) Enable storage account key rotation

---

## Answers and Explanations

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | **B** | Without purge protection, an admin (or attacker with sufficient permissions) can permanently purge the soft-deleted vault before the 90-day retention ends. Purge protection prevents this. |
| 2 | **B** | Azure RBAC with managed identity is the recommended model. It avoids storing credentials, uses the granular **Key Vault Secrets User** role (read secrets only), and follows least privilege. |
| 3 | **B** | Azure Disk Encryption (ADE) uses BitLocker (Windows) or dm-crypt (Linux) to encrypt disks at the OS level — visible to the guest OS. SSE (A) encrypts at the storage layer, transparent to the VM. |
| 4 | **C** | Immutable storage with a time-based retention policy locks blobs in WORM (Write Once, Read Many) state. Soft delete (A) only protects against accidental deletion, not modification by authorized users. |
| 5 | **C** | Dynamic Data Masking replaces sensitive data with masked values in query results for non-privileged users without changing stored data or requiring application changes. Always Encrypted (A) is client-side and does require app changes. |
| 6 | **B** | JIT VM access closes management ports by default and opens them on demand for a specific IP and time window. This eliminates persistent exposure of ports 22/3389. |
| 7 | **D** | Both Key Vault **Premium** (FIPS 140-2 Level 2 HSM) and **Managed HSM** (FIPS 140-2 Level 3) provide HSM-backed key protection. Premium is multi-tenant; Managed HSM is single-tenant. |
| 8 | **C** | Private Endpoint creates a private IP in the VNet for the SQL server and, when combined with disabling public access, removes internet exposure entirely. Service Endpoints (B) don't give a private IP. |
| 9 | **B** | Always Encrypted requires the client application to declare `Column Encryption Setting=Enabled` in the connection string so the driver knows to perform client-side decryption. |
| 10 | **B, D** | A SAS with full access and 365-day expiry is over-privileged (B) and provides a long exposure window (D). A **User Delegation SAS** signed with Azure AD (vs. account key) would reduce key exposure. |
| 11 | **B** | Azure Policy with the **allowed images** built-in policy enforces that only images from approved registries can run in the cluster via the OPA/Gatekeeper admission controller. NetworkPolicy (A) doesn't control image sources. |
| 12 | **A, C** | Soft delete retains deleted Key Vault objects. Purge protection prevents them from being permanently deleted during the retention period. Both are required to fully protect ADE keys. |
| 13 | **C** | TDE is enabled by default on all new Azure SQL Databases. It encrypts the database, transaction logs, and backups automatically. |
| 14 | **B** | AKS Workload Identity federates a Kubernetes service account with an Azure AD managed identity, allowing pods to obtain Azure AD tokens without any secrets. This is the current best practice (replaces AAD Pod Identity). |
| 15 | **C** | Restricting the storage firewall and using Private Endpoints eliminates public internet exposure. Soft delete (B) and key rotation (D) are good practices but don't address the public access issue. |
