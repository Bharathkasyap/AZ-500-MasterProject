# AZ-500 Practice Exam — 60 Questions

← [Back to README](../README.md)

> **Instructions:** Answer all questions before checking the answers. Aim for 80%+ (48/60) to be exam-ready. The real exam passing score is 700/1000.

---

## Domain 1: Manage Identity and Access (Questions 1–18)

**Q1.** Your company uses Microsoft Entra ID. You need to ensure that all users who are members of the Finance department group must use MFA when accessing the Azure portal, but not when accessing other applications. What is the BEST solution?

- A) Enable per-user MFA for all Finance department members
- B) Create a Conditional Access policy targeting the Azure portal application with Finance group members in scope, requiring MFA as the grant control
- C) Enable Security Defaults and configure exceptions for non-portal apps
- D) Configure Identity Protection sign-in risk policy for Finance group members

<details><summary>Answer & Explanation</summary>

**Answer: B**

A Conditional Access policy can target a specific **Cloud App** (Azure Management) and scope it to a specific user group. Grant control: Require MFA. This gives precise control without affecting other applications.

- A: Per-user MFA applies to all apps, not just the Azure portal.
- C: Security Defaults enables MFA globally for all apps and cannot be scoped to specific apps.
- D: Identity Protection triggers on risk levels, not on specific applications.
</details>

---

**Q2.** An administrator needs to temporarily elevate their permissions to perform a sensitive operation in a production subscription. The organization has PIM configured. Which PIM assignment type allows the admin to activate a role only when needed?

- A) Active permanent assignment
- B) Active time-bound assignment
- C) Eligible assignment
- D) Guest assignment

<details><summary>Answer & Explanation</summary>

**Answer: C**

An **eligible assignment** means the user is eligible to activate the role but does not have it active by default. They must activate it (providing justification, MFA, approval if required) before performing the privileged operation. After the duration expires, the role is deactivated automatically.

- A & B: Active assignments mean the role is already granted (permanently or with an end date) — no activation needed.
- D: Not a PIM term.
</details>

---

**Q3.** A user in your Entra ID tenant shows a user risk level of "High" in Microsoft Entra Identity Protection. The user risk policy is set to require a password change for High risk users. The user attempts to sign in but cannot complete the password change. Which of the following is the MOST likely cause?

- A) The user's MFA method is not configured
- B) The user risk policy is in report-only mode
- C) The user has not registered for SSPR
- D) The user is a guest account

<details><summary>Answer & Explanation</summary>

**Answer: C**

When Identity Protection requires a password change due to high user risk, the user is directed to the Self-Service Password Reset (SSPR) registration/reset flow. If the user hasn't registered for SSPR, they cannot complete the self-service password reset. An administrator must manually reset the password.

- A: MFA configuration affects MFA prompts, not password change.
- B: Report-only mode logs but does not enforce — in report-only, the user would sign in successfully.
- D: Guest accounts have separate considerations but the question specifies user risk policy applies.
</details>

---

**Q4.** You are assigning Azure RBAC roles. A user needs to be able to view all Azure resources in a subscription and their configurations but must NOT be able to make any changes. Which built-in role should you assign?

- A) Contributor
- B) Reader
- C) Security Reader
- D) Monitoring Reader

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Reader** allows viewing all Azure resources across all resource types but grants no write permissions. Security Reader (C) is limited to security-related views. Monitoring Reader (D) is limited to monitoring data. Contributor (A) allows resource creation and modification.
</details>

---

**Q5.** Your organization wants to allow contractors from Fabrikam (a partner company using Entra ID) to access your Azure DevOps projects. These contractors should use their Fabrikam credentials. Which Microsoft Entra feature should you use?

- A) Microsoft Entra B2C
- B) Microsoft Entra B2B (External Identities — collaboration)
- C) Create new Entra ID accounts for each contractor
- D) Federation with Fabrikam using ADFS

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Microsoft Entra B2B** allows external users (from partner organizations with their own Entra ID or other IdPs) to be invited as guest users to your tenant. They authenticate using their home organization's credentials. B2C (A) is for customer-facing consumer scenarios. Creating new accounts (C) is inefficient and doesn't use their existing credentials.
</details>

---

**Q6.** You are configuring a Conditional Access policy. The policy should require MFA for all users accessing any application EXCEPT when they are accessing from IP addresses in the 203.0.113.0/24 range (your corporate network). How should you configure the Location condition?

- A) Include: 203.0.113.0/24; Exclude: All trusted locations
- B) Include: All locations; Exclude: Named Location containing 203.0.113.0/24
- C) Include: Named Location 203.0.113.0/24; Exclude: All locations
- D) Include: All locations; no exclusion needed

<details><summary>Answer & Explanation</summary>

**Answer: B**

To require MFA from everywhere EXCEPT your corporate IPs: **Include All locations**, **Exclude** the Named Location (your corporate IPs). This means the policy applies to all sign-ins except those from the excluded IP range. Option A is backwards. Option C would only require MFA from corporate IPs.
</details>

---

**Q7.** An application running on an Azure App Service needs to access Azure SQL Database without storing database credentials in the application code. What is the RECOMMENDED approach?

- A) Store the connection string in Azure App Configuration with a read-only access key
- B) Enable a system-assigned managed identity on the App Service and configure the SQL Database to allow the managed identity with appropriate database permissions
- C) Create a service principal and store the client ID and secret in app settings
- D) Use a shared access signature for SQL Database authentication

