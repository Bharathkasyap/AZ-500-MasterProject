# AZ-500 Practice Exam — 60 Questions

> **Instructions**: Select the best answer for each question. Answers and explanations are provided after each section. Aim to complete 60 questions in 150 minutes (2.5 min/question).

---

## Section 1: Identity and Access (Questions 1–20)

---

**Question 1**

A company requires that Global Administrators in their Azure tenant must use MFA when activating their role. The administrators should have the role available on-demand rather than permanently assigned. Which feature should you implement?

A. Conditional Access with MFA requirement for Global Admins  
B. Privileged Identity Management (PIM) with MFA on activation  
C. Microsoft Entra ID Identity Protection with High user risk policy  
D. Security Defaults with per-user MFA  

---

**Question 2**

You need to ensure that users can only access a specific SaaS application from company-managed, compliant devices. The application supports modern authentication. What should you configure?

A. An NSG rule to block non-corporate IP addresses  
B. A Conditional Access policy requiring a compliant device  
C. An Azure AD B2C policy with device compliance check  
D. Per-user MFA for all users accessing the application  

---

**Question 3**

A developer needs to access secrets in Azure Key Vault from an Azure Virtual Machine without storing credentials in the application code. What is the most secure approach?

A. Store the service principal client secret in an environment variable on the VM  
B. Enable a system-assigned managed identity on the VM and grant it Key Vault Secrets User role  
C. Create a user-assigned managed identity and embed the client ID in the app config  
D. Generate a SAS token for Key Vault and store it in the application settings  

---

**Question 4**

Your organization uses Entra ID Conditional Access. A new policy requires MFA for all users. After enabling the policy, several service accounts used by automation scripts start failing. What should you do?

A. Exclude the service accounts from the Conditional Access policy  
B. Enable Security Defaults which supports legacy authentication  
C. Assign the service accounts to the Exempted Users group  
D. Use per-user MFA and exclude automation accounts  

---

**Question 5**

A user's account shows a High user risk in Microsoft Entra ID Identity Protection. The security team wants to automatically require the user to reset their password when this risk level is detected. What is the most appropriate configuration?

A. Create a Conditional Access policy targeting High user risk requiring a password change  
B. Configure a PIM access review that triggers on risk detection  
C. Enable Security Defaults and set the user risk threshold  
D. Create an alert rule in Azure Monitor for HighRisk users  

---

**Question 6**

An organization needs to grant an external partner company's users access to a specific SharePoint site. The partners should authenticate using their own organization's credentials. Which Entra ID feature should you use?

A. Azure AD B2C with social identity providers  
B. Azure AD B2B guest user invitation  
C. Create local accounts for each partner user  
D. Configure ADFS federation with the partner's domain  

---

**Question 7**

Which Azure RBAC role allows a user to manage all Azure resources but prevents them from assigning roles to other users?

A. Owner  
B. User Access Administrator  
C. Contributor  
D. Security Admin  

---

**Question 8**

A company wants to review all users with the Global Administrator role every 90 days and automatically remove access if the reviewer doesn't respond. Which feature should they configure?

A. PIM role activation with 90-day maximum duration  
B. Entra ID Access Reviews with auto-apply and no-response action set to Remove access  
C. Conditional Access policy with 90-day session lifetime  
D. Azure Policy audit effect for Global Admin role assignments  

---

**Question 9**

Security Defaults have been enabled in your Entra ID tenant. A security administrator wants to create a Conditional Access policy to allow users in a trusted location to skip MFA. What must the administrator do first?

A. Enable Entra ID P2 licensing  
B. Disable Security Defaults  
C. Create a named location for the trusted IP range  
D. Enable the Conditional Access policy in report-only mode  

---

**Question 10**

A user has been assigned the Contributor role at the subscription level and the Reader role at a specific resource group level. What is the user's effective access to resources in that resource group?

A. Reader only (most restrictive wins)  
B. Contributor (higher scope permissions apply)  
C. No access (conflicting roles cancel each other)  
D. Access is denied pending explicit Allow at the resource group level  

---

**Question 11**

An application needs to read secrets from Key Vault. You create a user-assigned managed identity. After assigning the Key Vault Secrets User role to the identity, the app still cannot read secrets. What is the most likely cause?

A. The Key Vault uses vault access policy model instead of RBAC  
B. User-assigned identities cannot access Key Vault  
C. The managed identity needs the Key Vault Secrets Officer role  
D. The application needs to be redeployed after identity assignment  

---

**Question 12**

A company requires that users who haven't signed in for more than 30 days should automatically lose access during the next Access Review cycle. Which Access Review setting accomplishes this?

