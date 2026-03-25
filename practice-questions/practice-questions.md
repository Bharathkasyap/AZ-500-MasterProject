# AZ-500 Practice Questions

> **100+ practice questions with answers and explanations** covering all four exam domains.

---

## Table of Contents

1. [Domain 1: Manage Identity and Access](#domain-1-manage-identity-and-access)
2. [Domain 2: Secure Networking](#domain-2-secure-networking)
3. [Domain 3: Secure Compute, Storage, and Databases](#domain-3-secure-compute-storage-and-databases)
4. [Domain 4: Manage Security Operations](#domain-4-manage-security-operations)
5. [Mixed / Advanced Questions](#mixed--advanced-questions)

---

## Domain 1: Manage Identity and Access

---

**Q1.** Your organization requires that all users accessing the Azure portal from outside corporate networks must use Multi-Factor Authentication. Users inside corporate networks should not be prompted for MFA. Which Entra ID feature should you configure?

- A) Identity Protection user risk policy
- B) Conditional Access policy with named locations
- C) Azure AD Multi-Factor Authentication server
- D) SSPR policy

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

A Conditional Access policy can be configured with a **named location** representing the corporate network IP ranges. The policy applies MFA when users sign in from **outside** the named location. Identity Protection risk policies (A) trigger based on risk, not location. MFA Server (C) is an on-premises legacy solution. SSPR (D) handles password reset, not MFA enforcement.

</details>

---

**Q2.** A user reports they cannot activate their Global Administrator role in Privileged Identity Management. They are listed as "Eligible" for the role. What is the MOST likely requirement they haven't met?

- A) The role requires approval from a designated approver
- B) The user's Entra ID P1 license has expired
- C) The user is not a member of a security group
- D) The activation window has already passed

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: A**

PIM activation for high-privilege roles (like Global Administrator) is commonly configured to require **approval from a designated approver**. The user may have completed MFA but is waiting for approval. PIM requires Entra ID **P2** (not P1), so B is incorrect. Group membership (C) doesn't directly block PIM activation. An "activation window" (D) is not a PIM concept.

</details>

---

**Q3.** You need to grant an application running in Azure the ability to read secrets from Azure Key Vault without storing any credentials in the application code. What should you use?

- A) Service principal with client secret
- B) Service principal with client certificate
- C) System-assigned managed identity
- D) User-assigned managed identity with stored certificate

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

A **system-assigned managed identity** provides an automatically managed identity for the application to authenticate to Azure services (like Key Vault) without storing credentials in code. Both service principal options (A and B) require credential management. User-assigned with stored certificate (D) still involves credential management.

</details>

---

**Q4.** Your organization uses Azure AD Connect with Password Hash Synchronization. The on-premises Active Directory has become unavailable. Which statement accurately describes what will happen?

- A) Users will be unable to sign in to Azure services
- B) Users can still sign in using cloud authentication
- C) Users must use FIDO2 keys to authenticate
- D) Only MFA will be bypassed temporarily

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

With **Password Hash Synchronization (PHS)**, the password hash is synchronized to the cloud, so **cloud authentication continues** even if on-premises AD is unavailable. This is one of the key advantages of PHS over Pass-Through Authentication (PTA) and Federation, where on-premises availability is required for authentication.

</details>

---

**Q5.** A user needs to be able to read all resources in a subscription but must not be able to make any changes. Additionally, the user must NOT be able to see the contents of Azure Key Vault secrets. Which role assignment is MOST appropriate?

- A) Assign Contributor role at the subscription scope
- B) Assign Reader role at the subscription scope
- C) Assign Reader role at the subscription scope; deny Key Vault secret read
- D) Assign Key Vault Reader and Reader roles separately

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

The **Reader** role at subscription scope grants view access to all resources. Importantly, the Reader role does NOT grant access to read Key Vault secret values (that requires the `Key Vault Secrets User` role separately). Contributor (A) allows modifications. Option C is not valid (deny assignments cannot be created manually). Option D grants Key Vault Reader, which allows reading Key Vault metadata but not secret values anyway.