<details><summary>Answer & Explanation</summary>

**Answer: B**

System-assigned **managed identity** on App Service eliminates stored credentials. Configure the SQL Database to use Entra ID authentication and grant the managed identity access. The app requests a token from IMDS at runtime — no credentials stored anywhere.

- A & C: Still require storing credentials somewhere.
- D: SAS tokens are for Azure Storage, not SQL Database.
</details>

---

**Q8.** Which Microsoft Entra ID license is required to use Privileged Identity Management (PIM)?

- A) Free
- B) P1
- C) P2
- D) Microsoft 365 E3

<details><summary>Answer & Explanation</summary>

**Answer: C**

**PIM requires Entra ID P2**. P1 includes Conditional Access. The Free tier includes basic features only. Microsoft 365 E3 includes P1 but not P2.
</details>

---

**Q9.** A developer registered an application in Entra ID that needs to read all users in the tenant without a signed-in user (background service). Which permission type and consent level are required?

- A) Delegated permission; user consent
- B) Delegated permission; admin consent
- C) Application permission; user consent
- D) Application permission; admin consent

<details><summary>Answer & Explanation</summary>

**Answer: D**

**Application permissions** are used when an application acts as itself (no user context — background service). The `User.Read.All` application permission allows reading all users. **Admin consent** is always required for application permissions (cannot be granted by individual users).
</details>

---

**Q10.** You want to prevent users from registering "Passw0rd" and other commonly used passwords in your Azure tenant. Which feature enables this?

- A) Microsoft Entra Password Protection
- B) SSPR password complexity policy
- C) Conditional Access password change policy
- D) Identity Protection user risk policy

<details><summary>Answer & Explanation</summary>

**Answer: A**

**Microsoft Entra Password Protection** (Azure AD Password Protection) maintains a global banned password list and allows custom banned passwords. It prevents registration of weak/common passwords. It can also be deployed to on-premises Active Directory.
</details>

---

**Q11.** In Azure RBAC, a user has been assigned the **Owner** role on Resource Group A and the **Reader** role on the subscription. What access does this user have on Resource Group A?

- A) Reader (subscription role takes precedence)
- B) Owner (the more permissive role is applied)
- C) The roles conflict and access is denied
- D) Owner for resources within RG A; Reader for resources outside RG A

<details><summary>Answer & Explanation</summary>

**Answer: D**

Azure RBAC is **additive**. The user has Owner on Resource Group A (all resources in that RG) AND Reader on the subscription (all resources in the subscription). The effective permissions are the **union** of all role assignments. So within RG A they have Owner; outside RG A they have Reader.
</details>

---

**Q12.** A Global Administrator accidentally disabled their own MFA method and is now locked out of the tenant. Which type of account should organizations maintain specifically for this scenario?

- A) A shared administrator account
- B) An emergency access account (break-glass account)
- C) A guest administrator account
- D) A federated identity administrator account

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Emergency access accounts** (break-glass accounts) are excluded from Conditional Access policies (including MFA requirements) and are used only in emergency scenarios when normal authentication methods are unavailable. They use strong passwords, are monitored, and are stored securely (e.g., passwords split between multiple people in separate physical locations).
</details>

---

**Q13.** You need to review which users have been assigned the Global Administrator role over the last 30 days and whether the assignment is still appropriate. Which Entra ID P2 feature automates this process?

- A) PIM role settings
- B) Access Reviews
- C) Identity Protection risky users report
- D) Conditional Access named locations

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Access Reviews** in Entra ID governance allow periodic reviews of role assignments (and group memberships) to certify whether assignments are still appropriate. Reviewers can approve, deny, or let the system auto-apply decisions.
</details>

---

**Q14.** Which of the following authentication methods is considered MOST resistant to phishing attacks?

- A) SMS-based OTP
- B) Email OTP
- C) FIDO2 security keys
- D) OATH software tokens (Authenticator app TOTP)

<details><summary>Answer & Explanation</summary>

**Answer: C**

**FIDO2 security keys** are cryptographically bound to the specific origin (website/domain). Even if a user is tricked into visiting a phishing site, the FIDO2 key will not respond to authentication requests from a different domain — it is phishing-resistant by design. SMS, email, and TOTP codes can all be intercepted or entered on phishing sites.
</details>

---

**Q15.** You have Security Defaults enabled in your Entra ID tenant. A junior admin wants to create a Conditional Access policy. What must you do first?

- A) Assign the admin a P2 license
- B) Disable Security Defaults
- C) Enable per-user MFA for the admin
- D) Create a PIM eligible assignment for the admin

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Security Defaults and Conditional Access policies are mutually exclusive**. To use Conditional Access policies, you must first disable Security Defaults. Security Defaults is the pre-configured, opinionated security baseline that is suitable for organizations not using Conditional Access.
</details>

---

**Q16.** An Azure application's service principal needs write access to Azure Blob Storage in a specific storage account only. Which role assignment provides the minimum required permissions?

- A) Contributor at subscription scope
- B) Storage Blob Data Contributor at the storage account scope
- C) Owner at the storage account scope
- D) Storage Account Contributor at the storage account scope

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Storage Blob Data Contributor** grants read, write, and delete permissions to blob data and is scoped to the specific storage account (principle of least privilege). Storage Account Contributor (D) manages the storage account itself (control plane) but does NOT grant access to blob data (data plane). Owner (C) is overly permissive. Contributor at subscription (A) is too broad.
</details>

