# AZ-500 Mock Exam — 60 Questions with Explanations

> **Instructions:** Allow yourself **90 minutes** to complete all 60 questions before reviewing answers.  
> **Passing target:** 42/60 (70%) — exam passing score is 700/1000.  
> **Format:** Multiple choice (some have more than one correct answer — noted where applicable).

---

## Domain 1 — Manage Identity and Access (Questions 1–18)

---

**Question 1**  
A company needs to implement just-in-time privileged access for Azure AD roles. What is required?

A) Azure AD Premium P1  
B) Azure AD Premium P2  
C) Azure AD Free  
D) Microsoft 365 E3  

**Answer: B**  
*Privileged Identity Management (PIM) requires Microsoft Entra ID P2 (or Microsoft Entra ID Governance). P1 is not sufficient.*

---

**Question 2**  
Your organization uses Conditional Access. A user signs in from a personal device that is not enrolled in Intune. The CA policy requires a compliant device. What happens?

A) The user is prompted for MFA and then allowed access  
B) The user is blocked from access  
C) The user is redirected to device enrollment  
D) The user is allowed read-only access  

**Answer: B**  
*The policy's grant control requires a compliant device. If the device is not compliant, access is blocked. Conditional Access is a binary decision — there is no "read-only fallback" unless explicitly configured.*

---

**Question 3**  
You assign a user to the Global Administrator role in PIM as "eligible." The user needs to access a resource that requires the Global Administrator role. What must the user do? (Choose 2)

A) Wait for an administrator to activate the role  
B) Navigate to PIM and activate the eligible assignment  
C) Provide a justification (if configured)  
D) Contact the help desk to request activation  

**Answer: B, C**  
*Eligible assignments require the user to self-activate through PIM. If the role settings require justification, the user must provide it during activation. The user does not need administrator intervention unless approval is required.*

---

**Question 4**  
A developer creates a service principal to authenticate an application to Azure Key Vault. The security team requires that the credentials never expire. Which credential type should be used?

A) Client secret  
B) Certificate  
C) Managed identity  
D) Federated credentials  

**Answer: C**  
*Managed identities are automatically managed by Azure and don't have credentials that expire. Client secrets and certificates have expiration dates. Federated credentials use external IdP tokens but require a specific workload setup.*

---

**Question 5**  
You need to allow external users from a partner company to access a SharePoint site in your tenant. The partner uses Google as their identity provider. What should you configure?

A) B2C tenant with Google as the IdP  
B) B2B collaboration with Google federation  
C) New Entra ID accounts for all partner users  
D) Application proxy with Google OAuth  

**Answer: B**  
*B2B collaboration allows external users to authenticate with their home identity provider (including Google). B2C is for customer-facing applications, not partner collaboration.*

---

**Question 6**  
An RBAC role assignment was made at the subscription level. What is the effect?

A) It applies only to resources directly in the subscription root  
B) It applies to all resource groups and resources within the subscription  
C) It applies to all subscriptions in the management group  
D) It must be propagated manually to each resource group  

**Answer: B**  
*RBAC assignments are inherited down the scope hierarchy. A subscription-level assignment automatically applies to all resource groups and resources within that subscription.*

---

**Question 7**  
A user needs to manage RBAC role assignments but should not be able to modify any other resources. Which built-in role should be assigned?

A) Owner  
B) Contributor  
C) User Access Administrator  
D) Security Admin  

**Answer: C**  
*User Access Administrator can manage role assignments only. Owner has full access including role assignment. Contributor cannot manage role assignments. Security Admin manages security policies, not RBAC.*

---

**Question 8**  
Which custom role permission allows an application to read the contents of Azure Blob Storage?

A) `Microsoft.Storage/storageAccounts/read`  
B) `Microsoft.Storage/storageAccounts/blobServices/containers/read`  
C) `Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read` (DataAction)  
D) `Microsoft.Storage/storageAccounts/listKeys/action`  

**Answer: C**  
*Reading blob contents is a data plane operation and uses `DataActions`, not `Actions`. The correct data action is `Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read`. The other options are management plane permissions.*

---

**Question 9**  
You configure a Conditional Access policy with the following settings:  
- Users: All users  
- Cloud apps: Microsoft Azure Management  
- Conditions: Sign-in risk: High  
- Grant: Block access  

