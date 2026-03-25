# Domain 1: Manage Identity and Access (25–30%)

> **Back to:** [README](../README.md)

---

## Table of Contents

1. [Microsoft Entra ID (Azure Active Directory)](#1-microsoft-entra-id-azure-active-directory)
2. [Multi-Factor Authentication and Conditional Access](#2-multi-factor-authentication-and-conditional-access)
3. [Privileged Identity Management (PIM)](#3-privileged-identity-management-pim)
4. [Managed Identities and Service Principals](#4-managed-identities-and-service-principals)
5. [Azure Role-Based Access Control (RBAC)](#5-azure-role-based-access-control-rbac)
6. [External Identities: B2B and B2C](#6-external-identities-b2b-and-b2c)
7. [Identity Protection](#7-identity-protection)
8. [Key Exam Tips](#key-exam-tips)

---

## 1. Microsoft Entra ID (Azure Active Directory)

### What it is
Microsoft Entra ID (formerly Azure Active Directory / Azure AD) is Microsoft's cloud-based identity and access management service. It authenticates and authorizes users for:
- Microsoft 365 and other Microsoft cloud services
- Thousands of pre-integrated SaaS applications
- Custom applications your organization builds

### Tenants and Directories
| Concept | Description |
|---------|-------------|
| **Tenant** | A dedicated instance of Entra ID, representing a single organization |
| **Directory** | The container that holds users, groups, devices, and app registrations |
| **Subscription** | Linked to exactly one tenant; multiple subscriptions can share one tenant |

### Entra ID Tiers
| Tier | Key Security Features |
|------|-----------------------|
| Free | User/group management, SSO for up to 10 apps, basic MFA |
| P1 | Conditional Access, self-service password reset (SSPR), hybrid identity |
| P2 | Identity Protection, Privileged Identity Management (PIM) |

### Users and Groups
- **User accounts:** Cloud-only, synchronized from on-premises AD, or guest (B2B)
- **Group types:** Security groups (access to resources) vs. Microsoft 365 groups (collaboration)
- **Dynamic membership:** Rules auto-populate groups based on user attributes
- **Nested groups:** Supported but limit depth to avoid permission creep

### Devices
| Feature | Purpose |
|---------|---------|
| **Entra ID Joined** | Cloud-only devices; full Entra ID management |
| **Entra ID Registered** | BYOD; lighter management footprint |
| **Hybrid Entra ID Joined** | On-premises AD + Entra ID; requires Azure AD Connect |
| **MDM/Intune enrollment** | Device compliance policies enforced through Conditional Access |

### Hybrid Identity with Azure AD Connect
- **Password Hash Synchronization (PHS):** Hash of the on-premises password hash sent to cloud (default, most resilient)
- **Pass-Through Authentication (PTA):** Validates password against on-premises AD in real time
- **Federation (AD FS):** On-premises STS issues tokens; cloud trusts the STS
- **Seamless SSO:** Automatically signs users in on domain-joined devices without re-entering credentials

---

## 2. Multi-Factor Authentication and Conditional Access

### Multi-Factor Authentication (MFA)
MFA requires users to verify their identity using two or more factors:
1. **Something you know** — password, PIN
2. **Something you have** — authenticator app, hardware token, SMS
3. **Something you are** — biometric

**MFA Methods available in Entra ID:**
| Method | Security Level |
|--------|---------------|
| Microsoft Authenticator (push) | High |
| FIDO2 security key | Very High (phishing-resistant) |
| Windows Hello for Business | Very High (phishing-resistant) |
| Certificate-based authentication | High |
| OATH hardware token | Medium-High |
| OATH software token | Medium-High |
| SMS / voice call | Low (susceptible to SIM swap) |

**Per-user MFA vs. Security Defaults vs. Conditional Access MFA:**
- **Security Defaults:** Free tier; MFA for all users, blocks legacy auth — good starting point
- **Per-user MFA:** Legacy approach; static enforcement — not recommended for new deployments
- **Conditional Access:** P1/P2 required; policy-based, flexible; preferred approach

### Conditional Access

Conditional Access is the **Zero Trust policy engine** of Entra ID. It evaluates signals and enforces access controls at the time of authentication.

**Policy structure: IF (conditions) THEN (controls)**

**Conditions (signals):**
| Signal | Examples |
|--------|---------|
| User / Group | Specific users, roles, or guest accounts |
| Cloud app | Microsoft 365, Azure Portal, custom apps |
| Sign-in risk | Low / Medium / High (requires P2) |
| User risk | Low / Medium / High (requires P2) |
| Device platform | iOS, Android, Windows, macOS |
| Location | Named locations (IP ranges), countries |
| Client app | Browser, modern auth, legacy auth (Exchange ActiveSync) |
| Device state | Compliant (Intune), Hybrid Entra ID Joined |

**Access controls (grant/block):**
| Control | Description |
|---------|-------------|
| Block access | Denies authentication entirely |
| Require MFA | Step-up authentication |
| Require compliant device | Device must meet Intune compliance policies |
| Require Hybrid Entra ID Joined | Domain-joined + cloud-joined device |
| Require approved client app | Only allow specific mobile apps (MAM) |
| Require app protection policy | Intune App Protection Policy (MAM without enrollment) |
| Require password change | Force reset for risky users |
| Terms of use | Require acknowledgement |

**Session controls:**
- Sign-in frequency: re-authenticate after N hours/days
- Persistent browser session: control "stay signed in"
- App-enforced restrictions: Exchange Online / SharePoint specific controls
- Continuous Access Evaluation (CAE): token revocation in near-real-time

**Named Locations:**
- Define trusted IP ranges (e.g., corporate office CIDR blocks)
- Mark as "trusted" to reduce MFA friction for known-good locations
- Country/region-based locations for geo-blocking

**Common Conditional Access policy patterns:**
1. Require MFA for all users accessing Azure Portal
2. Block legacy authentication protocols (no modern auth = no access)
3. Require compliant device for access to sensitive apps
4. Block access from specific countries
5. Require MFA for all guest/external users
6. Session control: no persistent sessions on unmanaged devices

**Report-only mode:** Deploy CA policies in audit mode before enforcement to understand the impact.

---

## 3. Privileged Identity Management (PIM)

### What it is
PIM provides **just-in-time (JIT) privileged access** to Azure resources and Entra ID roles. It reduces the attack surface by ensuring high-privilege roles are not permanently assigned.

**Requires:** Entra ID P2 (or Microsoft Entra ID Governance)

### PIM Key Concepts

| Concept | Description |
|---------|-------------|
| **Eligible assignment** | User can *activate* the role when needed (not permanently active) |
| **Active assignment** | Role is always active (use sparingly for break-glass accounts) |
| **Activation** | User requests to activate an eligible role for a defined time window |
| **Approval workflow** | Activation can require approval from one or more approvers |
| **Activation duration** | Maximum hours a role stays active after activation (1–24 hours) |
| **MFA on activation** | Require MFA when activating a role |
| **Justification** | Require a business reason for activation |
| **Ticket number** | Optional: link to ITSM ticket |

### PIM for Entra ID Roles
- Manage Global Administrator, Privileged Role Administrator, Security Administrator, etc.
- Access reviews can be run to certify who should remain eligible
- Alerts: notify when roles are assigned outside PIM

### PIM for Azure Resources
- Manage Owner, Contributor, User Access Administrator at subscription/resource group/resource level
- Same JIT activation model as Entra ID roles

### PIM Access Reviews
- Periodically verify whether users still need their role assignments
- Reviewers can be: self, specific reviewer, or manager
- Auto-apply results: auto-remove if reviewers don't respond (no response = remove)
- Scope: specific role + all members or specific members

### Privileged Access Workstations (PAW)
- Dedicated, hardened devices used only for administrative tasks
- Enforce PAW usage via Conditional Access (device compliance + named location)

---

## 4. Managed Identities and Service Principals

### Service Principals
A **service principal** is the identity of an application or service in Entra ID. It is the non-human identity used by apps to authenticate to Azure services.

**Types:**
| Type | Description |
|------|-------------|
| **Application** | Created when registering an application; scoped to the registered app |
| **Managed Identity** | Automatically managed by Azure; no credential management |
| **Legacy** | Created by older tooling; avoid for new workloads |

### App Registrations vs. Enterprise Applications
| Object | Purpose |
|--------|---------|
| **App Registration** | Defines the application: client ID, permissions, redirect URIs, certificates/secrets |
| **Enterprise Application** | The service principal instance in your tenant; manages user assignment, SSO, provisioning |

### Managed Identities
Managed identities eliminate the need to store credentials in code or configuration.

| Type | Description | Use Case |
|------|-------------|----------|
| **System-assigned** | Tied to the lifecycle of a single resource; deleted with the resource | VMs, App Services, Functions accessing Key Vault |
| **User-assigned** | Independent lifecycle; can be assigned to multiple resources | Shared identity across multiple VMs or services |

**How it works:**
1. Enable managed identity on a resource (e.g., VM)
2. Azure creates a service principal in the tenant
3. Resource requests a token from the Instance Metadata Service (IMDS) endpoint
4. Token is used to authenticate to Azure services (Key Vault, Storage, SQL, etc.)
5. No password or certificate to manage or rotate

**Supported resources:** VMs, VMSS, App Service, Functions, Logic Apps, AKS, Container Instances, API Management, Service Bus, Event Hubs, and more

### Authenticating Applications: Client Credentials
When managed identities aren't available, apps authenticate using:
- **Client secret:** String credential — must be rotated; avoid storing in code
- **Client certificate:** More secure than secrets; store in Key Vault
- **Federated identity credential (Workload Identity Federation):** External identity provider (GitHub Actions, Kubernetes) — no secrets at all; preferred modern approach

### Microsoft Graph API Permissions
| Permission Type | Description |
|----------------|-------------|
| **Delegated** | App acts on behalf of a signed-in user |
| **Application** | App acts as itself with no user context (background services) |

Least-privilege principle: grant only the specific Graph scopes required.

---

## 5. Azure Role-Based Access Control (RBAC)

### RBAC Fundamentals
Azure RBAC is the authorization system for Azure resource management. It controls **who** can do **what** on **which** resources.

**Components:**
| Component | Description |
|-----------|-------------|
| **Security principal** | User, group, service principal, or managed identity |
| **Role definition** | Collection of permissions (Actions, NotActions, DataActions, NotDataActions) |
| **Scope** | Management group → Subscription → Resource group → Resource |
| **Role assignment** | Binds a security principal to a role at a scope |

### Built-in Roles (Critical for Exam)
| Role | Description |
|------|-------------|
| **Owner** | Full access including ability to assign roles (RBAC management) |
| **Contributor** | Full access to resources but cannot assign roles or manage Azure Policy |
| **Reader** | View-only access to all resources |
| **User Access Administrator** | Manage user access to resources (RBAC assignments only) |
| **Security Admin** | Manage security policies, view alerts — Defender for Cloud |
| **Security Reader** | View security posture, alerts, policies — read-only |
| **Key Vault Administrator** | Full Key Vault data plane access |
| **Key Vault Secrets Officer** | Read, write, delete secrets (not keys/certs) |
| **Storage Blob Data Owner** | Full blob data access |
| **Storage Blob Data Contributor** | Read, write, delete blob data (no RBAC assignment) |
| **Storage Blob Data Reader** | Read-only blob data access |
| **AcrPull** | Pull container images from Azure Container Registry |
| **AcrPush** | Push and pull container images from ACR |

### Scope Hierarchy
```
Management Group (root)
  └── Management Group (dept/env)
        └── Subscription
              └── Resource Group
                    └── Resource
```
Assignments at a higher scope are inherited by all child scopes.

### Custom Roles
When built-in roles don't fit, create custom roles:
```json
{
  "Name": "Virtual Machine Operator",
  "IsCustom": true,
  "Description": "Can monitor and restart virtual machines.",
  "Actions": [
    "Microsoft.Storage/*/read",
    "Microsoft.Network/*/read",
    "Microsoft.Compute/*/read",
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": ["/subscriptions/{subscriptionId}"]
}
```

**Key rules:**
- Max 5,000 custom roles per tenant (Azure RBAC limit)
- `NotActions` subtracts from `Actions` (not a deny — they can be overridden by another role assignment at the same scope that does allow the action)
- For a true deny, use **Azure RBAC Deny assignments** (created by Azure Blueprints, not directly by users)

### Deny Assignments
- Block principals from performing specific actions even if a role assignment grants access
- Currently only created by Azure Blueprints and Managed Applications
- Take precedence over role assignments

### RBAC vs. Entra ID Roles
| | Azure RBAC | Entra ID Roles |
|-|------------|----------------|
| **Controls** | Azure resources | Entra ID objects (users, groups, apps) |
| **Scope** | Management group/subscription/RG/resource | Tenant-wide or Administrative Unit |
| **Examples** | Contributor on a storage account | Global Administrator, Security Administrator |
| **Portal** | Access Control (IAM) blade | Entra admin center → Roles |

---

## 6. External Identities: B2B and B2C

### Azure AD B2B (Business-to-Business)
Invite external users (partners, vendors) to access your tenant's resources.

| Aspect | Detail |
|--------|--------|
| **Identity stays** | In the guest user's home tenant / identity provider |
| **Invitation method** | Email invitation, direct link, or bulk import (CSV) |
| **Supported IdPs** | Microsoft accounts, Google, Facebook, SAML/WS-Fed federation |
| **Access** | Any resource you explicitly share (SharePoint, Teams, Azure resources) |
| **License** | Guest users get a ratio of 1 MAU per P1/P2 license (5:1 ratio) |

**B2B best practices:**
- Require MFA for all guests via Conditional Access
- Enable access reviews to periodically verify guest access
- Use entitlement management (access packages) for self-service guest access
- Cross-tenant access settings: configure inbound/outbound trust policies per partner organization

### Azure AD B2C (Business-to-Consumer)
A separate Entra ID tenant for customer-facing apps. Supports consumer-scale identity for your applications.

| Aspect | Detail |
|--------|--------|
| **Identity owned by** | Your B2C tenant; customer creates an account with your app |
| **Supported IdPs** | Local accounts, Google, Facebook, Microsoft, Twitter, SAML, OpenID Connect |
| **User flows** | Pre-built policies: sign-up/sign-in, password reset, profile edit |
| **Custom policies** | XML-based Identity Experience Framework for advanced scenarios |
| **Scale** | Millions of users; separate from your organizational Entra ID tenant |
| **MFA** | Configurable within user flows |

**Key difference:** B2B = partners sharing your apps; B2C = customers using your apps.

---

## 7. Identity Protection

### What it is
Entra ID Identity Protection (P2 required) uses machine learning to detect risky sign-ins and compromised user accounts.

### Risk Types
| Risk Type | Detection Basis |
|-----------|----------------|
| **Sign-in risk** | Probability that a *specific sign-in* is not authorized by the legitimate user |
| **User risk** | Probability that a *user account* is compromised |

**Sign-in risk detections:**
- Anonymous IP address (Tor browser, VPN)
- Atypical travel (sign-ins from geographically distant locations in short time)
- Malware-linked IP address
- Unfamiliar sign-in properties
- Admin-confirmed compromised sign-in

**User risk detections:**
- Leaked credentials (password found in breach databases)
- Azure AD threat intelligence (Microsoft internal signals)
- Unusual activity patterns

### Risk Levels
`Low → Medium → High`

### Identity Protection Policies
| Policy | Trigger | Action |
|--------|---------|--------|
| **User risk policy** | User risk ≥ threshold | Block or require password change |
| **Sign-in risk policy** | Sign-in risk ≥ threshold | Block or require MFA |
| **MFA registration policy** | New users | Require MFA registration |

> **Best practice:** Configure these as Conditional Access policies (more flexible) rather than the legacy Identity Protection policy blades.

### Investigating and Remediating Risk
- **Dismiss user risk:** Admin confirms the user is safe (e.g., after verifying with user)
- **Confirm user compromised:** Admin confirms the account is compromised → triggers high-severity alert
- **Safe password reset:** User resets password via SSPR — user risk automatically remediated
- **Risky users report:** View all users with active risk
- **Risky sign-ins report:** View all sign-ins flagged as risky

---

## Key Exam Tips

1. **PIM vs. Conditional Access:** PIM controls *when* you can use a privileged role; Conditional Access controls *how* you access an app. They are complementary, not alternatives.

2. **Managed Identity priority:** Always prefer system-assigned managed identity for a single-resource workload; user-assigned for workloads requiring a shared identity across multiple resources.

3. **MFA methods hierarchy:** FIDO2 and Windows Hello are phishing-resistant (strongest); SMS is weakest and not recommended for high-security scenarios.

4. **Scope of deny assignments:** Deny assignments (from Blueprints) override role assignment grants. They do NOT override Owner permissions unless the Owner is explicitly listed in the deny.

5. **Security Defaults vs. Conditional Access:** Security Defaults are free but inflexible. Conditional Access (P1) gives granular control. For the exam, Security Defaults is the quick "block legacy auth + require MFA" answer.

6. **B2B vs. B2C:** B2B = your tenant + guest users from external orgs. B2C = separate tenant for consumer identities. Don't confuse them.

7. **Identity Protection requires P2.** If a scenario mentions detecting leaked credentials or risky sign-ins automatically, the answer involves Entra ID P2.

8. **Eligible vs. Active PIM assignments:** Eligible = activate on demand (JIT). Active = always active. Break-glass accounts should have permanent Active Global Admin assignments with strong controls.

---

> **Next:** [Domain 2 — Secure Networking →](02-secure-networking.md)
