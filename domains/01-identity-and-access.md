# Domain 1: Manage Identity and Access (30–35%)

> This domain is the largest on the AZ-500 exam. Expect 12–20 questions covering Microsoft Entra ID (formerly Azure AD), role-based access control, Privileged Identity Management, and conditional access.

---

## Table of Contents

1. [Microsoft Entra ID (Azure Active Directory)](#1-microsoft-entra-id)
2. [Azure RBAC (Role-Based Access Control)](#2-azure-rbac)
3. [Conditional Access](#3-conditional-access)
4. [Privileged Identity Management (PIM)](#4-privileged-identity-management-pim)
5. [Multi-Factor Authentication (MFA)](#5-multi-factor-authentication-mfa)
6. [Managed Identities](#6-managed-identities)
7. [Azure AD B2B and B2C](#7-azure-ad-b2b-and-b2c)
8. [Identity Protection](#8-identity-protection)
9. [Access Reviews](#9-access-reviews)
10. [Key Exam Topics Checklist](#10-key-exam-topics-checklist)

---

## 1. Microsoft Entra ID

### Overview
Microsoft Entra ID (formerly Azure Active Directory / Azure AD) is Microsoft's cloud-based identity and access management service. It is the foundation of security for all Azure resources.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Tenant** | A dedicated instance of Entra ID for an organization |
| **Directory** | Contains users, groups, and app registrations |
| **Subscription** | Linked to one tenant; a tenant can have multiple subscriptions |
| **User Types** | Member users vs Guest users (B2B) |

### Entra ID Tiers

| Tier | Key Features |
|------|-------------|
| **Free** | Basic directory, SSO for up to 10 apps, self-service password change |
| **P1** | Conditional Access, Hybrid identity, Group-based access, SSPR |
| **P2** | Identity Protection, Privileged Identity Management (PIM), Access Reviews |

### App Registrations vs Enterprise Applications

- **App Registration**: Defines the app's identity — client ID, redirect URIs, certificates/secrets
- **Enterprise Application (Service Principal)**: The instance of the app in your directory — controls who has access and what permissions

### Service Principals

```bash
# Create a service principal and assign Contributor role
az ad sp create-for-rbac --name "MyAppSP" --role Contributor \
  --scopes /subscriptions/<subscription-id>

# List service principals
az ad sp list --display-name "MyAppSP"
```

### Key Exam Points — Entra ID
- **Global Administrator** is the most privileged role in Entra ID (NOT in Azure RBAC)
- You can have multiple Global Admins; Microsoft recommends 2–4
- **Emergency access accounts** (break-glass) should be excluded from Conditional Access and MFA policies
- Tenant ID is unique and immutable; it never changes

---

## 2. Azure RBAC

### Overview
Azure Role-Based Access Control (RBAC) manages access to Azure **resources** (not directory objects — that's Entra ID roles).

### RBAC Key Concepts

| Concept | Description |
|---------|-------------|
| **Security Principal** | User, group, service principal, or managed identity |
| **Role Definition** | Collection of permissions (Actions, NotActions, DataActions, NotDataActions) |
| **Scope** | Management Group → Subscription → Resource Group → Resource |
| **Role Assignment** | Binding of role definition to security principal at a scope |

### Built-in Roles (Most Important for Exam)

| Role | Permissions |
|------|-------------|
| **Owner** | Full access including ability to assign roles to others |
| **Contributor** | Full access to manage resources but CANNOT assign roles |
| **Reader** | View-only access |
| **User Access Administrator** | Manage user access to Azure resources only |

### Security-Specific Built-in Roles

| Role | Use Case |
|------|----------|
| **Security Admin** | View and update security policy; dismiss alerts; manage Defender for Cloud |
| **Security Reader** | View security policy, recommendations, and alerts (read-only) |
| **Security Operator** | Manage security alerts; cannot change policies |
| **Key Vault Administrator** | Full access to Key Vault operations |
| **Key Vault Secrets Officer** | Read/write secrets; cannot manage permissions |
| **Key Vault Secrets User** | Read secrets only |

### Custom Roles

```json
{
  "Name": "Custom VM Operator",
  "Description": "Can start/stop VMs but not create or delete",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
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

```bash
# Create custom role from JSON file
az role definition create --role-definition @custom-role.json

# Assign a role
az role assignment create \
  --assignee <user-or-sp-object-id> \
  --role "Contributor" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg-name>
```

### Key Exam Points — RBAC
- Role assignments are **additive** — a user gets the union of all assigned roles
- **Deny assignments** override role assignments; they are set by Azure Blueprints/Policy only (not manually)
- RBAC is evaluated **at the time of the request**, not at the time of assignment
- **NotActions** are NOT deny rules — they just remove permissions from the Actions list
- A **Contributor** cannot assign roles; only **Owner** or **User Access Administrator** can
- Scope inheritance: permissions assigned at a higher scope inherit down

---

## 3. Conditional Access

### Overview
Conditional Access is an Entra ID P1/P2 feature that enforces access controls based on signals (conditions) before granting access.

### Conditional Access Components

```
IF (signal conditions are met) THEN (enforce controls)
```

| Signal (Condition) | Examples |
|-------------------|----------|
| **User/Group** | All users, specific groups, guest users |
| **Cloud app** | All apps, specific apps (e.g., Office 365) |
| **User risk** | Low, Medium, High (requires P2) |
| **Sign-in risk** | Low, Medium, High (requires P2) |
| **Device platform** | Windows, iOS, Android, macOS |
| **Location** | Named locations, trusted IPs, countries |
| **Client apps** | Browser, mobile apps, legacy auth clients |
| **Device state** | Compliant, hybrid Entra ID joined |

| Access Control | Options |
|---------------|---------|
| **Grant** | Block access, Require MFA, Require compliant device, Require Entra joined, Require approved app, Require app protection policy |
| **Session** | App enforced restrictions, Conditional Access App Control (MCAS), Sign-in frequency, Persistent browser session |

### Named Locations

- Define trusted IP ranges or country/region-based locations
- Used to exclude trusted locations from MFA requirements
- Can be marked as "trusted" to reduce sign-in risk

### Conditional Access Policies — Best Practices

```
Policy 1: Require MFA for all users
- Users: All users
- Exclude: Emergency access accounts, service accounts
- Cloud apps: All cloud apps
- Grant: Require MFA

Policy 2: Block legacy authentication
- Users: All users
- Client apps: Exchange ActiveSync, Other clients (legacy)
- Grant: Block access

Policy 3: Require compliant device for privileged roles
- Users: Directory roles (Global Admin, etc.)
- Grant: Require compliant device OR Require Entra hybrid join
```

### Key Exam Points — Conditional Access
- **Report-only mode** tests the policy without enforcing it (logs results in sign-in logs)
- Conditional Access requires **Entra ID P1** minimum; risk-based policies need **P2**
- **Block** takes precedence over **Grant** controls
- Conditional Access does NOT apply to service accounts using client credentials flow (app-only)
- Legacy authentication (SMTP, POP3, IMAP, older Office clients) cannot support MFA — always block it

---

## 4. Privileged Identity Management (PIM)

### Overview
PIM (Entra ID P2 feature) provides just-in-time (JIT) privileged access, requiring activation for sensitive roles rather than permanent assignment.

### PIM Role States

| State | Description |
|-------|-------------|
| **Eligible** | User can activate the role when needed (JIT access) |
| **Active** | Role is currently active for the user |
| **Permanent Eligible** | Can always activate; no expiration on eligibility |
| **Time-bound Eligible** | Eligibility expires after a set date |
| **Permanent Active** | Always active, no activation required (avoid for privileged roles) |

### PIM Activation Settings (Per Role)

- **Activation duration**: Maximum hours the role stays active (1–24 hours)
- **Require justification**: User must provide a business justification
- **Require ticket information**: User must provide a support ticket number
- **Require MFA on activation**: Enforces MFA during the activation step
- **Require approval**: One or more approvers must approve activation requests
- **Notification**: Email notifications to admins when roles are activated

### PIM Access Reviews

- Periodically review who has eligible/active assignments
- Reviewers can be: the user themselves, specific reviewers, manager
- On expiration: remove access or keep access

### Azure Resource Roles in PIM

PIM also manages Azure RBAC roles (not just Entra ID roles):
- Owner, Contributor, User Access Administrator at subscription/RG/resource scope
- Activate with time-bound, JIT access

### Key Exam Points — PIM
- PIM requires **Entra ID P2**
- A user with an **eligible** assignment has **no access** until they activate the role
- PIM activation goes through **MFA** (if configured) even if the user already completed MFA for sign-in
- **Privileged Role Administrator** role manages PIM settings
- PIM audit logs capture all activation/deactivation events
- Always use **eligible** assignments for privileged roles; avoid permanent active assignments

---

## 5. Multi-Factor Authentication (MFA)

### Overview
MFA requires users to provide two or more verification methods to authenticate.

### MFA Methods

| Method | Security Level | Notes |
|--------|---------------|-------|
| Microsoft Authenticator app (push) | High | Recommended; supports number matching |
| FIDO2 security key | Very High | Phishing-resistant; passwordless |
| Windows Hello for Business | Very High | Phishing-resistant; passwordless |
| Certificate-based authentication | Very High | Smart card equivalent |
| OATH hardware token (TOTP) | High | Physical token |
| OATH software token (TOTP) | Medium-High | Authenticator app TOTP |
| SMS/Voice | Low | Vulnerable to SIM swapping; avoid if possible |

### MFA Enforcement Methods

1. **Per-user MFA** (legacy): Enable MFA for individual users in the portal
2. **Security Defaults**: Free tier; enables MFA for all users; blocks legacy auth
3. **Conditional Access** (recommended): Granular, policy-based MFA enforcement

### Security Defaults

- Free for all Entra ID tenants
- Requires MFA for all users
- Requires MFA always for administrators
- Blocks legacy authentication protocols
- **Incompatible** with Conditional Access — you must disable Security Defaults to use CA policies

### MFA Registration

- Users register via `aka.ms/mfasetup` or `mysignins.microsoft.com`
- **Combined security info registration**: Registers MFA + SSPR in one experience
- Admins can require MFA registration at next sign-in

### Number Matching

- Mitigates MFA fatigue attacks (push notification bombing)
- User must enter the number shown on the sign-in screen into the Authenticator app
- **Enabled by default** in the Microsoft Authenticator settings

### Key Exam Points — MFA
- **Security Defaults** and **Conditional Access** cannot coexist — disable Security Defaults first
- SMS/Voice is considered less secure; Authenticator push notifications are the default fallback
- **Number matching** is enabled by default to combat MFA fatigue attacks
- **FIDO2 keys** and **Windows Hello for Business** are phishing-resistant MFA methods
- Azure AD / Entra ID Free tier: use Security Defaults; P1/P2: use Conditional Access

---

## 6. Managed Identities

### Overview
Managed identities eliminate the need for developers to store credentials in code or configuration. Azure automatically manages the identity lifecycle.

### Types of Managed Identities

| Type | Description | Use Case |
|------|-------------|----------|
| **System-assigned** | Created and lifecycle-tied to a specific Azure resource | One resource needs to access one service |
| **User-assigned** | Standalone identity; can be assigned to multiple resources | Multiple resources share the same identity |

### Enabling Managed Identity

```bash
# Enable system-assigned identity on a VM
az vm identity assign --name MyVM --resource-group MyRG

# Create user-assigned managed identity
az identity create --name MyManagedIdentity --resource-group MyRG

# Assign user-assigned identity to a VM
az vm identity assign --name MyVM --resource-group MyRG \
  --identities /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyManagedIdentity
```

### Granting Access to Resources

```bash
# Get the principal ID of the managed identity
PRINCIPAL_ID=$(az vm show --name MyVM --resource-group MyRG \
  --query "identity.principalId" -o tsv)

# Assign Key Vault Secrets User role to the VM's identity
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>
```

### Accessing Secrets from Code

```python
# Python example using managed identity
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://<vault-name>.vault.azure.net/", credential=credential)
secret = client.get_secret("my-secret")
print(secret.value)
```

### Key Exam Points — Managed Identities
- **System-assigned** identity is deleted when the resource is deleted
- **User-assigned** identity persists independently; must be explicitly deleted
- Managed identities work with any service that supports Entra ID authentication
- Use managed identities instead of service principals with passwords/certificates when possible
- Managed identities are backed by service principals internally

---

## 7. Azure AD B2B and B2C

### B2B (Business-to-Business)

| Feature | Details |
|---------|---------|
| **Purpose** | Collaborate with external users (partners, vendors) |
| **User type** | Guest users in your directory |
| **Authentication** | External users authenticate with their own IdP (Google, Microsoft, etc.) |
| **Access** | Granted to specific resources or apps; governed by your policies |
| **MFA** | Can be required by your Conditional Access policies |

```bash
# Invite a guest user (B2B)
az ad user invite --invited-user-email-address partner@contoso.com \
  --invite-redirect-url https://myapp.example.com
```

### B2B Direct Connect

- Allows users from trusted organizations to access specific Teams channels directly
- No guest user object created in your directory
- Requires cross-tenant access settings (External Identities)

### B2C (Business-to-Consumer)

| Feature | Details |
|---------|---------|
| **Purpose** | Identity for customer-facing applications |
| **User type** | Consumer/customer accounts (not in corporate directory) |
| **Authentication** | Social identity providers (Google, Facebook, Apple) or local accounts |
| **Tenant** | Separate B2C tenant from corporate Entra ID tenant |
| **Policies** | User flows (sign-up, sign-in, profile edit, password reset) |

### Cross-Tenant Access Settings

- **Inbound**: What external users can access in your tenant
- **Outbound**: What your users can access in external tenants
- Settings: Trust MFA claims, trust compliant device claims, trust Entra hybrid joined claims

### Key Exam Points — B2B/B2C
- B2B users are **guest** users; they appear in your directory with userType = "Guest"
- B2C requires a **separate tenant** — it cannot be configured in your corporate tenant
- B2B guests use their **home tenant's** credentials for authentication
- You can enforce MFA on B2B guests through Conditional Access (don't trust their MFA)
- **Cross-tenant access settings** let you trust MFA from partner tenants

---

## 8. Identity Protection

### Overview
Entra ID Identity Protection (P2 feature) uses machine learning to detect and respond to identity-based risks.

### Risk Types

| Risk Type | Scope | Examples |
|-----------|-------|---------|
| **User risk** | Reflects the probability that an identity is compromised | Leaked credentials, dark web exposure |
| **Sign-in risk** | Reflects the probability that a specific authentication is not from the account owner | Atypical travel, anonymous IP, malware-linked IP |

### Risk Levels

| Level | Description |
|-------|-------------|
| **High** | Strong confidence of compromise; immediate action required |
| **Medium** | Suspicious but uncertain; requires investigation |
| **Low** | Low probability of compromise; monitor only |
| **None** | No risk detected |

### Identity Protection Policies

1. **User risk policy**: Automatically remediate or block when user risk reaches a threshold
   - Recommended: Require password change for Medium+ user risk
2. **Sign-in risk policy**: Require MFA or block when sign-in risk reaches a threshold
   - Recommended: Require MFA for Medium+ sign-in risk
3. **MFA registration policy**: Require all users to register for MFA within a time window

> **Note**: As of 2024, Microsoft recommends managing these policies through **Conditional Access** instead of the dedicated Identity Protection policy blades.

### Remediation Actions

| Action | Effect |
|--------|--------|
| **Self-remediation** | User completes MFA or password change to dismiss risk |
| **Admin dismiss** | Admin manually marks risk as resolved |
| **Admin confirm compromised** | Admin confirms compromise; user is blocked |
| **Reset password** | Admin resets password, clearing user risk |

### Key Exam Points — Identity Protection
- Identity Protection requires **Entra ID P2**
- **Leaked credentials** detection is automatic — Microsoft monitors dark web databases
- Risk-based Conditional Access policies are the modern way to configure Identity Protection responses
- Dismissed risks are marked as "Dismissed" and do not affect the user's risk score
- **Confirmed compromised** blocks the user immediately and revokes all active sessions

---

## 9. Access Reviews

### Overview
Access Reviews (Entra ID P2) allow organizations to regularly review and recertify user access to groups, applications, and privileged roles.

### Access Review Types

| Review Type | Purpose |
|-------------|---------|
| **Group membership** | Review who is a member of a security group or Microsoft 365 group |
| **Application access** | Review who has been assigned to an enterprise application |
| **Azure resource roles** | Review who has PIM-eligible/active assignments for Azure roles |
| **Entra ID roles** | Review who has PIM assignments for directory roles |

### Access Review Settings

- **Reviewers**: Users themselves (self-review), specific users, group owners, managers
- **Duration**: 1–365 days
- **Recurrence**: One-time, weekly, monthly, quarterly, semi-annually, annually
- **Auto-apply results**: Automatically remove or approve access based on reviewer decision
- **If reviewer doesn't respond**: Keep access, Remove access, or Take recommendations

### Microsoft's Recommendations (Auto-Apply)

When a reviewer doesn't respond within the review window:
- **Deny inactive users**: Auto-deny users who haven't signed in for 30+ days
- **Approve active users**: Auto-approve users who have signed in recently

### Key Exam Points — Access Reviews
- Access Reviews require **Entra ID P2**
- Reviews can be **delegated** — resource owners can run reviews for their own resources
- **Guest users** should be reviewed regularly (recommended: every 90 days)
- Access Reviews integrate with PIM for privileged role recertification
- Results can be **auto-applied** to remove access without admin intervention

---

## 10. Key Exam Topics Checklist

### Must-Know for Domain 1

- [ ] Difference between Entra ID roles (directory) and Azure RBAC roles (resources)
- [ ] Global Administrator vs Owner vs Contributor vs User Access Administrator
- [ ] Entra ID P1 vs P2 feature differences
- [ ] Conditional Access conditions and controls
- [ ] How to block legacy authentication with Conditional Access
- [ ] PIM eligible vs active role assignments
- [ ] PIM activation workflow and settings (MFA, justification, approval)
- [ ] System-assigned vs user-assigned managed identities
- [ ] How to grant a managed identity access to Key Vault
- [ ] MFA methods and their security levels
- [ ] Security Defaults vs Conditional Access (cannot coexist)
- [ ] B2B vs B2C use cases
- [ ] Identity Protection risk types (user risk vs sign-in risk)
- [ ] Access Reviews configuration and auto-apply settings

---

## 📖 Microsoft Learn Resources

- [Manage identities and governance in Azure](https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/)
- [Implement identity management solutions](https://learn.microsoft.com/en-us/training/paths/implement-identity-management-solutions/)
- [Implement access management for Azure resources](https://learn.microsoft.com/en-us/training/paths/implement-access-management-for-azure-resources/)
- [Plan and implement Privileged Identity Management](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure)
- [What is Conditional Access?](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview)

---

*← [Back to README](../README.md) | [Domain 2: Secure Networking →](02-secure-networking.md)*