A Global Administrator signs in with a high-risk sign-in. What happens?

A) The Global Administrator is blocked  
B) The Global Administrator is allowed because they are exempt from CA policies  
C) The Global Administrator is prompted for MFA  
D) The policy does not evaluate because the user is a Global Administrator  

**Answer: A**  
*Conditional Access applies to all users unless explicitly excluded. If the Global Administrator account is not excluded from the policy, it will be blocked. This is why break-glass accounts must be excluded from CA policies.*

---

**Question 10**  
You need to ensure that users can only access company resources from devices that are Entra ID joined and compliant. Which Conditional Access grant control should you use?

A) Require multi-factor authentication  
B) Require Hybrid Azure AD joined device  
C) Require compliant device AND Require Hybrid Azure AD joined device (either)  
D) Require compliant device  

**Answer: D**  
*A compliant device (Intune-enrolled and meeting compliance policies) satisfies the requirement. Hybrid Entra joined is for domain-joined on-premises devices. Requiring either one is less restrictive than requiring compliant only.*

---

**Question 11**  
Your company acquires another company. You need to allow users from the acquired company's Entra ID tenant to access resources in your tenant without creating new accounts. What should you configure?

A) Cross-tenant synchronization  
B) Azure AD B2B direct connect  
C) Guest access with Entra B2B collaboration  
D) Trust settings for the partner tenant  

**Answer: C**  
*B2B collaboration allows guest users from an external tenant to access resources in your tenant without creating new Entra ID accounts. They authenticate with their home tenant credentials.*

---

**Question 12**  
You are reviewing PIM access reviews. A reviewer did not complete their review before the deadline. The review is configured with "Apply results automatically" and "If reviewers don't respond: Remove access." What happens to the user whose access was under review?

A) The user retains access until manually reviewed  
B) The user's access is removed automatically  
C) The user receives a notification to self-review  
D) The review is extended by 7 days  

**Answer: B**  
*When automatic application is configured and the setting for no-response is "Remove access," PIM automatically removes the eligible or active assignment when the review period ends without a reviewer response.*

---

**Question 13**  
What is the primary security advantage of using federated credentials (workload identity federation) instead of client secrets for a GitHub Actions workflow?

A) Faster authentication  
B) No credentials to store, rotate, or leak  
C) Access to additional Azure services  
D) Compliance with PCI DSS  

**Answer: B**  
*Federated credentials use short-lived tokens issued by the external IdP (GitHub). No secret is created, stored in GitHub secrets, or needs to be rotated — eliminating credential theft risk.*

---

**Question 14**  
You need to assign the same Azure role to 500 users and 200 groups efficiently. What is the most efficient approach?

A) Assign roles individually to each user  
B) Create a custom role that automatically assigns to users  
C) Assign roles to groups and add users to the appropriate groups  
D) Use Entitlement Management access packages  

**Answer: C**  
*Assigning roles to groups and managing group membership is the most scalable approach. Role assignments to groups are inherited by all group members.*

---

**Question 15**  
Which Identity Protection risk detection indicates that a user's credentials may have been published online?

A) Atypical travel  
B) Anonymous IP address  
C) Leaked credentials  
D) Password spray  

**Answer: C**  
*"Leaked credentials" (also called "Leaked/compromised credentials") detects when a user's credentials appear in paste sites or the dark web, and Microsoft's threat intelligence has identified them.*

---

**Question 16**  
You need to grant a VM access to Azure Key Vault without using any passwords or secrets. What should you implement?

A) Service principal with client secret  
B) System-assigned managed identity with Key Vault Secrets User role  
C) Service principal with certificate  
D) User-assigned managed identity with Owner role  

**Answer: B**  
*A system-assigned managed identity is tied to the VM and uses Azure-managed credentials. Assigning the Key Vault Secrets User role grants read access to secrets without any password or certificate management.*

---

**Question 17**  
A Conditional Access policy has Sign-in Risk configured as a condition, but it doesn't seem to be triggering. What is the most likely cause?

A) Conditional Access is in Report-only mode  
B) The tenant does not have Entra ID P2 licenses  
C) Sign-in Risk requires Defender for Cloud Apps  
D) The policy is not applied to the correct app  