---

**Q17.** What happens to a system-assigned managed identity when the Azure resource it is associated with is deleted?

- A) The managed identity remains active and can be reassigned to another resource
- B) The managed identity is automatically deleted along with the resource
- C) The managed identity is disabled but remains in Entra ID for 30 days
- D) The managed identity is transferred to the resource group

<details><summary>Answer & Explanation</summary>

**Answer: B**

**System-assigned managed identities** are tied to the lifecycle of the Azure resource. When the resource is deleted, the managed identity is automatically deleted from Entra ID. This is different from **user-assigned managed identities**, which exist independently and persist after resources using them are deleted.
</details>

---

**Q18.** Your company wants to enforce that all new virtual machines deployed in a subscription must have the "CostCenter" tag. Which Azure feature should you use?

- A) Conditional Access
- B) Azure RBAC
- C) Azure Policy with the `Deny` effect
- D) PIM resource roles

<details><summary>Answer & Explanation</summary>

**Answer: C**

**Azure Policy** with the `Deny` effect can enforce that resources must have specific tags before they can be created. If the required tag is missing, the deployment is rejected. Conditional Access (A) manages sign-in conditions. RBAC (B) controls who can perform operations. PIM (D) manages privileged role access.
</details>

---

## Domain 2: Secure Networking (Questions 19–30)

**Q19.** An NSG has the following inbound rules:
- Priority 100: Allow TCP port 443 from Any
- Priority 200: Allow TCP port 80 from Any
- Priority 300: Deny Any from Any

An HTTP (port 80) request arrives at a VM protected by this NSG. What happens?

- A) The request is denied by priority 300
- B) The request is allowed by priority 200
- C) The request is denied because HTTPS is required
- D) The request is blocked until an admin resolves the conflict

<details><summary>Answer & Explanation</summary>

**Answer: B**

NSG rules are processed in **priority order** (lowest number = highest priority). Priority 200 (Allow TCP 80) is reached before priority 300 (Deny Any). The request is allowed. Rules are evaluated until a match is found — once matched, processing stops.
</details>

---

**Q20.** Azure Firewall is deployed in a hub VNet. You want all internet-bound traffic from spoke VNets to route through Azure Firewall. What Azure networking feature enables this?

- A) VNet peering with hub bypass
- B) User Defined Routes (UDR) with a route to Azure Firewall as Next Hop
- C) NSG service tags on spoke subnets
- D) Azure Bastion in the hub VNet

<details><summary>Answer & Explanation</summary>

**Answer: B**

**User Defined Routes (UDR)** override default Azure routing. Create a route table with a 0.0.0.0/0 route pointing to the Azure Firewall private IP as Next Hop (type: Virtual Appliance). Associate this route table with spoke subnets to force all internet-bound traffic through the firewall.
</details>

---

**Q21.** Your web application is experiencing a Layer 7 DDoS attack where attackers are sending malformed HTTP requests. Azure DDoS Protection Standard is enabled. Will it mitigate this attack?

- A) Yes, DDoS Protection Standard handles all DDoS attack types including Layer 7
- B) No, DDoS Protection Standard only protects against Layer 3 and Layer 4 attacks; WAF is needed for Layer 7
- C) Yes, but only if combined with Azure Firewall Premium with IDPS
- D) No, DDoS Protection does not protect Azure PaaS services

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Azure DDoS Protection** (both Basic and Standard) protects against **Layer 3 and Layer 4** (volumetric and protocol) attacks. For **Layer 7** (application layer) attacks such as HTTP floods and malformed requests, you need a **Web Application Firewall (WAF)** — either Application Gateway WAF or Azure Front Door WAF.
</details>

---

**Q22.** You need to ensure that an Azure Storage account can only be accessed from resources within a specific virtual network. The solution must provide the strongest isolation and prevent any access from the public internet. Which approach provides this?

- A) Configure VNet service endpoints on the subnet and restrict the storage account to that subnet
- B) Create a private endpoint for the storage account in the VNet and disable public network access on the storage account
- C) Add the VNet address space to the storage account firewall allow list
- D) Deploy an NSG to the storage account with deny rules for internet traffic

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Private Endpoints** + **disabling public network access** provides the strongest isolation. All traffic routes through the private IP within the VNet. Service Endpoints (A) also route via backbone but the storage account still has a public endpoint and service endpoints alone don't disable public access completely without additional configuration.
</details>

---

**Q23.** A VM does not have a public IP address and NSG rules block all inbound traffic from the internet. A security administrator needs to connect via RDP occasionally. What is the SIMPLEST solution that doesn't require changes to NSG rules?

- A) Add a public IP to the VM and open port 3389 in the NSG
- B) Deploy Azure Bastion in the same VNet
- C) Configure a site-to-site VPN to the VM's VNet
- D) Enable JIT VM access in Defender for Cloud

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Azure Bastion** provides browser-based RDP/SSH access to VMs without requiring a public IP or internet-exposed management ports. The Bastion service connects to VMs via their private IP within the VNet. No NSG rule changes for internet traffic are needed — only the Bastion subnet requires specific rules.
</details>

---

**Q24.** Azure Firewall processes three types of rule collections. What is the correct processing order?

- A) Application rules → Network rules → DNAT rules
- B) DNAT rules → Network rules → Application rules
- C) Network rules → DNAT rules → Application rules
- D) Application rules → DNAT rules → Network rules

