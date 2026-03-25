# Domain 1: Manage Identity and Access (25–30%)

> **Back to [README](../README.md)**

---

## Overview

Identity and Access Management (IAM) is the foundation of Azure security. This domain covers Microsoft Entra ID (formerly Azure Active Directory), multi-factor authentication, Privileged Identity Management, and identity governance.

---

## 1.1 Manage Microsoft Entra Identities

### Key Concepts

**Microsoft Entra ID (Azure AD)** is Microsoft's cloud-based identity and access management service. It provides authentication and authorization for cloud and on-premises resources.

| Concept | Description |
|---|---|
| **Tenant** | A dedicated instance of Entra ID for an organization |
| **User** | An individual account within a tenant |
| **Group** | A collection of users used for access assignment |
| **Service Principal** | An application identity for resource access |
| **Managed Identity** | System/user-assigned identity for Azure resources (no credential management) |

### User Account Types

| Type | Description |
|---|---|
| **Cloud Identity** | Users managed in Entra ID (e.g., `user@contoso.onmicrosoft.com`) |
| **Directory-Synchronized** | Users synced from on-premises AD via Azure AD Connect |
| **Guest Users (B2B)** | External users invited to collaborate |

### Creating Users — Azure CLI

```bash
# Create a new user
az ad user create \
  --display-name "John Smith" \
  --user-principal-name john@contoso.onmicrosoft.com \
  --password "P@ssw0rd1!" \
  --force-change-password-next-sign-in true

# Create a guest user (B2B invitation)
az ad invitation create \
  --invited-user-email external@partner.com \
  --invite-redirect-url "https://myapp.contoso.com"
```

### Creating Users — PowerShell

```powershell
# Install module if needed
Install-Module -Name Microsoft.Graph -Scope CurrentUser

# Connect
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Create user
$passwordProfile = @{
    Password = "P@ssw0rd1!"
    ForceChangePasswordNextSignIn = $true
}
New-MgUser -DisplayName "John Smith" `
  -UserPrincipalName "john@contoso.onmicrosoft.com" `
  -PasswordProfile $passwordProfile `
  -AccountEnabled
```

### Managed Identities

**System-assigned**: Tied to the lifecycle of an Azure resource (auto-deleted when resource is deleted).  
**User-assigned**: Standalone identity that can be assigned to multiple resources.

```bash
# Enable system-assigned managed identity on a VM
az vm identity assign \
  --name myVM \
  --resource-group myRG

# Create and assign user-assigned managed identity
az identity create --name myIdentity --resource-group myRG
az vm identity assign \
  --name myVM \
  --resource-group myRG \
  --identities myIdentity
```

---

## 1.2 Manage Microsoft Entra Authentication

### Multi-Factor Authentication (MFA)

MFA requires users to provide two or more verification methods:
- **Something you know** — password or PIN
- **Something you have** — authenticator app, SMS, phone call, hardware token
- **Something you are** — biometrics (fingerprint, face)

#### MFA Methods Available in Entra ID

| Method | Security Level | Notes |
|---|---|---|
| Microsoft Authenticator App (Push) | High | Recommended — supports number matching |
| FIDO2 Security Keys | Very High | Phishing-resistant |
| Windows Hello for Business | Very High | Certificate or PIN based |
| OATH Hardware Tokens | High | Time-based OTP |
| SMS / Voice Call | Low | Susceptible to SIM-swap attacks |

#### Enable MFA via Conditional Access (Recommended)

```
Azure Portal → Entra ID → Security → Conditional Access → + New Policy
  - Assignments: Users/Groups → Select target group
  - Conditions: (optional) sign-in risk, location, device state
  - Access Controls → Grant → Require multi-factor authentication
  - Enable policy: ON
```

### Self-Service Password Reset (SSPR)

SSPR allows users to reset passwords without help-desk intervention.

```
Azure Portal → Entra ID → Password reset → Properties → Self service password reset → Enabled
```

Authentication methods for SSPR (configure at least 2):
- Mobile app notification
- Mobile app code
- Email
- Mobile phone
- Office phone
- Security questions

### Password Protection

**Azure AD Password Protection** prevents weak passwords using:
- Global banned password list (maintained by Microsoft)
- Custom banned password list (up to 1,000 custom entries)

```
Azure Portal → Entra ID → Security → Authentication Methods → Password Protection
```

On-premises integration: Deploy **Azure AD Password Protection Proxy** and **DC Agent** on domain controllers.

---

## 1.3 Manage Microsoft Entra Authorization

### Role-Based Access Control (RBAC)

RBAC controls access to Azure resources at subscription, resource group, or resource level.

#### RBAC Hierarchy

```
Management Group
  └── Subscription
        └── Resource Group
              └── Resource
```

Roles are inherited downward. A role assigned at Subscription level applies to all Resource Groups and Resources within it.

#### Built-in Roles (Key Ones)

| Role | Permissions |
|---|---|
| **Owner** | Full access + manage access (assign roles) |
| **Contributor** | Full access to manage resources, cannot manage access |
| **Reader** | View-only access |
| **User Access Administrator** | Manage user access to Azure resources |
| **Security Admin** | View/update security policies, dismiss alerts |
| **Security Reader** | View security policies and alerts |
| **Key Vault Administrator** | Full Key Vault data plane access |

#### Assign a Role — Azure CLI

```bash
# Assign Contributor at resource group level
az role assignment create \
  --assignee john@contoso.com \
  --role "Contributor" \
  --resource-group myRG

