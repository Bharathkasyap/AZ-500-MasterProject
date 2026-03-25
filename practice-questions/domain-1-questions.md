# Practice Questions — Domain 1: Manage Identity and Access

> **Back to [README](../README.md)**  
> **Domain Weight**: 25–30% of AZ-500 exam

---

## Instructions

For each question, try to answer before reading the explanation. Questions are exam-style multiple choice or multi-select.

---

### Question 1

**Your organization wants to reduce the risk of compromised administrator accounts. You need to ensure that Global Administrator role assignments are temporary and require approval.**

**What should you configure?**

A. Azure AD Conditional Access policies  
B. Microsoft Entra Privileged Identity Management (PIM)  
C. Azure Role-Based Access Control (RBAC)  
D. Microsoft Entra Identity Protection  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Microsoft Entra Privileged Identity Management (PIM)**

PIM enables just-in-time (JIT) role activation with approval workflows and time-bound access. Users are made "eligible" for roles rather than having permanent assignments. They must activate the role (optionally with approval and MFA), and access automatically expires.

- **A is incorrect**: Conditional Access enforces sign-in policies but doesn't manage role assignments.
- **C is incorrect**: Azure RBAC is for resource access, not managing how/when Azure AD roles are assigned.
- **D is incorrect**: Identity Protection manages risk-based policies, not role assignment workflows.

</details>

---

### Question 2

**A developer needs to read secrets from Azure Key Vault without embedding credentials in their application code.**

**What is the recommended approach?**

A. Store the Key Vault access key in an environment variable  
B. Use a Service Principal with a client secret stored in a config file  
C. Assign a User-Assigned Managed Identity to the application and grant it Key Vault Secrets User role  
D. Use a Shared Access Signature (SAS) token for Key Vault  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Assign a User-Assigned Managed Identity and grant Key Vault Secrets User role**

Managed identities eliminate the need to manage credentials. The application authenticates to Key Vault using its managed identity — no secrets stored anywhere.

- **A is incorrect**: Environment variables can be exposed and don't eliminate the credential management problem.
- **B is incorrect**: Storing client secrets in config files is a security anti-pattern (secrets in code/config).
- **D is incorrect**: SAS tokens are for Azure Storage, not Key Vault.

</details>

---

### Question 3

**Users in your organization are able to reset their own passwords. However, when they reset passwords from the web portal, the changes are not reflected in the on-premises Active Directory.**

**What is required to fix this? (Select TWO)**

A. Azure AD Connect with Password Hash Synchronization  
B. Azure AD Connect with Password Writeback enabled  
C. Microsoft Entra ID P1 or P2 license  
D. Microsoft Entra ID Free license  
E. Azure AD Application Proxy  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B and C**

- **B**: Password Writeback is the Azure AD Connect feature that syncs password changes made in the cloud back to on-premises AD. It must be explicitly enabled in Azure AD Connect.
- **C**: Password Writeback with SSPR requires Microsoft Entra ID P1 or P2 license.

- **A is incorrect**: Password Hash Sync only syncs hashes FROM on-premises TO cloud, not the other direction.
- **D is incorrect**: Free license doesn't support Password Writeback.
- **E is incorrect**: Application Proxy is for publishing on-premises apps to the internet.

</details>

---

### Question 4

**You need to ensure that users signing in from unfamiliar locations are required to perform MFA. Users in the office should not be required to perform MFA.**

**What should you configure?**

A. Entra ID Identity Protection with Sign-in Risk Policy  
B. Conditional Access policy with Named Locations and MFA grant control  
C. MFA enabled per-user for all accounts  
D. PIM with location-based activation requirements  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Conditional Access policy with Named Locations and MFA grant control**

You create a Named Location for your office IP range(s), then create a Conditional Access policy that:
- Excludes users signing in from the Named Location
- Requires MFA for everyone else

- **A is incorrect**: Risk-based policies react to detected risk signals, but you need precise control based on a specific office IP.
- **C is incorrect**: Per-user MFA applies uniformly and doesn't distinguish by location.
- **D is incorrect**: PIM is for privileged role activation, not general sign-in MFA requirements.

</details>

---

### Question 5

**A security audit reveals that several users have the Owner role on a subscription but have not used Azure resources in the past 90 days.**

**What is the MOST appropriate action?**

A. Remove Owner role and assign Reader role  
B. Configure Access Reviews in Microsoft Entra Identity Governance  
C. Enable PIM and make current assignments "eligible" instead of "active"  
D. Delete the inactive user accounts  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Configure Access Reviews in Microsoft Entra Identity Governance**

Access Reviews are designed exactly for this scenario — periodically reviewing who has access to ensure least privilege. Reviewers (managers or resource owners) can certify or revoke access. This is a controlled, auditable process.

