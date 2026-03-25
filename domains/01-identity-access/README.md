# Domain 1 — Manage Identity and Access

> **Weight: 25–30% of the AZ-500 Exam**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Skill Areas](#skill-areas)
- [Microsoft Entra ID Fundamentals](#microsoft-entra-id-fundamentals)
- [Authentication Methods](#authentication-methods)
- [Azure RBAC](#azure-rbac)
- [Privileged Identity Management (PIM)](#privileged-identity-management-pim)
- [Conditional Access](#conditional-access)
- [Identity Protection](#identity-protection)
- [External Identities](#external-identities)
- [Workload Identities](#workload-identities)
- [Key Exam Points](#key-exam-points)

---

## Overview

Domain 1 covers securing identities in Microsoft Entra ID (formerly Azure Active Directory). This is one of the two highest-weighted domains and is foundational to Azure security. Everything else in Azure security builds on a solid identity layer.

**Key Theme:** *Implement Zero Trust principles — verify explicitly, use least privilege, assume breach.*

---

## Skill Areas

Based on the official study guide:

1. **Manage Microsoft Entra identities**
   - Secure users, groups, devices, service principals
   - Configure external identities (B2B, B2C)

2. **Manage Microsoft Entra authentication**
   - MFA, SSPR, passwordless, certificate-based auth
   - Azure AD Connect (hybrid identity)

3. **Manage Microsoft Entra authorization**
   - Azure RBAC, Entra ID roles
   - Custom roles, role assignments

4. **Manage Microsoft Entra access governance**
   - Privileged Identity Management (PIM)
   - Conditional Access
   - Identity Protection
   - Access Reviews
   - Entitlement Management

---

## Microsoft Entra ID Fundamentals

### Tenant & Directory
- A **tenant** is a dedicated instance of Microsoft Entra ID for an organization
- A tenant has a primary domain (e.g., `contoso.onmicrosoft.com`) and can have custom domains
- Resources in Azure subscriptions trust exactly **one** Entra ID tenant
- Multiple subscriptions can trust the same tenant

### User Types
| Type | Description |
|------|-------------|
| **Member** | Full directory member; internal user |
| **Guest** | External collaborator (B2B); limited permissions by default |
| **Service Principal** | Non-human identity for apps/services |

### Group Types
| Type | Assignment | Dynamic |
|------|-----------|---------|
| **Security** | Assigned / Dynamic | Yes |
| **Microsoft 365** | Assigned / Dynamic | Yes |

> **Exam tip:** Dynamic groups require **Entra ID P1** license. Nested groups are supported in Security groups, not Microsoft 365 groups.

### Devices
- **Entra ID Registered**: Personal/BYOD devices; user account used, not device account
- **Entra ID Joined**: Organization-owned; full device management; Windows 10/11 only
- **Hybrid Entra ID Joined**: Joined to both on-premises AD and Entra ID

---

## Authentication Methods

### Multi-Factor Authentication (MFA)
MFA requires two or more verification methods:
1. Something you **know** (password)
2. Something you **have** (phone, hardware token)
3. Something you **are** (biometric)

**MFA Methods (strongest to weakest):**
| Method | Security Level | Notes |
|--------|---------------|-------|
| FIDO2 Security Keys | ★★★★★ | Phishing-resistant |
| Windows Hello for Business | ★★★★★ | Biometric/PIN + device-bound |
| Microsoft Authenticator (passwordless) | ★★★★ | Number matching required |
| OATH Hardware Token | ★★★★ | Time-based OTP |
| Microsoft Authenticator (push) | ★★★ | Approve/Deny notification |
| TOTP (Authenticator app code) | ★★★ | 6-digit time-based code |
| SMS / Voice call | ★★ | Vulnerable to SIM-swap; legacy |

> **Exam tip:** Microsoft recommends disabling SMS/voice and migrating to the Authenticator app.

### Self-Service Password Reset (SSPR)
- Allows users to reset their own passwords without IT helpdesk
- Requires **Entra ID P1 or P2** (or Microsoft 365 Business Premium)
- Can require 1 or 2 authentication methods
- Methods: Email, mobile phone, security questions, app code, etc.
- **Password writeback** to on-premises AD requires Entra ID P1

### Passwordless Authentication
- **FIDO2**: USB/NFC security key (most phishing-resistant)
- **Windows Hello for Business**: Biometric or PIN tied to device certificate
- **Microsoft Authenticator app**: Phone sign-in without password

### Certificate-Based Authentication (CBA)
- Use X.509 certificates to authenticate to Entra ID
- Supports phishing-resistant MFA
- Configured in Entra ID > Security > Certificate-based authentication

---

## Azure RBAC

Azure Role-Based Access Control governs **what** authenticated users can **do** with Azure resources.

### RBAC Components
| Component | Description |
|-----------|-------------|
| **Security Principal** | User, group, service principal, or managed identity |
| **Role Definition** | Collection of permissions (actions, notActions, dataActions) |
| **Scope** | Management Group → Subscription → Resource Group → Resource |
| **Role Assignment** | Attaches a role definition to a principal at a scope |

### Built-in Roles (Must Know)
| Role | Key Permissions |
|------|----------------|
| **Owner** | Full access + manage access (assign roles) |
| **Contributor** | Full access to resources; cannot manage access |
| **Reader** | View only; no changes |
| **User Access Administrator** | Manage access only; cannot modify resources |
| **Security Admin** | Read + update security policies in Defender for Cloud |
| **Security Reader** | Read security policies and recommendations |
| **Key Vault Administrator** | Full Key Vault data plane access (RBAC model) |
| **Key Vault Secrets Officer** | Get/set secrets |
| **Key Vault Crypto Officer** | Manage keys |

### RBAC Scope Hierarchy
```
Management Group (broadest)
    └── Subscription
            └── Resource Group
                    └── Resource (narrowest)
```
- Permissions are **inherited downward**
- A deny assignment at child scope can block inherited permissions
- **Deny assignments** take precedence over role assignments

### Custom Roles
- Created when built-in roles don't meet requirements
- Defined in JSON with `Actions`, `NotActions`, `DataActions`, `NotDataActions`, `AssignableScopes`
- Can be assigned at any scope within `AssignableScopes`

---

## Privileged Identity Management (PIM)

PIM provides **just-in-time (JIT)** privileged access to minimize the attack surface of permanent assignments.

**Requires: Entra ID P2**

### PIM Concepts
| Concept | Description |
|---------|-------------|
| **Eligible assignment** | User can activate the role when needed |
| **Active assignment** | User has the role active permanently |
| **Activation** | Process of elevating from eligible → active |
| **Activation duration** | Maximum time a role can be active (default: 8 hours) |
| **Approval required** | Designated approver must approve activation |
| **Justification required** | User must provide business reason |
| **MFA on activation** | Enforce MFA before allowing activation |

### PIM Supports
- **Entra ID roles** (e.g., Global Administrator, Security Administrator)
- **Azure resource roles** (e.g., Owner, Contributor on subscriptions/RGs)
- **Eligible group membership** (Access Packages integration)

### PIM Access Reviews
- Periodically review who has eligible/active assignments
- Reviewers: Self, manager, or specific reviewers
- If reviewer doesn't respond: Auto-approve or auto-deny

> **Exam tip:** To configure PIM, the user must have the **Privileged Role Administrator** or **Global Administrator** role.

---

## Conditional Access

Conditional Access enforces access policies based on **signals** (conditions).

**Requires: Entra ID P1 or P2**

### Policy Components

```
IF [Assignments/Conditions are met]
THEN [Grant or Block access]
```

#### Assignments (Conditions)
| Signal | Examples |
|--------|---------|
| **Users/Groups** | All users, specific groups, guests |
| **Cloud apps** | Office 365, Azure portal, specific apps |
| **Conditions** | Sign-in risk, user risk, device platform, location, client apps |

#### Location Conditions
- **Named locations**: Trusted IP ranges or countries
- **MFA trusted IPs**: Legacy; prefer Named Locations

#### Grant Controls
| Control | Description |
|---------|-------------|
| **Block access** | Completely deny access |
| **Require MFA** | Enforce multi-factor authentication |
| **Require compliant device** | Device must be Intune-compliant |
| **Require Hybrid AD joined device** | Device joined to on-prem + Entra ID |
| **Require approved client app** | Must use specific Microsoft apps |
| **Require app protection policy** | Intune MAM policy required |

#### Session Controls
- Persistent browser session (allow/prevent)
- App-enforced restrictions (SharePoint/Exchange)
- Continuous access evaluation (CAE)
- Sign-in frequency

### Named Locations & MFA
- **Trusted locations** can be excluded from MFA requirements
- Countries/regions can be blocked entirely (Geo-blocking)
- IPv6 addresses are supported in named locations

> **Exam tip:** Conditional Access policies are evaluated **in the cloud**, not on-premises. They apply to cloud app sign-ins only.

---

## Identity Protection

Microsoft Entra ID Protection detects risky sign-ins and compromised identities.

**Requires: Entra ID P2**

### Risk Detections

| Detection Type | Examples |
|----------------|---------|
| **Sign-in risk** | Anonymous IP, atypical travel, malware-linked IP, password spray |
| **User risk** | Leaked credentials (dark web), Azure AD threat intelligence |

### Risk Levels
`Low → Medium → High`

### Remediation Actions
| Action | Trigger |
|--------|---------|
| Block sign-in | High sign-in risk + policy |
| Require MFA | Medium/High sign-in risk + policy |
| Require password change | High user risk + policy |
| Self-remediation | User completes MFA or changes password |
| Admin remediation | Manual dismiss / confirm compromise |

### Identity Protection Policies (legacy)
- **User risk policy**: Triggers on detected user risk
- **Sign-in risk policy**: Triggers on risky sign-ins
- **MFA registration policy**: Requires users to register for MFA

> **Modern approach:** Configure risk-based Conditional Access policies instead of standalone Identity Protection policies (more granular control).

---

## External Identities

### Azure AD B2B (Business-to-Business)
- Invite external users (guests) to collaborate within your tenant
- Guests use their existing identity (Microsoft account, Google, corporate)
- Access controlled via groups, Conditional Access, Access Packages
- Guest accounts created in your directory with `#EXT#` suffix in UPN

**B2B Settings:**
- Who can invite guests (admins only, members, anyone)
- External collaboration settings
- Cross-tenant access settings (inbound/outbound)

### Azure AD B2C (Business-to-Consumer)
- Separate service for customer-facing applications
- Customers create accounts with email, social identity (Google, Facebook), or local account
- Customizable user journeys (sign-up, sign-in, password reset)
- Supports OIDC, SAML, OAuth 2.0
- **Different service from Entra ID** — has its own tenant

### Access Packages (Entitlement Management)
- Bundle resources (groups, apps, SharePoint sites) into packages
- Users request access; approval workflows; automatic expiry
- Requires **Entra ID P2**

---

## Workload Identities

### Managed Identities
Managed identities provide an automatically managed identity in Entra ID for Azure services to authenticate without credentials in code.

| Type | Description |
|------|-------------|
| **System-assigned** | Tied to the resource lifecycle; auto-deleted when resource is deleted |
| **User-assigned** | Standalone resource; can be shared across multiple resources |

**Supported services:** VMs, App Service, Functions, AKS, Logic Apps, etc.

**How it works:**
1. Enable managed identity on a resource
2. Azure creates a service principal in Entra ID
3. Grant the managed identity RBAC permissions to target resources
4. Code calls Azure Instance Metadata Service (IMDS) to get a token
5. Token used to authenticate to Azure services (Key Vault, Storage, etc.)

> **Exam tip:** Managed identities eliminate the need to store credentials (client secrets) in code or config files.

### Service Principals
- An identity created for use with applications, services, or automation tools
- Has an **Application ID** (client ID) and **Object ID**
- Authenticates with a **client secret** or **certificate** (certificate preferred)
- Created when you register an app in Entra ID

### App Registrations
- Register an application in Entra ID to get an identity
- Creates an **Application object** (global, in home tenant) and a **Service Principal** (local, in each tenant)
- Configure:
  - Redirect URIs
  - Certificates & secrets
  - API permissions (Microsoft Graph, Azure management, custom APIs)
  - Expose an API (define scopes for other apps to consent to)

---

## Key Exam Points

### License Requirements Summary
| Feature | License |
|---------|---------|
| Basic MFA (per-user) | Entra ID Free |
| Conditional Access | Entra ID P1 or P2 |
| SSPR | Entra ID P1 or P2 |
| PIM | Entra ID P2 |
| Identity Protection | Entra ID P2 |
| Access Reviews | Entra ID P2 |
| Entitlement Management | Entra ID P2 |

### Common Scenario Questions
- **"Ensure admins use MFA when accessing Azure portal from outside trusted locations"** → Conditional Access policy with Location condition + Require MFA
- **"Minimize standing access for Global Administrators"** → Configure PIM with eligible assignments
- **"Allow temporary contractor access that automatically expires"** → PIM time-limited assignments or Access Packages
- **"Detect and block sign-ins from leaked credentials"** → Entra ID Identity Protection + risk-based Conditional Access
- **"Allow an Azure VM to access Key Vault without storing credentials"** → System-assigned Managed Identity + Key Vault RBAC/access policy

---

📖 [Detailed Study Notes →](study-notes.md) | [Practice Questions →](../../practice-questions/domain1-identity-access.md)