A. Set reviewer response to "Deny" for all users  
B. Enable machine learning-based recommendations and set no-response action to "Take recommendations"  
C. Configure a Conditional Access policy blocking inactive users  
D. Set PIM eligible assignments to expire after 30 days  

---

**Question 13**

You are configuring PIM for the Security Administrator role. You want to require approval before any user can activate this role, and activation should only last a maximum of 4 hours. Where do you configure these settings?

A. In the Conditional Access policy for the Security Administrator role  
B. In PIM → Azure AD Roles → Security Administrator → Settings  
C. In the user's profile under Authentication methods  
D. In Defender for Cloud → Role-based access control settings  

---

**Question 14**

A B2B guest user reports they cannot access an application protected by a Conditional Access policy requiring a compliant device. The guest's home organization uses Intune. What should the admin configure to allow the guest to access the app with their compliant device?

A. Exclude guest users from the Conditional Access policy  
B. Configure cross-tenant access settings to trust compliant device claims from the partner tenant  
C. Require the guest user to enroll their device in your organization's Intune  
D. Enable the "Trust all claims from guest users" setting in Security Center  

---

**Question 15**

Which Entra ID Premium tier (P1 or P2) is required MINIMUM for each of the following features?

| Feature | P1 | P2 |
|---------|----|----|
| Conditional Access | ✓ | |
| PIM | | ✓ |
| Identity Protection | | ✓ |
| Access Reviews | | ✓ |
| SSPR (Self-Service Password Reset) | ✓ | |

Which feature requires only Entra ID P1?

A. Privileged Identity Management  
B. Identity Protection  
C. Conditional Access  
D. Access Reviews  

---

**Question 16**

A company has a service principal used by an automation pipeline. The service principal's client secret is expiring. You need to rotate the secret with minimal disruption. What is the correct order of steps?

A. Delete the old secret → Create new secret → Update pipeline → Test pipeline  
B. Create new secret → Update pipeline → Test pipeline → Delete old secret  
C. Revoke all secrets → Create new secret → Update pipeline  
D. Update pipeline → Create new secret → Delete old secret  

---

**Question 17**

An organization wants to prevent users from registering applications in Entra ID unless they have been explicitly granted the Application Developer role. Which setting should be configured?

A. Set "Users can register applications" to "No" in Entra ID User Settings  
B. Create a Conditional Access policy blocking app registration  
C. Enable the AppRegistration audit policy in Defender for Cloud  
D. Configure an Azure Policy to deny application registrations  

---

**Question 18**

After configuring PIM for the Owner role on a subscription, you notice that a user can still permanently activate the Owner role without going through the PIM workflow. What is the most likely cause?

A. PIM only works for Entra ID roles, not Azure resource roles  
B. The user has a direct (permanent) role assignment outside of PIM  
C. The subscription is not linked to the Entra ID tenant with P2 licensing  
D. PIM must be enabled separately for each resource group  

---

**Question 19**

You need to assign a role that allows an identity to perform cryptographic operations (sign, verify, encrypt, decrypt) with keys in Key Vault, but NOT manage the keys themselves. Which role should you assign?

A. Key Vault Administrator  
B. Key Vault Crypto Officer  
C. Key Vault Crypto User  
D. Key Vault Secrets User  

---

**Question 20**

A company suspects a user account has been compromised. You need to immediately prevent the account from accessing any resources while preserving the investigation trail. What actions should you take? (Select TWO)

A. Delete the user account from Entra ID  
B. Disable the user account in Entra ID  
C. Revoke all active sessions for the user  
D. Reset the user's MFA methods  
E. Remove all role assignments from the user  

---

## Section 2: Secure Networking (Questions 21–35)

---

**Question 21**

An NSG has the following inbound rules:

| Priority | Source | Destination | Port | Protocol | Action |
|----------|--------|-------------|------|----------|--------|
| 100 | 10.0.0.0/24 | 10.1.0.0/24 | 443 | TCP | Allow |
| 200 | Internet | 10.1.0.0/24 | 443 | TCP | Allow |
| 300 | Any | Any | Any | Any | Deny |

A request comes in from IP 203.0.113.10 on port 443. What happens?

A. The request is denied (no explicit Allow for public IPs)  
B. The request is allowed by rule priority 200  
C. The request is denied because the default deny rule applies first  
D. The request is allowed because port 443 is in the allow list  

---

**Question 22**

You need to enable RDP access to a virtual machine for maintenance. The VM has no public IP address. You want the access to be time-limited and restricted to the administrator's IP address. What is the best solution?