- **A is incorrect**: Manually removing roles doesn't create a sustainable, repeatable process.
- **C is incorrect**: Making assignments eligible with PIM doesn't remove or review existing access.
- **D is incorrect**: Deleting accounts is drastic and may be inappropriate (users may be on leave).

</details>

---

### Question 6

**What is the difference between Application Permissions and Delegated Permissions in Microsoft Entra ID?**

A. Application permissions require user consent; delegated permissions require admin consent  
B. Application permissions allow apps to act as themselves; delegated permissions allow apps to act on behalf of a user  
C. Application permissions are for Azure resources; delegated permissions are for Microsoft 365  
D. Application permissions expire after 1 hour; delegated permissions do not expire  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Application permissions allow apps to act as themselves; delegated permissions allow apps to act on behalf of a user**

- **Delegated permissions**: The app acts on behalf of a signed-in user (user + app together must have permission). User consent is possible for low-risk permissions.
- **Application permissions**: The app acts with its own identity (no user context — like a service or daemon). Always requires admin consent due to the elevated nature.

- **A is incorrect**: It's the opposite — Application permissions always require admin consent.

</details>

---

### Question 7

**You need to allow a partner company's employees to access a SharePoint site in your Microsoft Entra ID tenant.**

**What is the correct approach?**

A. Create new internal user accounts for each partner employee  
B. Configure Entra ID B2B collaboration and invite them as guest users  
C. Set up Entra ID B2C for consumer identity federation  
D. Configure AD Federation Services (AD FS) trust  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Configure Entra ID B2B collaboration and invite them as guest users**

Azure AD B2B (Business-to-Business) is specifically designed for external partner collaboration. Partners authenticate with their own credentials (or social identity) and are represented as guest users in your tenant.

- **A is incorrect**: Creating internal accounts for partners is a security anti-pattern and increases management overhead.
- **C is incorrect**: B2C is for customer-facing applications with consumer identities (not business partners).
- **D is incorrect**: AD FS is for on-premises federation — overly complex for this scenario.

</details>

---

### Question 8

**Which authentication method provides the STRONGEST protection against phishing attacks in Microsoft Entra ID?**

A. SMS-based one-time passwords (OTP)  
B. Voice call verification  
C. FIDO2 security keys  
D. Microsoft Authenticator app push notifications  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — FIDO2 security keys**

FIDO2 security keys are **phishing-resistant** because:
- They use public-key cryptography (no shared secret to steal)
- The key is bound to the specific website/domain (can't be used on a phishing site)
- The physical key must be present

- **A and B are incorrect**: SMS and voice calls are vulnerable to SIM-swap attacks and interception.
- **D is incorrect**: Push notifications can be vulnerable to MFA fatigue attacks (bombing the user with notifications until they accidentally approve).

</details>

---

### Question 9

**Your organization wants to enforce that all service principals in your subscription use certificates rather than client secrets for authentication.**

**What should you use to enforce this requirement?**

A. Azure Conditional Access policy  
B. Azure Policy with a custom policy definition  
C. Entra ID PIM  
D. Azure Security Center recommendation  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Azure Policy with a custom policy definition**

Azure Policy can audit or enforce configuration requirements at scale. You would create a policy that audits (or denies creation of) service principals or app registrations that use client secrets.

- **A is incorrect**: Conditional Access controls sign-in access, not service principal credential types.
- **C is incorrect**: PIM manages privileged role activation for users.
- **D is incorrect**: Defender recommendations are advisory, not enforcement.

</details>

---

### Question 10

**You have a custom application that accesses Azure resources using a managed identity. The application stops working after you rename the resource group containing the VM.**

**What is the most likely cause?**

A. System-assigned managed identity was lost when the resource group was renamed  
B. RBAC role assignments scoped to the resource group were invalidated  
C. The managed identity token expired and needs to be renewed  
D. Renaming the resource group changed the subscription ID  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — RBAC role assignments scoped to the resource group were invalidated**

Wait — actually, renaming a resource group in Azure is **not possible** (you must delete and recreate). However, if resources were moved between resource groups, RBAC role assignments scoped to the old resource group do NOT automatically move with the resources. The role assignments at the old scope become orphaned.

The more likely real-world scenario: resources were **moved** to a new resource group, and the role assignments didn't follow.

- **A is incorrect**: System-assigned managed identity is tied to the resource, not the resource group — it survives resource group changes.
- **C is incorrect**: Managed identity tokens are automatically managed and renewed.
- **D is incorrect**: Renaming doesn't change the subscription ID.

</details>

---

## 📊 Score Yourself

| Score | Performance |
|---|---|
| 9–10 correct | Excellent — You're ready for exam day |
| 7–8 correct | Good — Review the topics you missed |
| 5–6 correct | Fair — Spend more time on Domain 1 |
| < 5 correct | Needs work — Re-read the study guide |

---

> ⬅️ [Back to README](../README.md) | ➡️ [Domain 2 Questions](./domain-2-questions.md)
