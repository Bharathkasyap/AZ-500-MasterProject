# Domain 1: Manage Identity and Access (25–30%)

> This domain is one of the highest-weighted areas of the AZ-500 exam. Master Azure Active Directory (Microsoft Entra ID), Conditional Access, PIM, and RBAC.

---

## Objectives Covered

- Manage Azure Active Directory (Microsoft Entra ID) identities
- Manage secure access by using Azure AD
- Manage application access in Azure AD
- Manage access control (Azure RBAC)

---

## 1.1 Azure Active Directory (Microsoft Entra ID)

### Core Concepts

**Azure Active Directory** (now branded **Microsoft Entra ID**) is Microsoft's cloud-based identity and access management service. It is the backbone of Azure security.

| Feature | Description |
|---|---|
| Tenants | An isolated instance of Azure AD representing an organization |
| Users | Cloud or synchronized identities |
| Groups | Security groups, Microsoft 365 groups, dynamic groups |
| Devices | Azure AD joined, hybrid joined, registered |
| Service principals | Identity for applications and automation |
| Managed identities | Automatically managed service principals for Azure resources |

### Azure AD Editions

| Edition | Key Features |
|---|---|
| Free | Basic user/group management, SSO for 10 apps |
| P1 (Premium P1) | Conditional Access, hybrid identity, self-service group management |
| P2 (Premium P2) | Identity Protection, Privileged Identity Management (PIM) |

> ⚠️ **Exam tip:** PIM and Identity Protection both require **Azure AD Premium P2**.

### User Account Types

- **Cloud identity:** Created directly in Azure AD
- **Synchronized identity:** Synced from on-premises AD via Azure AD Connect
- **Guest identity (B2B):** External user invited via Azure AD B2B collaboration

### Azure AD Connect

- Synchronizes on-premises Active Directory to Azure AD
- Authentication methods: **Password Hash Sync (PHS)**, **Pass-through Authentication (PTA)**, **Federation (AD FS)**
- **Seamless SSO** enables users to sign in without re-entering passwords on domain-joined machines

---

## 1.2 Conditional Access

Conditional Access is the **Zero Trust policy engine** of Azure AD. It evaluates signals and enforces access controls.

### Key Signals (Conditions)
- **User or group membership**
- **IP location / Named locations**
- **Device platform** (iOS, Android, Windows)
- **Device compliance state** (requires Intune)
- **Application** (specific cloud app)
- **Sign-in risk** (requires Identity Protection / P2)
- **User risk** (requires Identity Protection / P2)

### Access Controls (Grant)
- Block access
- Require multi-factor authentication (MFA)
- Require Hybrid Azure AD joined device
- Require compliant device
- Require approved client app
- Require app protection policy

### Session Controls
- Use app enforced restrictions
- Use Conditional Access App Control (Microsoft Defender for Cloud Apps)
- Sign-in frequency
- Persistent browser session

### Common Policies
```
// Require MFA for all administrators
Assignments:
  Users: Directory roles → Global Administrator, Security Administrator, etc.
  Cloud apps: All cloud apps
Grant:
  Require multi-factor authentication
```

```
// Block legacy authentication
Conditions:
  Client apps: Exchange ActiveSync clients + Other clients (legacy)
Grant:
  Block access
```

> ⚠️ **Exam tip:** Always create a **break-glass (emergency access) account** and **exclude it from all Conditional Access policies** to prevent admin lockout.

---

## 1.3 Multi-Factor Authentication (MFA)

### MFA Methods
| Method | Strength |
|---|---|
| Microsoft Authenticator app (push) | High |
| FIDO2 security key | Very High (passwordless) |
| Windows Hello for Business | Very High (passwordless) |
| OATH hardware token | High |
| SMS / Voice call | Lower (vulnerable to SIM swap) |
| Certificate-based authentication | High |

### MFA Registration & SSPR
- **Combined security info registration:** Single registration experience for MFA and Self-Service Password Reset (SSPR)
- **SSPR** requires Azure AD P1 for cloud-only users, P1 for hybrid writeback

### Per-User MFA vs Conditional Access MFA
- **Per-user MFA:** Legacy method; enabled/disabled per user; not recommended
- **Conditional Access MFA:** Policy-based; recommended approach; requires P1

---

## 1.4 Privileged Identity Management (PIM)

PIM provides **just-in-time privileged access** to Azure AD and Azure resources.

### Key Features
- **Eligible assignments:** User must activate the role (triggers MFA + optional approval)
- **Active assignments:** Always-on role (use sparingly)
- **Time-bound access:** Maximum activation duration (e.g., 1–8 hours)
- **Approval workflow:** Designated approvers must approve activation
- **Access reviews:** Periodic certification of role assignments
- **Audit history:** Full log of all activations and approvals

### PIM Role Types
| Scope | Role Examples |
|---|---|
| Azure AD roles | Global Administrator, Security Administrator, Privileged Role Administrator |
| Azure resource roles | Owner, Contributor, User Access Administrator |

### PIM Activation Flow
```
1. User navigates to PIM in Azure Portal
2. Selects the eligible role to activate
3. Provides justification / ticket number
4. MFA challenge (if required)
5. Waits for approval (if required)
6. Role becomes active for specified duration
7. Role expires automatically
```

> ⚠️ **Exam tip:** The **Privileged Role Administrator** role in Azure AD manages PIM for Azure AD roles. The **Owner** or **User Access Administrator** role manages PIM for Azure resource roles.