</details>

---

**Q6.** Which Conditional Access grant control BEST prevents access from devices that are not enrolled in Microsoft Intune?

- A) Require Multi-Factor Authentication
- B) Require Hybrid Azure AD joined device
- C) Require compliant device
- D) Require approved client app

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

**Require compliant device** enforces that the device meets Intune compliance policies. This includes requiring Intune enrollment. Hybrid Azure AD join (B) requires the device to be domain-joined to on-premises AD and Entra ID, but doesn't require Intune. Requiring MFA (A) doesn't control device enrollment. Approved client app (D) limits which apps can be used but doesn't enforce Intune enrollment.

</details>

---

**Q7.** You are configuring Azure AD B2B collaboration. An external user from `partner.com` accepts your invitation. What is their User Principal Name in your tenant?

- A) `user@partner.com`
- B) `user_partner.com#EXT#@yourtenant.onmicrosoft.com`
- C) `guest_user@yourtenant.onmicrosoft.com`
- D) `user@partner.com#EXT#@yourtenant.onmicrosoft.com`

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: D**

Azure AD B2B guest accounts use the format: `originalusername@originaldomain.com#EXT#@yourtenant.onmicrosoft.com`. The original email address is preserved, and `#EXT#` indicates it's an external (guest) user in your directory.

</details>

---

**Q8.** Identity Protection detects that a user account has a **High** user risk. What is the recommended automatic response you should configure?

- A) Block the user's sign-in permanently
- B) Require the user to reset their password using SSPR
- C) Require the user to re-register for MFA
- D) Notify the Global Administrator via email

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

For **High user risk**, the recommended response is to **require a secure password change**. This can be automated via an Identity Protection user risk policy that enforces password reset. Permanently blocking (A) is too disruptive. MFA re-registration (C) is appropriate for compromised MFA, not user risk. Email notification (D) is a manual process, not an automated response.

</details>

---

**Q9.** You need to ensure that no one can permanently delete objects from Azure Key Vault, even administrators. Which feature should you enable?

- A) Soft Delete
- B) Purge Protection
- C) Key Vault access policy
- D) Resource Lock (CanNotDelete)

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Purge Protection** prevents the permanent deletion (purging) of Key Vault objects during the retention period, even by administrators. Soft Delete (A) makes deletion recoverable but can be bypassed by administrators who can still purge. Access policy (C) controls permissions. Resource Lock (D) prevents vault deletion but not object deletion within the vault.

</details>

---

**Q10.** Your organization wants to assign the same managed identity to multiple Azure VMs to access a shared Azure Storage account. Which type of managed identity should you use?

- A) System-assigned managed identity
- B) User-assigned managed identity
- C) Service principal with client certificate
- D) Federated identity credential

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

A **user-assigned managed identity** is a standalone identity that can be assigned to **multiple resources**. A system-assigned managed identity (A) is tied to a single resource and deleted when the resource is deleted. Service principal (C) requires credential management. Federated identity credentials (D) are for external workloads (GitHub Actions, Kubernetes).

</details>

---

## Domain 2: Secure Networking

---

**Q11.** An NSG rule is configured with priority 100 that Allows inbound TCP port 3389 from any source. Another rule with priority 200 Denies inbound TCP port 3389 from any source. What is the result?

- A) Both rules cancel out; traffic is blocked by default
- B) RDP traffic is allowed (priority 100 wins)
- C) RDP traffic is blocked (Deny rules always win)
- D) The NSG configuration is invalid

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

NSG rules are evaluated in **priority order — lower number first**. Priority 100 (Allow) is evaluated before priority 200 (Deny). Once a matching rule is found, processing stops. Therefore, RDP traffic is **allowed** by the priority 100 rule. In NSGs, there is no "Deny wins" override — priority determines the outcome.

</details>

---

**Q12.** You need to allow VMs in a subnet to access Azure Storage without traffic leaving the Azure network and without assigning public IP addresses to the VMs. The storage account should not accept connections from the internet. Which solution should you implement?