**Answer: B**  
*Sign-in risk and user risk conditions in Conditional Access require Microsoft Entra ID P2 (Identity Protection). Without P2, the risk conditions are not evaluated.*

---

**Question 18**  
You need to ensure that users in the HR department can only approve access packages for HR-related resources. What Entitlement Management feature supports this?

A) Dynamic groups with department filter  
B) Access packages with approval policy scoped to HR  
C) Catalogs with specific owners  
D) PIM eligible assignments for catalog owners  

**Answer: C**  
*Entitlement Management catalogs can have specific owners who manage the access packages within that catalog. By creating an "HR Catalog" and assigning HR managers as catalog owners, they can only manage HR-related access packages.*

---

## Domain 2 — Secure Networking (Questions 19–33)

---

**Question 19**  
A VM in a subnet has both a subnet-level NSG and a NIC-level NSG. Traffic is inbound to the VM. In what order are the NSGs evaluated?

A) NIC NSG first, then subnet NSG  
B) Subnet NSG first, then NIC NSG  
C) Both simultaneously; most restrictive wins  
D) Only the subnet NSG is evaluated for inbound traffic  

**Answer: B**  
*For inbound traffic: subnet NSG is evaluated first, then NIC NSG. For outbound: NIC NSG first, then subnet NSG. Both must allow the traffic for it to pass.*

---

**Question 20**  
You need to allow web servers in an NSG to access Azure SQL Database without using IP addresses (since they may change). What should you use in the NSG rule?

A) FQDN-based NSG rule  
B) Service tag `Sql` as the destination  
C) Private endpoint for the SQL database  
D) Application Security Group with the SQL servers  

**Answer: B**  
*NSG service tags represent groups of IP address prefixes maintained by Microsoft. The `Sql` service tag covers all Azure SQL IP ranges and automatically updates when the IPs change.*

---

**Question 21**  
Azure Firewall is deployed in your hub VNet. A spoke VNet VM tries to access the internet, but traffic is being blocked even though you have application rules to allow it. What is the most likely cause?

A) The VM's NSG is blocking outbound traffic  
B) The route table on the spoke subnet does not route through the firewall  
C) Azure Firewall does not support outbound internet traffic  
D) DNAT rules are missing  

**Answer: B**  
*Without a User-Defined Route (UDR) with `0.0.0.0/0 → Azure Firewall private IP`, traffic from the spoke subnet takes the default Azure route to the internet, bypassing the firewall. The firewall cannot intercept traffic that isn't routed to it.*

---

**Question 22**  
Which WAF mode logs attacks but does NOT block them?

A) Prevention mode  
B) Detection mode  
C) Audit mode  
D) Learning mode  

**Answer: B**  
*Detection mode (also called Audit mode in some documentation) logs requests that match rules but does not block them. Prevention mode logs AND blocks matching requests with a 403 response.*

---

**Question 23**  
Your company wants to protect their public IP addresses from volumetric DDoS attacks and also get attack analytics and rapid response from Microsoft. What should they enable?

A) DDoS Basic (infrastructure protection)  
B) Azure Firewall with threat intelligence  
C) DDoS Network Protection (formerly Standard)  
D) Azure Front Door with WAF  

**Answer: C**  
*DDoS Network Protection (Standard tier) provides adaptive tuning, attack analytics, rapid response team access, and cost protection guarantee. DDoS Basic provides only basic platform-level protection without per-customer features.*

---

**Question 24**  
You need to connect on-premises clients to Azure Blob Storage privately, without traffic going over the internet. What should you implement?

A) Service endpoint for Azure Storage on the on-premises network  
B) Private endpoint for the storage account + VPN/ExpressRoute  
C) Storage account firewall with the on-premises IP range  
D) Azure Storage Replication to a private storage account  

**Answer: B**  
*Private endpoints work across VPN and ExpressRoute connections, enabling on-premises clients to access the private IP of the storage account's private endpoint. Service endpoints do NOT work with on-premises connectivity through VPN/ExpressRoute.*

---

**Question 25**  
You create a private endpoint for an Azure SQL server. After creation, external users report they can still access the SQL server from the internet. What should you do?

A) Delete and recreate the private endpoint  
B) Configure the SQL server firewall to deny public network access  
C) Add a Deny NSG rule for port 1433  
D) Disable the service endpoint for SQL  

