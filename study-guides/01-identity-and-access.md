# Domain 1: Manage Identity and Access (25–30%)

← [Back to README](../README.md)

---

## Table of Contents

1. [Microsoft Entra ID (Azure Active Directory)](#1-microsoft-entra-id)
2. [Authentication Methods](#2-authentication-methods)
3. [Conditional Access](#3-conditional-access)
4. [Privileged Identity Management (PIM)](#4-privileged-identity-management-pim)
5. [Microsoft Entra Identity Protection](#5-microsoft-entra-identity-protection)
6. [Managed Identities](#6-managed-identities)
7. [Service Principals & App Registrations](#7-service-principals--app-registrations)
8. [Azure Role-Based Access Control (RBAC)](#8-azure-role-based-access-control-rbac)
9. [Microsoft Entra External Identities (B2B/B2C)](#9-microsoft-entra-external-identities-b2bb2c)
10. [Key Exam Facts & Practice Questions](#10-key-exam-facts--practice-questions)

---

## 1. Microsoft Entra ID

**Microsoft Entra ID** (formerly Azure Active Directory / Azure AD) is Microsoft's cloud-based identity and access management service. It is the backbone of authentication and authorization in Azure.

### Editions

| Edition | Key Features |
|---------|-------------|
| **Free** | User/group management, SSO for 10 apps, basic security reports |
| **P1** | Conditional Access, self-service password reset (SSPR), hybrid environments |
| **P2** | All P1 features + Identity Protection + Privileged Identity Management (PIM) |
| **Governance** | Entitlement management, access reviews, lifecycle workflows |

> **Exam Tip:** PIM and Identity Protection require **Entra ID P2**. Conditional Access requires **P1 or P2**.

### Tenant Concepts

- **Tenant**: A dedicated instance of Entra ID. One organization = one tenant (usually).
- **Directory**: Synonymous with tenant; contains users, groups, devices, and applications.
- **Subscription**: Linked to one tenant; a tenant can have multiple subscriptions.
- **Management Groups**: Containers for subscriptions; policies and RBAC applied here cascade down.

### Users and Groups

- **Member users**: Standard users in the tenant.
- **Guest users**: External users invited via B2B (collaboration). Permissions are restricted.
- **Security groups**: Used for RBAC assignments and Conditional Access targeting.
- **Microsoft 365 groups**: Used for collaboration (Teams, SharePoint); also support RBAC.
- **Dynamic groups**: Membership auto-maintained via rules (requires P1/P2).

```
# Create a user via Azure CLI
az ad user create \
  --display-name "Alice Smith" \
  --user-principal-name alice@contoso.onmicrosoft.com \
  --password "SecureP@ssw0rd!" \
  --force-change-password-next-sign-in true
```

---

## 2. Authentication Methods

### Multi-Factor Authentication (MFA)

MFA requires at least **two verification factors**:
1. Something you **know** (password)
2. Something you **have** (phone, hardware token)
3. Something you **are** (biometric)

**Supported MFA methods:**
- Microsoft Authenticator app (push notification, passwordless)
- OATH hardware/software tokens (TOTP)
- SMS/Voice call (legacy — less secure)
- Windows Hello for Business
- FIDO2 security keys

**MFA Enforcement options:**
| Option | Description |
|--------|-------------|
| **Per-user MFA** | Legacy; enable MFA for individual users (not recommended for new deployments) |
| **Conditional Access** | Modern approach; require MFA based on conditions (location, device, risk) |
| **Security Defaults** | Free tier; enforces MFA for admins, blocks legacy auth (recommended for small orgs) |

> **Exam Tip:** Security Defaults and Conditional Access policies are **mutually exclusive** — you cannot use both simultaneously.

### Password Protection

- **Azure AD Password Protection**: Blocks commonly used passwords and custom banned passwords.
- Can be deployed to **on-premises Active Directory** via proxy agent.
- **Smart Lockout**: Locks accounts after failed sign-in attempts; cloud lockouts sync to on-prem.

### Self-Service Password Reset (SSPR)

- Allows users to reset their own passwords without admin intervention.
- Requires **P1 license** for hybrid environments.
- Supports: mobile app, email, phone, security questions (not recommended).

### Passwordless Authentication

| Method | Description |
|--------|-------------|
| **Windows Hello for Business** | PIN + biometric; uses certificate/key pair |
| **FIDO2 Security Keys** | Hardware key (e.g., YubiKey); phishing-resistant |
| **Microsoft Authenticator** | App-based sign-in with biometric confirmation |

### Legacy Authentication

Legacy authentication protocols (IMAP, POP3, SMTP AUTH, older Office clients) **do not support MFA** and must be blocked via Conditional Access.

```
# Conditional Access policy to block legacy auth
# Sign-in condition: Client Apps = "Exchange ActiveSync clients" + "Other clients"
# Grant: Block access
```

---

## 3. Conditional Access

Conditional Access is an **if-then** policy engine: *if* a set of conditions is met, *then* enforce controls.

### Signal → Decision → Enforcement

```
Signal (conditions):          Decision:        Enforcement:
- User/Group                  Allow            - Require MFA
- Cloud App                   Block            - Require compliant device
- Device Platform             Allow with MFA   - Require managed device
- Location (IP/Country)                        - Require password change
- Client App                                   - Restrict session
- Sign-in risk
- User risk
```

### Named Locations

- **IP-based**: Define trusted IP ranges (office IPs) — used to relax policies.
- **Country/Region-based**: Block or require MFA from specific countries.

### Device Compliance

- **Microsoft Intune** marks devices as compliant/non-compliant.
- Conditional Access can require a **compliant device** or **Hybrid Azure AD Joined** device.

### Common Conditional Access Policy Patterns

| Scenario | Configuration |
|----------|--------------|
| Require MFA for all admins | Users: All admin roles; Grant: Require MFA |
| Block legacy authentication | Client apps: Exchange ActiveSync + Other; Grant: Block |
| Require MFA from untrusted locations | Location: Exclude trusted IPs; Grant: Require MFA |
| Require compliant device for sensitive apps | Apps: Target app; Grant: Require compliant device |
| Sign-in risk-based MFA | Sign-in risk: Medium/High; Grant: Require MFA |

> **Exam Tip:** When multiple CA policies match, **all** apply simultaneously. Grant controls use **OR** logic (one satisfied = access granted). Session controls apply additively.

### Conditional Access — What's in Scope / Out of Scope

- ✅ **In scope**: Azure portal, Microsoft 365, any app registered in Entra ID
- ❌ **Not covered**: On-premises apps (without App Proxy), external services not integrated with Entra ID

---

## 4. Privileged Identity Management (PIM)

PIM provides **just-in-time (JIT)** privileged access and audit trail for high-privilege roles. It requires **Entra ID P2**.

### PIM Key Concepts

| Concept | Description |
|---------|-------------|
| **Eligible assignment** | User is eligible to activate a role (not yet active) |
| **Active assignment** | Role is currently active (permanent or time-bound) |
| **Activation** | User elevates themselves (may require MFA, justification, approval) |
| **Access reviews** | Periodic reviews to certify who needs privileged access |

### PIM Workflow

```
Administrator configures role settings:
  ├── Maximum activation duration (e.g., 8 hours)
  ├── Require MFA on activation
  ├── Require justification
  └── Require approval

User activates role:
  ├── Selects duration
  ├── Provides justification
  └── (If required) Waits for approver

PIM sends notification/alert
Role is active for specified duration → Auto-deactivated
```

### PIM Scope

PIM manages:
- **Entra ID roles** (Global Administrator, Security Administrator, etc.)
- **Azure resource roles** (Owner, Contributor, User Access Administrator per subscription/resource group)

### PIM Alerts

PIM can generate alerts for:
- Roles without MFA enabled on activation
- Administrators who haven't activated their roles recently
- Permanent assignments for roles that should be eligible-only
- Too many Global Administrators

### Access Reviews

- Created by admins or PIM
- Reviewers: self, manager, specific reviewer, or program owner
- On expiry: Remove access / Keep access / Require manual decision

```
# PowerShell — View PIM role assignments
Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -ResourceId "<tenant-id>"
```

---

## 5. Microsoft Entra Identity Protection

Identity Protection uses Microsoft's threat intelligence to **detect, investigate, and remediate** identity-based risks. Requires **Entra ID P2**.

### Risk Types

| Risk | Description | Examples |
|------|-------------|---------|
| **Sign-in risk** | Likelihood a given sign-in was not performed by the user | Atypical travel, anonymous IP, unfamiliar sign-in properties, malware-linked IP |
| **User risk** | Likelihood a user's account has been compromised | Leaked credentials, anomalous activity |

### Risk Levels

- **Low, Medium, High** — determined by Microsoft's ML models
- **Real-time** vs **Offline** detection (offline may take hours)

### Risk-Based Policies

| Policy | Trigger | Recommended Response |
|--------|---------|---------------------|
| **Sign-in risk policy** | Sign-in risk ≥ Medium | Require MFA |
| **User risk policy** | User risk ≥ High | Require password change |
| **MFA registration policy** | New user | Require MFA registration |

> **Best Practice:** Integrate risk policies with **Conditional Access** (modern approach) rather than the legacy Identity Protection policies.

### Investigating Risky Users

In the Entra portal: **Protection > Identity Protection > Risky users**

Actions available:
- **Confirm compromised**: Marks user risk as High; triggers risk-based policy
- **Dismiss user risk**: Closes the risk (when false positive confirmed)
- **Block user**: Blocks sign-ins immediately

---

## 6. Managed Identities

Managed Identities eliminate the need to store credentials in code or configuration. Azure manages the lifecycle of the identity.

### Types

| Type | Description |
|------|-------------|
| **System-assigned** | Created with and tied to a specific Azure resource; deleted when resource is deleted |
| **User-assigned** | Created independently; can be assigned to multiple resources; lifecycle managed separately |

### How It Works

1. Azure resource (VM, App Service, Function, etc.) gets a managed identity
2. Managed identity is registered in Entra ID as a **service principal**
3. Resource can request a token from the **Azure Instance Metadata Service (IMDS)** endpoint
4. Token is used to authenticate to Azure services (Key Vault, Storage, SQL, etc.)

```bash
# Get access token from inside a VM (system-assigned MI)
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net' \
  -H "Metadata: true"
```

```bash
# Assign a role to a managed identity via Azure CLI
az role assignment create \
  --assignee "<managed-identity-object-id>" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>"
```

### Supported Azure Services

Managed identities can authenticate to any service that supports **Azure AD/Entra ID authentication**, including:
- Azure Key Vault
- Azure Storage (Blob, Queue)
- Azure SQL Database
- Azure Service Bus
- Azure Event Hubs
- Azure Container Registry
- Azure Resource Manager

---

## 7. Service Principals & App Registrations

### App Registration vs Service Principal

| Concept | Description |
|---------|-------------|
| **App Registration** | The global definition of an application in Entra ID (home tenant) |
| **Service Principal (Enterprise App)** | The local instance of the application in a specific tenant |
| **Managed Identity** | A special type of service principal; lifecycle managed by Azure |

### App Registration Components

- **Application (Client) ID**: Unique GUID identifying the app globally
- **Directory (Tenant) ID**: The tenant this app is registered in
- **Client Secret / Certificate**: Credential used by the app to authenticate
- **Redirect URIs**: Where auth codes/tokens are returned after sign-in
- **API Permissions**: What resources/APIs this app can access (delegated vs application)
- **Expose an API (Scopes)**: If this app itself is an API, define scopes for other apps

### Permission Types

| Type | Description | Who consents? |
|------|-------------|---------------|
| **Delegated** | App acts on behalf of the signed-in user | User (or admin) |
| **Application** | App acts as itself (no user context, e.g., background service) | Admin only |

> **Exam Tip:** Application permissions always require **admin consent**. Delegated permissions may or may not require admin consent depending on the scope.

### Certificate vs Secret

- **Client secrets**: Simple strings; expire (max 2 years in Entra ID); easier to set up but riskier.
- **Certificates**: More secure; private key stays in customer control; recommended for production.

---

## 8. Azure Role-Based Access Control (RBAC)

Azure RBAC controls **what** operations users/principals can perform on Azure **resources**.

### RBAC Components

| Component | Description |
|-----------|-------------|
| **Security principal** | Who: user, group, service principal, managed identity |
| **Role definition** | What: set of permissions (Actions, NotActions, DataActions, NotDataActions) |
| **Scope** | Where: management group, subscription, resource group, or resource |
| **Role assignment** | Combination of security principal + role definition + scope |

### Built-In Roles (Key Ones for AZ-500)

| Role | Key Permissions |
|------|----------------|
| **Owner** | Full access including delegation (can assign roles) |
| **Contributor** | Create/manage resources; cannot assign roles or manage access |
| **Reader** | View resources; no modifications |
| **User Access Administrator** | Manage access (role assignments); no resource management |
| **Security Admin** | View security policies; update security policies; dismiss alerts |
| **Security Reader** | View security policies and alerts; read-only |
| **Key Vault Administrator** | Full Key Vault management including data plane |
| **Key Vault Secrets User** | Read secret values |
| **Network Contributor** | Manage networking resources |

### Custom Roles

Custom roles can be created at management group, subscription, or resource group scope.

```json
{
  "Name": "Custom VM Operator",
  "Description": "Can start and stop VMs",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/<subscription-id>"
  ]
}
```

### RBAC vs Entra ID Roles

| Azure RBAC | Entra ID Roles |
|-----------|----------------|
| Controls Azure **resource** access | Controls Entra ID **tenant** access |
| Assigned at management group/subscription/RG/resource | Assigned at tenant scope (some support AU scope) |
| Examples: Owner, Contributor, Reader | Examples: Global Admin, Security Admin, User Admin |

> **Exam Tip:** Azure RBAC and Entra ID roles are **separate systems**. Being Global Administrator does NOT give you Azure resource permissions by default (though Global Admins can elevate themselves via Tenant Properties).

### Deny Assignments

- Deny assignments **block** specific actions even if a role assignment grants them.
- Created automatically by Azure Blueprints and Managed Applications.
- Admins **cannot create** deny assignments directly (only via Blueprints).

---

## 9. Microsoft Entra External Identities (B2B/B2C)

### B2B (Business-to-Business)

**Purpose**: Collaborate with external partners, vendors, and contractors.

- External users are invited as **guest users** (UserType = Guest).
- They authenticate with their **own identity provider** (their org's Entra ID, Google, Microsoft account, etc.).
- Access controlled by the **inviting tenant's** policies.
- Guest users have **reduced default permissions** compared to members.

**Cross-tenant access settings:**
- **Inbound** (other tenants → your tenant): Control which external users can access your resources
- **Outbound** (your users → other tenants): Control where your users can go

### B2C (Business-to-Consumer)

**Purpose**: Customer-facing applications; allow customers to sign in with social/local identities.

- Separate **B2C tenant** (different from the organization's work tenant)
- Supports: local accounts (email/password), social providers (Google, Facebook, Apple)
- **User flows** (built-in policies): Sign-up/sign-in, password reset, profile editing
- **Custom policies** (Identity Experience Framework): Full control using XML policies

---

## 10. Key Exam Facts & Practice Questions

### Must-Know Facts

1. **PIM requires Entra ID P2** (not P1, not Free)
2. **Security Defaults** and **Conditional Access policies** cannot coexist — pick one
3. **Managed Identity** eliminates the need to manage credentials; system-assigned is tied to the resource lifecycle
4. **User risk** refers to the likelihood a user's credentials are compromised; **sign-in risk** refers to a specific sign-in being anomalous
5. **RBAC deny assignments** cannot be created by admins directly; only via Azure Blueprints
6. **Application permissions** always require admin consent; delegated permissions may not
7. **Guest users** (B2B) authenticate with their **home tenant**, not the inviting tenant
8. **Owner** role can assign roles; **Contributor** cannot
9. Conditional Access uses **OR** logic for Grant controls — satisfying one grant is sufficient
10. **SSPR** (Self-Service Password Reset) in hybrid environments requires **P1 license**

### Practice Questions

**Q1.** Your organization wants to require MFA only when users sign in from outside the corporate network. The simplest approach that scales to all users is:
- A) Enable per-user MFA for all accounts
- B) Create a Conditional Access policy with a named location exclusion
- C) Enable Security Defaults
- D) Configure Identity Protection sign-in risk policy

<details><summary>Answer</summary>
**B** — Conditional Access with a Named Location (trusted IPs) excluded. Per-user MFA (A) doesn't allow location-based exceptions easily. Security Defaults (C) requires MFA regardless of location. Identity Protection (D) triggers on risk, not location.
</details>

---

**Q2.** A developer needs their Azure Function to read secrets from Azure Key Vault without storing credentials in application settings. What is the recommended solution?

- A) Create a service principal and store the client secret in app settings
- B) Enable a system-assigned managed identity on the Function App and grant it Key Vault Secrets User role
- C) Use a shared access signature (SAS) token
- D) Store the Key Vault access key in Azure App Configuration

<details><summary>Answer</summary>
**B** — System-assigned managed identity with Key Vault Secrets User role. This eliminates stored credentials. Option A still stores a secret. SAS tokens (C) are for Storage, not Key Vault. App Configuration (D) still requires credentials to access.
</details>

---

**Q3.** Which Entra ID P2 feature allows you to assign users as *eligible* for a role rather than permanently active, requiring them to activate the role when needed?

- A) Conditional Access
- B) Identity Protection
- C) Privileged Identity Management (PIM)
- D) Access Reviews