- A) Configure a Service Endpoint on the subnet and restrict the storage account firewall to that VNet
- B) Configure a Private Endpoint for the storage account
- C) Configure a VPN Gateway to Azure Storage
- D) Use Azure Bastion to access storage

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

A **Private Endpoint** gives the storage account a private IP in your VNet. Traffic stays on the Microsoft backbone, the storage account can be configured to deny all public access, and VMs don't need public IPs. Service Endpoints (A) also keep traffic on the backbone but the storage account's public endpoint is still accessible (by the VNet); the storage account public IP is used as the destination. A VPN Gateway (C) connects networks, not a solution for PaaS access. Bastion (D) is for VM access.

</details>

---

**Q13.** Azure Firewall needs to allow VMs to access `https://updates.microsoft.com` but block all other outbound internet traffic. Which type of rule should you configure?

- A) Network rule allowing TCP port 443 to the internet
- B) Application rule with target FQDN `updates.microsoft.com`
- C) DNAT rule translating port 443 traffic
- D) NSG outbound rule allowing port 443

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

An **Application rule with FQDN** filtering is used to allow or deny traffic to specific domain names. A network rule (A) would allow TCP 443 to ANY internet destination, not just `updates.microsoft.com`. DNAT rules (C) are for inbound traffic translation. NSG rules (D) don't support FQDN filtering and don't go through Azure Firewall.

</details>

---

**Q14.** You have enabled Just-in-Time VM Access for a virtual machine. A developer requests access to the VM on RDP port 3389. After the access request is approved and the allowed time expires, what happens?

- A) The developer is logged out of the VM
- B) The NSG rule allowing the developer's IP is removed
- C) The VM is shut down automatically
- D) The developer's account is temporarily disabled

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

When the JIT access time expires, the **NSG rule** that was temporarily added to allow the specific IP address is **automatically removed**. The developer's active session is not interrupted (A). The VM is not shut down (C). The user account is not disabled (D). JIT controls network access, not VM state or user sessions.

</details>

---

**Q15.** Which Azure service should you use to provide secure RDP/SSH access to VMs without exposing port 3389 or 22 to the internet?

- A) Azure VPN Gateway point-to-site
- B) Azure Bastion
- C) Azure ExpressRoute
- D) Azure Front Door

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Azure Bastion** provides browser-based RDP/SSH access over HTTPS/TLS without requiring a public IP on the VM or opening RDP/SSH ports to the internet. VPN Gateway (A) requires client software and doesn't eliminate port exposure. ExpressRoute (C) is for private connectivity, not VM access management. Front Door (D) is for web apps.

</details>

---

**Q16.** Your organization uses Application Gateway WAF v2. During initial deployment, some legitimate requests are being blocked. What mode should the WAF be in during initial testing?

- A) Prevention mode
- B) Detection mode
- C) Audit mode
- D) Learning mode

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Detection mode** logs requests that match WAF rules but does NOT block them. This allows you to identify false positives and tune the WAF rules before switching to Prevention mode. Prevention mode (A) actively blocks matched requests. There is no "Audit" or "Learning" mode in Azure WAF.

</details>

---

**Q17.** You need to ensure that the Azure Bastion host can be deployed in a VNet. Which subnet requirement must be met?

- A) The subnet must be named `BastionSubnet` with at least /27 prefix
- B) The subnet must be named `AzureBastionSubnet` with at least /26 prefix
- C) The subnet must be named `AzureBastionSubnet` with at least /27 prefix
- D) The subnet must be named `GatewaySubnet` with at least /26 prefix

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

Azure Bastion requires a subnet named **exactly** `AzureBastionSubnet` with a minimum prefix length of **/26** (at least 64 IP addresses). The name must be exact — no variations allowed. A /27 is insufficient. `GatewaySubnet` is used for VPN/ExpressRoute gateways.

</details>

---