A. Add a public IP to the VM and open port 3389 in the NSG  
B. Use Azure Bastion Standard tier for RDP without a public IP  
C. Use Microsoft Defender for Cloud JIT VM Access  
D. Create an SSL VPN connection using Point-to-Site VPN  

---

**Question 23**

Azure Bastion must be deployed into a specific subnet. What are the EXACT requirements? (Select TWO)

A. The subnet must be named "AzureFirewallSubnet"  
B. The subnet must be named "AzureBastionSubnet"  
C. The minimum subnet size is /28  
D. The minimum subnet size for Standard SKU is /26  
E. Bastion requires a Standard SKU public IP  

---

**Question 24**

A company wants to ensure that their Azure SQL Database is only accessible from their Azure Virtual Network and not from the public internet. They require private DNS resolution. What should they implement?

A. Configure a VNet Service Endpoint on the subnet and create a firewall rule in SQL  
B. Create a Private Endpoint for Azure SQL and configure a private DNS zone  
C. Disable public access in SQL and add the VNet to the firewall allow list  
D. Use SQL VNet rules with a service endpoint and disable public access  

---

**Question 25**

Your organization is deploying Azure Firewall. All internet-bound traffic from spoke VNets must be inspected by the firewall. What configuration is required to route traffic through the firewall?

A. Configure NSG rules to redirect internet traffic to the firewall IP  
B. Create User Defined Routes (UDRs) in spoke VNets with next hop set to the firewall private IP  
C. Enable firewall interception mode in the Azure portal  
D. Configure the VNet Gateway to forward traffic to the firewall  

---

**Question 26**

An application deployed in an Azure VNet needs to call an Azure Storage account. The security requirement states that traffic must NOT traverse the public internet. Which two options satisfy this requirement? (Select TWO)

A. Enable a Storage Service Endpoint on the subnet  
B. Create a Private Endpoint for the Storage account in the VNet  
C. Configure a Firewall rule on the Storage account to allow the VNet IP range  
D. Use Azure Bastion to connect to Storage  
E. Whitelist the public IP of the VNet in the Storage firewall  

---

**Question 27**

You have deployed WAF on Application Gateway in Prevention mode. Some legitimate users are being incorrectly blocked by a WAF rule. You need to allow this traffic without disabling WAF. What should you do?

A. Switch WAF to Detection mode  
B. Create a WAF custom rule with higher priority to Allow the traffic  
C. Create an exclusion for the specific WAF rule that is causing false positives  
D. Disable the specific OWASP rule set causing the false positive  

---

**Question 28**

A company has DDoS Network Protection (standard plan) enabled. During a DDoS attack, the company incurs significant Azure resource costs due to autoscaling triggered by the attack traffic. What DDoS Protection benefit addresses this?

A. DDoS plan automatically scales down resources to reduce costs  
B. The DDoS Rapid Response team blocks the attack before it reaches resources  
C. Azure provides cost credits for additional Azure charges incurred during a verified DDoS attack  
D. The DDoS plan automatically moves resources to a different region  

---

**Question 29**

An organization's on-premises network connects to Azure via ExpressRoute. They need to ensure data confidentiality for traffic traversing the ExpressRoute circuit. What should they implement?

A. ExpressRoute circuits encrypt traffic by default using AES-256  
B. Configure MACsec encryption on ExpressRoute Direct circuits  
C. Enable Microsoft peering which includes encryption  
D. The private connection of ExpressRoute makes encryption unnecessary  

---

**Question 30**

You need to restrict outbound internet access from an AKS cluster's nodes so that only specific FQDNs are allowed (e.g., `*.azurecr.io`, `management.azure.com`). What is the best solution?

A. Create NSG deny rules for all outbound internet traffic  
B. Deploy Azure Firewall with application rules allowing the required FQDNs  
C. Create a list of allowed IP addresses in the AKS network policy  
D. Use a Service Endpoint for each required Azure service  

---

**Question 31**

After creating a Private Endpoint for an Azure Blob Storage account, users in the VNet report that DNS still resolves to the public IP. Traffic is still going over the internet. What needs to be configured?

A. Disable public access on the storage account  
B. Create a Private DNS zone for `privatelink.blob.core.windows.net` and link it to the VNet  
C. Add a UDR to route storage traffic to the private endpoint  
D. Enable DNS forwarding on the storage account  

---

**Question 32**

An organization wants to protect their web application from SQL injection and cross-site scripting (XSS) attacks. The application is deployed behind an Azure Application Gateway. What should they enable?

