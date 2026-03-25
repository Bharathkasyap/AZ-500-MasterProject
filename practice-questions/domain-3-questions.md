# Practice Questions — Domain 3: Secure Compute, Storage, and Databases

> **Back to [README](../README.md)**  
> **Domain Weight**: 20–25% of AZ-500 exam

---

### Question 1

**You need to ensure that sensitive data in an Azure SQL Database column (credit card numbers) is never exposed to application developers — even when they query the database directly.**

**Which feature should you implement?**

A. Transparent Data Encryption (TDE)  
B. Dynamic Data Masking (DDM)  
C. Always Encrypted  
D. Row-Level Security (RLS)  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Always Encrypted**

Always Encrypted encrypts column data on the **client side** before sending it to the database. The database engine never sees the plaintext — meaning DBAs, database admins, and even Microsoft support cannot read the data.

- **A is incorrect**: TDE encrypts data AT REST (the physical database files). Data is decrypted when queried — DBAs can still see the values.
- **B is incorrect**: DDM masks display output but the underlying data is still accessible. DBAs and privileged users can see real data.
- **D is incorrect**: RLS controls which ROWS a user can see, not column-level data protection.

</details>

---

### Question 2

**An application running on an Azure VM needs to read secrets from Azure Key Vault. The application should not store any credentials.**

**Which solution meets these requirements with the LEAST operational overhead?**

A. Create a service principal and store the client secret in a Key Vault  
B. Create a service principal and store the client certificate in the application's local cert store  
C. Enable system-assigned managed identity on the VM and assign Key Vault Secrets User role  
D. Use the storage account access key for Key Vault authentication  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — System-assigned managed identity with Key Vault Secrets User role**

System-assigned managed identity:
- Is automatically created when enabled on the VM
- Credentials are managed by Azure (no manual rotation needed)
- The VM authenticates to Key Vault using the managed identity token (from IMDS)
- Zero credential storage required

- **A is incorrect**: Still requires storing a client secret — even if in Key Vault, you need credentials to access that Key Vault first (bootstrapping problem).
- **B is incorrect**: Certificates require management and rotation.
- **D is incorrect**: Storage account keys have nothing to do with Key Vault authentication.

</details>

---

### Question 3

**Your company stores customer PII in Azure Blob Storage. Compliance requires that data be encrypted with company-managed keys that can be revoked immediately if needed.**

**Which configuration satisfies this requirement?**

A. Platform-managed keys (PMK) with Azure Storage Service Encryption (SSE)  
B. Customer-managed keys (CMK) stored in Azure Key Vault with purge protection enabled  
C. Azure Disk Encryption (ADE) applied to the storage account  
D. Client-side encryption using the Azure Storage SDK  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Customer-managed keys (CMK) in Azure Key Vault**

CMK allows you to:
- Use your own keys (BYOK)
- Control key lifecycle (rotate, disable, revoke)
- **Disable or delete the key** to immediately prevent data access (revoking CMK makes the storage inaccessible)
- Meet compliance requirements for key ownership

- **A is incorrect**: PMK means Microsoft controls the keys — you cannot revoke them.
- **C is incorrect**: ADE is for VM disk encryption, not storage account blob encryption.
- **D is incorrect**: Client-side encryption is done by the application — while valid, it doesn't use Key Vault CMK for server-side encryption.

</details>

---

### Question 4

**You generate a SAS token for a storage container with full access. You realize you need to invalidate it immediately because it was accidentally shared.**

**What is the MOST effective approach?**

A. Delete and recreate the storage account  
B. Regenerate the storage account access key used to sign the SAS token  
C. Delete the storage container  
D. Change the storage account name  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Regenerate the storage account access key**

An Account SAS or Service SAS is signed using the storage account access key. When you regenerate the key, all SAS tokens signed with the old key are **immediately invalidated**.

- **A is incorrect**: Deleting the storage account loses all data.
- **C is incorrect**: Deleting the container loses data and the SAS may have access to other containers.
- **D is incorrect**: You cannot rename a storage account.

**Better prevention**: Use **User Delegation SAS** (signed with Entra credentials, not storage keys). To revoke, revoke the user's permissions — no key rotation needed.

</details>

---

### Question 5

**You want to detect SQL injection attempts and unusual database access patterns in Azure SQL Database.**

**What should you enable?**

A. Azure SQL Auditing to Storage Account  
B. Microsoft Defender for SQL  
C. Transparent Data Encryption (TDE)  
D. SQL Server Firewall Rules  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Microsoft Defender for SQL**

Defender for SQL includes:
- **Advanced Threat Protection (ATP)**: Detects SQL injection attempts, brute force attacks, unusual access patterns, suspicious privilege escalation
- **Vulnerability Assessment**: Scans for misconfigurations and compliance issues

- **A is incorrect**: Auditing logs all activity but doesn't analyze for threats.
- **C is incorrect**: TDE encrypts at rest — has nothing to do with threat detection.
- **D is incorrect**: Firewall rules restrict access but don't detect attacks.

</details>

---

### Question 6

**Which Azure Key Vault feature prevents the permanent deletion of a vault or its contents during a 7–90 day retention period?**

A. Key Vault access policies  
B. Soft delete  
C. Purge protection  
D. Key rotation  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Soft delete**

Soft delete retains deleted Key Vault resources for a configurable period (7–90 days, default 90). During this period, resources appear in a "deleted" state and can be recovered.

