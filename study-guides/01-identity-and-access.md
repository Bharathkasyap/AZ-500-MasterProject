# Domain 1: Manage Identity and Access (25–30%)

> **Exam Weight:** 25–30% — This is one of the two heaviest domains. Expect 10–18 questions.

---

## Table of Contents

1. [Microsoft Entra ID (Azure Active Directory)](#1-microsoft-entra-id-azure-active-directory)
2. [Authentication Methods](#2-authentication-methods)
3. [Conditional Access](#3-conditional-access)
4. [Azure AD Privileged Identity Management (PIM)](#4-azure-ad-privileged-identity-management-pim)
5. [Azure Role-Based Access Control (RBAC)](#5-azure-role-based-access-control-rbac)
6. [Managed Identities](#6-managed-identities)
7. [Azure AD B2B and B2C](#7-azure-ad-b2b-and-b2c)
8. [Identity Protection](#8-identity-protection)
9. [Key Exam Topics Checklist](#9-key-exam-topics-checklist)

---

## 1. Microsoft Entra ID (Azure Active Directory)

### What It Is
Microsoft Entra ID (formerly Azure Active Directory) is Microsoft's cloud-based identity and access management service. It provides authentication and authorization for Azure resources, Microsoft 365, and thousands of SaaS applications.

### Core Concepts

| Concept | Description |
|---|---|
| **Tenant** | A dedicated instance of Entra ID for an organization |
| **Directory** | Stores users, groups, devices, and apps |
| **Subscription** | Linked to exactly one Entra ID tenant |
| **Domain** | Default: `<tenantname>.onmicrosoft.com`; custom domains can be added |

### Entra ID Tiers

| Tier | Key Features |
|---|---|
| **Free** | User/group management, SSO (up to 10 apps), basic MFA |
| **P1** | Conditional Access, self-service password reset, hybrid identity |
| **P2** | Identity Protection, Privileged Identity Management (PIM) |

### User Types

- **Member users** — Belong to the organization's tenant
- **Guest users (B2B)** — External users invited to collaborate
- **Service principals** — Application identities in the directory

### Groups

| Type | Description |
|---|---|
| **Security groups** | Control access to Azure resources |
| **Microsoft 365 groups** | Collaborate with shared mailbox, calendar, etc. |
| **Dynamic groups** | Membership auto-assigned based on user attributes (requires P1) |

---

## 2. Authentication Methods

### Multi-Factor Authentication (MFA)

MFA requires users to verify their identity using two or more factors:
- **Something you know** — Password, PIN
- **Something you have** — Authenticator app, hardware token, SMS
- **Something you are** — Biometrics (fingerprint, face)

**MFA Methods (strongest → weakest):**
1. FIDO2 security keys (most secure, phishing-resistant)
2. Microsoft Authenticator (passwordless)
3. OATH hardware tokens
4. OATH software tokens
5. SMS and voice calls (weakest — avoid where possible)

### Passwordless Authentication

| Method | How It Works |
|---|---|
| **Windows Hello for Business** | PIN/biometric tied to a specific device |
| **Microsoft Authenticator** | App-based approval with biometric |
| **FIDO2 Keys** | Physical hardware key (YubiKey, etc.) |

### Self-Service Password Reset (SSPR)

- Requires Entra ID P1 or P2
- Users can reset passwords without calling IT help desk
- Supports phone, email, security questions, authenticator app
- **Write-back to on-premises AD** requires Azure AD Connect + Entra ID P1

### Azure AD Connect

Synchronizes on-premises Active Directory identities to Entra ID.

| Sync Mode | Description |
|---|---|
| **Password Hash Sync (PHS)** | Hash of user password synced to cloud (simplest, recommended) |
| **Pass-Through Authentication (PTA)** | Authentication validated on-premises in real-time |
| **Federation (AD FS)** | Authentication redirected to on-premises AD FS server |

> **Exam tip:** PHS is the most resilient — cloud auth still works if on-prem connectivity is lost.

---

## 3. Conditional Access

### What It Is
Conditional Access is the policy engine of Entra ID. It enforces access decisions based on **signals** such as user, location, device, and risk.

### Conditional Access Policy Structure

```
IF (conditions are met)
THEN (apply access controls)
```

**Conditions (signals):**
- User / Group membership
- Cloud app or action
- Sign-in risk level (requires P2)
- User risk level (requires P2)
- Device platform (iOS, Android, Windows)
- Location (named locations, IP ranges, countries)
- Client apps (browser, mobile apps, Exchange ActiveSync)

**Access Controls:**
- **Grant** — Allow access with requirements (MFA, compliant device, hybrid Azure AD join, approved app)
- **Block** — Deny access completely
- **Session** — Limit what users can do within the session

### Common Conditional Access Policies

| Scenario | Policy |
|---|---|
| Require MFA for all admins | Users = Admin roles → Grant: Require MFA |
| Block legacy authentication | Client apps = Exchange ActiveSync, Other clients → Block |
| Require compliant device for corporate apps | Cloud apps = All cloud apps → Grant: Require compliant device |
| Block access from high-risk countries | Locations = Blocked countries → Block |

### Named Locations
- Define trusted IP ranges or countries
- Trusted locations can be excluded from MFA requirements
- Used to block access from specific geographies

### Conditional Access in Report-Only Mode
- Policies evaluate but **do not enforce** — safe way to test before enabling

> **Exam tip:** Conditional Access requires Entra ID P1. Risk-based Conditional Access requires P2.

---

## 4. Azure AD Privileged Identity Management (PIM)

### What It Is
PIM provides **just-in-time (JIT)** privileged access to Azure AD roles and Azure resources. It reduces the risk of standing admin access.

### PIM Key Concepts

| Concept | Description |
|---|---|
| **Eligible assignment** | User can activate the role when needed (not always active) |
| **Active assignment** | Role is always active for the user |
| **Activation** | Process of elevating from eligible to active (may require MFA, justification) |
| **Approval workflow** | Activations can require approval from designated approvers |
| **Maximum activation duration** | Configurable (e.g., 1–8 hours) |

### PIM Workflow

1. Assign user as **Eligible** for Global Administrator
2. User requests activation from PIM portal
3. User completes MFA and provides business justification
4. (Optional) Approver receives notification and approves
5. User has Global Admin access for the configured duration
6. Access expires automatically — no permanent privilege

### PIM Access Reviews
- Periodic review of who has privileged access
- Reviewers can confirm or revoke access
- Automated removal if no response
- Requires Entra ID P2

### Alerts in PIM
PIM generates alerts for suspicious privilege usage:
- Roles being activated too frequently
- Roles with permanent assignments
- Users not using MFA during activation

> **Exam tip:** PIM requires Entra ID P2. Know the difference between eligible and active assignments.

---

## 5. Azure Role-Based Access Control (RBAC)

### What It Is
Azure RBAC controls who can do what on which Azure resources. It uses role assignments to grant permissions.

### RBAC Components

| Component | Description |
|---|---|
| **Security Principal** | Who: User, group, service principal, or managed identity |
| **Role Definition** | What: A collection of permissions (actions, notActions, dataActions) |
| **Scope** | Where: Management group, subscription, resource group, or resource |

### Built-In Role Hierarchy

```
Management Group
    └── Subscription
            └── Resource Group
                    └── Resource
```

Permissions flow **down** — a role at the subscription level applies to all resource groups and resources within it.

### Common Built-In Roles

| Role | Description |
|---|---|
| **Owner** | Full access including ability to assign roles |
| **Contributor** | Full access except cannot assign roles or manage access |
| **Reader** | View-only access |
| **User Access Administrator** | Manage user access to Azure resources |
| **Security Admin** | View and update security policies; dismiss alerts |
| **Security Reader** | View security policies and alerts (read-only) |

### Custom Roles
When built-in roles don't fit, create custom roles:
- Define allowed actions (`Actions`)
- Define denied actions (`NotActions`)
- Specify allowed data actions (`DataActions`)
- Assign to specific scopes

```json
{
  "Name": "Custom VM Operator",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "AssignableScopes": ["/subscriptions/{subscriptionId}"]
}
```

### Deny Assignments
- Explicitly deny access even if a role grants it
- Created automatically by Azure Blueprints
- Cannot be created manually by users

> **Exam tip:** Know the difference between Azure RBAC (resource access) and Entra ID roles (directory-level access).

---

## 6. Managed Identities

### What It Is
A managed identity provides an Azure service with an automatically managed identity in Entra ID. Applications use this identity to authenticate without managing credentials.

### Types

| Type | Description | Use Case |
|---|---|---|
| **System-assigned** | Created for one resource; deleted when the resource is deleted | Single-purpose identity for one resource |
| **User-assigned** | Standalone identity; can be assigned to multiple resources | Shared identity across multiple resources |

### How Managed Identities Work

1. Enable managed identity on an Azure resource (e.g., Virtual Machine)
2. Azure creates a service principal in Entra ID for the resource
3. Resource requests a token from Azure Instance Metadata Service (IMDS)
4. Token is used to authenticate to Azure services (Key Vault, Storage, etc.)
5. No credentials stored in code or configuration

### Supported Services
Managed identities can be used with: Azure VMs, App Service, Azure Functions, AKS, Logic Apps, Service Bus, Event Hubs, and more.

> **Exam tip:** Managed identities eliminate the need to store credentials. System-assigned is tied to one resource; user-assigned can be shared.

---

## 7. Azure AD B2B and B2C

### Azure AD B2B (Business-to-Business)

| Aspect | Details |
|---|---|
| **Purpose** | Invite external partners/vendors to access your Azure resources |
| **User type** | Guest users in your directory |
| **Authentication** | External users authenticate with their own IdP |
| **Access** | Controlled via RBAC, Conditional Access, app assignments |
| **License** | Entra ID Free supports up to 5 external users per internal licensed user |

**B2B Process:**
1. Admin sends invitation to external email
2. External user receives email and accepts invitation
3. Guest account created in your directory (`user@externaldomain.com#EXT#@yourtenant.onmicrosoft.com`)
4. Assign appropriate roles/permissions

### Azure AD B2C (Business-to-Consumer)

| Aspect | Details |
|---|---|
| **Purpose** | Customer-facing identity management for apps |
| **Users** | Consumers (not employees or partners) |
| **Authentication** | Social accounts (Google, Facebook), local accounts, enterprise IdPs |
| **Customization** | Fully customizable sign-in/sign-up experience |
| **Scale** | Millions of identities, billions of authentications per day |

> **Exam tip:** B2B = partners accessing your resources; B2C = customers using your apps.

---

## 8. Identity Protection

### What It Is
Microsoft Entra ID Protection (requires P2) uses ML to detect and respond to identity-based risks automatically.

### Risk Types

| Risk | Description | Examples |
|---|---|---|
| **Sign-in risk** | Probability that the sign-in wasn't performed by the user | Atypical travel, anonymous IP, malware-linked IP |
| **User risk** | Probability that a user account is compromised | Leaked credentials, password spray attack |

### Risk Levels
- **Low** — Informational; monitor
- **Medium** — Investigate; consider requiring MFA
- **High** — Block or require password reset

### Identity Protection Policies

| Policy | Trigger | Response |
|---|---|---|
| **Sign-in risk policy** | Sign-in risk ≥ threshold | Require MFA or block |
| **User risk policy** | User risk ≥ threshold | Require password change or block |
| **MFA registration policy** | New users | Require MFA registration |

### Integration with Conditional Access
Identity Protection feeds risk signals into Conditional Access:
- `Sign-in risk: High` → Block access
- `User risk: Medium or higher` → Require secure password change

> **Exam tip:** Identity Protection requires Entra ID P2. It detects risks; Conditional Access enforces responses.

---

## 9. Key Exam Topics Checklist

Use this checklist to confirm your readiness for Domain 1:

- [ ] Configure and manage Microsoft Entra ID tenants
- [ ] Create and manage users, groups (including dynamic groups)
- [ ] Configure MFA methods (Authenticator app, FIDO2, OATH tokens)
- [ ] Enable and configure SSPR
- [ ] Configure Azure AD Connect (PHS, PTA, Federation)
- [ ] Create and assign Conditional Access policies
- [ ] Configure named locations
- [ ] Enable PIM for Azure AD roles and Azure resources
- [ ] Configure eligible vs. active assignments in PIM
- [ ] Set up PIM access reviews
- [ ] Assign Azure RBAC roles at different scopes
- [ ] Create custom RBAC roles
- [ ] Enable system-assigned and user-assigned managed identities
- [ ] Configure B2B guest access
- [ ] Understand B2C for customer scenarios
- [ ] Configure Identity Protection risk policies

---

*Next: [Domain 2 — Secure Networking →](02-secure-networking.md)*