**Q18.** You need to protect your Azure subscription from volumetric and protocol-based DDoS attacks with adaptive tuning and attack analytics. Which DDoS protection option should you implement?

- A) Azure DDoS Network Protection (Basic) — free tier
- B) Azure DDoS IP Protection on each public IP
- C) Azure DDoS Network Protection (Standard) plan
- D) Azure Firewall Premium with IDPS

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

**Azure DDoS Network Protection (Standard)** provides adaptive tuning based on your traffic patterns, attack analytics, rapid response support, and cost protection. The free/basic tier (A) provides basic protection without tuning or analytics. IP Protection (B) protects individual IPs but with fewer features. Azure Firewall Premium IDPS (D) protects against known threats but is not specifically designed for volumetric DDoS.

</details>

---

**Q19.** Which statement BEST describes the difference between Service Endpoints and Private Endpoints for Azure Storage?

- A) Service Endpoints use a private IP in your VNet; Private Endpoints use the service's public IP
- B) Private Endpoints use a private IP in your VNet; Service Endpoints keep the service's public IP as the destination
- C) Both Service Endpoints and Private Endpoints use private IPs
- D) Service Endpoints block public access; Private Endpoints allow public access

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

With **Private Endpoints**, the storage account gets a **private IP** from your VNet (NIC with private IP). With **Service Endpoints**, traffic stays on the Azure backbone but the **destination is still the storage account's public IP**. Private Endpoints allow you to fully disable public access to the storage account; Service Endpoints restrict public access to specific VNets but the public endpoint still exists.

</details>

---

**Q20.** You configure an NSG flow log on a subnet NSG. Where must you store the flow log data?

- A) Azure SQL Database
- B) Log Analytics workspace directly
- C) Azure Storage account
- D) Azure Event Hub

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

NSG flow logs are stored in an **Azure Storage account**. From there, they can be processed by Traffic Analytics (which uses a Log Analytics workspace) for analysis and visualization. They are not stored directly in Log Analytics (B), SQL Database (A), or Event Hub (D).

</details>

---

## Domain 3: Secure Compute, Storage, and Databases

---

**Q21.** You need to encrypt an Azure VM's OS disk and ensure that the encryption keys are stored in Azure Key Vault. Which feature should you use?

- A) Storage Service Encryption (SSE) with platform-managed keys
- B) Azure Disk Encryption (ADE) with BitLocker/DM-Crypt
- C) Server-side encryption with customer-managed keys
- D) Encryption at host

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Azure Disk Encryption (ADE)** uses BitLocker (Windows) or DM-Crypt (Linux) to encrypt VM disks at the OS level. Encryption keys are stored in **Azure Key Vault**. SSE (A) encrypts at the storage layer without Key Vault involvement (for PMK). Server-side encryption with CMK (C) encrypts at the storage layer using Key Vault CMK but does not use BitLocker/DM-Crypt. Encryption at host (D) encrypts temp disks and cache.

</details>

---

**Q22.** A developer needs to allow a web application to read blobs from Azure Storage. You want to grant access that expires in 24 hours without using the storage account keys. Which method should you use?

- A) Account SAS token signed with the storage account key
- B) User Delegation SAS token
- C) Service SAS token with access policy
- D) Stored access policy on the container

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

A **User Delegation SAS** is signed using **Azure AD credentials** (not the storage account key), making it more secure. It has a maximum validity of 7 days. Account SAS (A) and Service SAS (C) use the storage account key. Stored access policy (D) requires a service SAS — it doesn't eliminate the key requirement.

</details>

---

**Q23.** Your Azure SQL Database is configured with Transparent Data Encryption (TDE). The database admin can still read sensitive data. Which feature should you implement to protect data from database admins?

- A) Dynamic Data Masking
- B) Row-Level Security
- C) Always Encrypted
- D) SQL Auditing

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

**Always Encrypted** performs client-side encryption — the database engine (and therefore DBAs) **never see the plaintext data**. Keys are managed by the client application. Dynamic Data Masking (A) only masks display — DBAs with the right permissions can see unmasked data. Row-Level Security (B) controls row-level access, not column encryption. SQL Auditing (D) logs activities but doesn't protect data.

