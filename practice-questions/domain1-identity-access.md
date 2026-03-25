# Domain 1 Practice Questions — Manage Identity and Access

> 20 questions covering identity and access topics. Answers at the bottom.

---

## Questions

**Q1.** Your company wants to ensure that all Global Administrators use multi-factor authentication when signing into the Azure portal from outside the corporate office. What is the MOST appropriate solution?

A) Enable Security Defaults in Microsoft Entra ID  
B) Create a Conditional Access policy with a location condition targeting named locations  
C) Enable per-user MFA for all Global Administrators  
D) Configure Azure AD Connect to enforce MFA on-premises  

---

**Q2.** You need to implement just-in-time privileged access for users who occasionally need the Global Administrator role. The solution must require approval before the role is activated and must limit activation to a maximum of 4 hours. What should you configure?

A) Azure RBAC with time-limited role assignments  
B) Privileged Identity Management (PIM) with approval workflow  
C) Conditional Access with session controls  
D) Azure AD Connect with password hash synchronization  

---

**Q3.** A developer needs to allow their Azure App Service to read secrets from Azure Key Vault without storing credentials in the application code. What is the MOST secure solution?

A) Create a service principal with a client secret and store it in application settings  
B) Enable a system-assigned managed identity on the App Service and grant it Key Vault Secrets User role  
C) Use a shared access signature for Key Vault  
D) Store the Key Vault access key in Azure Key Vault  

---

**Q4.** You have an on-premises Active Directory. You want to synchronize user accounts to Microsoft Entra ID while ensuring that user authentication occurs on-premises. The solution should NOT synchronize password hashes to the cloud. Which authentication method should you use?

A) Password Hash Synchronization (PHS)  
B) Pass-Through Authentication (PTA)  
C) Active Directory Federation Services (AD FS) Federation  
D) Azure AD B2C  

---

**Q5.** A user reports they cannot sign in to Azure from a country where your company does not operate. You suspect a compromised account. Which Entra ID feature automatically detected this anomalous sign-in?

A) Azure Sentinel  
B) Conditional Access Named Locations  
C) Microsoft Entra ID Identity Protection  
D) Microsoft Defender for Cloud  

---

**Q6.** You need to grant a team of developers access to a specific resource group in Azure. They should be able to create and manage resources but should NOT be able to assign roles to other users. Which built-in role should you assign?

A) Owner  
B) Contributor  
C) Reader  
D) User Access Administrator  

---

**Q7.** Your organization invites external partners as guest users. You want to restrict what guest users can see and do in your Entra ID directory. You need to ensure guests CANNOT enumerate the full list of directory users. Which setting controls this?

A) External collaboration settings — Guest user access restrictions  
B) Conditional Access policy with guest user condition  
C) PIM eligible assignments for guest users  
D) Azure AD B2C tenant configuration  

---

**Q8.** You need to implement Self-Service Password Reset (SSPR) for all users. SSPR must be enabled, and users must register using at least two authentication methods. Which license is the MINIMUM required?

A) Microsoft Entra ID Free  
B) Microsoft Entra ID P1  
C) Microsoft Entra ID P2  
D) Microsoft 365 E3  

---

**Q9.** An application registration in Microsoft Entra ID has been granted the `User.Read.All` application permission for Microsoft Graph. What additional step is required before the application can use this permission?

A) Grant admin consent  
B) Configure a Conditional Access policy for the application  
C) Assign the application a PIM eligible role  
D) Enable the managed identity for the app registration  

---

**Q10.** You need to configure Conditional Access to require MFA for all users signing in from unmanaged devices. However, you also want to test the policy impact BEFORE enforcing it. What configuration should you use?

A) Set the policy to "On" and monitor the Entra ID sign-in logs  
B) Set the policy to "Report-only" mode  
C) Create the policy but leave it "Off" and review named location logs  
D) Use Azure Policy to audit compliance  

---

**Q11.** You have configured PIM for the Security Administrator role with the following settings: activation requires MFA, maximum activation duration = 8 hours, approval is required. A user's manager is the designated approver. The user submits an activation request. The manager is on vacation and does not respond within 24 hours. What happens to the request?

A) The request is automatically approved after 24 hours  
B) The request expires with no approval; access is not granted  
C) The request escalates to the Global Administrator automatically  
D) The user can activate the role without approval after the timeout  

---

**Q12.** Your company recently acquired another company and needs to give their users access to your Azure applications. The acquired company has its own Microsoft Entra ID tenant. Which feature should you use?

A) Azure AD B2C  
B) Azure AD B2B collaboration  
C) Entra ID Connect federation  
D) Guest user import from CSV  

---

**Q13.** You need to ensure that all new users in the organization register for MFA within 14 days of account creation. If they haven't registered, they should still be allowed to sign in but prompted to register. Which Entra ID feature provides this capability?

A) Conditional Access policy with MFA grant control  
B) Microsoft Entra ID Identity Protection — MFA registration policy  
C) Per-user MFA enforcement  
D) Security defaults  

---