# Assign Reader at subscription level
az role assignment create \
  --assignee john@contoso.com \
  --role "Reader" \
  --scope "/subscriptions/<subscription-id>"
```

#### Custom RBAC Roles

```json
{
  "Name": "Virtual Machine Operator",
  "IsCustom": true,
  "Description": "Can start and stop VMs",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": ["/subscriptions/<subscription-id>"]
}
```

```bash
az role definition create --role-definition custom-role.json
```

### Azure AD Roles vs Azure RBAC Roles

| | Azure AD Roles | Azure RBAC Roles |
|---|---|---|
| **Scope** | Tenant-wide (Entra ID objects) | Azure resource hierarchy |
| **Examples** | Global Administrator, User Administrator | Owner, Contributor, Reader |
| **Managed in** | Entra ID Portal | Azure Portal / ARM |

---

## 1.4 Manage Privileged Access

### Privileged Identity Management (PIM)

PIM provides **just-in-time (JIT)** privileged access to minimize standing access.

#### Key Features

| Feature | Description |
|---|---|
| **Eligible Assignments** | Users must activate the role to use it |
| **Time-bound Access** | Roles expire after a configured period |
| **Activation Approval** | Require approval before activation |
| **MFA on Activation** | Require MFA at activation time |
| **Access Reviews** | Periodic reviews of who has access |
| **Audit Logs** | All activations and approvals are logged |

#### Configure PIM — Portal Steps

```
Azure Portal → Entra ID → Privileged Identity Management
  → Manage → Azure AD Roles (or Azure Resources)
  → Roles → Select role (e.g., Global Administrator)
  → Add assignments → Select user
  → Assignment type: Eligible
  → Duration: bounded or permanent (eligible)
```

#### Activating a PIM Role (as a user)

```
Entra ID → PIM → My Roles → Activate → Provide reason → Activate
```

### Access Reviews

Access reviews ensure that only the right people have access to resources.

```
Entra ID → Identity Governance → Access Reviews → New access review
  - Review type: Teams + Groups / Applications / Azure AD Roles
  - Reviewers: Managers / Group owners / Selected reviewers / Users review own access
  - Duration: Weekly / Monthly / Quarterly
```

---

## 1.5 Manage Microsoft Entra Application Access

### Enterprise Applications & App Registrations

| Concept | Description |
|---|---|
| **App Registration** | Defines what the app is (metadata, permissions required) |
| **Enterprise Application** | The service principal — how the app is used in the tenant |
| **OAuth 2.0 / OpenID Connect** | Standard protocols used for delegated and app-only access |

### Application Permissions vs Delegated Permissions

| Type | Description | Who consents |
|---|---|---|
| **Delegated** | App acts on behalf of a signed-in user | User (or admin for sensitive scopes) |
| **Application** | App acts as itself (no user) | Admin only |

### Conditional Access App Control

Configure Conditional Access policies targeting specific applications:

```
Entra ID → Security → Conditional Access → New Policy
  → Assignments → Cloud apps or actions → Select Apps
  → Access controls → Session → Use Conditional Access App Control
```

### Managed Identities for App Access

Instead of storing credentials in app config, use managed identity:

```csharp
// .NET — Use DefaultAzureCredential (picks up managed identity automatically)
var client = new SecretClient(
    new Uri("https://mykeyvault.vault.azure.net/"),
    new DefaultAzureCredential());
```

---

## 1.6 Key Azure Policies for Identity

### Important Built-in Policies

| Policy | Description |
|---|---|
| `Require MFA for accounts with owner permissions on subscriptions` | Enforces MFA for highly privileged accounts |
| `Audit privileged identity management configuration` | Flags PIM not enabled |
| `Audit usage of custom RBAC rules` | Minimizes risk from overly permissive custom roles |

---

## 📝 Exam Tips — Domain 1

1. **PIM vs Conditional Access**: PIM manages privileged role activation (JIT). Conditional Access enforces policies at sign-in (location, device, risk).
2. **Managed Identities**: Always prefer managed identity over service principal with stored credentials.
3. **MFA methods**: SMS is the weakest; FIDO2 and Windows Hello are phishing-resistant.
4. **RBAC scope**: Roles cascade downward. Deny assignments take precedence over allow.
5. **Access Reviews**: Used for periodic certification of access — not real-time enforcement.
6. **Global Admin vs Security Admin**: Global Admin can manage everything; Security Admin manages security-specific settings.
7. **SSPR**: Requires Entra ID P1 or P2 license for hybrid (on-premises writeback requires P1).

---

## 🔗 References

- [Microsoft Entra ID Documentation](https://learn.microsoft.com/en-us/entra/identity/)
- [PIM Documentation](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/)
- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/)
- [Conditional Access Documentation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/)

---

> ⬅️ [Back to README](../README.md) | ➡️ [Domain 2: Secure Networking](./02-secure-networking.md)