</details>

---

**Q24.** Microsoft Defender for Cloud shows a secure score of 42%. Which action will help INCREASE the secure score?

- A) Enable Azure Monitor alerts
- B) Implement the recommendations shown in Defender for Cloud
- C) Enable diagnostic settings on all resources
- D) Configure Azure Policy audit policies

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

The **secure score increases** when you **implement the security recommendations** shown in Defender for Cloud. Each recommendation has an associated score increase. Enabling Monitor alerts (A) and diagnostic settings (C) are good practices but don't directly increase the secure score. Azure Policy (D) can enforce compliance but Defender for Cloud's score is based on its own recommendations.

</details>

---

**Q25.** You need to ensure that all connections to an Azure Storage account use HTTPS. Which setting should you configure?

- A) Enable storage account encryption
- B) Enable Secure transfer required
- C) Configure a HTTPS-only SAS token
- D) Enable Private Endpoint for the storage account

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Secure transfer required** (also called "HTTPS-only") setting on the storage account rejects all HTTP connections and enforces HTTPS. This is enabled by default on new storage accounts. Encryption (A) is about data at rest. HTTPS-only SAS (C) only affects SAS token access, not all connections. Private Endpoint (D) is about network isolation.

</details>

---

**Q26.** You need to store an RSA key in Azure Key Vault and ensure that the key is protected by a Hardware Security Module (HSM) and is compliant with FIPS 140-2 Level 2. Which Key Vault tier should you use?

- A) Standard tier with software-protected keys
- B) Premium tier with HSM-protected keys
- C) Managed HSM with FIPS 140-2 Level 3
- D) Standard tier with customer-managed keys

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Key Vault Premium** supports HSM-protected keys that are FIPS 140-2 Level 2 compliant. Standard tier (A, D) only uses software-protected keys. Managed HSM (C) is FIPS 140-2 Level 3 — that's even higher than required and is a separate service, not a Key Vault tier.

</details>

---

**Q27.** You want to detect if sensitive data, such as credit card numbers, is uploaded to Azure Blob Storage. Which feature should you enable?

- A) Storage Analytics logging
- B) Microsoft Defender for Storage
- C) Azure Policy for storage
- D) Azure Monitor storage diagnostics

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Microsoft Defender for Storage** includes sensitive data discovery that detects uploads of data containing PII and financial information (like credit card numbers) and generates security alerts. Storage Analytics (A) and Monitor diagnostics (D) log access operations but don't classify data. Azure Policy (C) enforces configuration, not data content.

</details>

---

**Q28.** An AKS cluster needs to pull container images from Azure Container Registry (ACR) without storing any credentials. What is the BEST approach?

- A) Enable the ACR admin account and store credentials as a Kubernetes secret
- B) Assign the AcrPull role to the AKS cluster's managed identity
- C) Create a service principal with AcrPull permissions and store in a Kubernetes secret
- D) Configure a personal access token and store in a Kubernetes secret

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

Assigning the **AcrPull role to the AKS cluster's managed identity** (kubelet identity) allows AKS to pull images from ACR without any credentials. The managed identity handles authentication automatically. Enabling admin account (A) creates a shared credential security risk. Service principal with stored credentials (C) requires credential management. Personal access tokens (D) are not a standard ACR authentication mechanism.

</details>

---

**Q29.** You need to ensure that all Azure SQL Databases in a subscription have Advanced Threat Protection enabled and that any new databases automatically get this protection. What is the MOST efficient approach?

- A) Enable Advanced Threat Protection on each database manually
- B) Enable Microsoft Defender for SQL at the subscription level
- C) Create an Azure Policy to audit databases without ATP
- D) Use Azure Automation to check and enable ATP daily

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

Enabling **Microsoft Defender for SQL at the subscription level** automatically protects all existing and **new** Azure SQL Databases in the subscription. Manual configuration (A) doesn't cover new databases. Azure Policy audit (C) identifies non-compliance but doesn't automatically enable protection. Automation runbook (D) is complex and has delays.