<details><summary>Answer & Explanation</summary>

**Answer: B**

Azure Firewall processes rule collections in this order:
1. **DNAT rules** (inbound traffic destination translation)
2. **Network rules** (IP/port-based filtering)
3. **Application rules** (FQDN-based outbound HTTP/HTTPS filtering)

Within each type, rules are processed by priority (lowest number first). If traffic matches a DNAT or Network rule, Application rules are not evaluated for that traffic.
</details>

---

**Q25.** Which tool in Azure Network Watcher allows you to test whether an NSG rule permits or blocks traffic between two specific endpoints?

- A) Connection Monitor
- B) Next Hop
- C) IP Flow Verify
- D) Packet Capture

<details><summary>Answer & Explanation</summary>

**Answer: C**

**IP Flow Verify** tests whether a packet with specific source/destination IP, port, and protocol is allowed or denied by NSG rules on a specific VM. It identifies which NSG rule is allowing or blocking the traffic. Connection Monitor (A) continuously tests connectivity. Next Hop (B) identifies routing. Packet Capture (D) captures actual network packets.
</details>

---

**Q26.** Your organization's ExpressRoute connection is used to transfer sensitive financial data between on-premises and Azure. A compliance officer states that all data in transit must be encrypted. What is the recommended solution if you cannot use ExpressRoute Direct?

- A) ExpressRoute is automatically encrypted; no action needed
- B) Deploy Azure Firewall with TLS inspection on the ExpressRoute circuit
- C) Configure IPsec/IKE VPN tunnels over the ExpressRoute private peering using Azure VPN Gateway
- D) Use Azure Application Gateway with SSL termination on the ExpressRoute connection

<details><summary>Answer & Explanation</summary>

**Answer: C**

ExpressRoute does NOT encrypt traffic by default. For encryption without ExpressRoute Direct (which supports MACsec): configure **IPsec VPN over ExpressRoute private peering** using a VPN Gateway. This adds Layer 3 encryption over the dedicated circuit.
</details>

---

**Q27.** You want to restrict outbound internet traffic from Azure VMs to only allow access to specific FQDNs like `update.microsoft.com`. Which Azure service supports FQDN-based filtering for outbound traffic?

- A) Network Security Group (NSG)
- B) Azure DDoS Protection
- C) Azure Firewall
- D) Azure Application Gateway

<details><summary>Answer & Explanation</summary>

**Answer: C**

**Azure Firewall** supports **Application rules** that filter outbound traffic based on FQDNs. NSGs (A) only support IP addresses and port ranges — not FQDNs. DDoS (B) is for inbound attack protection. Application Gateway (D) is for inbound HTTP/HTTPS routing and WAF.
</details>

---

**Q28.** An organization uses Azure Front Door for global traffic management. They need to block traffic from specific countries and limit the request rate from individual IPs to prevent abuse. Which Azure Front Door feature provides this?

- A) Origin policies and health probes
- B) Azure Front Door WAF policy with custom rules
- C) Azure DDoS Protection Standard
- D) TLS minimum version enforcement

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Azure Front Door WAF policy** supports **custom rules** for geo-filtering (block specific countries) and **rate limiting** (throttle requests per IP). These are applied at the Azure network edge before traffic reaches your origin. DDoS (C) protects against volumetric attacks but not country/rate-based blocking.
</details>

---

**Q29.** Azure Bastion requires a dedicated subnet. What must this subnet be named?

- A) `bastion-subnet`
- B) `AzureFirewallSubnet`
- C) `AzureBastionSubnet`
- D) `GatewaySubnet`

<details><summary>Answer & Explanation</summary>

**Answer: C**

Azure Bastion requires a subnet named exactly **`AzureBastionSubnet`** with a minimum size of /26. The subnet cannot be used for any other resources. AzureFirewallSubnet (B) is for Azure Firewall. GatewaySubnet (D) is for VPN/ExpressRoute Gateway.
</details>

---

**Q30.** NSG Flow Logs are enabled on a subnet. A security analyst wants to visualize traffic patterns, identify top talkers, and see a map of traffic flows. Which Azure feature provides this visualization?

- A) Azure Monitor Workbooks
- B) Network Watcher Traffic Analytics
- C) Microsoft Sentinel UEBA
- D) Defender for Cloud network map

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Network Watcher Traffic Analytics** processes NSG Flow Logs (via Log Analytics) and provides a visual dashboard with traffic maps, top talkers, geo distribution of traffic, and anomaly detection. It requires a Log Analytics workspace and a storage account for flow logs.
</details>

---

## Domain 3: Secure Compute, Storage, and Databases (Questions 31–44)

**Q31.** You need to encrypt the OS disk of a Windows VM in Azure and store the encryption key in Azure Key Vault. Which Azure feature should you use?

- A) Azure Storage Service Encryption (SSE) with CMK
- B) Azure Disk Encryption (ADE) with Azure Key Vault
- C) BitLocker with a local key store
- D) Managed disk encryption with infrastructure encryption

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Azure Disk Encryption (ADE)** uses BitLocker (Windows) or DM-Crypt (Linux) to encrypt VM OS and data disks. Keys and secrets are stored in **Azure Key Vault**. SSE (A) encrypts at the storage platform level — ADE adds in-VM encryption. ADE provides an additional layer beyond SSE.
</details>

---