A. Azure DDoS Network Protection Plan  
B. NSG rules blocking known malicious IPs  
C. Azure Web Application Firewall (WAF) on the Application Gateway  
D. Azure Firewall Premium with IDPS  

---

**Question 33**

You are troubleshooting why a VM cannot communicate with another VM in a different subnet. You want to quickly verify whether an NSG rule is blocking the traffic. Which Network Watcher tool should you use?

A. Connection Monitor  
B. NSG Flow Logs  
C. IP Flow Verify  
D. Packet Capture  

---

**Question 34**

A company needs to ensure that Point-to-Site (P2S) VPN clients can only connect if they are using Intune-enrolled, compliant devices. Which P2S authentication method supports integration with Conditional Access?

A. Certificate-based authentication  
B. RADIUS authentication  
C. Entra ID (Azure AD) authentication  
D. IKEv2 with pre-shared key  

---

**Question 35**

Your organization needs to capture all network flows in a VNet for compliance purposes and analyze traffic patterns using AI. Which combination of features should you use?

A. Azure Firewall logs + Log Analytics  
B. NSG Flow Logs (v2) + Traffic Analytics  
C. Network Watcher Packet Capture + Azure Monitor  
D. Connection Monitor + Application Insights  

---

## Section 3: Compute, Storage, and Databases (Questions 36–48)

---

**Question 36**

A VM's OS disk needs to be encrypted using a customer-managed key stored in Key Vault. The Key Vault must be protected against permanent deletion of the key. What Key Vault features must be enabled? (Select TWO)

A. Soft delete  
B. Purge protection  
C. RBAC authorization  
D. Private endpoint  
E. Key auto-rotation  

---

**Question 37**

An application deployed on Azure App Service needs to connect to an Azure SQL Database. The connection string (including credentials) must not be stored in application code or environment variables. What is the recommended approach?

A. Store the connection string in an Azure Storage table  
B. Use a managed identity for the App Service to authenticate to SQL without a password, and use a Key Vault reference for the connection string in App Settings  
C. Encrypt the connection string using DPAPI and store it in appsettings.json  
D. Store the connection string in a GitHub repository secret  

---

**Question 38**

A company stores financial records in Azure Blob Storage that must be immutable for 7 years for regulatory compliance (SEC Rule 17a-4). What should they configure?

A. Enable versioning on the container and set a retention policy  
B. Configure time-based immutability policy (WORM) with a 7-year retention period and lock the policy  
C. Enable soft delete with 7-year retention on the storage account  
D. Set a lifecycle management policy to archive blobs after 7 years  

---

**Question 39**

You are reviewing Azure Container Registry (ACR) security. The security team found that the admin account is enabled. What risk does this create and what should you do?

A. The admin account provides read-only access; enable it only in development  
B. The admin account uses a single shared credential that grants full access; disable it and use managed identities or service principals  
C. The admin account is required for AKS integration; keep it enabled but rotate credentials monthly  
D. The admin account only applies to the registry UI; it poses no API security risk  

---

**Question 40**

An AKS cluster must meet the following requirements:
- API server is not accessible from the internet
- Users authenticate using Entra ID
- Local Kubernetes accounts are disabled

Which cluster features should be enabled? (Select THREE)

A. Enable private cluster  
B. Enable Entra ID integration  
C. Disable local accounts  
D. Enable network policy  
E. Enable pod security admission  

---

**Question 41**

A developer wants to ensure that only container images that have been digitally signed by the security team can be deployed to an Azure Container Registry. Which feature should they enable?

A. Azure Defender for Containers  
B. ACR Content Trust (Notation/Notary v2)  
C. ACR Tasks with security scanning  
D. Azure Policy for Kubernetes  

---

**Question 42**

An application stores sensitive customer data in Azure SQL Database. The data must be encrypted such that even database administrators cannot see the plaintext values. Which SQL security feature achieves this?

A. Transparent Data Encryption (TDE)  
B. Dynamic Data Masking  
C. Always Encrypted  
D. Row-Level Security (RLS)  

---

**Question 43**

A user reports that when they query the `CreditCard` column in the `Orders` table, they see `XXXX-XXXX-XXXX-1234` instead of the actual number. DBAs can see the full number. Which security feature is in use?

A. Always Encrypted  
B. Column-level encryption  
C. Dynamic Data Masking  
D. Transparent Data Encryption  

---

**Question 44**

A storage account stores sensitive data. You need to generate a SAS token for a partner application that should be revocable at any time without changing the storage account keys. What should you use?

A. Account SAS signed with the storage account key  
B. Service SAS signed with the storage account key  
C. User Delegation SAS signed with Entra ID credentials  
D. A stored access policy with a Service SAS  