**Answer: B**  
*Creating a private endpoint does not automatically disable public access. You must explicitly set "Deny public network access" on the Azure SQL server's firewall to prevent internet connections.*

---

**Question 26**  
Azure Bastion requires a dedicated subnet. What must the subnet be named, and what is the minimum size?

A) AzureBastionSubnet; /27  
B) BastionSubnet; /28  
C) AzureBastionSubnet; /26  
D) AzureFirewallSubnet; /26  

**Answer: C**  
*The subnet must be named exactly `AzureBastionSubnet` (case-sensitive) and must be at least /26 (64 IP addresses). Microsoft requires /26 to support future scaling of the Bastion service.*

---

**Question 27**  
Which Azure Firewall SKU is required to enable TLS inspection and intrusion detection/prevention (IDPS)?

A) Azure Firewall Basic  
B) Azure Firewall Standard  
C) Azure Firewall Premium  
D) Azure Firewall Enterprise  

**Answer: C**  
*Azure Firewall Premium adds TLS inspection (requires certificate), IDPS signature-based detection, URL filtering, and web categories. These features are not available in the Standard SKU.*

---

**Question 28**  
You need to implement Just-in-Time VM Access. Which Microsoft Defender plan must be enabled?

A) Defender for Cloud (free tier)  
B) Defender for Servers Plan 1  
C) Defender for Servers Plan 2  
D) Defender for Resource Manager  

**Answer: B**  
*JIT VM Access is included in Defender for Servers Plan 1 (not just Plan 2). Plan 2 adds additional capabilities but JIT is available from Plan 1.*

---

**Question 29**  
You need to allow only virtual machines in the "WebServers" application security group to communicate with SQL Server VMs in the "DatabaseServers" ASG on port 1433. What rule should you create in the NSG?

A) Source: Any → Destination: DatabaseServers ASG → Port: 1433 → Allow  
B) Source: WebServers ASG → Destination: DatabaseServers ASG → Port: 1433 → Allow  
C) Source: 10.1.1.0/24 → Destination: DatabaseServers ASG → Port: 1433 → Allow  
D) Source: VirtualNetwork → Destination: Sql service tag → Port: 1433 → Allow  

**Answer: B**  
*ASGs are used as source and destination in NSG rules to create workload-based micro-segmentation without tracking IP addresses. VMs in the source ASG can reach VMs in the destination ASG on the specified port.*

---

**Question 30**  
You need to inspect TLS-encrypted traffic from VMs to the internet for malware. The VMs are in an Azure VNet. What is the minimum required solution?

A) Azure Firewall Standard with application rules  
B) Azure Firewall Premium with TLS inspection enabled  
C) Azure WAF on Application Gateway  
D) Network Watcher packet capture  

**Answer: B**  
*TLS inspection requires Azure Firewall Premium. It terminates TLS, inspects the plaintext, and re-encrypts. Azure Firewall Standard cannot inspect TLS traffic. WAF protects inbound traffic, not outbound VM traffic.*

---

**Question 31**  
An administrator wants to verify whether a specific NSG rule is blocking traffic from IP 1.2.3.4 to a VM on port 443. Which Network Watcher feature should they use?

A) Connection monitor  
B) NSG flow logs  
C) IP flow verify  
D) Topology view  

**Answer: C**  
*IP Flow Verify tests whether a specific packet (defined by source/destination IP, protocol, and port) is allowed or denied by NSG rules, and which specific rule applies. It's a point-in-time test, not continuous monitoring.*

---

**Question 32**  
You need to capture all network flows (allowed and denied) for compliance auditing in a subnet. What should you configure?

A) Azure Firewall diagnostic logging  
B) NSG flow logs on the subnet's NSG  
C) Network Watcher packet capture  
D) Azure Monitor metrics for the subnet  

**Answer: B**  
*NSG flow logs capture all traffic flows (allowed and denied) through an NSG, including source/destination IP, port, protocol, and bytes. They are stored in a Storage Account and optionally sent to Log Analytics via Traffic Analytics.*

---

**Question 33**  
A company requires that all internet-bound traffic from Azure VMs passes through their on-premises security appliance for inspection. What should they implement?