**Q32.** A Key Vault has soft-delete enabled (90-day retention) but purge protection is NOT enabled. An administrator accidentally deletes a critical encryption key. They also run the purge command immediately. Can the key be recovered?

- A) Yes, soft-delete always prevents permanent deletion for 90 days
- B) No, the purge command permanently deleted the key despite soft-delete
- C) Yes, Microsoft maintains a backup and can restore it
- D) No, but a new key can be generated from the same key material

<details><summary>Answer & Explanation</summary>

**Answer: B**

Without **purge protection**, anyone with the appropriate permissions can permanently purge a soft-deleted object immediately. Purge protection prevents this by enforcing that soft-deleted objects cannot be purged until the retention period expires. This is why purge protection is strongly recommended for production Key Vaults.
</details>

---

**Q33.** Which Azure Key Vault permission model is RECOMMENDED for new deployments and allows integration with Azure RBAC?

- A) Vault access policies
- B) Azure RBAC authorization model
- C) Managed identity access
- D) Service endpoint access control

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Azure RBAC** is the recommended permission model for Key Vault. It uses standard Azure role assignments (integrated with Entra ID), supports fine-grained roles (e.g., Key Vault Secrets User vs. Secrets Officer), and provides a single pane of glass for all Azure access management. Vault access policies (A) are the legacy model with limitations.
</details>

---

**Q34.** A storage account is configured with Shared Key authorization disabled. A legacy application that uses storage account keys is attempting to connect but failing. What is the MINIMUM permission change to fix this while maintaining security?

- A) Re-enable Shared Key authorization on the storage account
- B) Assign the application's service principal the Storage Account Contributor role
- C) Assign the application's managed identity the Storage Blob Data Contributor role and use Entra ID authentication
- D) Generate a new SAS token using the storage account key

<details><summary>Answer & Explanation</summary>

**Answer: C**

The best approach when moving away from Shared Key: migrate the application to use a **managed identity** with appropriate **data plane RBAC role** (Storage Blob Data Contributor or similar). This avoids re-enabling shared keys (A) or using SAS tokens derived from shared keys (D). Option B grants control plane access, not data access.
</details>

---

**Q35.** An Azure SQL Database has Transparent Data Encryption (TDE) enabled with a service-managed key. Your compliance team now requires that your organization manage the TDE encryption key and be able to revoke access to encrypted data immediately if needed. What should you implement?

- A) Enable Always Encrypted on sensitive columns
- B) Configure TDE with Customer-Managed Key (BYOK) stored in Azure Key Vault
- C) Enable Dynamic Data Masking on all columns
- D) Migrate to Azure SQL Managed Instance

<details><summary>Answer & Explanation</summary>

**Answer: B**

**TDE with Customer-Managed Key (BYOK)** allows you to store the TDE protector in your own Azure Key Vault. You can revoke access to the data by disabling or deleting the key in Key Vault — this renders the database inaccessible. Service-managed TDE (default) doesn't allow this level of control.
</details>

---

**Q36.** A DBA needs to read customer email addresses stored in an Azure SQL column for reporting purposes. However, compliance requires that junior analysts querying the same table see masked values (e.g., `aXX@XXXX.com`). The actual data must NOT be changed in the database. Which feature should you configure?

- A) Always Encrypted
- B) Row-Level Security
- C) Dynamic Data Masking
- D) Column-level permissions with DENY

<details><summary>Answer & Explanation</summary>

**Answer: C**

**Dynamic Data Masking (DDM)** masks column values in query results for non-privileged users. The actual data in the database remains unchanged. Privileged users (DBAs with UNMASK permission) can still see the real values. Always Encrypted (A) encrypts data so even DBAs can't read it in plaintext.
</details>

---

**Q37.** Which SAS token type uses Entra ID credentials for signing (rather than the storage account key) and is considered more secure?

- A) Account SAS
- B) Service SAS
- C) User Delegation SAS
- D) Storage Shared Key

<details><summary>Answer & Explanation</summary>

**Answer: C**

**User Delegation SAS** is signed using Entra ID credentials (OAuth 2.0 token) rather than the storage account key. This means: (1) the storage account key is not exposed, (2) the SAS can be audited in Entra ID sign-in logs, and (3) it can only be used for Blob and Data Lake Storage Gen2.
</details>

---

**Q38.** Microsoft Defender for Cloud shows that several Azure VMs have the recommendation "Management ports should be closed on your virtual machines." What is the recommended remediation?

- A) Enable Azure Bastion for all VMs
- B) Enable Just-In-Time VM access for the affected VMs
- C) Deny all inbound traffic using NSG rules
- D) Install the Azure Monitor Agent on VMs

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Just-In-Time (JIT) VM access** in Defender for Cloud addresses this recommendation by blocking management ports (3389, 22) by default and only opening them temporarily when explicitly requested. This reduces the attack surface without permanently closing ports needed for management.
</details>

---

**Q39.** A container image in Azure Container Registry has been found to contain a critical vulnerability. Images are deployed to AKS. What is the FIRST action to take?

- A) Delete the AKS cluster and redeploy from a new image
- B) Patch the vulnerability in the source code, rebuild the image, push to ACR, and redeploy affected pods
- C) Enable network policies on AKS to isolate the affected pods
- D) Rotate all ACR admin credentials

<details><summary>Answer & Explanation</summary>

**Answer: B**