**However**: Even with soft delete enabled, a user with sufficient permissions can permanently purge the deleted vault/secret.

**Purge protection** (option C) prevents purging during the soft-delete retention period — even by users with high permissions. To fully prevent accidental or malicious deletion, you need **BOTH soft delete AND purge protection**.

- **A is incorrect**: Access policies control who can access secrets/keys/certs.
- **C is incorrect**: Purge protection prevents PERMANENT deletion after soft delete — but it requires soft delete to be enabled first.
- **D is incorrect**: Key rotation updates the key version used for encryption.

</details>

---

### Question 7

**A developer stored a database password in Azure App Service application settings as plain text. How should this be remediated?**

A. Encrypt the application settings file  
B. Replace the value with a Key Vault reference using the syntax `@Microsoft.KeyVault(SecretUri=...)`  
C. Store the password in a separate config file protected by ACLs  
D. Base64-encode the password in application settings  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Use a Key Vault reference**

Azure App Service supports **Key Vault references** directly in application settings. The value `@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/DbPassword/)` is resolved at runtime — the app sees the secret value but it's stored securely in Key Vault.

Requirements:
- The App Service must have a managed identity
- The managed identity must have `Key Vault Secrets User` role

- **A is incorrect**: App Service settings files cannot be "encrypted" by the developer.
- **C is incorrect**: ACLs in App Service don't prevent reading by the platform or other processes.
- **D is incorrect**: Base64 is encoding, not encryption — trivially reversible.

</details>

---

### Question 8

**You need to ensure that Azure VMs in your subscription use only images from a trusted, approved set published by your organization. How do you enforce this?**

A. Configure an NSG to block VM creation from unauthorized images  
B. Use Azure Policy with a deny effect to restrict allowed VM images  
C. Enable Microsoft Defender for Servers  
D. Configure Azure Advisor recommendations  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Azure Policy with deny effect**

Azure Policy can enforce allowed VM images at the subscription or resource group level. The policy evaluates the `imageReference` in the VM deployment and denies creation if the image is not in the approved list.

```json
// Policy rule example
"if": {
  "not": {
    "field": "Microsoft.Compute/virtualMachines/storageProfile.imageReference.publisher",
    "in": "[parameters('approvedPublishers')]"
  }
},
"then": {
  "effect": "deny"
}
```

- **A is incorrect**: NSGs control network traffic, not resource creation.
- **C is incorrect**: Defender for Servers detects threats but doesn't restrict what images are used.
- **D is incorrect**: Advisor provides recommendations, not enforcement.

</details>

---

### Question 9

**What is the purpose of Azure Disk Encryption (ADE) compared to Storage Service Encryption (SSE)?**

A. ADE encrypts OS and data disks at the OS level; SSE encrypts storage at the Azure storage layer  
B. ADE is for Linux VMs only; SSE is for Windows VMs  
C. ADE requires a Standard tier storage account; SSE works with all tiers  
D. ADE uses AES-128; SSE uses AES-256  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: A — ADE encrypts at OS level; SSE encrypts at storage layer**

| | Azure Disk Encryption (ADE) | Storage Service Encryption (SSE) |
|---|---|---|
| **Where** | OS-level (BitLocker/dm-crypt) | Azure storage infrastructure |
| **Key storage** | Azure Key Vault | PMK (default) or CMK in Key Vault |
| **Protects against** | Physical disk theft, unauthorized OS access | Unauthorized storage access |
| **Transparency** | OS manages encryption | Transparent to OS and VMs |

Both can be used together for defense-in-depth. SSE is always on; ADE is optional but provides deeper protection.

</details>

---

### Question 10

**You need to allow data scientists (non-privileged users) to query the `Salary` column in a database table, but they should only see masked values (e.g., `XXXX` instead of actual salaries).**

**Which feature should you implement?**

A. Always Encrypted with deterministic encryption  
B. Row-Level Security  
C. Dynamic Data Masking with a custom mask function  
D. Column-level encryption using Transact-SQL  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Dynamic Data Masking**

DDM is designed exactly for this scenario:
- Non-privileged users see masked data (e.g., `0` for numbers, `XXXX-XXXX` for custom patterns)
- Privileged users (with `UNMASK` permission) see real values
- No changes to application code or data storage
- Data is masked at query time

```sql
ALTER TABLE Employees
ALTER COLUMN Salary ADD MASKED WITH (FUNCTION = 'default()');
-- Non-privileged users see: 0
-- With custom mask: FUNCTION = 'partial(0,"XXXX",0)' shows XXXX
```

- **A is incorrect**: Always Encrypted hides data from DBAs at the engine level — more extreme than needed.
- **B is incorrect**: RLS controls which ROWS are visible based on user context.
- **D is incorrect**: T-SQL column encryption would break queries for all users.

</details>

---

## 📊 Score Yourself

| Score | Performance |
|---|---|
| 9–10 correct | Excellent — Strong compute/storage/DB security knowledge |
| 7–8 correct | Good — Review weak areas |
| 5–6 correct | Fair — Revisit Domain 3 study guide |
| < 5 correct | Needs work — Re-read study guide thoroughly |

---

> ⬅️ [Domain 2 Questions](./domain-2-questions.md) | ➡️ [Domain 4 Questions](./domain-4-questions.md)