A) Azure Firewall in the hub VNet  
B) Forced tunneling via UDR with 0.0.0.0/0 → VPN Gateway  
C) Private endpoints for all services  
D) Network Virtual Appliance in a hub VNet  

**Answer: B**  
*Forced tunneling redirects all internet-bound traffic back to on-premises via VPN or ExpressRoute. This is achieved with a UDR that sets 0.0.0.0/0 → VPN Gateway (VNet Gateway type).*

---

## Domain 3 — Secure Compute, Storage & Databases (Questions 34–48)

---

**Question 34**  
An application needs to retrieve a secret from Key Vault. The Key Vault uses the RBAC access model. The application is running as a managed identity. What minimum role should be assigned?

A) Key Vault Administrator  
B) Key Vault Secrets Officer  
C) Key Vault Secrets User  
D) Contributor  

**Answer: C**  
*Key Vault Secrets User grants read-only access to secret values. This is the principle of least privilege — the application only needs to read secrets, not create, update, or delete them.*

---

**Question 35**  
You need to prevent the permanent deletion of a Key Vault secret even by administrators, to protect against ransomware and accidental deletion. What feature should you enable?

A) Soft-delete with 7-day retention  
B) Private endpoint for Key Vault  
C) Purge protection  
D) Customer-managed keys  

**Answer: C**  
*Purge protection prevents permanent deletion (purging) of soft-deleted objects during the retention period, even by vault administrators. Soft-delete alone allows purging after the soft-delete. Purge protection requires soft-delete to be enabled first.*

---

**Question 36**  
A VM's OS disk needs to be encrypted using BitLocker with the encryption keys stored in Azure Key Vault. What service provides this?

A) Server-Side Encryption (SSE) with customer-managed keys  
B) Azure Disk Encryption (ADE)  
C) Storage Service Encryption (SSE) with platform-managed keys  
D) Azure Confidential Computing  

**Answer: B**  
*Azure Disk Encryption (ADE) uses BitLocker (Windows) or DM-Crypt (Linux) to encrypt VM OS and data disks, with encryption keys protected by Azure Key Vault. SSE is a storage-layer encryption and does not use BitLocker.*

---

**Question 37**  
A developer generates a Shared Access Signature (SAS) token for a storage container. The token expires in 1 year and provides full access. The security team is concerned. Which type of SAS would be most secure?

A) Account SAS with the storage account key  
B) Service SAS with the storage account key  
C) User Delegation SAS signed with Entra ID credentials  
D) Anonymous public access on the container  

**Answer: C**  
*User Delegation SAS uses Entra ID credentials (not storage account keys). Even if the SAS token is stolen, it can be revoked by revoking the user delegation key. Additionally, the token lifetime cannot exceed 7 days, limiting exposure.*

---

**Question 38**  
Your Azure SQL Database stores credit card numbers. You need to ensure that the database engine itself cannot read the plaintext credit card numbers, even for queries. What should you implement?

A) Transparent Data Encryption with customer-managed keys  
B) Dynamic Data Masking  
C) Always Encrypted  
D) Row-Level Security  

**Answer: C**  
*Always Encrypted performs encryption on the client side, before data is sent to SQL Server. The database engine only ever sees encrypted data — it cannot decrypt it. TDE encrypts the physical database file but not data in memory during query execution. DDM only masks query results, not the underlying data.*

---

**Question 39**  
An application writes sensitive data to Azure Storage. You need to ensure no one can modify or delete the data for 7 years for regulatory compliance. What should you configure?

A) Storage account geo-redundancy  
B) Blob versioning  
C) Immutable storage with a time-based retention policy  
D) Soft delete with 7-year retention  

**Answer: C**  
*Immutable storage with a time-based retention policy implements WORM (Write Once, Read Many) storage. Data cannot be modified or deleted during the retention period, satisfying regulatory requirements like SEC 17a-4 and FINRA.*

---

**Question 40**  
You need to scan container images in Azure Container Registry for vulnerabilities before they are deployed. What should you enable?

A) Azure Policy for AKS  
B) Microsoft Defender for Containers  
C) Azure Container Registry content trust  
D) Private endpoint for the registry  

**Answer: B**  
*Microsoft Defender for Containers scans container images in ACR for OS and application layer vulnerabilities on push, on schedule, and on pull. It provides vulnerability reports in Defender for Cloud.*