The correct remediation for a container image vulnerability: fix the vulnerability in the source (patch library/OS package), rebuild the image, push the patched image to ACR, then redeploy the affected pods using the new image. Network policies (C) can be used as temporary mitigation but don't fix the vulnerability. Deleting the cluster (A) is disruptive and unnecessary.
</details>

---

**Q40.** An Azure Function App stores a database connection string in Azure Key Vault. The Function App has a system-assigned managed identity. In Key Vault, the vault uses Azure RBAC. What role must the managed identity be assigned to read the secret value?

- A) Key Vault Administrator
- B) Key Vault Reader
- C) Key Vault Secrets User
- D) Key Vault Secrets Officer

<details><summary>Answer & Explanation</summary>

**Answer: C**

**Key Vault Secrets User** allows reading (getting) secret values. Key Vault Reader (B) can only view vault metadata (not secret values). Key Vault Secrets Officer (D) can manage secrets (create, update, delete) — overly permissive. Key Vault Administrator (A) has full access — far too permissive for a Function App.
</details>

---

**Q41.** What encryption method does Azure Disk Encryption use for Linux VMs?

- A) BitLocker
- B) VeraCrypt
- C) DM-Crypt
- D) LUKS with no key management

<details><summary>Answer & Explanation</summary>

**Answer: C**

Azure Disk Encryption uses **BitLocker** for Windows VMs and **DM-Crypt** for Linux VMs. Keys are stored in Azure Key Vault.
</details>

---

**Q42.** An Azure Storage account receives a Defender for Storage alert: "Unusual amount of data extracted." A 500 GB download was detected from an IP address in an unusual country. What is the IMMEDIATE containment action?

- A) Delete the storage account
- B) Rotate the storage account keys and revoke any SAS tokens that may have been compromised
- C) Enable soft delete on all containers
- D) Change the storage account replication type to LRS

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Rotating storage account keys** invalidates all connections and SAS tokens that were based on the old keys, effectively cutting off any attacker who had obtained credentials. Then investigate how the credentials were obtained. Deleting the storage account (A) is drastic and may destroy evidence. Soft delete (C) and replication changes (D) don't address the immediate compromise.
</details>

---

**Q43.** You need to ensure compliance requires all Blob storage in your organization is encrypted with customer-managed keys. Some existing storage accounts use Microsoft-managed keys. What is the MOST efficient way to identify and remediate non-compliant storage accounts?

- A) Manually check each storage account in the Azure portal
- B) Assign a built-in Azure Policy definition that audits storage accounts for CMK usage and create a remediation task
- C) Write a PowerShell script to check each storage account and update encryption settings
- D) Use Microsoft Defender for Storage alerts to identify non-compliant accounts

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Azure Policy** provides the most efficient, scalable approach. The built-in policy "Storage accounts should use customer-managed key for encryption" can be assigned at subscription or management group scope. Compliance reports show all non-compliant accounts. For remediation, since this requires key configuration (not automatic), you'd use the compliance report to guide remediation tasks.
</details>

---

**Q44.** Always Encrypted in Azure SQL uses two types of encryption. Which type should be used for columns that need to be searched with equality operators (e.g., `WHERE SSN = '123-45-6789'`)?

- A) Randomized encryption
- B) Deterministic encryption
- C) Transparent encryption
- D) Always-on encryption

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Deterministic encryption** always produces the same ciphertext for a given plaintext value. This allows the database to perform equality comparisons and index lookups on encrypted columns. **Randomized encryption** (A) produces different ciphertext each time — more secure but does not support searching or joining on the column. Transparent encryption (C) is TDE — full database encryption, not column-level.
</details>

---

## Domain 4: Manage Security Operations (Questions 45–60)

**Q45.** Microsoft Sentinel needs to ingest Azure Activity Log data. What is the MOST direct method to connect this data source?

- A) Deploy an Azure Monitor agent on all VMs
- B) Configure a Diagnostic Setting to send the Activity Log to the Log Analytics workspace backing Sentinel
- C) Enable Defender for Cloud and configure continuous export
- D) Create a custom REST API connector in Sentinel

<details><summary>Answer & Explanation</summary>

**Answer: B**

The **Azure Activity Log** can be connected to a Log Analytics workspace via a **Diagnostic Setting** (or via the native Azure Activity Log connector in Sentinel). This is the direct, built-in method. The Activity Log records subscription-level ARM operations.
</details>

---

**Q46.** A Sentinel analytics rule creates an incident every time a specific KQL query returns results. The SOC team is receiving dozens of false positive incidents from this rule daily. What should you use to suppress these known false positives WITHOUT modifying the detection logic?

- A) Delete the analytics rule
- B) Create an automation rule to close incidents matching the false positive pattern
- C) Increase the query frequency to reduce incident volume
- D) Switch the analytics rule to report-only mode

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Automation rules** in Sentinel can automatically close (or suppress) incidents that match specific conditions (e.g., specific alert name + entity values that are known false positives). This preserves the detection logic while reducing SOC noise. Automation rules run before playbooks and require no coding.
</details>

---

**Q47.** Which Azure Monitor component collects and stores structured log data from Azure resources, VMs, and applications, and is queried using KQL?

- A) Azure Metrics
- B) Log Analytics workspace
- C) Azure Application Insights (standalone)
- D) Azure Activity Log

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Log Analytics workspace** stores structured log data and is the primary data store for Azure Monitor Logs. It is queried using KQL. Microsoft Sentinel is built on Log Analytics. Azure Metrics (A) stores numerical time-series data, not logs. Activity Log (D) is a specific source, not the storage/query mechanism.
</details>

