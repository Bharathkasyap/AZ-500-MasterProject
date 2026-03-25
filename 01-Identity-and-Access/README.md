# Domain 1: Manage Identity and Access

**Exam Weight: 25–30%**

← [Back to Main Guide](../README.md)

---

## Overview

This domain tests your ability to manage and secure identities in Azure, configure access controls, and protect privileged accounts. It is the largest domain and touches nearly every other aspect of Azure security.

---

## Table of Contents

1. [Microsoft Entra ID (Azure Active Directory)](#1-microsoft-entra-id-azure-active-directory)
2. [Role-Based Access Control (RBAC)](#2-role-based-access-control-rbac)
3. [Privileged Identity Management (PIM)](#3-privileged-identity-management-pim)
4. [Multi-Factor Authentication (MFA)](#4-multi-factor-authentication-mfa)
5. [Conditional Access](#5-conditional-access)
6. [Identity Protection](#6-identity-protection)
7. [Managed Identities](#7-managed-identities)
8. [Azure AD B2B and B2C](#8-azure-ad-b2b-and-b2c)
9. [Application Registrations and Service Principals](#9-application-registrations-and-service-principals)
10. [Key Exam Tips](#key-exam-tips)

---

## 1. Microsoft Entra ID (Azure Active Directory)

### What It Is
Microsoft Entra ID (formerly Azure Active Directory) is Microsoft's cloud-based identity and access management service. It is the backbone of authentication and authorization across all Azure services.

### Key Concepts
| Concept | Description |
|---|---|
| **Tenant** | A dedicated instance of Entra ID for an organization |
| **Directory** | Container for users, groups, devices, and applications |
| **User Principal Name (UPN)** | The login identity (e.g., user@contoso.com) |
| **Hybrid Identity** | Synchronizing on-premises Active Directory with Entra ID |
| **Azure AD Connect** | Tool to sync on-premises AD with Entra ID |
| **Pass-through Authentication (PTA)** | Validates passwords against on-premises AD in real-time |
| **Password Hash Sync (PHS)** | Syncs a hash of passwords to Entra ID |
| **Federation** | Using ADFS or other identity providers for authentication |

### License Tiers
| Feature | Free | P1 | P2 |
|---|---|---|---|
| SSO | ✅ | ✅ | ✅ |
| MFA (basic) | ✅ | ✅ | ✅ |
| Conditional Access | ❌ | ✅ | ✅ |
| Identity Protection | ❌ | ❌ | ✅ |
| PIM | ❌ | ❌ | ✅ |
| Access Reviews | ❌ | ❌ | ✅ |

### Exam Tips
- Know the difference between **PHS**, **PTA**, and **Federation**
- PHS is the **simplest and most resilient** hybrid identity option
- **Seamless SSO** works with both PHS and PTA

---

## 2. Role-Based Access Control (RBAC)

### What It Is
RBAC allows you to grant users, groups, and service principals specific permissions to Azure resources based on their role.

### RBAC Components
| Component | Description |
|---|---|
| **Security Principal** | User, group, service principal, or managed identity |
| **Role Definition** | A collection of permissions (e.g., Reader, Contributor) |
| **Scope** | The boundary where the role assignment applies |
| **Role Assignment** | Binding a role definition to a security principal at a scope |

### Scope Hierarchy
```
Management Group
  └── Subscription
        └── Resource Group
              └── Resource
```
Roles assigned at a **higher scope are inherited** by lower scopes.

### Built-in Roles (Critical for Exam)
| Role | Permissions |
|---|---|
| **Owner** | Full access + manage access |
| **Contributor** | Full access, cannot manage access |
| **Reader** | Read-only access |
| **User Access Administrator** | Manage user access only |
| **Security Admin** | View and update Security Center policies |
| **Security Reader** | Read-only access to Security Center |

### Custom Roles
- Defined in JSON with `Actions`, `NotActions`, `DataActions`, `NotDataActions`
- Can be assigned at subscription or management group scope
- Can be cloned from built-in roles

```json
{
  "Name": "Custom VM Operator",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action"
  ],
  "NotActions": [],
  "AssignableScopes": ["/subscriptions/{subscriptionId}"]
}
```

### Exam Tips
- `Actions` vs `DataActions`: Actions are **management plane**, DataActions are **data plane** (e.g., reading blob data)
- `NotActions` do **not** deny — they simply exclude from `Actions`
- To **explicitly deny**, use **Azure Deny Assignments** (created by Blueprints/managed apps only)

---

## 3. Privileged Identity Management (PIM)

### What It Is
PIM provides just-in-time (JIT) privileged access to Azure resources and Entra ID roles. It requires **Azure AD P2 license**.

### Key Features
| Feature | Description |
|---|---|
| **Just-in-time access** | Activate roles only when needed, for a limited time |
| **Eligible assignments** | User has the right but must activate the role |
| **Active assignments** | Always-on role assignment |
| **Approval workflow** | Require approver before role activation |
| **MFA on activation** | Require MFA before activating a privileged role |
| **Access reviews** | Periodically review and certify role assignments |
| **Audit history** | Full log of activations, approvals, and reviews |

### PIM Workflow
1. Admin configures a role as **eligible** in PIM
2. User requests activation (with justification)
3. Optional: Approver reviews and approves
4. Role is activated for configured duration (e.g., 1–8 hours)
5. Role expires and user loses access automatically

### Exam Tips
- PIM requires **Azure AD Premium P2**
- Know the difference between **eligible** and **active** assignments
- PIM can manage both **Entra ID roles** and **Azure resource roles**
- **Access reviews** in PIM can automatically remove stale assignments

---

## 4. Multi-Factor Authentication (MFA)

### What It Is
MFA requires users to verify their identity using two or more methods from: something you know (password), something you have (phone/authenticator), something you are (biometrics).

### MFA Methods in Azure
| Method | Notes |
|---|---|
| **Microsoft Authenticator app** | Push notification or TOTP code — recommended |
| **OATH hardware token** | Physical token generating TOTP codes |
| **SMS text message** | SMS to registered phone number |
| **Voice call** | Automated call to registered phone |
| **FIDO2 security key** | Phishing-resistant hardware key |
| **Windows Hello for Business** | Biometric/PIN-based — phishing resistant |

### Enabling MFA
- **Per-user MFA**: Legacy method; enables MFA for specific users individually
- **Security Defaults**: Free tier; enforces MFA for all users, blocks legacy auth
- **Conditional Access (recommended)**: Fine-grained policies, requires P1/P2 license

### Exam Tips
- **Security Defaults** and **per-user MFA** cannot coexist with Conditional Access — disable one before enabling the other
- **SSPR (Self-Service Password Reset)** can be combined with MFA registration
- **Legacy authentication** (SMTP, POP3, IMAP) does NOT support MFA — block it with Conditional Access

---

## 5. Conditional Access

### What It Is
Conditional Access is Azure's Zero Trust policy engine — it evaluates signals (user, device, location, application, risk) and enforces access controls (grant, block, require MFA).

### Policy Structure
```
IF (assignments are met)
THEN (apply access controls)
```

### Assignments (Signals)
| Signal Type | Examples |
|---|---|
| **Users / Groups** | Specific users, groups, roles |
| **Cloud apps** | Microsoft 365, Azure portal, custom apps |
| **Conditions** | Sign-in risk, user risk, device platform, location, client app |

### Access Controls
| Control | Description |
|---|---|
| **Block access** | Deny all access |
| **Grant access** | Allow, but require conditions (MFA, compliant device, etc.) |
| **Require MFA** | Enforce MFA |
| **Require compliant device** | Device must meet Intune compliance policy |
| **Require hybrid Azure AD join** | Device must be joined to on-premises AD + Entra ID |
| **Require approved client app** | App must be in approved list |
| **Require app protection policy** | App must have Intune MAM policy |
| **Session controls** | Limit session lifetime, block downloads, etc. |

### Named Locations
- Define trusted IP ranges (e.g., corporate network)
- Used in Conditional Access policies for location-based conditions
- **MFA trusted IPs**: Legacy feature — use named locations instead

### Exam Tips
- **What If tool** in Entra ID lets you test Conditional Access policies without applying them
- Policies work on a **grant or block** model — most permissive matching policy wins for grants; any block policy denies
- Know the difference between **sign-in risk** (probability this specific sign-in is unauthorized) vs **user risk** (probability the account is compromised)

---

## 6. Identity Protection

### What It Is
Microsoft Entra ID Protection uses machine learning to detect risks associated with user accounts and sign-ins. Requires **Azure AD P2**.

### Risk Types
| Risk | Scope | Description |
|---|---|---|
| **Sign-in risk** | Per sign-in | Probability that the specific sign-in is unauthorized |
| **User risk** | Per user | Probability that the user account is compromised |

### Risk Levels
- **High** — Strong confidence of compromise
- **Medium** — Suspicious activity detected
- **Low** — Anomalous but not conclusive

### Risk Detections
| Detection | Type |
|---|---|
| Anonymous IP address | Sign-in |
| Atypical travel | Sign-in |
| Malware-linked IP address | Sign-in |
| Unfamiliar sign-in properties | Sign-in |
| Password spray | User |
| Leaked credentials | User |
| Azure AD threat intelligence | Both |

### Risk Policies
- **Sign-in risk policy**: Automatically require MFA for medium/high risk sign-ins
- **User risk policy**: Automatically require password change for high-risk users
- Both are configured as Conditional Access policies (modern approach)

### Exam Tips
- **Remediation**: User can self-remediate by completing MFA or changing password
- **Dismiss**: Admin can dismiss risk if confirmed not compromised
- **Confirm compromise**: Admin confirms the account was compromised; user is blocked

---

## 7. Managed Identities

### What It Is
Managed identities allow Azure services to authenticate to other Azure services without storing credentials in code or configuration.

### Types
| Type | Description |
|---|---|
| **System-assigned** | Tied to a specific resource; deleted when the resource is deleted |
| **User-assigned** | Standalone identity; can be assigned to multiple resources |

### Supported Services
- Azure VMs, App Service, Azure Functions, AKS, Logic Apps, Data Factory, and many more

### How It Works
1. Enable managed identity on the resource
2. Assign RBAC role to the managed identity for target resource
3. Application code requests token from the Instance Metadata Service (IMDS) endpoint: `http://169.254.169.254/metadata/identity/oauth2/token`

### Exam Tips
- System-assigned identities have a **1:1 relationship** with the resource
- User-assigned identities can be shared across multiple resources
- Managed identities **eliminate the need for credentials** in code — always prefer over service principals with secrets

---

## 8. Azure AD B2B and B2C

### Azure AD B2B (Business-to-Business)
- Invite **external users** (guest users) to collaborate in your tenant
- Guest users use their **own identity provider** (work account, Microsoft account, Google, etc.)
- Access is controlled through Entra ID roles and RBAC
- **Cross-tenant access settings**: Control inbound/outbound B2B collaboration per partner

### Azure AD B2C (Business-to-Consumer)
- **Separate Azure AD tenant** designed for customer-facing applications
- Supports social identity providers (Google, Facebook, Apple) and local accounts
- Customizable **user flows** (sign-up, sign-in, profile editing, password reset)
- **Custom policies**: Advanced XML-based configurations for complex scenarios

### Key Differences
| Feature | B2B | B2C |
|---|---|---|
| **Target users** | Business partners, employees | Consumers / customers |
| **Identity providers** | Work/school accounts, social | Social, local accounts |
| **Tenant type** | Same tenant (as guests) | Separate B2C tenant |
| **Customization** | Limited | Fully customizable UX |

### Exam Tips
- B2B guests appear in your directory as **guest users** with `#EXT#` in the UPN
- B2C is a **separate service** — not just a feature of Entra ID
- **Entitlement Management** uses access packages to manage B2B user lifecycle

---

## 9. Application Registrations and Service Principals

### Application Registration
- Represents an application in Entra ID
- Contains: App ID, credentials (secrets/certificates), API permissions, redirect URIs
- **Global** — registered once, usable across tenants

### Service Principal
- The **local representation** of an application in a specific tenant
- Created automatically when an app registration is used in a tenant
- Can also create service principals for Azure CLI/automation scenarios

### Key Settings
| Setting | Description |
|---|---|
| **Client ID (App ID)** | Unique identifier for the application |
| **Client Secret** | Password credential for the application |
| **Certificate** | Preferred over secrets — more secure |
| **API Permissions** | What APIs the app can access |
| **Delegated permissions** | Access on behalf of a user |
| **Application permissions** | Access without a user (background service) |
| **Admin consent** | Required for application permissions and high-privilege delegated permissions |

### Exam Tips
- Prefer **certificates** over client secrets for service principal authentication
- **Application permissions** require admin consent; **delegated permissions** may require user consent
- Monitor app permissions with **Entra ID App Governance** or **Defender for Cloud Apps**
- Rotate secrets/certificates before expiry; set up **expiry notifications**

---

## Key Exam Tips

1. **RBAC hierarchy**: Permissions flow down from Management Group → Subscription → Resource Group → Resource
2. **PIM requires Azure AD P2** — know when and why to use it
3. **Conditional Access beats per-user MFA** — it's the modern, recommended approach
4. **Managed identities > service principal secrets** — no credential management
5. **Security Defaults** is free but cannot coexist with Conditional Access
6. **Identity Protection requires P2** — produces risk signals consumed by Conditional Access
7. **JIT access** (via PIM or Microsoft Defender for Cloud) reduces attack surface
8. Know which authentication methods are **phishing-resistant**: FIDO2, Windows Hello for Business, Certificate-based auth

---

← [Back to Main Guide](../README.md) | [Domain 2: Secure Networking →](../02-Secure-Networking/README.md)
