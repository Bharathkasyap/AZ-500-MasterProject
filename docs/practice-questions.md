# AZ-500 Practice Questions

> **Back to:** [README](../README.md)

> ⚠️ These questions are scenario-based study aids. Read each carefully and select the BEST answer before checking the explanation.

---

## Domain 1: Manage Identity and Access

**Q1.** Your organization requires that users must re-authenticate every 8 hours when accessing the Azure portal from corporate-managed devices. Which feature should you configure?

- A) Multi-Factor Authentication per user settings
- B) Conditional Access sign-in frequency
- C) Azure AD Connect seamless SSO timeout
- D) Privileged Identity Management activation duration

> **Answer: B**  
> Sign-in frequency is a Conditional Access session control that forces re-authentication after a specified time interval. PIM activation duration controls how long a privileged role is active after activation, which is not the same as portal session re-authentication.

---

**Q2.** A developer needs to allow their Azure Function to read secrets from Key Vault without storing any credentials in code or configuration. What is the recommended approach?

- A) Store the Key Vault access key in an application setting
- B) Create a service principal with a client secret and store it in environment variables
- C) Enable a system-assigned managed identity on the Function App and grant it Key Vault Secrets User role
- D) Use an account SAS token stored in an Azure Key Vault secret

> **Answer: C**  
> System-assigned managed identities eliminate the need to manage credentials. The identity is automatically created and tied to the Function App's lifecycle. Granting the Key Vault Secrets User RBAC role gives it read access to secrets without any stored credentials.

---

**Q3.** Your security team wants to ensure that no one has permanent access to the Global Administrator role. Activations must require approval and a justification. Which service should you configure?

- A) Conditional Access with compliant device requirement
- B) Privileged Identity Management (PIM) with approval workflow
- C) Identity Protection user risk policy
- D) Azure AD Access Reviews

> **Answer: B**  
> PIM provides just-in-time privileged access. You can configure an eligible role assignment for Global Administrator with required approval, justification, and MFA on activation. Access Reviews periodically verify existing assignments but don't control the activation workflow.

---

**Q4.** Your company has acquired another organization. You need to give their users access to your SharePoint sites and Azure resources as guests. Their identity should remain in their own tenant. What should you configure?

- A) Azure AD B2C
- B) Azure AD B2B collaboration (guest access)
- C) Create new accounts in your tenant for each external user
- D) Federation with their AD FS

> **Answer: B**  
> Azure AD B2B allows external users to authenticate with their home identity (their organization's Entra ID, Microsoft account, or social IdP) and access resources in your tenant as guests. B2C is for consumer-facing applications, not partner access scenarios.

---

**Q5.** A Conditional Access policy is configured with the following conditions: Users = All users; Cloud apps = Azure portal; Conditions = Sign-in risk = Medium or above. Grant = Block access. A user with a medium-risk sign-in tries to access the Azure portal. What happens?

- A) Access is granted because the risk is only medium, not high
- B) Access is blocked
- C) The user is prompted for MFA and then granted access if MFA succeeds
- D) The user is redirected to the Identity Protection portal

> **Answer: B**  
> The policy explicitly blocks access when sign-in risk is medium or above. Since the user's sign-in is flagged as medium risk, which meets the condition, access is blocked. The policy says "Block" not "Require MFA," so MFA will not be offered.

---

**Q6.** You need to create an Azure RBAC custom role that allows users to start and restart VMs but prevents them from creating or deleting VMs. Which JSON property correctly defines this?

- A) `"Actions": ["Microsoft.Compute/virtualMachines/*"]` with `"NotActions": ["Microsoft.Compute/virtualMachines/delete/action"]`
- B) `"Actions": ["Microsoft.Compute/virtualMachines/start/action", "Microsoft.Compute/virtualMachines/restart/action"]` with `"NotActions": []`
- C) `"Actions": ["Microsoft.Compute/virtualMachines/write"]` with `"NotActions": ["Microsoft.Compute/virtualMachines/delete"]`
- D) `"DataActions": ["Microsoft.Compute/virtualMachines/start/action"]`

> **Answer: B**  
> The custom role should grant only `start` and `restart` actions using explicit action paths. Using `/*` wildcards and NotActions for delete is incorrect because NotActions on delete won't prevent create or other write operations. DataActions are for data plane operations, not management plane (start/restart).

---

**Q7.** You want to configure Identity Protection to automatically remediate when a user's account shows high user risk. The user should be able to recover by resetting their password themselves. What should you configure?

