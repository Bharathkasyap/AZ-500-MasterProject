# Domain 1: Manage Identity and Access
## AZ-500 Microsoft Azure Security Technologies Study Guide

**Exam Weight: 25–30%**

---

## Table of Contents

1. [Microsoft Entra ID (formerly Azure AD)](#1-microsoft-entra-id-formerly-azure-ad)
2. [Multi-Factor Authentication (MFA)](#2-multi-factor-authentication-mfa)
3. [Privileged Identity Management (PIM)](#3-privileged-identity-management-pim)
4. [Identity Protection](#4-identity-protection)
5. [Role-Based Access Control (RBAC)](#5-role-based-access-control-rbac)
6. [Azure AD Application Management](#6-azure-ad-application-management)
7. [External Identities and Access Reviews](#7-external-identities-and-access-reviews)

---

## 1. Microsoft Entra ID (formerly Azure AD)

Microsoft Entra ID is Microsoft's cloud-based identity and access management service. It is the backbone of authentication and authorization across Microsoft 365, Azure, and thousands of SaaS applications.

### 1.1 Entra ID Editions

| Feature | Free | P1 | P2 |
|---|---|---|---|
| User/Group management | ✅ | ✅ | ✅ |
| SSO (up to 10 apps) | ✅ | Unlimited | Unlimited |
| MFA (basic) | ✅ | ✅ | ✅ |
| Conditional Access | ❌ | ✅ | ✅ |
| Self-Service Password Reset (cloud) | ❌ | ✅ | ✅ |
| SSPR (on-premises writeback) | ❌ | ✅ | ✅ |
| Identity Protection | ❌ | ❌ | ✅ |
| Privileged Identity Management (PIM) | ❌ | ❌ | ✅ |
| Access Reviews | ❌ | ❌ | ✅ |
| Entitlement Management | ❌ | ❌ | ✅ |
| Sign-in risk policy | ❌ | ❌ | ✅ |
| Group-based licensing | ❌ | ✅ | ✅ |
| Dynamic groups | ❌ | ✅ | ✅ |
| Azure AD Join / Hybrid Join | ❌ | ✅ | ✅ |

> **📝 Exam Tip:** PIM and Identity Protection require **P2** licenses. Conditional Access requires at minimum **P1**. The Free tier MFA is only via Security Defaults — not Conditional Access.

### 1.2 Users, Groups, and Guest Accounts

#### User Types

| Type | Description | UPN Format |
|---|---|---|
| Cloud-only | Created directly in Entra ID | user@tenant.onmicrosoft.com |
| Synced (hybrid) | Synced from on-prem AD via Connect | user@contoso.com |
| Guest (B2B) | External identity invited via B2B | user_externaldomain.com#EXT#@tenant.onmicrosoft.com |

#### Group Types

| Type | Membership | Supports Dynamic Rules | License Assignment |
|---|---|---|---|
| Security group | Assigned or Dynamic | ✅ | ✅ |
| Microsoft 365 group | Assigned or Dynamic | ✅ | ✅ |
| Distribution group | Assigned only | ❌ | ❌ |
| Mail-enabled security | Assigned only | ❌ | ❌ |

**Dynamic Group Rule Examples (Azure CLI)**

```bash
# Create a dynamic security group
az ad group create \
  --display-name "All Sales Users" \
  --mail-nickname "all-sales" \
  --description "Dynamic group for Sales department"

# Update the group with a dynamic membership rule
az rest --method PATCH \
  --uri "https://graph.microsoft.com/v1.0/groups/{group-id}" \
  --body '{"membershipRule":"(user.department -eq \"Sales\")","membershipRuleProcessingState":"On","groupTypes":["DynamicMembership"]}'
```

**PowerShell — Dynamic Group**

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All"

# Create dynamic group
New-MgGroup -DisplayName "All Engineers" `
  -MailNickname "all-engineers" `
  -SecurityEnabled $true `
  -MailEnabled $false `
  -GroupTypes @("DynamicMembership") `
  -MembershipRule '(user.jobTitle -contains "Engineer")' `
  -MembershipRuleProcessingState "On"
```

#### Guest Accounts (B2B)

Guest users are invited into your tenant. They authenticate with their **home tenant's credentials** (or a one-time passcode). Their UPN in your tenant is suffixed with `#EXT#`.

```bash
# Invite a guest user via Azure CLI
az ad invitation create \
  --invited-user-email-address "partner@contoso.com" \
  --invite-redirect-url "https://myapps.microsoft.com" \
  --send-invitation-message true
```

> **📝 Exam Trap:** Guest users have **limited permissions** by default. They cannot enumerate all users/groups in your directory. This is controlled by the **External collaboration settings** under Entra ID → External Identities.

### 1.3 Hybrid Identity

Hybrid Identity connects on-premises Active Directory with Entra ID. The right method depends on your organization's requirements.

#### Azure AD Connect (now called Microsoft Entra Connect)

Azure AD Connect synchronizes on-premises AD identities to Entra ID. It installs on a Windows Server and runs sync cycles (default: every 30 minutes).

**Key components:**
- **Synchronization Service** — Handles sync rules and connector spaces
- **AD FS component** — Optional, for federation
- **Password writeback** — Allows cloud SSPR to write back to on-prem AD

```powershell
# Force a delta sync (PowerShell on the Connect server)
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Delta

# Force a full sync
Start-ADSyncSyncCycle -PolicyType Initial
```

#### Authentication Methods Compared

| Method | How it Works | On-Prem Dependency | Supports SSPR Writeback | Best For |
|---|---|---|---|---|
| **Password Hash Sync (PHS)** | Hash of hash of password synced to cloud | Minimal (sync service only) | ✅ | Most organizations (recommended) |
| **Pass-Through Authentication (PTA)** | Auth request forwarded to on-prem agents | ✅ PTA Agent required | ✅ | Compliance requiring on-prem validation |
| **Federation (AD FS)** | SAML tokens issued by on-prem AD FS | ✅ AD FS farm required | ✅ | Complex claims requirements, smart-card |

> **📝 Exam Tip:** **Password Hash Sync** is Microsoft's **recommended** method. It provides the best availability (works even if on-prem is down) and is required to enable **Identity Protection** leaked credential detection.

> **📝 Exam Trap:** **Seamless SSO** is a separate feature that works with **both PHS and PTA** — it uses a Kerberos ticket to silently sign in domain-joined machines. It does NOT work with Federation.

#### Azure AD Connect Health

Monitors your hybrid identity infrastructure and alerts on issues.

```bash
# View Connect Health alerts (via Azure CLI / REST)
az rest --method GET \
  --uri "https://management.azure.com/providers/Microsoft.ADHybridHealthService/services?api-version=2014-01-01"
```

### 1.4 Azure AD B2B and B2C

#### B2B (Business-to-Business)

B2B allows external users to access **your** resources using **their own credentials**. The external user is represented as a guest in your directory.

**Flow:**
1. Admin or app invites external user
2. User receives email invitation
3. User redeems invitation and is granted access
4. Guest account created with `#EXT#` UPN

**B2B Access Control Options:**
- Direct federation (SAML/WS-Fed with partner IdP)
- Google federation
- Microsoft account
- Email one-time passcode (OTP)

```bash
# Configure Google federation for B2B
az ad b2b-direct-federation create \
  --issuer "https://accounts.google.com" \
  --passive-requestor-endpoint "https://accounts.google.com/o/saml2/idp" \
  --metadata-exchange-uri "https://accounts.google.com/..."
```

#### B2C (Business-to-Consumer)

B2C is a **separate tenant type** used for customer-facing applications. It manages millions of consumer identities with custom branding and identity flows.

| Feature | B2B | B2C |
|---|---|---|
| Audience | Partners/employees of other orgs | End consumers |
| Tenant | Your existing Entra ID tenant | Separate B2C tenant |
| Identity Providers | Work/school accounts, Google, Facebook | Any OIDC/SAML provider, social IdPs |
| Custom branding | Limited | Extensive (custom HTML/CSS) |
| User flows | Standard | Fully customizable (user flows & custom policies) |
| Cost | Based on MAU for external users | Free up to 50,000 MAU, then per MAU |

> **📝 Exam Tip:** B2C is its **own directory type** — not just a feature of Entra ID. You must create a separate B2C tenant. Don't confuse B2B (partner access) with B2C (consumer access) on the exam.

---

## 2. Multi-Factor Authentication (MFA)

MFA requires users to provide two or more verification factors — something you know, something you have, or something you are.

### 2.1 MFA Methods

| Method | Type | Phishing Resistant | Notes |
|---|---|---|---|
| Microsoft Authenticator (push) | Something you have | ❌ | Most common; supports number matching |
| TOTP (Authenticator app code) | Something you have | ❌ | Works offline; 30-second codes |
| FIDO2 Security Key | Something you have + are | ✅ | Hardware key (YubiKey, etc.) |
| Windows Hello for Business | Something you have + are | ✅ | Biometric or PIN on device |
| SMS / Voice call | Something you have | ❌ | Least secure; avoid for sensitive accounts |
| Temporary Access Pass (TAP) | Something you know | ❌ | Time-limited one-time passcode |
| Certificate-based Auth (CBA) | Something you have | ✅ | X.509 certificates on smart card/device |

> **📝 Exam Tip:** **FIDO2 keys** and **Windows Hello for Business** are considered **phishing-resistant MFA**. Microsoft recommends these for privileged accounts. The exam may ask which methods are phishing-resistant.

### 2.2 Security Defaults vs Conditional Access MFA

| Feature | Security Defaults | Per-User MFA | Conditional Access MFA |
|---|---|---|---|
| Configuration | Single on/off toggle | Per-user setting | Granular policies |
| License Required | Free | Free | P1 or P2 |
| Flexibility | None | Low | High |
| Recommended for | Small orgs / no P1 | Legacy approach | All P1+ tenants |
| Blocks legacy auth | ✅ | ❌ | ✅ (with policy) |
| Applies to all users | ✅ | Individual | Configurable |

> **📝 Exam Trap:** **Security Defaults and Conditional Access are mutually exclusive.** Enabling Conditional Access requires disabling Security Defaults. You cannot use both simultaneously.

### 2.3 Conditional Access Policies

Conditional Access is the **Zero Trust policy engine** for Entra ID. It evaluates signals and enforces access controls.

**Signal → Decision → Enforcement**

```
Signals (WHO, WHERE, WHAT):
  ├── User / Group / Role
  ├── Named Location / IP range
  ├── Device (compliant, hybrid-joined, platform)
  ├── Application
  ├── Sign-in risk (Identity Protection)
  └── User risk (Identity Protection)

Decision:
  ├── Allow
  ├── Block
  └── Grant (with conditions)

Enforcement (Grant Controls):
  ├── Require MFA
  ├── Require compliant device
  ├── Require hybrid Azure AD join
  ├── Require approved client app
  ├── Require app protection policy
  └── Require password change

Session Controls:
  ├── Sign-in frequency
  ├── Persistent browser session
  ├── App enforced restrictions (SharePoint/Exchange)
  └── Conditional Access App Control (MCAS proxy)
```

**Creating a Conditional Access Policy (Azure CLI / Graph)**

```bash
# Create a CA policy requiring MFA for all users accessing Azure portal
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" \
  --body '{
    "displayName": "Require MFA for Azure Portal",
    "state": "enabled",
    "conditions": {
      "users": {
        "includeUsers": ["All"]
      },
      "applications": {
        "includeApplications": ["797f4846-ba00-4fd7-ba43-dac1f8f63013"]
      }
    },
    "grantControls": {
      "operator": "OR",
      "builtInControls": ["mfa"]
    }
  }'
```

**PowerShell — Create Conditional Access Policy**

```powershell
Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess"

$policy = @{
    displayName = "Block Legacy Authentication"
    state = "enabled"
    conditions = @{
        users = @{
            includeUsers = @("All")
        }
        clientAppTypes = @("exchangeActiveSync", "other")
    }
    grantControls = @{
        operator = "OR"
        builtInControls = @("block")
    }
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy
```

### 2.4 Named Locations and Trusted IPs

**Named Locations** define geographic or IP-based locations used in Conditional Access.

```bash
# Create an IP-based named location
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations" \
  --body '{
    "@odata.type": "#microsoft.graph.ipNamedLocation",
    "displayName": "Contoso Office IPs",
    "isTrusted": true,
    "ipRanges": [
      {
        "@odata.type": "#microsoft.graph.iPv4CidrRange",
        "cidrAddress": "203.0.113.0/24"
      }
    ]
  }'
```

**Trusted IPs (Legacy MFA Settings)** — Found under Entra ID → Security → MFA → Additional cloud-based MFA settings. These bypass MFA for specified IP ranges but are **less granular** than Named Locations.

> **📝 Exam Tip:** Named Locations in Conditional Access are **more powerful** than legacy Trusted IPs. Named Locations can be used as conditions (include/exclude), while Trusted IPs simply bypass MFA. Prefer Named Locations for new configurations.

### 2.5 MFA Registration Policy

Found in Entra ID → Security → Identity Protection → MFA Registration Policy. This policy forces users to register for MFA within a set timeframe.

```
Policy settings:
  ├── Assignments: Users / Groups (All users recommended)
  ├── Controls: Require Azure AD MFA registration
  └── Enforce policy: On
```

> **📝 Exam Tip:** MFA Registration Policy is in **Identity Protection** (requires P2). Don't confuse it with the MFA service settings, which are separate legacy settings.

---

## 3. Privileged Identity Management (PIM)

PIM provides **just-in-time (JIT)** privileged access to Entra ID and Azure resources. It reduces the attack surface by ensuring accounts have elevated privileges only when needed.

### 3.1 Eligible vs Active Assignments

| Assignment Type | Description | Duration | Requires Activation |
|---|---|---|---|
| **Eligible** | User can activate the role when needed | Time-bounded or permanent eligible | ✅ Yes |
| **Active** | Role is always assigned and active | Time-bounded or permanent active | ❌ No |

> **📝 Exam Tip:** The key benefit of PIM is converting **permanent Active** assignments to **time-bound Eligible** assignments. This reduces standing privilege.

### 3.2 Just-in-Time (JIT) Access Flow

```
1. Admin assigns user as ELIGIBLE for a role
2. User navigates to PIM portal
3. User requests activation (provides justification, selects duration)
4. [Optional] Approver receives notification and approves/denies
5. Role becomes ACTIVE for specified duration
6. Audit log entry created
7. Role automatically deactivates after duration
```

**Activating a PIM Role (PowerShell)**

```powershell
Connect-MgGraph -Scopes "RoleManagement.ReadWrite.Directory"

# Get the role definition ID for Global Administrator
$roleDefinition = Get-MgRoleManagementDirectoryRoleDefinition `
  -Filter "displayName eq 'Global Administrator'"

# Create a role activation request
$params = @{
    action = "selfActivate"
    principalId = (Get-MgContext).Account
    roleDefinitionId = $roleDefinition.Id
    directoryScopeId = "/"
    justification = "Performing emergency configuration change"
    scheduleInfo = @{
        startDateTime = (Get-Date).ToUniversalTime()
        expiration = @{
            type = "AfterDuration"
            duration = "PT2H"  # 2 hours
        }
    }
}

New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params
```

**Azure CLI — List PIM eligible assignments**

```bash
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilitySchedules?\$filter=principalId eq '{user-object-id}'"
```

### 3.3 PIM Settings (Role Settings)

Each role in PIM can be configured with:

| Setting | Description |
|---|---|
| Activation maximum duration | How long the role can be active (1–24 hours) |
| On activation, require MFA | Forces MFA before activation |
| On activation, require justification | User must enter a reason |
| On activation, require approval | Specific approvers must approve |
| Require ticket information | ITSM ticket number required |
| Assignment expiration | Eligible/Active assignments can be set to expire |
| Allow permanent eligible | Whether permanent eligible assignments are allowed |
| Allow permanent active | Whether permanent active assignments are allowed |
| Notifications | Alerts sent on activation, assignment changes |

### 3.4 Access Reviews in PIM

Access Reviews ensure that role assignments remain appropriate over time.

```
Review types:
  ├── Users reviewing their own access (self-review)
  ├── Managers reviewing their reports' access
  ├── Specific reviewers designated by admin
  └── Multi-stage reviews (sequential approvals)

Outcomes:
  ├── Approved → Access retained
  ├── Denied → Access removed
  └── No response → Auto-apply settings determine outcome
       ├── Remove access
       └── Approve access (keep as-is)
```

**Creating an Access Review (PowerShell)**

```powershell
Connect-MgGraph -Scopes "AccessReview.ReadWrite.All"

$reviewParams = @{
    displayName = "Quarterly Global Admin Review"
    startDateTime = "2024-01-01T00:00:00Z"
    endDateTime = "2024-01-15T00:00:00Z"
    reviewers = @(
        @{
            query = "/users/{reviewer-id}"
            queryType = "MicrosoftGraph"
        }
    )
    scope = @{
        query = "/roleManagement/directory/roleAssignmentScheduleInstances?`$filter=roleDefinitionId eq '{global-admin-role-id}'"
        queryType = "MicrosoftGraph"
    }
    settings = @{
        autoApplyDecisionsEnabled = $true
        defaultDecision = "Deny"
        justificationRequiredOnApproval = $true
        recommendationsEnabled = $true
    }
}

New-MgIdentityGovernanceAccessReviewDefinition -BodyParameter $reviewParams
```

### 3.5 PIM for Azure Resources vs Entra Roles

| Aspect | PIM for Entra Roles | PIM for Azure Resources |
|---|---|---|
| Scope | Entra directory roles (Global Admin, etc.) | Azure RBAC roles (Owner, Contributor, etc.) |
| Scope Level | Tenant-wide | Management group, subscription, RG, resource |
| Role examples | Global Admin, Security Admin, User Admin | Owner, Contributor, Key Vault Admin |
| Activation | PIM portal or My Access | PIM portal |
| Audit | Entra audit logs | Azure Activity Log + PIM audit |

> **📝 Exam Trap:** PIM for **Azure Resources** manages Azure RBAC roles (like Contributor), NOT Entra directory roles. These are configured separately in PIM, even though both are in the same PIM portal.

---

## 4. Identity Protection

Microsoft Entra Identity Protection uses ML to detect suspicious sign-in behaviors and compromised credentials. **Requires P2 license.**

### 4.1 Risk Types

#### Sign-In Risk
Probability that the specific sign-in wasn't performed by the account owner.

| Detection | Description | Risk Level |
|---|---|---|
| Anonymous IP address | Tor, anonymous proxy | Medium/High |
| Atypical travel | Sign-in from geographically impossible location | Medium |
| Malware-linked IP | IP associated with botnet | Medium |
| Unfamiliar sign-in properties | New device, location, ASN | Low/Medium |
| Admin confirmed compromised | Manually flagged by admin | High |
| Password spray | Many failed attempts across accounts | High |
| Impossible travel | Two geographically distant sign-ins in short time | Medium/High |
| Token issuer anomaly | Abnormal token properties | Medium |

#### User Risk
Probability that a user's identity has been compromised.

| Detection | Description | Risk Level |
|---|---|---|
| Leaked credentials | Credentials found in dark web/public breach | High |
| Azure AD threat intelligence | Internal MS intelligence signals | Variable |
| Unusual user activity | Anomalous user behavior patterns | Medium |
| Admin confirmed user compromised | Manually flagged | High |
| Possible attempt to access Primary Refresh Token | PRT attack indicator | High |

### 4.2 Risk Policies

Two built-in policies (configured in Identity Protection):

#### Sign-In Risk Policy
```
Conditions: Sign-in risk level (Low and above / Medium and above / High)
Access controls:
  ├── Block access
  └── Allow access + Require MFA

Recommended: Medium and above → Require MFA
```

#### User Risk Policy
```
Conditions: User risk level (Low and above / Medium and above / High)
Access controls:
  ├── Block access
  └── Allow access + Require password change

Recommended: Medium and above → Require password change
```

> **📝 Exam Tip:** For the **sign-in risk policy**, the remediation is **MFA**. For the **user risk policy**, the remediation is **password change**. These policies can be configured in Identity Protection OR in Conditional Access (recommended approach for more flexibility).

### 4.3 Responding to Risks

| Action | Who | Description |
|---|---|---|
| **Confirm compromised** | Admin | Marks user as confirmed compromised; sets user risk to High |
| **Confirm safe** | Admin | Marks a risky sign-in as safe; doesn't change user risk |
| **Dismiss user risk** | Admin | Resets user risk to None (without remediation) |
| **Block user** | Admin | Disables the user account |
| **Self-remediation** | User | User completes MFA or changes password via policy |
| **Manual password reset** | Admin | Admin forces password reset |

```bash
# Dismiss user risk via Graph API
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/identityProtection/riskyUsers/dismiss" \
  --body '{"userIds": ["{user-object-id}"]}'

# Confirm a risky user as compromised
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/identityProtection/riskyUsers/confirmCompromised" \
  --body '{"userIds": ["{user-object-id}"]}'
```

### 4.4 Self-Service Password Reset (SSPR)

SSPR allows users to reset their passwords without calling the help desk.

| Feature | Free | P1 | P2 |
|---|---|---|---|
| Cloud-only password reset | ✅ | ✅ | ✅ |
| On-premises writeback | ❌ | ✅ | ✅ |
| Password writeback required | — | Azure AD Connect | Azure AD Connect |

**SSPR Authentication Methods:**
- Mobile app notification (Microsoft Authenticator)
- Mobile app code (TOTP)
- Email
- Mobile phone (SMS)
- Office phone
- Security questions (not recommended for admins)

**SSPR Settings:**

```
Enabled: None / Selected (groups) / All
Authentication methods required: 1 or 2
Methods available: [select from above list]
Registration:
  ├── Require users to register at sign-in: Yes/No
  └── Number of days before users asked to re-confirm: 0–730

Notifications:
  ├── Notify users on password reset: Yes/No
  └── Notify admins when other admins reset password: Yes/No

Customization:
  └── Custom helpdesk link or email
```

> **📝 Exam Trap:** **SSPR writeback** (syncing password reset to on-prem AD) requires **Azure AD Connect** AND at minimum **P1 license**. Without writeback, a cloud password reset does NOT update the on-prem AD password.

---

## 5. Role-Based Access Control (RBAC)

Azure RBAC controls **who** can do **what** to **which** Azure resources. It uses role assignments to grant access.

### 5.1 RBAC Components

```
Role Assignment = Security Principal + Role Definition + Scope

Security Principal:
  ├── User
  ├── Group
  ├── Service Principal
  └── Managed Identity

Role Definition (collection of permissions):
  ├── Actions (allowed control plane operations)
  ├── NotActions (excluded from Actions)
  ├── DataActions (allowed data plane operations)
  ├── NotDataActions (excluded from DataActions)
  └── AssignableScopes

Scope (resource hierarchy):
  ├── Management Group (/ or /providers/Microsoft.Management/managementGroups/{id})
  ├── Subscription (/subscriptions/{id})
  ├── Resource Group (/subscriptions/{id}/resourceGroups/{name})
  └── Resource (/subscriptions/{id}/resourceGroups/{name}/providers/{type}/{name})
```

### 5.2 Built-In Roles

| Role | Permissions | Can Assign Roles | Notes |
|---|---|---|---|
| **Owner** | Full access to all resources | ✅ Yes | Can delegate access; highest privilege |
| **Contributor** | Create and manage resources | ❌ No | Cannot grant/revoke access to others |
| **Reader** | View resources only | ❌ No | Read-only access |
| **User Access Administrator** | Manage user access | ✅ Yes | Can assign roles; cannot manage resources |

**Other important built-in roles:**

| Role | Scope |
|---|---|
| Security Admin | Can manage security policies and alerts in Defender |
| Security Reader | Read-only access to security features |
| Key Vault Administrator | Full access to Key Vault (data plane + management) |
| Key Vault Secrets Officer | Read/write secrets, not keys or certificates |
| Key Vault Reader | Read Key Vault metadata (not secret values) |
| Virtual Machine Contributor | Manage VMs (not the VNet or storage they use) |
| Network Contributor | Manage networks (not access management) |
| Storage Blob Data Owner | Full blob data access including setting ACLs |
| Storage Blob Data Contributor | Read/write/delete blob data |
| Storage Blob Data Reader | Read blob data only |

> **📝 Exam Tip:** **Contributor** cannot assign roles. **User Access Administrator** can assign roles but cannot manage resources. **Owner** can do both. For least privilege role assignment, use **User Access Administrator** rather than Owner.

### 5.3 Role Assignment Commands

**Azure CLI:**

```bash
# List all role assignments for a subscription
az role assignment list --subscription "{subscription-id}" --output table

# Assign Contributor role to a user at resource group scope
az role assignment create \
  --assignee "user@contoso.com" \
  --role "Contributor" \
  --scope "/subscriptions/{sub-id}/resourceGroups/myRG"

# Assign a role to a managed identity
az role assignment create \
  --assignee "{managed-identity-object-id}" \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/mystorage"

# Remove a role assignment
az role assignment delete \
  --assignee "user@contoso.com" \
  --role "Contributor" \
  --scope "/subscriptions/{sub-id}/resourceGroups/myRG"

# List role definitions
az role definition list --query "[?isCustom==\`true\`]" --output table
```

**PowerShell:**

```powershell
# Get all role assignments at subscription scope
Get-AzRoleAssignment -Scope "/subscriptions/{subscription-id}"

# Assign Owner role at management group scope
New-AzRoleAssignment `
  -ObjectId "{user-object-id}" `
  -RoleDefinitionName "Owner" `
  -Scope "/providers/Microsoft.Management/managementGroups/{mg-id}"

# Assign to a group
New-AzRoleAssignment `
  -ObjectId "{group-object-id}" `
  -RoleDefinitionName "Reader" `
  -ResourceGroupName "myRG"

# Remove role assignment
Remove-AzRoleAssignment `
  -ObjectId "{user-object-id}" `
  -RoleDefinitionName "Contributor" `
  -ResourceGroupName "myRG"
```

### 5.4 Custom Roles

Custom roles allow you to define a precise set of permissions when built-in roles are too broad or too narrow.

**Custom Role JSON Definition:**

```json
{
  "Name": "Virtual Machine Operator",
  "IsCustom": true,
  "Description": "Can start, stop, and restart virtual machines",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/{subscription-id-1}",
    "/subscriptions/{subscription-id-2}"
  ]
}
```

**Creating a Custom Role:**

```bash
# Create custom role from JSON file
az role definition create --role-definition @vm-operator-role.json

# Create custom role from JSON string
az role definition create --role-definition '{
  "Name": "VM Reader Plus",
  "Description": "Read VMs and view metrics",
  "Actions": [
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/instanceView/read",
    "Microsoft.Insights/metrics/read"
  ],
  "AssignableScopes": ["/subscriptions/{sub-id}"]
}'

# Update a custom role
az role definition update --role-definition @updated-role.json

# Delete a custom role
az role definition delete --name "Virtual Machine Operator"
```

```powershell
# Create custom role from JSON file in PowerShell
$role = Get-Content -Path "vm-operator-role.json" -Raw | ConvertFrom-Json
New-AzRoleDefinition -Role $role

# Or using the object directly
$customRole = [Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition]::new()
$customRole.Name = "Virtual Machine Operator"
$customRole.Description = "Can start, stop, and restart VMs"
$customRole.Actions = @(
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read"
)
$customRole.AssignableScopes = @("/subscriptions/{sub-id}")
New-AzRoleDefinition -Role $customRole
```

### 5.5 Scope Hierarchy and Inheritance

```
Management Group
    └── Subscription
            └── Resource Group
                    └── Resource

Permissions INHERIT downward. A role assigned at a higher scope
is effective at all child scopes.

Example: Owner at Management Group level = Owner on ALL
subscriptions, resource groups, and resources within.
```

> **📝 Exam Trap:** Role assignments are **additive** — if a user is Contributor on a subscription AND Reader on a specific resource group, the effective permission on that resource group is **Contributor** (the higher permission wins). **Deny assignments** are the exception — they take precedence over allows.

### 5.6 Deny Assignments

Deny assignments **block** specific actions regardless of role assignments. They are created by:
- Azure Blueprints (now deprecated, use Azure Deployment Environments or Policy)
- Azure Managed Applications
- You cannot create deny assignments directly (only via the above mechanisms)

```bash
# List deny assignments
az rest --method GET \
  --uri "https://management.azure.com/subscriptions/{sub-id}/providers/Microsoft.Authorization/denyAssignments?api-version=2022-04-01"
```

> **📝 Exam Tip:** **You cannot directly create deny assignments** — they are system-created by Azure services like Blueprints and Managed Applications. Deny assignments **override allow permissions** including Owner.

---

## 6. Azure AD Application Management

### 6.1 App Registrations vs Enterprise Applications

| Aspect | App Registration | Enterprise Application |
|---|---|---|
| What it is | Developer-facing configuration | Tenant-specific instance of an application |
| Created when | Developer registers a new app | An app is added to the tenant (via registration or gallery) |
| Contains | Client ID, secrets, certificates, redirect URIs, API permissions | Service principal, user assignments, SSO config, provisioning |
| Relationship | 1 App Registration | 1+ Enterprise Apps (one per tenant) |
| Analogy | Class definition | Object instance |

> **📝 Exam Tip:** An App Registration creates a **service principal** in the home tenant. When other tenants consent to the app, a **separate service principal** is created in each tenant. The App Registration is in ONE tenant; Enterprise Applications exist in MANY tenants.

### 6.2 Service Principals

A service principal is the **identity of an application** in a specific Entra ID tenant.

```bash
# Create an app registration (creates SP in home tenant)
az ad app create --display-name "MyApp" --sign-in-audience "AzureADMyOrg"

# Get the object ID of a service principal
az ad sp show --id "{app-id-or-display-name}" --query "id" -o tsv

# Create a service principal for an existing app
az ad sp create --id "{app-id}"

# Assign a role to a service principal
az role assignment create \
  --assignee "{service-principal-object-id}" \
  --role "Contributor" \
  --scope "/subscriptions/{sub-id}"

# Create a client secret for an app
az ad app credential reset \
  --id "{app-id}" \
  --append \
  --years 1
```

### 6.3 Managed Identities

Managed Identities allow Azure services to authenticate to other Azure services **without storing credentials**. The identity lifecycle is managed by Azure.

| Type | Lifecycle | Sharing | Use Case |
|---|---|---|---|
| **System-assigned** | Tied to the resource; deleted with resource | 1:1 with resource | Single-resource scenarios |
| **User-assigned** | Independent lifecycle | Can be shared across resources | Multiple resources needing same identity |

**Enabling System-Assigned Managed Identity:**

```bash
# Enable system-assigned identity on a VM
az vm identity assign --name "myVM" --resource-group "myRG"

# Enable on an App Service
az webapp identity assign --name "myApp" --resource-group "myRG"

# Enable on a Function App
az functionapp identity assign --name "myFunctionApp" --resource-group "myRG"
```

**Creating and Assigning User-Assigned Managed Identity:**

```bash
# Create user-assigned managed identity
az identity create \
  --name "myUserMI" \
  --resource-group "myRG" \
  --location "eastus"

# Get the identity's principal ID
PRINCIPAL_ID=$(az identity show --name "myUserMI" --resource-group "myRG" --query "principalId" -o tsv)

# Assign to a VM
az vm identity assign \
  --name "myVM" \
  --resource-group "myRG" \
  --identities "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myUserMI"

# Grant the identity access to Key Vault
az role assignment create \
  --assignee "$PRINCIPAL_ID" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/{sub-id}/resourceGroups/myRG/providers/Microsoft.KeyVault/vaults/myKV"
```

**PowerShell — Managed Identity:**

```powershell
# Enable system-assigned identity
$vm = Get-AzVM -Name "myVM" -ResourceGroupName "myRG"
Update-AzVM -VM $vm -ResourceGroupName "myRG" -IdentityType SystemAssigned

# Create user-assigned identity
New-AzUserAssignedIdentity -Name "myUserMI" -ResourceGroupName "myRG" -Location "eastus"

# Assign user-assigned identity to VM
$identity = Get-AzUserAssignedIdentity -Name "myUserMI" -ResourceGroupName "myRG"
$vm = Get-AzVM -Name "myVM" -ResourceGroupName "myRG"
Update-AzVM -VM $vm -ResourceGroupName "myRG" `
  -IdentityType UserAssigned `
  -IdentityId $identity.Id
```

**Using Managed Identity from code (IMDS token endpoint):**

```bash
# From inside an Azure VM — get a token using IMDS
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' \
  -H "Metadata: true"
```

> **📝 Exam Trap:** Managed Identities authenticate via the **Instance Metadata Service (IMDS)** endpoint `169.254.169.254` — this is NOT accessible from outside the VM. For user-assigned identities with multiple assigned to one resource, you must specify the `client_id` in the token request.

### 6.4 OAuth 2.0 and OpenID Connect Flows

| Flow | Use Case | Token Types | Notes |
|---|---|---|---|
| **Authorization Code** | Web apps with server-side backend | Access + Refresh + ID | Most secure for web apps |
| **Auth Code + PKCE** | SPAs and mobile apps | Access + Refresh + ID | Replaces Implicit flow |
| **Client Credentials** | Service-to-service (no user) | Access token only | Uses client secret or certificate |
| **Device Code** | Devices without browsers | Access + Refresh + ID | User completes auth on another device |
| **On-Behalf-Of (OBO)** | API calling another API | Access token | Middle-tier API acts on behalf of user |
| **Implicit** | Legacy SPAs | Access + ID (no refresh) | **Deprecated** — use PKCE instead |

> **📝 Exam Tip:** For **daemon/background services** (no user context), use **Client Credentials flow**. For **APIs calling other APIs**, use **On-Behalf-Of (OBO)** flow. For modern SPAs, use **Authorization Code + PKCE** (NOT Implicit).

**App Permission Types:**

| Type | Description | Requires Admin Consent |
|---|---|---|
| **Delegated** | App acts on behalf of signed-in user | Sometimes (depends on scope) |
| **Application** | App acts as itself (no user) | Always |

> **📝 Exam Trap:** **Application permissions** (used with Client Credentials flow) **always require admin consent**. Delegated permissions may or may not require admin consent depending on the specific permission. High-privilege delegated permissions like `User.Read.All` require admin consent.

---

## 7. External Identities and Access Reviews

### 7.1 Entitlement Management

Entitlement Management (part of Azure AD Identity Governance) automates access request, approval, and review workflows.

**Key Components:**

```
Catalog
  └── Contains resources (apps, groups, SharePoint sites, etc.)
      └── Access Packages
              ├── Resource roles (what access is granted)
              ├── Policies (who can request, approval, expiration)
              │     ├── Who can request: Users in directory, external users, admin only
              │     ├── Approval: Single/multi-stage, specific approvers or manager
              │     ├── Expiration: Fixed date, number of days, or no expiration
              │     └── Access review settings
              └── Assignments (who has the package and until when)
```

### 7.2 Access Packages

Access packages bundle multiple resource accesses together and provide a single request point for users.

```bash
# Create a catalog via Graph API
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/catalogs" \
  --body '{
    "displayName": "Marketing Resources",
    "description": "Catalog for marketing team resources",
    "isExternallyVisible": true
  }'

# Create an access package
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages" \
  --body '{
    "displayName": "Marketing Team Access",
    "description": "Access to marketing tools and groups",
    "catalog": {
      "id": "{catalog-id}"
    }
  }'
```

**PowerShell — Access Package:**

```powershell
Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

# Get all access packages
Get-MgEntitlementManagementAccessPackage | Select-Object DisplayName, Id

# Get assignments for an access package
Get-MgEntitlementManagementAccessPackageAssignment `
  -Filter "accessPackageId eq '{package-id}' and state eq 'delivered'"
```

### 7.3 Connected Organizations

Connected Organizations allow external organizations (B2B partners) to self-serve access to your access packages.

```
Connected Organization:
  ├── Represents an external tenant or domain
  ├── Trust: AAD tenant, domain, SAML/WS-Fed IdP
  ├── State: Configured (manually added) or Proposed (auto-created on first request)
  └── Sponsors: Internal/external users who can approve access for the org
```

> **📝 Exam Tip:** When a user from a **Connected Organization** requests an access package that allows all members of connected orgs, their organization becomes "proposed" status. Admins can review and change to "configured" to make it official.

### 7.4 Access Reviews (Standalone)

Access reviews can be created for:
- Group memberships
- Application assignments
- Azure AD roles (via PIM)
- Azure resource roles (via PIM)
- Access package assignments

**Access Review Configuration Options:**

| Setting | Options |
|---|---|
| Reviewers | Group owners, Selected users/groups, Self-review, Managers |
| Duration | 1–180 days |
| Recurrence | Weekly, Monthly, Quarterly, Semi-annually, Annually |
| Auto-apply results | Enable/Disable |
| Default decision (if no response) | Approve, Deny, Recommendations |
| Recommendations | Based on last sign-in activity |
| Scope | All users, Guest users only |

```powershell
# Get all access reviews
Connect-MgGraph -Scopes "AccessReview.Read.All"
Get-MgIdentityGovernanceAccessReviewDefinition | Select-Object DisplayName, Status

# Get decisions for a review instance
Get-MgIdentityGovernanceAccessReviewDefinitionInstance `
  -AccessReviewScheduleDefinitionId "{review-id}" | 
  ForEach-Object {
    Get-MgIdentityGovernanceAccessReviewDefinitionInstanceDecision `
      -AccessReviewScheduleDefinitionId "{review-id}" `
      -AccessReviewInstanceId $_.Id
  }
```

> **📝 Exam Tip:** When access review results are **auto-applied**, denied access is removed automatically. If auto-apply is disabled, an admin must manually apply the results. The **recommendation** feature uses sign-in activity — users who haven't signed in for 30+ days get a "Deny" recommendation.

---

## Quick Reference: Key Exam Topics

### License Requirements Summary

| Feature | License |
|---|---|
| Conditional Access | P1 |
| SSPR (cloud only) | P1 |
| SSPR (with on-prem writeback) | P1 + Azure AD Connect |
| Dynamic Groups | P1 |
| Group-based licensing | P1 |
| PIM | P2 |
| Identity Protection | P2 |
| Access Reviews | P2 |
| Entitlement Management | P2 |
| B2B (up to 5 guests) | Free (per external user model) |

### Authentication Method Security Ranking (Strongest to Weakest)

1. FIDO2 Security Key (phishing-resistant)
2. Windows Hello for Business (phishing-resistant)
3. Certificate-based Authentication (phishing-resistant)
4. Microsoft Authenticator (push with number matching)
5. TOTP (Authenticator app code)
6. Temporary Access Pass (TAP)
7. SMS / Voice Call (weakest — SIM swap attacks)

### Common Exam Scenarios

**Scenario 1:** "A company wants to ensure admins only have Global Administrator rights when needed, with approval required."
→ **Answer:** Configure PIM with Global Administrator as an **eligible** assignment, enable **approval** in PIM role settings.

**Scenario 2:** "Users need to access resources from a partner company. The partner uses their own Azure AD."
→ **Answer:** Configure **Azure AD B2B** — invite users as guests or set up **direct federation**.

**Scenario 3:** "Block all sign-ins from countries your company doesn't operate in."
→ **Answer:** Create a **Named Location** for allowed countries, then create a **Conditional Access policy** to block sign-ins from outside those locations.

**Scenario 4:** "A developer needs an app to access Azure Storage without storing credentials in code."
→ **Answer:** Enable a **Managed Identity** on the compute resource, assign **Storage Blob Data Reader/Contributor** role to the managed identity.

**Scenario 5:** "Ensure that users who have been flagged as high risk are forced to change their password."
→ **Answer:** Configure the **User Risk Policy** in Identity Protection (or Conditional Access) to require **password change** for High risk.

**Scenario 6:** "A user's account shows leaked credentials. What should you do immediately?"
→ **Answer:** **Confirm user compromised** in Identity Protection to set risk to High, then either force a password reset or disable the account while investigating.

---

*Next: [Domain 2 — Secure Networking →](./02-secure-networking.md)*