---

**Q48.** You need to automatically respond to a Microsoft Sentinel incident by blocking a malicious IP address in Azure Firewall. Which Sentinel component provides this automated response capability?

- A) Analytics rules
- B) Hunting queries
- C) Playbooks (Logic Apps)
- D) UEBA anomaly detection

<details><summary>Answer & Explanation</summary>

**Answer: C**

**Playbooks** (Azure Logic Apps) provide **SOAR (Security Orchestration, Automation, and Response)** capabilities. A playbook triggered by an incident can extract the malicious IP from the incident entities and call the Azure Firewall API to add a deny rule. Analytics rules (A) detect threats and create incidents. Hunting queries (B) are for proactive search.
</details>

---

**Q49.** What is the PRIMARY data store used by Microsoft Sentinel?

- A) Azure Cosmos DB
- B) Azure SQL Database
- C) Log Analytics workspace
- D) Azure Data Lake Storage

<details><summary>Answer & Explanation</summary>

**Answer: C**

Microsoft Sentinel is built on top of a **Log Analytics workspace**. All ingested data, incidents, analytics rule results, and hunting query results are stored in the Log Analytics workspace. This is why Sentinel uses KQL as its query language.
</details>

---

**Q50.** Azure Policy has the effect `DeployIfNotExists`. This effect requires what additional configuration on the policy assignment?

- A) A PAT token for deployment authorization
- B) A managed identity with appropriate deployment permissions
- C) An Entra ID service principal with Contributor rights
- D) An Azure DevOps pipeline for the deployment

<details><summary>Answer & Explanation</summary>

**Answer: B**

`DeployIfNotExists` (and `Modify`) effects require the policy assignment to have a **managed identity** with sufficient permissions to deploy/modify resources. Azure Policy uses this managed identity to create remediation tasks that deploy the required resources when non-compliant resources are found.
</details>

---

**Q51.** Your organization wants to track all administrative operations performed on Azure resources in the last 30 days, specifically to see who deleted a virtual network last week. Which Azure feature should you query?

- A) Azure Monitor Metrics
- B) Azure Activity Log
- C) VM Diagnostics logs
- D) NSG Flow Logs

<details><summary>Answer & Explanation</summary>

**Answer: B**

The **Azure Activity Log** records all **control plane** operations (ARM API calls) including resource deletions. It includes the operation name, caller identity, timestamp, and result. It retains data for 90 days by default. For "who deleted a VNet" — this is an ARM operation captured in the Activity Log.
</details>

---

**Q52.** A security analyst runs the following KQL query in Sentinel:

```kql
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != 0
| summarize FailedAttempts = count() by UserPrincipalName
| where FailedAttempts > 20
```

What is this query detecting?

- A) Successful sign-ins from unusual locations
- B) Users with more than 20 failed sign-in attempts in the last hour (potential brute-force)
- C) Users with multiple MFA failures
- D) Sign-ins from risky IP addresses

<details><summary>Answer & Explanation</summary>

**Answer: B**

The query filters `SigninLogs` for **non-zero ResultType** (failures), counts failures per user over the last hour, and shows users with more than 20 failures — this is a **brute-force/password spray detection** pattern. ResultType 0 = success; non-zero = failure.
</details>

---

**Q53.** Which Microsoft Sentinel feature uses machine learning to establish behavioral baselines for users and entities, then generates anomaly scores when behavior deviates from the baseline?

- A) Fusion detection rules
- B) Scheduled analytics rules
- C) UEBA (User and Entity Behavior Analytics)
- D) NRT (Near Real-Time) rules

<details><summary>Answer & Explanation</summary>

**Answer: C**

**UEBA (User and Entity Behavior Analytics)** uses ML to establish normal behavior patterns for users, hosts, IPs, and applications. It generates anomaly scores and insights shown in entity pages and incidents. Fusion (A) correlates alerts from multiple sources for multi-stage attack detection. NRT (D) is for low-latency scheduled queries.
</details>

---

**Q54.** Your organization is required to maintain Azure resource logs for 2 years for compliance. The default Azure Monitor log retention is 30 days (free tier). What is the MOST cost-effective approach to retain security logs for 2 years?

- A) Set the Log Analytics workspace retention to 730 days (2 years) for all tables
- B) Configure Diagnostic Settings to archive logs to Azure Storage with a lifecycle policy for 2-year retention at archive tier
- C) Purchase a Log Analytics commitment tier
- D) Export logs to a third-party SIEM

<details><summary>Answer & Explanation</summary>

**Answer: B**

Archiving logs to **Azure Storage** (cool or archive tier) is significantly cheaper than retaining in Log Analytics for 2 years. Set up **Diagnostic Settings** to export to a storage account, then use **Azure Storage lifecycle management policies** to move blobs to archive tier after 30–90 days. This retains all logs for 2 years at minimal cost.
</details>

---

**Q55.** A security engineer needs to investigate a potential insider threat. They want to see all file access events, sign-in activities, and email forwarding rules created by a specific user over the last 30 days, correlated in a single view. Which Sentinel feature provides an entity-centric investigation view?

- A) KQL hunting query in the Logs blade
- B) Sentinel Workbooks with pre-built dashboards
- C) Investigation Graph showing the entity's timeline
- D) Fusion analytics rule details page