- A) A Conditional Access policy with user risk = high → Block access
- B) A Conditional Access policy with user risk = high → Require password change
- C) An Identity Protection user risk policy with action = Block sign-in
- D) Enable Self-Service Password Reset (SSPR) with security questions only

> **Answer: B**  
> Configuring a Conditional Access user risk policy with "Require password change" allows the user to complete a self-service password reset to remediate their own risk level. Using "Block" would require admin intervention. The legacy Identity Protection policy blades exist but Conditional Access integration is the preferred approach.

---

## Domain 2: Secure Networking

**Q8.** You need to allow your web application (running in a VNet subnet) to access Azure SQL Database, ensuring that traffic stays on the Microsoft backbone and does not traverse the public internet. The SQL database should still be accessible from the Azure portal and Azure Cloud Shell. What is the MINIMUM change required?

- A) Create a Private Endpoint for the SQL server in the web app's subnet
- B) Enable a Service Endpoint on the subnet and add a VNet rule on the SQL firewall
- C) Add the SQL server's public IP to an allow rule in the subnet's NSG
- D) Configure VNet peering between the web app VNet and the SQL VNet

> **Answer: B**  
> Service Endpoints allow the subnet's traffic to the SQL server to stay on the Microsoft backbone. Adding a VNet rule on the SQL firewall restricts access to that specific subnet. The public endpoint remains accessible (for the portal/Cloud Shell), which meets the stated requirement. Private Endpoint would also work but is more complex and changes DNS resolution.

---

**Q9.** Your organization wants to block all RDP (port 3389) access to Azure VMs from the internet while still allowing administrators to connect to VMs for maintenance. What is the BEST solution?

- A) Add an NSG deny rule for port 3389 on all VM NICs
- B) Deploy Azure Bastion and use JIT VM access with Defender for Servers enabled
- C) Use Azure VPN Gateway so admins connect via VPN before accessing VMs
- D) Remove all public IPs from VMs and use ExpressRoute for admin access

> **Answer: B**  
> Azure Bastion provides browser-based RDP/SSH without public IPs on VMs and without opening port 3389 to the internet. JIT further ensures management ports are closed by default and only opened on request for a limited time. This is the Azure-recommended secure remote access solution.

---

**Q10.** You are deploying an e-commerce web application in Azure. Which services should you combine to protect against DDoS volumetric attacks AND OWASP web application attacks?

- A) Azure Firewall Premium + NSG
- B) Azure DDoS Protection (Network Protection) + Application Gateway with WAF
- C) Azure Front Door + Azure Firewall Standard
- D) NSG + Azure Bastion

> **Answer: B**  
> DDoS Protection (Network Protection) mitigates L3/L4 volumetric attacks. Application Gateway WAF inspects L7 HTTP/HTTPS traffic and blocks OWASP top 10 attacks (SQL injection, XSS, etc.). These two services are complementary and cover different layers of web application protection.

---

**Q11.** You have deployed an Azure Firewall in your hub VNet. Spoke VNets are peered to the hub. You want all internet-bound traffic from spoke VNets to be inspected by the Azure Firewall. What must you configure in the spoke VNets?

- A) An NSG with a deny rule for Internet on each spoke subnet
- B) A User Defined Route (UDR) with destination `0.0.0.0/0` and next hop set to the Azure Firewall private IP
- C) A service endpoint for Azure Firewall on each spoke subnet
- D) VNet peering with "Use remote gateways" enabled on the spoke

> **Answer: B**  
> A UDR with `0.0.0.0/0 → Virtual Appliance (Firewall IP)` overrides the default Azure system route that allows internet egress directly. This forces all traffic through the Azure Firewall in the hub. Service endpoints don't exist for Azure Firewall; "Use remote gateways" is for VPN/ExpressRoute routing.

---

**Q12.** A developer reports that after configuring a Private Endpoint for their Azure Storage account, the storage SDK in their application still connects to the public IP of the storage account. The application runs inside the peered VNet. What is the most likely cause?

- A) Private Endpoint requires the application to be restarted
- B) The Private DNS Zone for the storage account is not linked to the application's VNet
- C) The storage account firewall is not configured to deny public access
- D) The Private Endpoint NIC does not have a public IP assigned

> **Answer: B**  
> Private Endpoints require a corresponding Private DNS Zone (e.g., `privatelink.blob.core.windows.net`) linked to the VNet. Without it, the FQDN resolves to the public IP even from inside the VNet. The application's DNS queries must return the private IP address from the Private DNS Zone.

---

## Domain 3: Secure Compute, Storage, and Databases

