# Domain 1 — Manage Identity and Access (25–30%)

## Overview

This domain is one of the heaviest in the AZ-500 exam. It covers how Azure manages **who can access what** using Azure Active Directory (now called **Microsoft Entra ID**) and associated services.

---

## 1.1 Azure Active Directory (Microsoft Entra ID)

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Tenant** | A dedicated instance of Azure AD tied to an organization |
| **Directory** | Repository of users, groups, devices, and applications within a tenant |
| **Subscription** | Billing and resource boundary; trusts one Azure AD tenant |
| **Azure AD B2B** | Invite external guest users to your directory |
| **Azure AD B2C** | Customer identity platform for apps (separate tenant) |
| **Azure AD DS** | Managed domain services (LDAP, Kerberos) — not the same as Azure AD |

### Azure AD Editions

| Feature | Free | P1 | P2 |
|---------|------|----|----|
| SSO | ✅ | ✅ | ✅ |
| Conditional Access | ❌ | ✅ | ✅ |
| Identity Protection | ❌ | ❌ | ✅ |
| PIM | ❌ | ❌ | ✅ |
| Access Reviews | ❌ | ❌ | ✅ |

### Hybrid Identity Options

| Method | Description | Password Hash Sync |
|--------|-------------|-------------------|
| **PHS** (Password Hash Sync) | Hash of hash synced to Azure AD | Yes — in cloud |
| **PTA** (Pass-through Auth) | Auth request forwarded to on-prem AD | No — on-prem |
| **Federation (ADFS)** | Trust-based; on-prem IdP handles auth | No — on-prem |

**Azure AD Connect** — tool to sync on-premises AD objects to Azure AD.
- **Azure AD Connect Cloud Sync** — newer, lightweight agent-based approach (replaces Azure AD Connect for many scenarios).

---

## 1.2 Multi-Factor Authentication (MFA)

### MFA Methods (Azure AD)

| Method | Strength | Notes |
|--------|----------|-------|
| **Microsoft Authenticator (push notification)** | Strong | Recommended for most users |
| **TOTP (authenticator app code)** | Strong | Works offline |
| **FIDO2 Security Key** | Strongest (passwordless) | Phishing resistant |
| **Windows Hello for Business** | Strongest (passwordless) | Tied to device |
| **SMS / Voice call** | Weak | Susceptible to SIM-swap |
| **Email OTP** | Weak | Allowed only for B2B guests |

### Conditional Access Policies

Conditional Access evaluates **signals** to enforce **access controls**:

```
Signals (IF)              →    Controls (THEN)
─────────────────────────────────────────────────
User / Group              →    Require MFA
Device compliance         →    Require compliant device
Location (named location) →    Block access
App / Workload            →    Require Hybrid AD Join
Sign-in risk (P2)         →    Require password change
User risk (P2)            →    Block / require MFA
```

**Important**: Conditional Access requires **Azure AD P1** (or P2 for risk-based policies).

#### Named Locations
- IP range-based or country/region-based
- Used to exclude corporate networks from MFA requirements or block risky countries

#### Session Controls
- Sign-in frequency — forces re-authentication after a set time
- Persistent browser session — controls whether "Stay signed in" is shown
- App-enforced restrictions (SharePoint/Exchange)

---

## 1.3 Privileged Identity Management (PIM)

PIM provides **just-in-time (JIT)** privileged access to Azure AD and Azure resources.

**Requires Azure AD P2.**

### PIM Role States

| State | Description |
|-------|-------------|
| **Eligible** | User can request activation of the role |
| **Active** | Role is currently assigned and usable |
| **Permanent active** | Role is always active (avoid this for sensitive roles) |

### PIM Activation Flow

```
User requests activation
        ↓
Justification / MFA required
        ↓
Optional: Approval by designated approver
        ↓
Role is activated for a configurable time window (default: 1–8 hours)
        ↓
Role automatically deactivated at expiry
```

### Access Reviews (Azure AD P2)
- Periodically review who has access to roles/groups/apps
- Reviewers can be users themselves (self-review), managers, or designated
- On no-response: auto-approve or auto-deny
- Integrated with PIM for privileged role reviews

---

## 1.4 Azure AD Identity Protection

**Requires Azure AD P2.**

### Risk Types

| Risk | Type | Examples |
|------|------|----------|
| **Sign-in risk** | Real-time or offline | Atypical travel, anonymous IP, password spray |
| **User risk** | Aggregate | Leaked credentials, multiple sign-in failures |

### Risk Policies