---

**Question 45**

A company needs to store secrets in Azure Key Vault and requires that the keys are protected by a dedicated single-tenant Hardware Security Module (HSM) at FIPS 140-2 Level 3. What Azure service meets this requirement?

A. Key Vault Premium tier with HSM-protected keys  
B. Azure Managed HSM  
C. Key Vault Standard tier with customer-managed keys  
D. Azure Dedicated Host with Key Vault  

---

**Question 46**

An Azure VM running Windows Server has been compromised. You want to investigate the incident while preventing the VM from communicating with other systems. What is the recommended action in Microsoft Defender for Endpoint?

A. Delete the VM immediately to stop the attack  
B. Isolate the device in Microsoft Defender for Endpoint  
C. Assign an NSG rule to block all traffic from the VM's IP  
D. Shut down the VM from the Azure portal  

---

**Question 47**

A company wants to ensure that all new Azure Storage accounts created in their subscription have blob public access disabled. Some teams attempt to enable public access for development purposes, which should be blocked. What should they implement?

A. Azure Defender for Storage alerts when public access is enabled  
B. An Azure Policy with Deny effect that prevents storage accounts from enabling public blob access  
C. An Azure Monitor alert that triggers a Logic App to disable public access  
D. A Conditional Access policy restricting storage account creation to approved users  

---

**Question 48**

You need to enable Azure Disk Encryption (ADE) on a VM. The Key Vault must be configured correctly to support ADE. Which Key Vault setting is required?

A. Enable the Key Vault for template deployment  
B. Enable the Key Vault for disk encryption  
C. Enable purge protection on the Key Vault  
D. Configure a private endpoint for the Key Vault  

---

## Section 4: Security Operations (Questions 49–60)

---

**Question 49**

A company wants to automatically create a support ticket in ServiceNow and send a Teams notification when a high-severity security incident is created in Microsoft Sentinel. What Sentinel feature should they configure?

A. An automation rule that runs a playbook  
B. A Sentinel analytics rule with action set to "Notify"  
C. A Fusion rule that correlates high-severity alerts  
D. An Azure Monitor alert rule with an action group  

---

**Question 50**

Microsoft Sentinel shows a Fusion incident combining a leaked credential alert and a sign-in from an anonymous IP. Which analytics rule type generated this incident?

A. Scheduled analytics rule  
B. NRT (Near Real-Time) rule  
C. Fusion rule  
D. Microsoft Security rule  

---

**Question 51**

A security team wants to query Microsoft Sentinel to find all users who signed in successfully from both the United States and Russia within the same 24-hour period (impossible travel). Which Sentinel feature/language should they use?

A. Azure Monitor metrics queries  
B. Kusto Query Language (KQL) on SigninLogs data  
C. Microsoft Sentinel UEBA anomaly detection  
D. Conditional Access log analysis  

---

**Question 52**

Defender for Cloud shows a Secure Score of 45%. The security team wants to improve the score quickly. What should they focus on?

A. Enable all Defender plans (paid workload protection)  
B. Remediate High severity recommendations grouped under controls with the highest maximum score  
C. Add more Azure subscriptions to increase the total resource count  
D. Enable all regulatory compliance standards in Defender for Cloud  

---

**Question 53**

An Azure Policy with DeployIfNotExists effect is assigned to deploy a Log Analytics agent on all VMs. New VMs are being created but the agent is not being deployed automatically. What is the most likely cause?

A. The policy effect should be AuditIfNotExists for automatic deployment  
B. The policy assignment's managed identity does not have sufficient permissions to deploy the agent  
C. DeployIfNotExists policies only apply to existing resources, not new resources  
D. The policy must be applied at the resource group level, not the subscription level  

---

**Question 54**

You are configuring Microsoft Sentinel data connectors. Which connector should you use to ingest logs from an on-premises Cisco ASA firewall that outputs logs in Common Event Format (CEF)?

A. REST API connector  
B. Azure Monitor agent with custom log collection  
C. CEF/Syslog connector via a Linux syslog forwarder  
D. TAXII connector  

---

**Question 55**

Your organization wants to ensure that resources are deployed with specific security configurations. You want resources that don't comply to be automatically remediated (not just flagged). Which Azure Policy effect should you use?

A. Audit  
B. AuditIfNotExists  
C. Deny  
D. DeployIfNotExists  

---

**Question 56**

A company subscribes to a commercial threat intelligence feed that provides Indicators of Compromise (IOCs) in STIX format via a TAXII 2.1 server. How should this feed be ingested into Microsoft Sentinel?