</details>

---

**Q30.** You need to grant a web application access to Azure Key Vault secrets without any credentials in code. The app runs in Azure App Service. What is the recommended approach?

- A) Store a service principal client secret in App Service application settings
- B) Enable a system-assigned managed identity on App Service and grant it Key Vault Secrets User role
- C) Store the Key Vault access key in environment variables
- D) Use a shared access policy for Key Vault

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

Enabling a **system-assigned managed identity** on App Service and granting it the **Key Vault Secrets User** role eliminates the need for any credentials. The managed identity token is automatically obtained by the application. Storing a client secret (A) or access key (C) in App Service settings still involves credential management. Key Vault doesn't have "shared access policies" (D).

</details>

---

## Domain 4: Manage Security Operations

---

**Q31.** You need to investigate a security incident in Microsoft Sentinel. Multiple alerts are firing for the same attack. Where should you investigate to see all related alerts grouped together?

- A) Security alerts in Microsoft Defender for Cloud
- B) Analytics rules log in Sentinel
- C) Incidents in Microsoft Sentinel
- D) Azure Activity Log

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

**Incidents** in Microsoft Sentinel group related alerts together, providing a unified view of an attack. The incident contains all associated alerts, entities (users, IPs, hosts), and evidence. Defender for Cloud alerts (A) are individual, ungrouped. Analytics rules log (B) shows rule configuration. Activity Log (D) shows Azure ARM operations.

</details>

---

**Q32.** A KQL query in Microsoft Sentinel should alert when more than 5 failed sign-in attempts occur from the same IP address within 1 hour. Which analytics rule type should you use?

- A) Fusion rule
- B) Scheduled rule
- C) NRT (Near Real-Time) rule
- D) ML Behavior Analytics rule

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

A **Scheduled rule** runs a KQL query at a configured interval (e.g., every hour) and creates an alert when the query returns results. It's the most flexible rule type for custom detection logic. Fusion rules (A) use ML to correlate signals — not custom KQL. NRT rules (C) run every minute for fast detection of simpler conditions. ML Behavior Analytics (D) uses built-in ML models, not custom queries.

</details>

---

**Q33.** You want to automatically block a user in Entra ID when Microsoft Sentinel detects a high-severity incident involving that user. What should you configure?

- A) An Analytics rule with auto-response
- B) A Sentinel Playbook triggered by an incident
- C) A Conditional Access policy with Identity Protection
- D) A Defender for Cloud workflow automation

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

A **Sentinel Playbook** (Logic App) triggered by an incident can automatically call the Entra ID API to block the user's sign-in and revoke their tokens. Analytics rules (A) detect threats but don't have built-in response actions. Conditional Access with Identity Protection (C) responds to risk, not Sentinel incidents. Defender for Cloud workflow automation (D) responds to Defender alerts, not Sentinel incidents.

</details>

---

**Q34.** Azure Policy is configured with the `Deny` effect on a policy that requires all storage accounts to have "Secure transfer required" enabled. A developer tries to create a storage account with HTTP enabled. What happens?

- A) The storage account is created with a compliance warning
- B) The storage account is created and the policy remediation runs afterward
- C) The storage account creation request is rejected
- D) An alert is sent to the security team but the account is created

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

The `Deny` effect in Azure Policy **blocks the deployment request** from completing. The resource is not created. This is different from `Audit` (which would log non-compliance but allow creation) and `DeployIfNotExists` (which deploys a related resource). With `Deny`, the ARM request is rejected with a policy violation error.

</details>

---

**Q35.** You need to ensure that Azure resources in your subscription cannot be accidentally deleted during a critical business period. What is the MOST appropriate action?

- A) Assign the Reader role to all users
- B) Apply a CanNotDelete resource lock to the resource group
- C) Enable soft delete on all resources
- D) Configure Azure Policy to audit delete operations

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