---

**Question 41**  
A storage account is configured with `Secure transfer required = Enabled`. What is the effect?

A) Data is encrypted before leaving the VM  
B) HTTP requests to the storage account are rejected  
C) Only encrypted VMs can read from the storage account  
D) Data is encrypted at rest automatically  

**Answer: B**  
*"Secure transfer required" enforces HTTPS only. All HTTP connections are rejected with an error. It does not affect at-rest encryption, VM requirements, or data-in-transit encryption method — it simply rejects unencrypted HTTP.*

---

**Question 42**  
You need to encrypt an Azure SQL Database with a key that your company manages, controls, and can revoke. What should you configure?

A) Transparent Data Encryption with service-managed keys (default)  
B) Dynamic Data Masking with customer keys  
C) TDE with customer-managed key (BYOK) stored in Key Vault  
D) Always Encrypted with Key Vault integration  

**Answer: C**  
*TDE with Bring Your Own Key (BYOK) uses a customer-managed TDE protector stored in Azure Key Vault. The customer controls the key lifecycle, rotation, and can revoke access (which makes the database inaccessible).*

---

**Question 43**  
An AKS cluster needs to pull images from Azure Container Registry without using admin credentials. What is the recommended approach?

A) Store ACR admin password in a Kubernetes secret  
B) Attach ACR to AKS using managed identity  
C) Create a service principal with AcrPull role  
D) Make the ACR public  

**Answer: B**  
*The recommended approach is to attach ACR to AKS using managed identity. This grants the AKS cluster's managed identity the `AcrPull` role, eliminating the need for passwords or service principal credential management.*

---

**Question 44**  
A user with the Storage Blob Data Reader role on a storage account tries to list storage account keys using the portal. What happens?

A) They can list the keys because Reader role is included  
B) They cannot list keys because listKeys is a management plane operation requiring Contributor or Owner  
C) They can list the keys because Blob Data Reader grants full storage access  
D) They receive a partial key that can only be used for read operations  

**Answer: B**  
*`listKeys` is a management plane operation (`Actions`). Storage Blob Data Reader grants data plane access (`DataActions`) only. To list storage account keys, the user needs Contributor or higher on the management plane.*

---

**Question 45**  
You need to audit all SQL queries executed against an Azure SQL Database and store the logs for 90 days. What should you configure?

A) SQL Profiler connected to the database  
B) Azure SQL Auditing to a Storage Account with 90-day retention  
C) Diagnostic settings → Log Analytics  
D) SQL Threat Protection  

**Answer: B**  
*Azure SQL Auditing logs SQL queries and other database events to a Storage Account, Log Analytics workspace, or Event Hub. Setting 90-day retention in the storage account satisfies the requirement. Option C could also work, but storage account + retention days is the direct answer.*

---

**Question 46**  
Which feature of Microsoft Defender for SQL detects potentially harmful SQL injection attempts in real time?

A) SQL Auditing  
B) Transparent Data Encryption  
C) Advanced Threat Protection  
D) Vulnerability Assessment  

**Answer: C**  
*Advanced Threat Protection (part of Microsoft Defender for SQL) detects anomalous activities like SQL injection, unusual access patterns, and brute force attacks. Vulnerability Assessment scans for misconfigurations but doesn't provide real-time threat detection.*

---

**Question 47**  
A Key Vault has the access model set to "Vault access policy." A managed identity has an access policy granting it `Get` and `List` permissions on secrets. The Key Vault firewall is enabled with "Allow trusted Microsoft services" checked and only one VNet subnet added. The managed identity's resource is in a different subnet. What happens when it tries to retrieve a secret?

A) Access is granted because the access policy allows it  
B) Access is denied because the managed identity's subnet is not in the firewall allow list  
C) Access is granted because managed identities bypass the Key Vault firewall  
D) Access is denied because access policies are deprecated  

**Answer: B**  
*Key Vault enforces both authorization (access policy/RBAC) AND network access controls. Even with a valid access policy, if the calling resource's IP or subnet is not in the firewall allow list, the request is denied with a 403 Forbidden. The managed identity must come from an allowed subnet or IP.*

---

**Question 48**  
You need to ensure that pods in an AKS cluster can only communicate with pods in the same namespace and with the backend tier in another namespace. What should you implement?

