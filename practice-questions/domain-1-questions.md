# Domain 1 — Practice Questions: Manage Identity and Access

> **Instructions**: Choose the best answer(s) for each question. Answers and explanations are at the bottom of the file.

---

## Questions

### Q1
A company wants to allow users to authenticate to Azure AD without syncing password hashes to the cloud. What hybrid identity method should they use?

A) Password Hash Synchronization (PHS)  
B) Pass-Through Authentication (PTA)  
C) Azure AD Connect Cloud Sync  
D) OpenID Connect Federation

---

### Q2
An administrator needs to ensure that users can only access the Azure portal when connecting from the corporate network. Which Azure AD feature should be used?

A) Azure AD Identity Protection user risk policy  
B) Conditional Access policy with a named location condition  
C) Azure AD Multi-Factor Authentication per-user enforcement  
D) Azure AD B2B collaboration

---

### Q3
A user has the **Contributor** role on a subscription. They try to assign a **Reader** role to another user on a resource group. The operation fails. Why?

A) The Contributor role does not have permission to assign roles  
B) The resource group does not support RBAC role assignments  
C) The user needs the Reader role first to assign it  
D) Contributor does not include `Microsoft.Authorization/roleAssignments/write`

---

### Q4
A company requires that administrative role activations be time-limited and require approval. Which feature provides this?

A) Conditional Access  
B) Privileged Identity Management (PIM)  
C) Azure AD Identity Protection  
D) Azure AD Access Reviews

---

### Q5
Which of the following MFA methods is MOST resistant to phishing attacks?

A) SMS one-time password  
B) Voice call  
C) FIDO2 security key  
D) Email OTP

---

### Q6
A developer needs to allow an Azure Logic App to read secrets from Azure Key Vault without storing credentials in the app's code. What is the BEST approach?

A) Use a service principal with a client secret stored in an environment variable  
B) Store the Key Vault access key in Azure App Configuration  
C) Assign a system-assigned managed identity to the Logic App and grant it Key Vault Secrets User  
D) Use a shared access signature token for the Key Vault

---

### Q7
An organization's security team wants to review all users who have the Global Administrator role in Azure AD on a quarterly basis. Which tool should they use?

A) Azure AD Audit Logs  
B) Azure AD Identity Protection  
C) Azure AD Access Reviews  
D) Microsoft Defender for Cloud

---

### Q8
A user signs in from an IP address flagged as an anonymous proxy. Azure AD Identity Protection generates a sign-in risk of **High**. The sign-in risk policy is configured to require **MFA** for **Medium and above** risk. What happens?

A) The user is immediately blocked from signing in  
B) The user is prompted to complete MFA before accessing resources  
C) Nothing — risk policies only alert, they do not enforce controls  
D) The user is forced to reset their password

---

### Q9
Which Azure AD license is required to configure Conditional Access policies?

A) Azure AD Free  
B) Azure AD Premium P1  
C) Azure AD Premium P2  
D) Microsoft 365 Business Basic

---

### Q10
A company has an Azure AD tenant and wants to allow customers to sign up and sign in to a mobile app using their social media accounts (Google, Facebook). Which Azure service should be used?

A) Azure AD B2B  
B) Azure AD External Identities  
C) Azure AD B2C  
D) Azure AD Domain Services

---

### Q11 (Multi-select)
Which TWO of the following are valid ways to secure an application's access to Azure resources without using passwords? *(Select 2)*

A) Store credentials in Azure Key Vault and retrieve them at runtime  
B) Use a system-assigned managed identity  
C) Use a user-assigned managed identity  
D) Store credentials in source code with GitHub secret scanning enabled  
E) Use a Conditional Access named location

---

### Q12
An admin creates a custom RBAC role that includes `Microsoft.Compute/virtualMachines/*` in Actions. A security reviewer flags this as too permissive and asks the admin to restrict it so users can start and stop VMs but NOT delete them. Which change should be made?