A. Use the Microsoft Defender Threat Intelligence (MDTI) connector  
B. Configure the TAXII data connector in Sentinel with the feed's URL and credentials  
C. Export IOCs to Azure Storage and use a custom Logic App to import them  
D. Use the Syslog connector to receive IOC feeds  

---

**Question 57**

Microsoft Defender for Servers Plan 2 is enabled on a subscription. A security administrator wants to monitor for changes to critical OS files on Windows VMs (e.g., `%SystemRoot%\System32`). Which feature provides this capability?

A. Microsoft Defender for Endpoint real-time protection  
B. File Integrity Monitoring (FIM)  
C. Adaptive application controls  
D. Azure Update Manager  

---

**Question 58**

An organization has an Azure subscription with multiple resource groups. They want to receive an email alert whenever a new Owner role assignment is made in the subscription. Which service should they use?

A. Microsoft Sentinel with a scheduled analytics rule on AuditLogs  
B. Azure Monitor Activity Log alert filtered on "Create role assignment" operation  
C. Defender for Cloud with a custom alert for role changes  
D. Entra ID Identity Protection with role change detection  

---

**Question 59**

A security team is investigating a potential breach. They need to determine which user deleted a Key Vault secret two days ago. Where should they look?

A. Azure Activity Log  
B. Key Vault diagnostic logs (AuditEvent category) in Log Analytics  
C. Microsoft Defender for Cloud security alerts  
D. NSG Flow Logs  

---

**Question 60**

You have an Azure subscription with Defender for Cloud enabled. You want to ensure all new VMs automatically get vulnerability assessment configured. What is the best approach?

A. Create a script that runs on VM creation via Azure Automation  
B. Enable the built-in Azure Policy "Configure machines to receive a vulnerability assessment provider"  
C. Manually enable vulnerability assessment for each VM in Defender for Cloud  
D. Deploy a custom Log Analytics workspace agent with vulnerability scanning  

---

## ✅ Answers and Explanations

---

### Section 1: Identity and Access

**1. B** — PIM provides JIT access with MFA on activation. This is exactly the scenario: eligible assignment (on-demand) with MFA enforcement during activation.

**2. B** — Conditional Access policies can require compliant devices as a Grant control. NSGs operate at the network layer and can't verify device compliance.

**3. B** — System-assigned managed identity + RBAC role assignment is the recommended credential-free approach. SAS tokens don't apply to Key Vault; service principal secrets defeat the purpose.

**4. A** — Service accounts using app-only flows (client credentials) can't complete MFA. They should be excluded from user-targeted CA policies. Security Defaults would make things worse by enforcing MFA everywhere.

**5. A** — Risk-based Conditional Access policies (user risk → require password change) is the modern, recommended approach. Identity Protection policies work through Conditional Access.

**6. B** — B2B guest invitations allow external users to authenticate with their own organization's credentials. B2C is for consumer-facing apps, not business partner collaboration.

**7. C** — Contributor can manage all resources but cannot perform role assignments. Owner can. User Access Administrator can only manage access.

**8. B** — Access Reviews with auto-apply results and "no response = remove access" automates the recertification process. PIM activation duration is per-session, not a review cycle.

**9. B** — Security Defaults and Conditional Access are mutually exclusive. Security Defaults must be disabled before any Conditional Access policies can be effective.

**10. B** — Azure RBAC is additive. The user has Contributor at subscription scope, which inherits down to all resource groups including that one. Reader at the RG doesn't reduce the Contributor permissions.

**11. A** — The most likely cause is that the Key Vault uses the **vault access policy** authorization model, not RBAC. RBAC role assignments have no effect on Key Vaults configured with vault access policies (you must also add the identity to the vault access policy, or switch the Key Vault to RBAC model).

**12. B** — ML-based recommendations in Access Reviews identify inactive users and suggest "deny" for them. Setting no-response to "Take recommendations" auto-applies these suggestions.

**13. B** — PIM role settings (activation requirements, maximum duration, approval, MFA) are configured per-role in PIM → Azure AD Roles → [Role Name] → Settings.

**14. B** — Cross-tenant access settings allow you to trust compliance claims from specific partner tenants. This lets partner users use their own compliant devices without re-enrolling in your tenant.

**15. C** — Conditional Access requires only Entra ID P1. PIM, Identity Protection, and Access Reviews require P2.

**16. B** — Always create the new secret first, update the pipeline, test, then delete the old one. This avoids downtime.

**17. A** — "Users can register applications" in Entra ID User Settings controls whether all users can register apps. Setting it to "No" restricts this to users with the Application Developer role.