**Q14.** Which of the following statements about Azure RBAC scope is CORRECT?

A) Role assignments at a child scope override role assignments at the parent scope  
B) Role assignments are inherited from parent scope to child scope  
C) A user can only have one role assignment per subscription  
D) RBAC roles defined in Entra ID automatically apply to Azure resources  

---

**Q15.** You need to allow a new vendor to access a SharePoint site for exactly 3 months with no IT intervention required to remove access. Which solution should you use?

A) B2B guest access with manual access removal  
B) Conditional Access policy with time-based restrictions  
C) Access packages in Entitlement Management with an expiration policy  
D) PIM eligible group membership with 90-day activation duration  

---

**Q16.** A user in your organization is flagged by Identity Protection as having leaked credentials. The user's account currently does NOT have a high user risk policy applied. What is the IMMEDIATE risk to your organization?

A) The user's password is expired and they cannot sign in  
B) The user's credentials may be used by an attacker to sign in  
C) The user account has been automatically disabled  
D) All the user's Azure resources have been deleted  

---

**Q17.** You need to create a custom RBAC role that can read all resources in a subscription but can only create and delete storage accounts. Which JSON properties should be set?

A) `Actions: ["*/read", "Microsoft.Storage/storageAccounts/*"]`  
B) `Actions: ["*/read"]` and `DataActions: ["Microsoft.Storage/storageAccounts/*"]`  
C) `Actions: ["*/read", "Microsoft.Storage/storageAccounts/write", "Microsoft.Storage/storageAccounts/delete"]`  
D) `Actions: ["*"]` with `NotActions: ["Microsoft.Storage/storageAccounts/read"]`  

---

**Q18.** What is the difference between a **system-assigned managed identity** and a **user-assigned managed identity**?

A) System-assigned uses Azure RBAC; user-assigned uses access policies  
B) System-assigned is tied to the resource lifecycle; user-assigned is a standalone resource  
C) System-assigned supports multiple resources; user-assigned supports only one  
D) User-assigned requires a client secret; system-assigned does not  

---

**Q19.** You configure a Conditional Access policy with the following settings:
- Users: All users
- Cloud apps: Azure portal
- Conditions: Sign-in risk = High
- Grant: Block access

A legitimate user is flagged as high-risk due to an unusual location and is blocked. The security team confirms it is not a compromise. Which action should the administrator take to immediately restore access for this user?

A) Delete and recreate the Conditional Access policy  
B) Dismiss the user's sign-in risk in Identity Protection  
C) Add the user to the Conditional Access policy exclusion list  
D) Change the policy grant to "Require MFA" instead of Block  

---

**Q20.** Which of the following requires an **Entra ID P2** license? (Choose all that apply)

A) Conditional Access policies  
B) Privileged Identity Management (PIM)  
C) Self-Service Password Reset (SSPR)  
D) Identity Protection  
E) Dynamic groups  

---

## ✅ Answers

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | B | Conditional Access with named location condition is the correct and most flexible approach. Security Defaults (A) cannot be customized. Per-user MFA (C) is a legacy approach. |
| 2 | B | PIM is specifically designed for JIT privileged access with approval workflows and time limits. |
| 3 | B | Managed identity eliminates credential management. Grant Key Vault Secrets User role for read access. |
| 4 | B | PTA forwards authentication to on-premises AD without syncing password hashes. |
| 5 | C | Identity Protection detects anomalous sign-ins such as atypical travel and unusual locations. |
| 6 | B | Contributor has full resource management permissions but cannot assign roles (Owner can). |
| 7 | A | External collaboration settings control guest user access restrictions within the directory. |
| 8 | B | SSPR requires Entra ID P1 as the minimum (or Microsoft 365 Business Premium). |
| 9 | A | Application permissions (`User.Read.All`) require admin consent before use. |
| 10 | B | Report-only mode evaluates the policy and logs what WOULD have happened without enforcing. |
| 11 | B | PIM requests expire if not approved within the configured time; no automatic approval. |
| 12 | B | B2B collaboration allows guests from external tenants to access your apps using their existing identity. |
| 13 | B | Identity Protection MFA registration policy prompts users to register within a configurable window. |
| 14 | B | RBAC permissions are inherited from parent to child scope (subscription → resource group → resource). |
| 15 | C | Access packages in Entitlement Management support automatic expiration without IT intervention. |
| 16 | B | Leaked credentials mean attackers have the user's password and can use it to sign in. |
| 17 | C | The Actions array needs both `*/read` for read and specific write/delete actions for storage. |
| 18 | B | System-assigned identity is deleted when the resource is deleted. User-assigned persists independently. |
| 19 | B | Dismissing the sign-in risk in Identity Protection removes the high risk status; Conditional Access re-evaluates. |
| 20 | B, D | PIM requires P2; Identity Protection requires P2. Conditional Access and SSPR require P1; dynamic groups require P1. |

---

[← Domain 1 Guide](../domains/01-identity-access/README.md) | [Full Mock Exam →](full-mock-exam.md)