<details><summary>Answer & Explanation</summary>

**Answer: C**

The **Investigation Graph** in Sentinel provides an entity-centric, visual, interactive timeline of all activities and alerts related to a specific entity (user, IP, host). It shows entity relationships and correlated events over time — ideal for insider threat investigation.
</details>

---

**Q56.** A new junior analyst joins the SOC team and needs to view Microsoft Sentinel incidents and run hunting queries but should NOT be able to create or modify analytics rules, playbooks, or automation rules. Which built-in Sentinel role should you assign?

- A) Microsoft Sentinel Contributor
- B) Microsoft Sentinel Reader
- C) Microsoft Sentinel Responder
- D) Log Analytics Reader

<details><summary>Answer & Explanation</summary>

**Answer: C**

**Microsoft Sentinel Responder** can view incidents, investigate, and update incident status/assignments. It cannot create or modify analytics rules. **Reader** (B) can only view — cannot take actions on incidents. **Contributor** (A) can create/modify analytics rules and playbooks. The question requires more than read-only but less than full contributor.

*Note: For running hunting queries, Responder role is sufficient. If the role didn't allow hunting, Contributor would be needed.*
</details>

---

**Q57.** Your organization requires that no Azure resources in the production subscription can be deleted without approval from the security team. Which Azure feature prevents resource deletion?

- A) Azure Policy with `Deny` effect for delete operations
- B) Azure Resource Locks (Delete lock / CanNotDelete)
- C) RBAC — remove Delete permission from all users
- D) Azure Blueprints with ReadOnly lock

<details><summary>Answer & Explanation</summary>

**Answer: B**

**Azure Resource Locks** with `CanNotDelete` type prevent deletion of locked resources regardless of RBAC permissions (even Owners cannot delete without removing the lock first). This is a simple, effective control. Azure Policy (A) can restrict who can delete, but resource locks provide a more direct protection.
</details>

---

**Q58.** Defender for Cloud shows a high severity alert: "Suspicious PowerShell Activity Detected" on a production VM. The alert indicates a Base64-encoded command was executed. What is the RECOMMENDED immediate response action?

- A) Reboot the VM to clear the suspicious process
- B) Isolate the VM using Microsoft Defender for Endpoint network isolation, capture a memory dump, and investigate the encoded command
- C) Enable disk encryption on the VM
- D) Rotate all service principal credentials in the subscription

<details><summary>Answer & Explanation</summary>

**Answer: B**

The proper incident response for a suspicious process: **isolate** the VM to prevent lateral movement (without losing evidence), **capture forensic evidence** (memory/disk), then **investigate** the encoded command (Base64 decode and analyze). Rebooting (A) destroys volatile evidence. Disk encryption (C) is not an incident response action. Rotating SP creds (D) may be needed later but is not the first action.
</details>

---

**Q59.** An analytics rule in Sentinel generates 50 incidents per day for legitimate vulnerability scanner activity. The security team wants to suppress incidents from this scanner's IP address (192.168.1.100) without disabling the detection rule for other sources. What is the BEST approach?

- A) Add a filter to the analytics rule KQL to exclude the scanner IP
- B) Create an automation rule that closes incidents where the entity IP equals 192.168.1.100
- C) Delete the analytics rule and recreate it without scanner triggers
- D) Add the scanner IP to the Threat Intelligence watchlist

<details><summary>Answer & Explanation</summary>

**Answer: B**

An **automation rule** that automatically closes incidents from the known scanner IP is the cleanest approach — the rule still runs and logs the activity (for audit), but the SOC is not burdened with false positive incidents. Option A modifies the detection rule (may miss legitimate alerts from that IP if the scanner is compromised). Option D would incorrectly mark it as a threat.
</details>

---

**Q60.** Your organization must demonstrate compliance with the PCI DSS standard for Azure workloads. Which Microsoft Defender for Cloud feature displays a mapped compliance view showing which Azure resources pass or fail PCI DSS controls?

- A) Secure Score dashboard
- B) Regulatory Compliance dashboard
- C) Security Alerts timeline
- D) Defender plans coverage view

<details><summary>Answer & Explanation</summary>

**Answer: B**

The **Regulatory Compliance dashboard** in Defender for Cloud maps your Azure resource configurations to compliance standard controls (PCI DSS, NIST, ISO 27001, CIS, etc.) and shows passing/failing assessments per control. This provides auditors with evidence of compliance status.
</details>

---

## Score Yourself

| Domain | Questions | Your Score |
|--------|-----------|------------|
| Domain 1: Manage Identity and Access | Q1–Q18 (18 questions) | __ / 18 |
| Domain 2: Secure Networking | Q19–Q30 (12 questions) | __ / 12 |
| Domain 3: Secure Compute, Storage, and Databases | Q31–Q44 (14 questions) | __ / 14 |
| Domain 4: Manage Security Operations | Q45–Q60 (16 questions) | __ / 16 |
| **Total** | **60 questions** | **__ / 60** |

### Readiness Assessment

| Score | Assessment |
|-------|-----------|
| 48–60 (80%+) | Exam ready — schedule your exam! |
| 42–47 (70–79%) | Nearly ready — review weak domains |
| 36–41 (60–69%) | More study needed — focus on failed questions |
| Below 36 (<60%) | Significant gaps — review full study guides |

---

← [Back to README](../README.md)