<details><summary>Answer</summary>
**C** — PIM provides just-in-time privileged access with eligible assignments.
</details>

---

**Q4.** A user's account shows a "High" user risk in Identity Protection. The user risk policy is set to require password change for High risk. The user tries to sign in but says they cannot complete the password change. What is the most likely cause?

- A) The user's account has been deleted
- B) The user has not registered for SSPR
- C) The Conditional Access policy is blocking the password change
- D) The user does not have an Entra ID P2 license

<details><summary>Answer</summary>
**B** — If the user hasn't registered for SSPR (Self-Service Password Reset), they won't be able to complete the password change flow triggered by the user risk policy. An admin would need to manually reset the password.
</details>

---

**Q5.** Your company has three Azure subscriptions. You want to apply a single RBAC role assignment that gives a security team read access to resources in all three subscriptions. What is the most efficient approach?

- A) Create three role assignments, one per subscription
- B) Place all subscriptions under a Management Group and assign the Reader role at the management group scope
- C) Use Azure Policy to assign Reader permissions
- D) Create a custom role with read access to all three subscription IDs

<details><summary>Answer</summary>
**B** — RBAC assignments at a Management Group scope **inherit** to all subscriptions, resource groups, and resources below. This is the most efficient approach.
</details>

---

← [Back to README](../README.md) | [Next: Domain 2 — Secure Networking →](./02-secure-networking.md)