| Policy | Trigger | Recommended Action |
|--------|---------|-------------------|
| Sign-in risk policy | Sign-in risk ≥ Medium | Require MFA |
| User risk policy | User risk = High | Require password change + MFA |
| MFA registration policy | New user | Force MFA registration |

### Investigation Workflow
1. Review **Risky Sign-ins** report
2. Review **Risky Users** report
3. Confirm compromise → trigger password reset, revoke sessions
4. Dismiss risk if false positive

---

## 1.5 Role-Based Access Control (RBAC)

### RBAC Concepts

| Concept | Definition |
|---------|-----------|
| **Security Principal** | User, group, service principal, or managed identity |
| **Role Definition** | Set of allowed actions (e.g., `Microsoft.Compute/*/read`) |
| **Scope** | Management group, subscription, resource group, or resource |
| **Role Assignment** | Binding of a principal to a role at a scope |

### Key Built-in Roles

| Role | Permissions |
|------|------------|
| **Owner** | Full access including ability to assign roles |
| **Contributor** | Full access except cannot assign roles |
| **Reader** | View-only access |
| **User Access Administrator** | Manage user access only |
| **Security Admin** | Security Center: manage security policies |
| **Security Reader** | Security Center: view-only |
| **Key Vault Administrator** | Full Key Vault management |
| **Key Vault Secrets Officer** | Manage secrets (not keys/certs) |

### Custom Roles
- Defined in JSON with `Actions`, `NotActions`, `DataActions`, `NotDataActions`
- Scope: management group, subscription, or resource group
- Up to **5,000 custom roles** per Azure AD tenant

```json
{
  "Name": "VM Operator",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "AssignableScopes": ["/subscriptions/{subscriptionId}"]
}
```

### RBAC vs Azure AD Roles

| Aspect | Azure RBAC | Azure AD Roles |
|--------|-----------|----------------|
| **Scope** | Azure resources (subscriptions, RGs) | Azure AD directory objects |
| **Examples** | Owner, Contributor, Reader | Global Admin, Security Admin |
| **Managed in** | Azure portal → IAM | Azure AD → Roles and Administrators |

---

## 1.6 Managed Identities

Eliminate the need to manage credentials by using managed identities for Azure services.

| Type | Description |
|------|-------------|
| **System-assigned** | Tied to one resource; deleted with the resource |
| **User-assigned** | Standalone resource; can be assigned to multiple services |

**Common use case**: Allow an Azure Function or VM to access Key Vault without storing secrets.

```
Azure VM (with managed identity)
    ↓ GET https://vault.azure.net/secrets/mySecret
Azure AD token issued for the VM's identity
    ↓
Key Vault verifies the token and returns the secret
```

---

## 1.7 Application Access in Azure AD

### Service Principals
- An **Application Registration** creates an **Application object** (global, in home tenant)
- A **Service Principal** is the local representation in each tenant where the app is used
- Credential types: **Client secret** (avoid in prod) or **Certificate** (recommended)

### Microsoft Identity Platform Flows

| Flow | Use Case |
|------|---------|
| **Authorization Code + PKCE** | Web apps, SPAs (most secure) |
| **Client Credentials** | Service-to-service (no user) |
| **On-behalf-of (OBO)** | Middle-tier API acting on behalf of user |
| **Device Code** | Devices without a browser (IoT) |

### API Permissions
- **Delegated** — app acts as a signed-in user
- **Application** — app acts as itself (daemon/service); **requires admin consent**

### Consent Framework
- **User consent** — for low-privilege delegated permissions
- **Admin consent** — required for application permissions and some delegated permissions

---

## 1.8 Azure AD Access Reviews

| Setting | Options |
|---------|---------|
| **Scope** | Users, guest users, service principals |
| **Reviewers** | Self, managers, selected users |
| **Duration** | 1–180 days |
| **Recurrence** | One-time, weekly, monthly, quarterly, semi-annual, annual |
| **Upon completion** | Auto-apply results (remove access) or manual apply |

---

## 🎯 Exam Focus Points — Domain 1

1. **Know the difference between Azure RBAC and Azure AD roles** — a very common trap question.
2. **PIM activation requirements** — eligible vs. active, approval workflows, time-bound activation.
3. **Conditional Access policy evaluation order** — all matching policies apply; most restrictive wins.
4. **Managed identities vs. service principals** — when to use each.
5. **Identity Protection risk levels** — what triggers each and the recommended remediation.
6. **Azure AD Connect sync methods** — PHS, PTA, Federation — differences and security implications.
7. **MFA methods strength** — FIDO2 > Authenticator app > TOTP > SMS/Voice.
8. **Least privilege** — always assign the minimum required RBAC role.