A) NSG rules on the AKS node pool subnet  
B) Kubernetes NetworkPolicy resources  
C) Azure Firewall with FQDN rules for pod names  
D) AKS private cluster configuration  

**Answer: B**  
*Kubernetes NetworkPolicy resources define ingress and egress rules at the pod level, allowing fine-grained micro-segmentation within the cluster. NSGs operate at the VM/NIC level and cannot target individual pods or namespaces.*

---

## Domain 4 — Manage Security Operations (Questions 49–60)

---

**Question 49**  
Your Secure Score is 65%. You identify a security control worth 8 points that has 4 recommendations. You remediate 3 of the 4 recommendations. How many points do you gain?

A) 6 points  
B) 8 points  
C) 0 points  
D) 2 points  

**Answer: C**  
*In Defender for Cloud, points for a security control are only awarded when ALL recommendations within that control are completed. Completing 3 out of 4 recommendations awards 0 points until the final one is fixed.*

---

**Question 50**  
You need to automatically deploy the Log Analytics agent to all new VMs in your subscription. Which Azure Policy effect should you use?

A) Audit  
B) Deny  
C) DeployIfNotExists  
D) Modify  

**Answer: C**  
*`DeployIfNotExists` deploys a related resource (in this case, the Log Analytics agent extension) if it doesn't already exist on the target resource. This is the standard effect used for agent auto-provisioning.*

---

**Question 51**  
You need to detect when an Azure VM makes an unusual outbound connection that has never been observed before. Which Microsoft Sentinel analytics rule type is most appropriate?

A) Scheduled query rule  
B) Microsoft Security rule  
C) Anomaly rule  
D) Fusion rule  

**Answer: C**  
*Anomaly rules in Sentinel use machine learning to baseline normal behavior and detect deviations. An unusual outbound connection would be detected by behavioral anomaly detection. Scheduled rules run KQL queries but need explicit thresholds defined.*

---

**Question 52**  
A Sentinel analytics rule creates an alert every time a high-risk sign-in is detected. Multiple alerts for the same user appear as separate incidents. You want all related alerts for the same user within 1 hour to be grouped into a single incident. What should you configure?

A) Fusion rule with correlation  
B) Alert grouping settings in the analytics rule  
C) Incident creation rule  
D) UEBA entity behavior  

**Answer: B**  
*Analytics rules have an "Alert grouping" (Incident settings) configuration where you can group alerts into a single incident by matching entities (e.g., Account entity) within a defined time window.*

---

**Question 53**  
You want Microsoft Sentinel to automatically disable a user account when a "Credential Stuffing" incident is created. What should you configure?

A) An analytics rule with the "Disable user" action  
B) An automation rule that triggers a playbook to disable the user  
C) A Fusion rule connected to Entra ID  
D) An alert suppression rule for false positives  

**Answer: B**  
*Automation rules in Sentinel can trigger playbooks (Logic Apps) when incidents are created or updated. A playbook can call the Entra ID API to disable the user account. Analytics rules detect threats but don't perform response actions directly.*

---

**Question 54**  
You need to query Microsoft Sentinel to find all successful Azure resource deletions in the last 24 hours. Which table should you query?

A) `SecurityAlert`  
B) `AzureActivity`  
C) `AuditLogs`  
D) `SecurityEvent`  

**Answer: B**  
*`AzureActivity` contains Azure Activity Log events, including all management plane operations such as resource creation, modification, and deletion. `AuditLogs` is for Entra ID operations. `SecurityEvent` is for Windows Security Event Log.*

---

**Question 55**  
Your company must comply with PCI DSS. In Defender for Cloud's Regulatory Compliance dashboard, several controls are failing. What should you do first?

A) Purchase Defender CSPM to fix the compliance  
B) Click on the failing control and review the underlying recommendations  
C) Disable the PCI DSS standard and create a custom one  
D) Export the compliance report and submit it to the auditor  

**Answer: B**  
*The first step is to identify *what* is failing. Each failing control in the Regulatory Compliance dashboard maps to specific recommendations in Defender for Cloud. Review and remediate the recommendations to improve compliance.*

---

**Question 56**  
Which Microsoft Sentinel feature uses machine learning to correlate multiple low-severity alerts from different data sources into a single high-confidence incident?