**18. B** — PIM manages eligible assignments. If a user has a permanent (direct) role assignment made outside PIM, they bypass the PIM activation workflow. Permanent assignments must be removed and replaced with eligible assignments in PIM.

**19. C** — Key Vault Crypto User allows cryptographic operations (sign, verify, encrypt, decrypt, wrap, unwrap) but NOT key management (create, delete, update). Crypto Officer includes management.

**20. B and C** — Disabling the account prevents new logins; revoking sessions invalidates existing tokens. This immediately stops access while preserving the account for investigation. Deleting the account destroys evidence.

---

### Section 2: Secure Networking

**21. B** — Priority 200 allows HTTPS from Internet to 10.1.0.0/24. The rules are evaluated in priority order; priority 200 matches before the Deny at priority 300.

**22. C** — JIT VM Access provides time-limited, IP-restricted port access without a public IP (ports are blocked by NSG by default and temporarily opened on request). Bastion is also correct but doesn't restrict by IP in basic config; JIT is more precise for this scenario.

**23. B and D** — The subnet must be named exactly "AzureBastionSubnet" and the Standard SKU requires a minimum /26 subnet (Basic requires /27). E is also correct but not listed as choices B and D.

**24. B** — Private Endpoints provide a private IP in the VNet for Azure SQL, fully removing public internet access. Private DNS zone is required for correct name resolution from within the VNet.

**25. B** — User Defined Routes (UDRs) with `0.0.0.0/0` next hop set to the Azure Firewall's private IP force internet-bound traffic through the firewall. NSGs don't redirect traffic; they allow/deny.

**26. A and B** — Both Service Endpoints and Private Endpoints keep traffic on the Azure backbone (not the public internet). Service Endpoints use the Azure backbone routing; Private Endpoints use a private IP. Options C and E still traverse public IPs.

**27. C** — WAF exclusions allow specific request elements (headers, cookies, query strings) to skip specific rules while keeping WAF in Prevention mode. Custom Allow rules can also work (B) but exclusions are more targeted.

**28. C** — Azure DDoS Network Protection Plan includes a service credit (cost guarantee) for additional Azure resource costs incurred during a verified DDoS attack.

**29. B** — ExpressRoute does NOT encrypt traffic by default. MACsec provides Layer 2 encryption on ExpressRoute Direct circuits. You can also use IPsec over ExpressRoute for Layer 3 encryption.

**30. B** — Azure Firewall with application rules using FQDN tags or custom FQDNs is the best solution for FQDN-based outbound filtering. NSG rules can't filter by FQDN.

**31. B** — Private Endpoints require a Private DNS zone to override the public DNS resolution. Without the DNS zone linked to the VNet, queries resolve to the public IP instead of the private endpoint IP.

**32. C** — WAF on Application Gateway protects against OWASP Top 10 attacks (SQL injection, XSS, etc.) at Layer 7. DDoS protects against volumetric attacks; NSGs are Layer 4; Firewall IDPS is for known signatures.

**33. C** — IP Flow Verify checks whether a specific flow (source IP, destination IP, port, protocol) is allowed or denied by NSG rules for a specific VM. NSG Flow Logs capture historical flows but aren't real-time troubleshooting.

**34. C** — Entra ID (Azure AD) authentication for P2S VPN supports Conditional Access integration, allowing device compliance enforcement. Certificate and RADIUS authentication don't integrate with Conditional Access.

**35. B** — NSG Flow Logs v2 captures all VNet traffic data; Traffic Analytics uses AI/ML to analyze the flow data in Log Analytics and provides traffic maps, threat detection, and bandwidth insights.

---

### Section 3: Compute, Storage, and Databases

**36. A and B** — Both soft delete and purge protection are required for Key Vaults used with ADE CMK scenarios. Purge protection prevents permanent deletion of keys. Both are Microsoft requirements for CMK disk encryption.

**37. B** — The combination of managed identity (passwordless SQL auth) plus Key Vault reference in App Settings (for other connection details) is the recommended approach. The managed identity authenticates to SQL without any stored secret.

**38. B** — WORM (time-based immutability) with the policy locked is the correct approach for SEC Rule 17a-4 compliance. Soft delete doesn't prevent modification; lifecycle management doesn't prevent deletion.

**39. B** — The ACR admin account uses a single shared username/password with full registry access. It cannot be audited per-user and cannot be disabled individually per-user. Disable it and use managed identities or service principals with scoped permissions.

**40. A, B, and C** — Private cluster hides the API server, Entra ID integration enables organizational authentication, and disabling local accounts enforces Entra-only access.