A **CanNotDelete resource lock** prevents anyone (including resource owners) from deleting the locked resource or its children. This is the most direct way to prevent accidental deletion. Assigning Reader (A) would prevent modifications too, not just deletions. Soft delete (C) allows recovery after deletion but doesn't prevent it. Azure Policy (D) can audit but not block delete operations.

</details>

---

**Q36.** When should you use an NRT (Near Real-Time) analytics rule in Microsoft Sentinel instead of a Scheduled rule?

- A) When the query requires complex joins across multiple tables
- B) When you need the fastest possible detection with minimal latency
- C) When you need to correlate events across multiple MITRE ATT&CK stages
- D) When the detection requires ML-based anomaly detection

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**NRT rules** run every minute, providing the **fastest detection** with minimal latency. They are best for time-sensitive detections. Complex joins (A) are better suited for Scheduled rules which can run on longer timeframes. Multi-stage correlation (C) is handled by Fusion rules. ML-based detection (D) is handled by ML Behavior Analytics rules.

</details>

---

**Q37.** You need to add the PCI DSS compliance standard to Microsoft Defender for Cloud to track your organization's compliance posture. Where do you configure this?

- A) Azure Policy → Assignments
- B) Defender for Cloud → Regulatory compliance → Add standard
- C) Azure Monitor → Compliance dashboard
- D) Microsoft Sentinel → Workbooks

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

In **Defender for Cloud → Regulatory compliance**, you can add industry standards like PCI DSS, NIST, ISO 27001, etc. and track compliance against them. Azure Policy → Assignments (A) is where policies are assigned but adding a compliance standard to Defender for Cloud is done through its compliance dashboard. Azure Monitor (C) and Sentinel Workbooks (D) don't manage compliance standards.

</details>

---

**Q38.** You need to monitor who is accessing secrets in Azure Key Vault and detect unusual access patterns. What should you configure?

- A) Key Vault access policy review
- B) Azure Monitor metrics for Key Vault
- C) Key Vault diagnostic settings → Log Analytics → Microsoft Sentinel
- D) Azure Advisor recommendations for Key Vault

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

Enabling **Key Vault diagnostic settings** to send audit logs to **Log Analytics** (and then to **Microsoft Sentinel**) allows you to monitor and detect unusual access patterns using analytics rules and KQL queries. Access policy review (A) is a manual process. Metrics (B) provide aggregate counts, not detailed access logs. Azure Advisor (D) gives cost/performance recommendations, not security monitoring.

</details>

---

**Q39.** A Sentinel analytics rule generates an alert every time a user signs in from a new country. Your CEO frequently travels internationally and is generating false-positive alerts. What is the BEST way to handle this?

- A) Delete the analytics rule
- B) Increase the alert threshold
- C) Add the CEO's account to an exclusion in the rule or create a suppression rule
- D) Assign the CEO a lower-privilege account

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

Adding the CEO to a **rule exclusion** (by modifying the KQL query to exclude the CEO's UPN) or creating a **suppression rule** (to suppress alerts for that user) handles the false positive without removing the valuable detection entirely. Deleting the rule (A) removes protection for all users. Changing the threshold (B) might miss real threats. Changing the CEO's account (D) doesn't solve the false positive issue.

</details>

---

**Q40.** Which log source should you configure in Sentinel to detect Azure AD sign-in anomalies, such as impossible travel or sign-ins from anonymous proxies?

- A) Azure Activity Log
- B) Microsoft Entra ID Sign-in Logs via Diagnostic Settings
- C) Windows Security Event Log from Azure AD Connect server
- D) Azure Monitor VM metrics

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Microsoft Entra ID Sign-in Logs** (connected via Entra ID Diagnostic Settings or the Sentinel data connector for Azure Active Directory) contain all sign-in events including metadata like IP address, location, and device. Sentinel's analytics rules and UEBA use this data to detect impossible travel and anonymous proxy usage. Azure Activity Log (A) logs ARM operations, not user sign-ins. Windows Security Events (C) log on-premises events. VM metrics (D) are performance metrics.