A) UEBA  
B) Threat Intelligence  
C) Fusion  
D) Anomaly rules  

**Answer: C**  
*Fusion is Microsoft Sentinel's multi-stage attack detection engine. It correlates multiple low-fidelity alerts (potentially from different data sources) to identify high-confidence, high-impact incidents like ransomware campaigns or credential compromise chains.*

---

**Question 57**  
Your company uses Defender for Cloud and wants to receive email alerts for all High severity security alerts. Where should this be configured?

A) Azure Monitor → Alerts  
B) Defender for Cloud → Environment settings → Email notifications  
C) Defender for Cloud → Workflow automation  
D) Log Analytics workspace → Alerts  

**Answer: B**  
*Defender for Cloud has a dedicated email notifications configuration in Environment settings where you can specify email addresses and which roles to notify, and configure notification for specific severity levels.*

---

**Question 58**  
An Azure Policy is assigned at the subscription level with the "Deny" effect for "Storage accounts should use customer-managed key." A developer tries to create a new storage account with platform-managed keys. What happens?

A) The storage account is created but flagged as non-compliant  
B) The storage account creation is blocked  
C) The storage account is created and automatically gets a customer-managed key  
D) The policy creates a compliance alert but allows creation  

**Answer: B**  
*The "Deny" effect prevents resource creation or modification that doesn't comply with the policy. The storage account creation request is rejected immediately. "Audit" would allow creation but flag as non-compliant.*

---

**Question 59**  
You need to investigate a security incident in Sentinel. You want to see all entities (users, IPs, hosts) involved and their relationships visually. What should you use?

A) Sentinel Workbooks  
B) Sentinel Investigation Graph  
C) Log Analytics KQL query  
D) Defender for Cloud Attack Path Analysis  

**Answer: B**  
*The Sentinel Investigation Graph provides an interactive, visual representation of all entities involved in an incident and their relationships, enabling investigators to trace attack paths and identify scope.*

---

**Question 60**  
Defender for Cloud recommends enabling Microsoft Defender for Storage on your subscription. The plan costs money. Your manager asks if there's a free alternative to detect malware in uploaded blobs. What is the correct answer?

A) Use Azure Antimalware extension on the storage account  
B) There is no free malware detection for Azure Blob Storage  
C) Use Azure Policy to block executables  
D) Enable anonymous public access restrictions  

**Answer: B**  
*Malware scanning in Azure Storage (detecting malware in blob uploads) is a paid feature of Microsoft Defender for Storage. There is no free, built-in malware scanning equivalent for blob storage. Azure Policy cannot scan file contents.*

---

## Score Card

| Domain | Questions | Your Score |
|--------|-----------|-----------|
| Identity & Access (Domain 1) | 1–18 (18 questions) | /18 |
| Secure Networking (Domain 2) | 19–33 (15 questions) | /15 |
| Compute, Storage & DBs (Domain 3) | 34–48 (15 questions) | /15 |
| Security Operations (Domain 4) | 49–60 (12 questions) | /12 |
| **Total** | **60 questions** | **/60** |

**Target:** 42/60 (70%) before booking the exam.  
**Exam target:** 700/1000 (passing score).

---

## Answer Key

| Q | A | Q | A | Q | A | Q | A |
|---|---|---|---|---|---|---|---|
| 1 | B | 16 | B | 31 | C | 46 | C |
| 2 | B | 17 | B | 32 | B | 47 | B |
| 3 | B,C | 18 | C | 33 | B | 48 | B |
| 4 | C | 19 | B | 34 | C | 49 | C |
| 5 | B | 20 | B | 35 | C | 50 | C |
| 6 | B | 21 | B | 36 | B | 51 | C |
| 7 | C | 22 | B | 37 | C | 52 | B |
| 8 | C | 23 | C | 38 | C | 53 | B |
| 9 | A | 24 | B | 39 | C | 54 | B |
| 10 | D | 25 | B | 40 | B | 55 | B |
| 11 | C | 26 | C | 41 | B | 56 | C |
| 12 | B | 27 | C | 42 | C | 57 | B |
| 13 | B | 28 | B | 43 | B | 58 | B |
| 14 | C | 29 | B | 44 | B | 59 | B |
| 15 | C | 30 | B | 45 | B | 60 | B |