**Q13.** A security audit finds that your Azure SQL Database backups and transaction logs are not encrypted with your organization's own keys. You need to ensure the organization controls the encryption key and can revoke access to the database if needed. What should you configure?

- A) Enable Azure Disk Encryption (ADE) on the SQL server VM
- B) Configure Transparent Data Encryption (TDE) with a Customer-Managed Key (CMK) stored in Azure Key Vault
- C) Enable Always Encrypted on all sensitive columns
- D) Enable SQL Auditing and store logs in a geo-redundant storage account

> **Answer: B**  
> TDE with CMK (BYOK) stores the TDE protector key in Azure Key Vault under your control. This encrypts the database files, backups, and transaction logs. Revoking access to the key in Key Vault immediately prevents SQL from accessing encrypted data. ADE encrypts VM disks, not SQL data specifically.

---

**Q14.** Your application stores credit card numbers in an Azure SQL Database column. These numbers should never be visible to database administrators who have access to the SQL server. Which feature prevents DBAs from seeing the plaintext values?

- A) Transparent Data Encryption (TDE)
- B) Dynamic Data Masking
- C) Always Encrypted
- D) Row-Level Security

> **Answer: C**  
> Always Encrypted encrypts data at the client driver level. The SQL server never sees or processes plaintext values. Even database administrators with sa-level access cannot read the plaintext column values. Dynamic Data Masking shows masked data in query results but DBAs can still see plaintext. TDE encrypts files on disk but not in memory during processing.

---

**Q15.** A storage account contains highly sensitive financial data. You need to ensure that all access to the storage account is only from within a specific VNet subnet, and that the public endpoint is completely disabled. What TWO actions must you take?

- A) Configure a service endpoint on the subnet; set storage firewall to allow only the subnet
- B) Create a private endpoint in the subnet; disable public network access on the storage account
- C) Create an NSG deny rule for Internet on the subnet; enable storage firewalls
- D) Enable customer-managed keys; configure storage logging

> **Answer: B**  
> A Private Endpoint creates a private IP in the subnet for the storage account. Disabling public network access ensures all public internet access is blocked. Option A uses service endpoints which still allow public endpoint access from other sources. NSG rules (C) do not disable the storage account's public endpoint.

---

**Q16.** You need to give a third-party auditor time-limited, read-only access to specific Azure Blob containers for 24 hours without creating an Entra ID account for them. Which is the MOST secure approach?

- A) Share the storage account access key with the auditor
- B) Generate a User Delegation SAS token with read permission and 24-hour expiry for the specific containers
- C) Generate an Account SAS with read permission signed with the storage account key
- D) Enable anonymous blob access on the containers temporarily

> **Answer: B**  
> A User Delegation SAS is signed with Entra ID credentials (not the storage account key), scoped to specific containers, limited to read permission, and expires after 24 hours. It provides precisely scoped, time-limited access without sharing master keys or creating user accounts. Account SAS signed with the storage account key is less secure than User Delegation SAS.

---

**Q17.** An application running on an AKS cluster needs to retrieve secrets from Azure Key Vault at runtime. The operations team requires that secrets be mounted as files in the pod filesystem rather than injected as environment variables. What should you deploy?

- A) Azure Key Vault Flexible Server with managed identity
- B) Secrets Store CSI Driver with Azure Key Vault provider
- C) An Init container that calls the Key Vault REST API and writes secrets to a shared volume
- D) Azure App Configuration with feature flags

> **Answer: B**  
> The Secrets Store CSI Driver (with Azure Key Vault provider) allows secrets, keys, and certificates from Key Vault to be mounted as files in pod filesystem volumes. It uses the AKS managed identity or Workload Identity for authentication — no credentials in manifests or environment variables.

---

**Q18.** Defender for Cloud shows a recommendation: "Container images should have vulnerability findings resolved (powered by MDVM)." What service is generating these findings and where are the scanned images stored?

- A) Microsoft Defender for Servers scanning all running VMs for container image vulnerabilities
- B) Microsoft Defender for Containers scanning images stored in Azure Container Registry
- C) Microsoft Defender for Resource Manager scanning ARM templates for container configurations
- D) Azure Policy scanning Kubernetes workload specs for vulnerable base images

> **Answer: B**  
> Defender for Containers scans container images pushed to Azure Container Registry (ACR). It uses Microsoft Defender Vulnerability Management (MDVM) to assess OS packages and application dependencies for known vulnerabilities (CVEs). Results appear as Defender for Cloud recommendations.

---

## Domain 4: Manage Security Operations