**41. B** — ACR Content Trust (using Notation/Notary v2) enables image signing and verification. Only images signed with the trusted key can be pulled and deployed. Defender for Containers scans but doesn't enforce signing.

**42. C** — Always Encrypted encrypts data at the client side before it reaches the database. The database engine never sees the plaintext. TDE encrypts data at rest (file level), DDM masks output, RLS restricts rows.

**43. C** — Dynamic Data Masking shows masked output to non-privileged users while DBAs (with `UNMASK` permission) see the real data. This is not encryption — the data is stored in plaintext.

**44. D** — A stored access policy allows you to revoke SAS tokens without changing the account key. User Delegation SAS (C) is also revocable by revoking the Entra ID token, but stored access policies work with account-key-signed SAS and provide group revocation.

**45. B** — Azure Managed HSM provides a dedicated, single-tenant HSM at FIPS 140-2 Level 3. Key Vault Premium uses a shared HSM (multi-tenant); Standard uses software protection.

**46. B** — Device isolation in Microsoft Defender for Endpoint cuts off network communication while keeping the Defender connection active for investigation and remediation. This preserves forensic data (unlike deletion) and stops the threat (unlike shutdown, which loses memory artifacts).

**47. B** — An Azure Policy with Deny effect that sets `allowBlobPublicAccess: false` prevents teams from enabling public access. Alerts notify but don't prevent; Logic Apps remediate after the fact (not preventive).

**48. B** — The Key Vault property `--enabled-for-disk-encryption` must be set to `true` for Azure Disk Encryption to store the disk encryption key/secret in the Key Vault. This is a specific permission separate from general access.

---

### Section 4: Security Operations

**49. A** — Automation rules in Sentinel can run playbooks (Logic Apps) when incidents are created. The playbook can integrate with ServiceNow and Teams. Analytics rules generate alerts/incidents, not response actions.

**50. C** — Fusion rules are specifically designed to correlate multiple low-fidelity signals (like leaked credentials + anonymous IP sign-in) into a single high-fidelity incident using ML.

**51. B** — KQL queries on SigninLogs can join sessions by user and time, then calculate location changes to detect impossible travel. UEBA also does this automatically, but the question asks about querying.

**52. B** — Secure Score increases by completing security controls. Focus on High severity recommendations in controls with the highest max score for the fastest improvement. Enabling Defender plans doesn't directly improve Secure Score (it improves workload protection).

**53. B** — DeployIfNotExists policies use a managed identity to deploy resources. If the managed identity lacks permissions (e.g., Contributor on the subscription), deployments fail silently.

**54. C** — CEF-formatted logs from network devices (Cisco ASA, etc.) are ingested via a Linux syslog forwarder that forwards CEF messages to the Sentinel workspace. This is the standard connector for on-premises firewalls.

**55. D** — DeployIfNotExists automatically deploys a related resource (e.g., diagnostic settings, agents) if it doesn't exist. Deny prevents creation; Audit flags; AuditIfNotExists flags if a related resource is missing.

**56. B** — The TAXII data connector in Microsoft Sentinel accepts threat intelligence in STIX format from any TAXII 2.0/2.1 server. MDTI is Microsoft's own TI feed (separate service).

**57. B** — File Integrity Monitoring (FIM) monitors changes to Windows OS files, registry keys, and Linux files. It requires Defender for Servers Plan 2. MDE provides real-time protection but FIM is the specific feature for file change auditing.

**58. B** — Azure Monitor Activity Log alerts can trigger on specific management operations like "Microsoft.Authorization/roleAssignments/write" which captures new role assignments. This is simpler and more direct than Sentinel for this use case.

**59. B** — Key Vault audit logs (AuditEvent category in diagnostic settings) capture all data plane operations including secret deletions, with the identity of the caller. The Activity Log captures management plane operations (creating/deleting the vault itself).

**60. B** — Azure Policy with "Configure machines to receive a vulnerability assessment provider" effect (DeployIfNotExists) automatically configures vulnerability assessment on new and existing VMs. This scales across the subscription without manual intervention.

---

## 📊 Score Interpretation

| Score | Interpretation |
|-------|---------------|
| 50/60 (83%+) | Excellent — Ready for the exam |
| 42/60 (70%+) | Good — Review weak areas |
| 35/60 (58%+) | Average — More study needed |
| Below 35/60 | More preparation needed — Review domain guides |

---

*← [Domain 4: Security Operations](../domains/04-security-operations.md) | [Hands-On Labs →](../labs/hands-on-labs.md)*