</details>

---

## Mixed / Advanced Questions

---

**Q41.** Your organization's security policy requires that no Azure storage account allows public blob access, and this must be enforced automatically for all future deployments. What is the BEST solution?

- A) Conduct weekly manual reviews of storage account configurations
- B) Configure a Defender for Cloud recommendation to audit non-compliant storage
- C) Assign an Azure Policy with the `Deny` effect requiring public blob access to be disabled
- D) Configure a Sentinel analytics rule to alert on public blob access creation

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

**Azure Policy with the `Deny` effect** prevents the creation or modification of storage accounts that would enable public blob access. This enforces the policy automatically for all future deployments. Manual reviews (A) are not automated. Defender for Cloud recommendation (B) audits but doesn't prevent. Sentinel alert (D) detects after the fact but doesn't prevent the misconfiguration.

</details>

---

**Q42.** You need to implement a solution that provides both SIEM and SOAR capabilities for your Azure environment. Which Azure service should you deploy?

- A) Microsoft Defender for Cloud
- B) Azure Monitor with Action Groups
- C) Microsoft Sentinel
- D) Azure Security Center (legacy)

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

**Microsoft Sentinel** is Azure's cloud-native SIEM (Security Information and Event Management) and SOAR (Security Orchestration, Automation, and Response) platform. Defender for Cloud (A) is CSPM/CWPP, not SIEM/SOAR. Azure Monitor (B) provides monitoring and alerts but not SIEM capabilities. Azure Security Center (D) is the old name for Defender for Cloud.

</details>

---

**Q43.** A user in your organization has the Global Administrator role permanently assigned in Entra ID. According to security best practices, what should you do?

- A) Remove the user from Global Administrator and assign Reader role
- B) Convert the assignment to an eligible assignment in PIM
- C) Add the user to all management groups as Owner
- D) Require the user to use a dedicated admin workstation

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

The security best practice is **just-in-time (JIT) access** via PIM. Converting the permanent assignment to an **eligible assignment** means the user only has Global Admin when they explicitly activate it (with MFA and justification). This reduces the attack surface of standing admin access. Removing Global Admin entirely (A) may be needed but isn't addressed here. Adding Owner everywhere (C) is worse. A dedicated workstation (D) is a good practice but doesn't address the standing privilege issue.

</details>

---

**Q44.** Which of the following is a correct statement about Azure RBAC and Entra ID roles?

- A) Entra ID roles control access to Azure resources like VMs and storage
- B) Azure RBAC roles control directory-level operations like managing users
- C) Azure RBAC roles control access to Azure resources; Entra ID roles control directory operations
- D) Both Azure RBAC and Entra ID roles are interchangeable

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: C**

**Azure RBAC** manages access to **Azure resources** (VMs, storage, networking, etc.). **Entra ID roles** manage **directory-level operations** (user management, group management, application registrations). They are separate systems with separate role definitions and are NOT interchangeable.

</details>

---

**Q45.** You need to ensure that a specific virtual machine's administrative ports (RDP and SSH) are never exposed to the internet, but authorized administrators can still access the VM when needed. Which combination provides the BEST security?

- A) NSG allowing RDP/SSH from corporate IP range + Azure Bastion
- B) Azure Bastion + Just-in-Time VM Access
- C) Public IP on VM + Azure Firewall DNAT rules
- D) VPN Gateway point-to-site + NSG allowing VPN subnet

<details>
<summary>✅ Answer & Explanation</summary>

**Answer: B**

**Azure Bastion** eliminates the need for a public IP on the VM and provides browser-based RDP/SSH over HTTPS. **JIT VM Access** locks down the VM's network-level ports by default and only opens them temporarily when authorized. Together, they provide defense-in-depth: no public IP, no exposed ports, time-limited access. Option A still exposes ports to a corporate IP range. Option C uses DNAT but still exposes a public IP. Option D requires VPN client software.

</details>

---

*Back to: [README — Project Overview](../README.md)*