**Q19.** Your SOC team receives a Sentinel incident indicating a user has signed in from two geographically distant locations within 30 minutes (impossible travel alert). What should be the FIRST containment action?

- A) Delete the user account from Entra ID
- B) Disable the user account in Entra ID and revoke all active sign-in sessions
- C) Force password reset via SSPR and monitor for 24 hours
- D) Block the user's IP address in the Azure Firewall

> **Answer: B**  
> Disabling the user account and revoking sign-in sessions (via `revokeSignInSessions`) immediately terminates any active sessions and prevents new logins. This is the fastest containment action. Deleting the account is too destructive for initial containment. Forcing a password reset alone doesn't terminate existing sessions.

---

**Q20.** A Sentinel analytics rule should fire when the same IP address fails to authenticate to 10 or more different user accounts within a 1-hour window. Which KQL clause correctly aggregates this data?

- A) `| where FailureCount > 10 | summarize by IPAddress`
- B) `| summarize DistinctUsers = dcount(UserPrincipalName), FailedAttempts = count() by IPAddress, bin(TimeGenerated, 1h) | where DistinctUsers >= 10`
- C) `| extend hourly = bin(TimeGenerated, 1h) | count by UserPrincipalName, IPAddress`
- D) `| join (SigninLogs) on IPAddress | where ResultType != 0`

> **Answer: B**  
> The query must count *distinct user accounts* per IP address per hour window. `dcount(UserPrincipalName)` counts distinct users; `bin(TimeGenerated, 1h)` creates the time bucket; `where DistinctUsers >= 10` applies the threshold. This detects password spraying attacks where one IP tries many accounts.

---

**Q21.** You need to ensure that whenever a new Azure subscription is created in your organization, an NSG with specific deny rules is automatically deployed to all resource groups. Which Azure service achieves this with the LEAST operational overhead?

- A) Azure Blueprints with a deployIfNotExists policy initiative
- B) Azure Policy with a `deployIfNotExists` policy effect targeting subscriptions
- C) ARM template + GitHub Actions CI/CD pipeline triggered on subscription creation
- D) Azure Automation runbook triggered by an Activity Log alert for subscription creation

> **Answer: B**  
> Azure Policy with `deployIfNotExists` effect can automatically deploy resources (like NSGs) when they don't exist in a specified scope. This runs automatically and continuously without pipeline maintenance. Assignment at the management group level covers all new subscriptions. Blueprints would also work but are being deprecated.

---

**Q22.** Defender for Cloud shows your subscription's Secure Score has decreased by 8%. The biggest contributing recommendation is "MFA should be enabled on accounts with owner permissions on your subscription." How should you remediate this?

- A) Enable Security Defaults in Entra ID
- B) Configure a Conditional Access policy requiring MFA for all users assigned Owner role at the subscription
- C) Enable per-user MFA for the specific Owner accounts in the Microsoft 365 admin center
- D) Remove the Owner role assignment from all users and replace with Contributor

> **Answer: B**  
> A Conditional Access policy targeting users with the Owner role assignment requiring MFA is the recommended, flexible approach. Security Defaults (A) enable MFA for all users but may conflict with existing Conditional Access policies if the tenant already has CA policies. Per-user MFA (C) is a legacy approach not recommended for new deployments.

---

**Q23.** You need to export all Defender for Cloud security alerts to a third-party SIEM tool in real-time. The third-party SIEM has a REST API endpoint that accepts JSON payloads. What is the MOST direct configuration?

- A) Configure Defender for Cloud continuous export to Log Analytics → configure a Log Analytics alert to call a Logic App webhook → Logic App POSTs to SIEM
- B) Configure Defender for Cloud continuous export to Event Hub → configure the SIEM to consume from Event Hub
- C) Create a scheduled Logic App that queries the Defender for Cloud REST API every 5 minutes and forwards to the SIEM
- D) Enable Microsoft Sentinel and configure a Sentinel automation rule to forward alerts to the SIEM

> **Answer: B**  
> Defender for Cloud Continuous Export supports direct export to Azure Event Hubs. Most modern SIEMs and SOAR tools support consuming from Event Hubs natively. This provides near-real-time streaming with minimal latency and no intermediate components to maintain.

---

**Q24.** A Log Analytics alert should fire whenever a user is added to the Global Administrator role in Entra ID. Which table and filter should the KQL query use?