A) Add `Microsoft.Compute/virtualMachines/delete` to **NotActions**  
B) Remove `Microsoft.Compute/virtualMachines/*` and add only `start` and `restart` actions  
C) Change the scope to a resource group level  
D) Add a Deny assignment at the subscription level

---

### Q13
A company is deploying applications in Azure and requires all app-to-service communications to use certificates instead of client secrets. Where should the certificates be stored?

A) In the application's configuration file  
B) In an Azure Blob Storage container  
C) In Azure Key Vault  
D) In an Azure App Configuration store

---

### Q14
An Azure AD tenant has **Security Defaults** enabled. Which of the following statements is TRUE?

A) Security Defaults allow custom Conditional Access policies to be configured  
B) Security Defaults require MFA for all users using Microsoft Authenticator or TOTP  
C) Security Defaults can coexist with Conditional Access policies  
D) Security Defaults are available only with Azure AD Premium P2

---

### Q15
An employee leaves the company. The IT team disables their Azure AD account. However, the employee had a **permanent active** assignment for the **Owner** role in PIM. What is the risk?

A) No risk — disabling the account prevents all Azure access  
B) The employee can still access Azure resources because PIM permanent active assignments bypass account disabled status  
C) The assignment must be manually removed because disabling the account does not automatically remove Azure RBAC assignments  
D) PIM automatically removes assignments when an account is disabled

---

## Answers and Explanations

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | **B** | PTA validates credentials against on-premises AD without syncing password hashes. PHS syncs password hashes to the cloud. |
| 2 | **B** | Conditional Access with a Named Location condition allows or blocks access based on IP ranges. Identity Protection policies (A) are risk-based, not location-based. |
| 3 | **A / D** | Both A and D express the same thing: the Contributor role does not include `Microsoft.Authorization/roleAssignments/write`, which is required to assign roles. Only **Owner** and **User Access Administrator** can assign roles. |
| 4 | **B** | PIM provides JIT role activation with time limits, MFA requirements, and approval workflows for both Azure AD and Azure resource roles. |
| 5 | **C** | FIDO2 security keys are phishing-resistant because they bind the authentication to the origin URL; a phishing site cannot receive the credential. SMS and voice are vulnerable to SIM-swapping. |
| 6 | **C** | Managed identities eliminate the need to store credentials. The Logic App's identity is granted the Key Vault Secrets User RBAC role, allowing it to retrieve secrets using its Azure AD token. |
| 7 | **C** | Access Reviews enable periodic, structured reviews of role memberships. Audit Logs (A) provide a history but not a structured review process. |
| 8 | **B** | The sign-in risk is High, which is above the Medium threshold. The policy enforces MFA. The user will be challenged for MFA. They are not blocked (D would apply to a User Risk policy set to Block at High). |
| 9 | **B** | Conditional Access requires Azure AD Premium P1 (or P2 for risk-based conditions). Free tier does not include Conditional Access. |
| 10 | **C** | Azure AD B2C is a customer identity platform that supports social identity providers (Google, Facebook, Apple). B2B is for partner/employee external collaboration. |
| 11 | **B, C** | Both system-assigned and user-assigned managed identities allow Azure services to authenticate without passwords. Storing credentials in Key Vault (A) is better than hardcoding but still uses credentials. |
| 12 | **A** | Adding `Microsoft.Compute/virtualMachines/delete` to **NotActions** excludes it from the wildcard. This is the most surgical change. |
| 13 | **C** | Azure Key Vault is the designated secure store for certificates, keys, and secrets in Azure. |
| 14 | **B** | Security Defaults enforce MFA registration for all users and block legacy authentication. They are free. However, once you create any Conditional Access policy, you must disable Security Defaults (C is FALSE). |
| 15 | **C** | Disabling an Azure AD account prevents login, but RBAC role assignments are not automatically removed. The assignment persists and must be manually revoked. Best practice: immediately remove all role assignments when offboarding users. |