---

## 1.5 Identity Protection

Azure AD Identity Protection (P2) uses ML to detect risky sign-ins and users.

### Risk Types
| Risk | Examples |
|---|---|
| Sign-in risk | Anonymous IP, atypical travel, malware-linked IP, password spray, impossible travel |
| User risk | Leaked credentials, Azure AD threat intelligence |

### Risk Levels
- Low, Medium, High, None

### Identity Protection Policies
1. **User risk policy:** Trigger when user risk ≥ threshold → require password change
2. **Sign-in risk policy:** Trigger when sign-in risk ≥ threshold → require MFA
3. **MFA registration policy:** Require all users to register for MFA

> 💡 Microsoft recommends migrating Identity Protection policies to **Conditional Access** (which now supports risk-based conditions with P2).

---

## 1.6 Managed Identities

Managed identities eliminate the need to store credentials in code.

### Types
| Type | Description | Lifecycle |
|---|---|---|
| System-assigned | Created for a single Azure resource | Deleted when resource is deleted |
| User-assigned | Created as standalone Azure resource | Independent lifecycle; can be assigned to multiple resources |

### Supported Resources
Azure VMs, App Service, Azure Functions, Azure Container Instances, AKS, Logic Apps, and more.

### How to Use
```bash
# Assign system-assigned managed identity to a VM
az vm identity assign \
  --resource-group myRG \
  --name myVM

# Grant the identity access to Key Vault secrets
az keyvault set-policy \
  --name myKeyVault \
  --object-id <principalId-from-above> \
  --secret-permissions get list
```

---

## 1.7 Azure Role-Based Access Control (RBAC)

Azure RBAC controls access to **Azure resources** (separate from Azure AD role assignments).

### RBAC Components
- **Security principal:** User, group, service principal, managed identity
- **Role definition:** Collection of permissions (Actions, NotActions, DataActions, NotDataActions)
- **Scope:** Management group → Subscription → Resource group → Resource
- **Role assignment:** Binds principal + role + scope

### Key Built-in Roles
| Role | Description |
|---|---|
| Owner | Full access + can delegate access |
| Contributor | Full access, cannot delegate access |
| Reader | Read-only access |
| User Access Administrator | Manages access (but not resources) |
| Security Admin | View and update security policies |
| Security Reader | View security state |

### Custom Roles
```json
{
  "Name": "VM Operator",
  "Description": "Can start/stop VMs but cannot create or delete",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "AssignableScopes": [
    "/subscriptions/<subscriptionId>"
  ]
}
```

### Azure AD Roles vs Azure RBAC Roles

| Aspect | Azure AD Roles | Azure RBAC Roles |
|---|---|---|
| Manages | Azure AD objects (users, groups, apps) | Azure resources (VMs, storage, etc.) |
| Portal | Azure AD blade | Subscriptions / Resource Groups blade |
| Scope | Tenant-wide (or Administrative Unit) | Management group / Subscription / RG / Resource |
| Examples | Global Admin, Security Admin | Owner, Contributor, Reader |

> ⚠️ **Exam tip:** These are **two separate control planes**. A Global Administrator does NOT automatically have Owner on Azure subscriptions.

---

## 1.8 Application Access & Service Principals

### App Registration vs Enterprise Application
- **App Registration:** Developer-facing; defines the application's identity, permissions, and secrets
- **Enterprise Application (Service Principal):** Tenant-facing representation of the app; manages user assignment and SSO

### OAuth 2.0 Permission Types
| Type | Description |
|---|---|
| Delegated permissions | App acts on behalf of a signed-in user |
| Application permissions | App acts as itself (no user context) — requires admin consent |

### Admin Consent
- Required for application permissions
- Granted by a **Global Administrator** or **Privileged Role Administrator**

---

## 🔬 Practice Questions

**Q1.** A company requires that all Global Administrators activate their role for a maximum of 2 hours and must provide an approval before activation. Which Azure service should be configured?
> **Answer:** Azure AD Privileged Identity Management (PIM) — configure eligible assignment with approval required and maximum activation duration of 2 hours.

**Q2.** You need to implement a Conditional Access policy that requires MFA only when users sign in from outside the corporate network. What should you configure as the condition?
> **Answer:** Named locations — define the corporate IP range as a trusted named location, then set the policy to apply when the location is **not** the trusted named location.

**Q3.** A web application running on an Azure VM needs to read secrets from Azure Key Vault without storing any credentials. What is the recommended approach?
> **Answer:** Enable a **system-assigned managed identity** on the VM and grant it the **Key Vault Secrets User** role (or Key Vault access policy) on the Key Vault.

**Q4.** What is the minimum Azure AD license required to use Azure AD Identity Protection?
> **Answer:** Azure AD Premium P2.

**Q5.** A user has the Contributor role on a resource group and the Reader role on a specific storage account in that resource group. What is the user's effective permission on the storage account?
> **Answer:** Contributor (more permissive role wins; RBAC uses additive permissions — the most permissive applicable role applies).

---

## 📚 Further Reading

- [Azure AD documentation](https://learn.microsoft.com/en-us/azure/active-directory/)
- [Conditional Access overview](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview)
- [What is PIM?](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure)
- [Managed identities overview](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Azure RBAC overview](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)

---

*Next: [Domain 2 — Secure Networking →](02-secure-networking.md)*