- A) `SigninLogs | where UserPrincipalName contains "admin"`
- B) `AuditLogs | where OperationName == "Add member to role" | where TargetResources has "Global Administrator"`
- C) `AzureActivity | where OperationName == "Assign Role" | where Properties has "Global Administrator"`
- D) `SecurityAlert | where AlertType == "RoleAssignmentAlert"`

> **Answer: B**  
> `AuditLogs` captures Entra ID directory operations including role assignments. The operation "Add member to role" with the target resource containing "Global Administrator" precisely captures this event. `AzureActivity` captures Azure RBAC changes (subscription level), not Entra ID role assignments.

---

**Q25.** Your organization must demonstrate compliance with PCI DSS for Azure workloads. Which Defender for Cloud feature provides an out-of-the-box compliance dashboard mapped to PCI DSS controls?

- A) Secure Score improvement actions
- B) Regulatory Compliance dashboard with the PCI DSS initiative assigned
- C) Microsoft Sentinel compliance workbook
- D) Azure Policy compliance dashboard with built-in definitions

> **Answer: B**  
> Defender for Cloud's Regulatory Compliance dashboard maps security recommendations to compliance controls from standard frameworks including PCI DSS. Assigning the PCI DSS initiative to your subscription populates the dashboard with control coverage and generates audit-ready compliance reports.

---

## Mixed Domain Scenario Questions

**Q26.** A security assessment finds the following issues in your Azure environment:
1. Several VMs have public IPs and RDP/SSH open to the internet
2. Key Vault is accessible from all public IPs
3. Storage accounts allow access from all networks
4. No MFA is required for admin accounts

List these issues from HIGHEST to LOWEST severity based on Azure security best practices.

> **Answer (suggested priority):**
> 1. **No MFA for admin accounts** — credential compromise is the #1 initial access vector; administrative accounts without MFA can lead to complete tenant/subscription takeover
> 2. **VMs with public IPs and RDP/SSH open** — direct remote access to compute; high risk of brute force/exploitation; immediate lateral movement potential
> 3. **Storage accounts open to all networks** — data exfiltration risk; depends on data sensitivity; Defender for Storage can partially mitigate
> 4. **Key Vault accessible from all public IPs** — still protected by RBAC/access policies; lowest risk if authentication is strong, but should be network-restricted for defense-in-depth

---

**Q27.** You are designing a security architecture for a new application with the following requirements:
- App runs on AKS
- Retrieves secrets from Key Vault
- Writes to Azure SQL Database
- Images stored in ACR
- No secrets in code or container images

Which combination of features satisfies ALL requirements?

> **Answer:**
> - **AKS Workload Identity** (or Pod Managed Identity) — assign a managed identity to pods
> - **Secrets Store CSI Driver** — mount Key Vault secrets as files in pods
> - **Entra ID Authentication on Azure SQL** — AKS managed identity authenticates to SQL; no connection string password needed
> - **AcrPull role** on the AKS cluster managed identity — pull images from ACR without stored credentials
> - **Private Endpoints** for Key Vault, SQL, and ACR — network-level isolation
> - **Defender for Containers** — scan ACR images for vulnerabilities

---

**Q28.** Sentinel receives an alert: "Rare subscription-level operation performed by previously unseen user." Investigation reveals a newly created service principal made 47 resource deletion calls across multiple resource groups in 3 minutes. What does this pattern most likely indicate, and what immediate actions should you take?

> **Answer:**
> **Pattern:** Likely a compromised service principal used in a destructive attack (ransomware-style cloud attack — delete resources to extort payment, or a competitor/disgruntled insider wiping infrastructure).
>
> **Immediate actions:**
> 1. **Disable the service principal** in Entra ID (revoke all tokens by disabling the app registration or resetting credentials)
> 2. **Review and revoke** the service principal's role assignments
> 3. **Check Azure Activity Log** for all operations performed by the SPN in the past 24 hours
> 4. **Activate Resource Locks** on remaining critical resources to prevent further deletion
> 5. **Assess deleted resources** — are they recoverable from soft-delete, snapshots, backups?
> 6. **Initiate incident investigation** to determine how the SPN credentials were obtained (leaked credential, compromised CI/CD pipeline, etc.)
> 7. **Review App Registration** for the SPN — check API permissions, owner, credential type and age

---

*Additional practice questions and full mock exams are available via the [Microsoft Learn Practice Assessment](https://learn.microsoft.com/en-us/credentials/certifications/azure-security-engineer/practice/assessment?assessment-type=practice&assessmentId=57) (free, official).*

---

> **Back to:** [README](../README.md) | **Also see:** [Labs →](labs.md) | [Cheat Sheet →](cheat-sheet.md)
