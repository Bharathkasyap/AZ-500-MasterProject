# Domain 1: Manage Identity and Access (25–30%)

← [Back to main README](../../README.md)

This domain covers **Azure Active Directory (Microsoft Entra ID)**, role-based access controls, multi-factor authentication, Privileged Identity Management, and Conditional Access. It accounts for **25–30%** of the AZ-500 exam.

---

## Table of Contents

1. [Azure Active Directory (Microsoft Entra ID)](#1-azure-active-directory-microsoft-entra-id)
2. [Azure AD Users and Groups](#2-azure-ad-users-and-groups)
3. [Multi-Factor Authentication (MFA)](#3-multi-factor-authentication-mfa)
4. [Conditional Access Policies](#4-conditional-access-policies)
5. [Azure AD Identity Protection](#5-azure-ad-identity-protection)
6. [Privileged Identity Management (PIM)](#6-privileged-identity-management-pim)
7. [Azure Role-Based Access Control (RBAC)](#7-azure-role-based-access-control-rbac)
8. [Managed Identities](#8-managed-identities)
9. [Azure AD Application Registration and Service Principals](#9-azure-ad-application-registration-and-service-principals)
10. [Azure AD B2B and B2C](#10-azure-ad-b2b-and-b2c)
11. [Access Reviews](#11-access-reviews)
12. [Key Exam Tips for Domain 1](#key-exam-tips-for-domain-1)

---

## 1. Azure Active Directory (Microsoft Entra ID)

### What It Is
Azure Active Directory (now branded as **Microsoft Entra ID**) is Microsoft's cloud-based identity and access management service. It provides:

- **Single Sign-On (SSO)** to thousands of cloud applications
- **Multi-factor Authentication** to protect sign-ins
- **Conditional Access** to enforce policy-based access
- **Identity Protection** to detect risky users and sign-ins

### Azure AD Editions

| Edition | Key Features |
|---|---|
| **Free** | Included with Azure subscription; basic user management, SSO (10 apps) |
| **Microsoft 365 Apps** | Bundled with M365; group-based licensing, self-service password reset (SSPR) |
| **P1** | Conditional Access, hybrid identities, SSPR with on-prem writeback, dynamic groups |
| **P2** | Everything in P1 + Identity Protection, PIM, access reviews |

> **Exam Tip**: PIM and Identity Protection both require **Azure AD P2**. Conditional Access requires **P1 or P2**.

### Key Concepts

| Term | Definition |
|---|---|
| **Tenant** | A dedicated Azure AD instance for your organization |
| **Directory** | Synonymous with tenant in Azure AD context |
| **Domain** | e.g., `contoso.onmicrosoft.com` or a custom verified domain |
| **Subscription trust** | An Azure subscription trusts one Azure AD tenant |

---

## 2. Azure AD Users and Groups

### User Types

| Type | Description |
|---|---|
| **Member user** | Regular internal user created in your tenant |
| **Guest user** | External collaborator invited via Azure AD B2B |
| **Service principal** | Identity for an application or service |
| **Managed identity** | System or user-assigned identity for Azure resources |

### Group Types

| Type | Description | Used For |
|---|---|---|
| **Security group** | Controls access to resources | RBAC, app registration, Conditional Access |
| **Microsoft 365 group** | Collaboration with mailbox, Teams, SharePoint | M365 services |

### Group Membership

| Method | Description |
|---|---|
| **Assigned** | Members manually added by admin |
| **Dynamic User** | Membership determined by user attribute rules (requires P1/P2) |
| **Dynamic Device** | Membership determined by device attribute rules |

---

## 3. Multi-Factor Authentication (MFA)

### Authentication Methods

| Method | Security Level | Notes |
|---|---|---|
| Password | Low | Baseline; should never be used alone |
| SMS/Phone call | Medium | Legacy; vulnerable to SIM swapping |
| Microsoft Authenticator app | High | Push notifications or TOTP codes |
| FIDO2 security key | Very High | Phishing-resistant; passwordless |
| Windows Hello for Business | Very High | Biometric/PIN on trusted devices |
| Certificate-based auth | Very High | Smart card or certificate |

### MFA Configuration Locations

1. **Per-user MFA** — Legacy; found in Azure AD > Users > Multi-Factor Authentication
2. **Security defaults** — Free tier; enforces MFA for all users and admins (blocks legacy auth)
3. **Conditional Access** (recommended) — Policy-driven, granular control (requires P1/P2)

> **Exam Tip**: Security defaults and Conditional Access **cannot be used simultaneously**. If Conditional Access is enabled, disable security defaults.

### Legacy Authentication Protocols

Legacy auth protocols (Basic Auth, SMTP AUTH, IMAP, POP3) do **not support MFA challenges**. They must be blocked using:
- Conditional Access policy: condition = "Client apps = Legacy authentication clients"
- Azure AD Sign-in logs to identify legacy auth usage

---

## 4. Conditional Access Policies

### Policy Structure

A Conditional Access policy is an **if-then statement**:

```
IF   [Assignments: Users, Cloud apps, Conditions]
THEN [Access Controls: Grant or Block]
```

### Assignments

| Component | Options |
|---|---|
| **Users and groups** | All users, specific users/groups, directory roles |
| **Cloud apps or actions** | All apps, specific apps, user actions |
| **Conditions** | Sign-in risk, user risk, device platforms, locations, client apps, device filters |

### Grant Controls (Access Controls)

| Control | Description |
|---|---|
| **Block access** | Deny all matching sign-ins |
| **Grant access** | Allow with zero or more requirements |
| **Require MFA** | Force second factor |
| **Require compliant device** | Intune compliance required |
| **Require Hybrid Azure AD join** | Domain-joined + Entra-joined device |
| **Require approved client app** | Only specific mobile apps (Intune-approved) |
| **Require app protection policy** | Intune MAM policy required |

### Named Locations

Used as conditions in Conditional Access:
- **IP ranges**: Trust corporate office IPs; block sign-ins from unusual countries
- **Countries/regions**: Block or require MFA for specific geographies
- **Mark as trusted**: Trusted locations can be excluded from MFA requirements

### Policy Modes

| Mode | Description |
|---|---|
| **Report-only** | Logs what *would* happen without enforcing; useful for testing |
| **On** | Fully enforced |
| **Off** | Disabled; no effect |

> **Exam Tip**: Always test policies in **report-only** mode before enabling them to avoid locking out users.

---

## 5. Azure AD Identity Protection

### What It Does
Detects **risky users** and **risky sign-ins** using Microsoft's threat intelligence and machine learning.

### Risk Types

| Risk Type | Examples |
|---|---|
| **Sign-in risk** | Atypical travel, anonymous IP, malware-linked IP, leaked credentials |
| **User risk** | Leaked credentials, Azure AD threat intelligence |

### Risk Levels

`Low` → `Medium` → `High`

### Identity Protection Policies

| Policy | Trigger | Default Action |
|---|---|---|
| **User risk policy** | User risk ≥ threshold | Require password change |
| **Sign-in risk policy** | Sign-in risk ≥ threshold | Require MFA |
| **MFA registration policy** | New users | Require MFA registration |

### Risky Users and Sign-ins Reports

- **Risky users report**: Lists users with active risk detections
- **Risky sign-ins report**: Lists individual sign-ins flagged as risky
- **Risk detections report**: Detailed list of each detection event

> **Exam Tip**: Identity Protection policies are enforced via **Conditional Access** or directly through the Identity Protection blade (the standalone policies in Identity Protection are considered legacy — prefer Conditional Access integration).

---

## 6. Privileged Identity Management (PIM)

### What PIM Does
PIM provides **just-in-time (JIT) privileged access** to Azure AD roles and Azure resource roles:

- Users are **eligible** for roles but not permanently assigned
- Users **activate** their role when needed (with optional approval and MFA)
- Activations are **time-limited** (e.g., 1–8 hours)

### Role Assignment Types

| Type | Description |
|---|---|
| **Eligible** | User can request to activate the role temporarily |
| **Active** | User always has the role without needing to activate |

### PIM Workflow

```
1. Admin makes user "Eligible" for Global Administrator
2. User requests activation → provides business justification
3. (Optional) Approver receives notification and approves/denies
4. User activates role for configured duration (e.g., 2 hours)
5. Activation recorded in PIM audit log
6. Role automatically deactivated when duration expires
```

### PIM Settings (per role)

- **Activation duration**: Max time for a single activation
- **Require MFA on activation**: Force MFA when activating
- **Require justification**: User must explain why they need access
- **Require approval**: One or more designated approvers must approve
- **Require ticket information**: Incident/change ticket number required
- **Notification settings**: Email alerts for activations

### Access Reviews in PIM

Periodically review who has eligible or active role assignments:
- Duration: Configurable (weekly/monthly/quarterly/annual)
- Reviewers: Self, specific users, or managers
- On no response: Remove access or leave unchanged

### PIM for Azure Resources

PIM also manages:
- Azure subscription roles (Owner, Contributor, etc.)
- Resource group level roles
- Individual resource roles (e.g., Key Vault Administrator)

> **Exam Tip**: PIM requires **Azure AD P2**. Know the difference between **Eligible** and **Active** assignments, and know how to configure approval workflows.

---

## 7. Azure Role-Based Access Control (RBAC)

### RBAC Concepts

| Concept | Description |
|---|---|
| **Security principal** | User, group, service principal, or managed identity that needs access |
| **Role definition** | Collection of permissions (actions, notActions, dataActions) |
| **Scope** | Management group, subscription, resource group, or resource |
| **Role assignment** | Binding of a role definition to a security principal at a scope |

### Built-in Role Hierarchy

```
Management Group
  └── Subscription
        └── Resource Group
              └── Resource
```

Permissions are **inherited downward**. An Owner at subscription level is Owner of all resource groups and resources within.

### Key Built-in Roles

| Role | Permissions |
|---|---|
| **Owner** | Full access + can assign RBAC roles to others |
| **Contributor** | Full access to resources; cannot assign RBAC roles |
| **Reader** | Read-only access |
| **User Access Administrator** | Manage RBAC assignments only; no resource access |

### Common Security-Relevant Built-in Roles

| Role | Purpose |
|---|---|
| Security Admin | View/update security policy; dismiss alerts |
| Security Reader | Read-only access to security center |
| Key Vault Administrator | Full control of key vault data plane |
| Key Vault Secrets User | Read secret values |
| Storage Blob Data Owner | Full access to blob storage |
| Storage Blob Data Reader | Read blob data |

### Custom Roles

Custom roles allow fine-grained permission sets:
```json
{
  "Name": "VM Operator",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": ["/subscriptions/{subscriptionId}"]
}
```

> **Exam Tip**: `Actions` control management plane operations; `DataActions` control data plane operations (e.g., reading blob content). These are evaluated separately.

### deny Assignments

- Created by Azure Blueprints or managed apps
- **Block** specific actions even if a role assignment would allow them
- Cannot be created directly by users — only by Azure managed services

---

## 8. Managed Identities

### Problem Solved
Eliminates the need to store credentials (passwords, connection strings) in application code.

### Types

| Type | Description | Best For |
|---|---|---|
| **System-assigned** | Tied to the lifecycle of the Azure resource; deleted when resource is deleted | Single-resource use cases |
| **User-assigned** | Independent Azure resource; can be assigned to multiple Azure resources | Shared identity across multiple resources |

### How It Works

1. Azure resource (VM, App Service, Function, etc.) is assigned a managed identity
2. A **service principal** is automatically created in Azure AD
3. Application uses the [Azure SDK / IMDS endpoint](http://169.254.169.254/metadata/identity/oauth2/token) to get a token without any credentials
4. Token is used to authenticate to Azure services (Key Vault, Storage, SQL, etc.)

### Supported Services (Examples)

- Azure Virtual Machines
- Azure App Service / Azure Functions
- Azure Kubernetes Service (AKS) pods (via workload identity)
- Azure Logic Apps
- Azure Container Instances

> **Exam Tip**: Managed identities are the **preferred** way to authenticate from Azure compute to Azure services. Never store credentials in code or config files.

---

## 9. Azure AD Application Registration and Service Principals

### Application Registration vs Service Principal

| Concept | Description |
|---|---|
| **App Registration** | The definition of an application in your tenant (or home tenant) |
| **Service Principal** | The instance of the app in a specific tenant; what actually gets permissions |

### Key App Registration Settings

| Setting | Purpose |
|---|---|
| **Client ID (Application ID)** | Unique identifier for the app |
| **Client Secret / Certificate** | Credential for the app to authenticate |
| **Redirect URIs** | Where the identity provider sends the response |
| **API Permissions** | What Microsoft Graph or other API scopes the app needs |
| **Expose an API** | Define scopes that other apps can request |

### Permission Types

| Type | Description | Consent Required |
|---|---|---|
| **Delegated** | App acts on behalf of a signed-in user | User or Admin |
| **Application** | App acts as itself (daemon/service) | Admin only |

> **Exam Tip**: Application permissions (not delegated) require **admin consent**. Watch for questions about what happens when a user tries to consent to an app that requires admin consent.

### App Registration Security Best Practices

- Prefer **certificate credentials** over client secrets
- Rotate client secrets before expiry
- Grant only **minimum required permissions** (principle of least privilege)
- Use **Conditional Access for workload identities** (requires Azure AD P2) to restrict service principal sign-ins

---

## 10. Azure AD B2B and B2C

### Azure AD B2B (Business-to-Business)

Allows external users (from other organizations) to access your resources as **guest users**:

| Aspect | Details |
|---|---|
| **Identity source** | External user's own identity (Microsoft, Google, federated) |
| **User type** | Guest (UserType = Guest) |
| **Access management** | RBAC + Conditional Access + access reviews |
| **Invitation** | Email invite or direct link; redeemable once |

**Cross-Tenant Access Settings** (Inbound/Outbound):
- **Inbound**: Control what external guest users from other tenants can access in your tenant
- **Outbound**: Control what your users can access in external tenants

### Azure AD B2C (Business-to-Consumer)

A **separate Azure AD tenant** for customer-facing identity:

| Aspect | Details |
|---|---|
| **Use case** | Customer apps — e-commerce, mobile apps, SaaS |
| **Identities** | Social accounts (Google, Facebook, Apple) + local accounts |
| **User flows** | Pre-built sign-up/sign-in/profile edit/password reset flows |
| **Custom policies** | XML-based Identity Experience Framework for advanced scenarios |

---

## 11. Access Reviews

### What Access Reviews Do
Periodically review who has access to what and clean up stale assignments.

### Types of Reviews

| Type | Scope |
|---|---|
| **Group membership reviews** | Review members of a security group or M365 group |
| **App assignment reviews** | Review users assigned to an enterprise application |
| **Azure AD role reviews** | Review assignments to Azure AD directory roles (via PIM) |
| **Azure resource role reviews** | Review assignments to Azure RBAC roles (via PIM) |

### Review Settings

| Setting | Options |
|---|---|
| **Reviewers** | Selected users, group owners, managers, or self-review |
| **Duration** | 1–180 days |
| **Recurrence** | Weekly, monthly, quarterly, semi-annually, annually, or one-time |
| **On no response** | Remove access, approve access, or take recommendations |
| **Auto-apply results** | Automatically apply review decisions when review ends |

### Recommendations
Azure AD can auto-generate recommendations based on last sign-in activity:
- User not signed in for 30+ days → recommend removing access

> **Exam Tip**: Access reviews require **Azure AD P2**.

---

## Key Exam Tips for Domain 1

1. **MFA configuration precedence**: Per-user MFA < Security defaults < Conditional Access (CA is most flexible and recommended)
2. **PIM vs direct role assignment**: PIM provides JIT access; direct assignments are permanent. Prefer eligible assignments via PIM.
3. **P1 vs P2 features**:
   - P1: Conditional Access, dynamic groups, hybrid join
   - P2: PIM, Identity Protection, access reviews
4. **Managed identity types**: System-assigned dies with the resource; user-assigned is independent and reusable.
5. **Delegated vs Application permissions**: Delegated = user context; Application = app's own identity. Application permissions always need admin consent.
6. **B2B vs B2C**: B2B = external business users as guests; B2C = separate tenant for customer identity.
7. **Conditional Access report-only mode**: Use before going live to avoid accidental lockouts.
8. **Named locations**: Used to define trusted IP ranges or countries; can exclude from MFA requirements.
9. **Access reviews auto-apply**: Enable auto-apply so decisions are enforced without manual action.
10. **Global Administrator vs Security Administrator**: GA has full control; Security Admin can manage security policies and alerts but cannot manage other GA roles.
