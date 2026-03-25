# Domain 1 — Manage Identity and Access (25–30%)

> **Exam weight:** 25–30% of the total score (~15–18 questions out of 60)

---

## Table of Contents

1. [Microsoft Entra ID Fundamentals](#1-microsoft-entra-id-fundamentals)
2. [Users, Groups & Devices](#2-users-groups--devices)
3. [App Registrations & Service Principals](#3-app-registrations--service-principals)
4. [Managed Identities](#4-managed-identities)
5. [Role-Based Access Control (RBAC)](#5-role-based-access-control-rbac)
6. [Privileged Identity Management (PIM)](#6-privileged-identity-management-pim)
7. [Conditional Access](#7-conditional-access)
8. [Identity Protection](#8-identity-protection)
9. [Access Reviews & Entitlement Management](#9-access-reviews--entitlement-management)
10. [External Identities (B2B/B2C)](#10-external-identities-b2bb2c)
11. [Key Exam Points](#key-exam-points)

---

## 1. Microsoft Entra ID Fundamentals

**Microsoft Entra ID** (formerly Azure Active Directory) is Microsoft's cloud-based identity and access management service.

### Tenants and Directories
- A **tenant** is a dedicated Entra ID instance for an organization.
- Each Azure subscription is associated with exactly **one** Entra ID tenant.
- Multiple subscriptions can trust the same tenant.

### License Tiers (relevant to exam)
| Feature | Free | P1 | P2 |
|---------|------|----|----|
| User/group management | ✅ | ✅ | ✅ |
| Conditional Access | ❌ | ✅ | ✅ |
| PIM | ❌ | ❌ | ✅ |
| Identity Protection | ❌ | ❌ | ✅ |
| Access Reviews | ❌ | ✅ | ✅ |

> **Exam tip:** PIM and Identity Protection require **P2** (or Microsoft Entra ID Governance).

---

## 2. Users, Groups & Devices

### User Types
| Type | Description |
|------|-------------|
| **Member** | Standard internal user |
| **Guest** | External collaborator (B2B) |
| **Service Principal** | Application identity |

### Group Types
| Type | Membership | Supports License Assignment |
|------|-----------|----------------------------|
| **Assigned** | Manual | ✅ |
| **Dynamic User** | Attribute-based rules | ✅ |
| **Dynamic Device** | Device attribute rules | ❌ |

#### Dynamic group rule example
```
(user.department -eq "Engineering") -and (user.accountEnabled -eq True)
```

### Device Registration Options
| Method | Requires Domain Join | MDM Enrollment | SSO to Azure Resources |
|--------|---------------------|----------------|----------------------|
| Entra Registered | No | Optional | Limited |
| Entra Joined | No (cloud only) | Yes | Yes |
| Hybrid Entra Joined | Yes (on-prem AD) | Optional | Yes |

---

## 3. App Registrations & Service Principals

### Key Concepts
- **App Registration** — the *global* identity definition (one per tenant where the app is defined).
- **Service Principal** — the *local* instance in each tenant that uses the app registration.
- **Enterprise Application** — the service principal as it appears in the enterprise apps blade.

### Authentication Flows
| Flow | When to Use |
|------|------------|
| Authorization Code + PKCE | Interactive user sign-in (SPA, web app) |
| Client Credentials | Daemon / service-to-service (no user) |
| On-Behalf-Of | Middle-tier API calling downstream API |
| Device Code | Devices without a browser |

### Credentials
- **Client Secret** — string secret; expires; avoid in production when possible.
- **Certificate** — preferred; stored in Key Vault; stronger security.
- **Federated credentials** — workload identity federation (GitHub Actions, Kubernetes).

> **Exam tip:** Federated credentials eliminate the need to manage long-lived secrets.

---

## 4. Managed Identities

Managed identities allow Azure services to authenticate to other Azure services **without managing credentials**.

| Type | Lifecycle | Sharing |
|------|-----------|---------|
| **System-Assigned** | Tied to the resource; deleted with it | 1:1 with resource |
| **User-Assigned** | Independent resource | Can be shared across multiple resources |

### Supported Resources (non-exhaustive)
- Azure VMs, VMSS
- Azure App Service / Functions
- Azure Container Instances / AKS
- Azure Logic Apps
- Azure Data Factory

### Common Pattern
```bash
# Assign Key Vault Secret Reader role to a VM's system-assigned managed identity
az role assignment create \
  --assignee <vm-principal-id> \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault>
```

---

## 5. Role-Based Access Control (RBAC)

### Built-In Roles (High Priority for AZ-500)
| Role | Level | Key Permissions |
|------|-------|----------------|
| Owner | Management/resource | Full access + assign roles |
| Contributor | Management/resource | Full access, no role assignment |
| Reader | Management/resource | Read-only |
| User Access Administrator | Management/resource | Manage role assignments only |
| Security Admin | Subscription | Manage security policies; dismiss alerts |
| Security Reader | Subscription | Read security state; no remediation |
| Security Operator | Subscription | Manage alerts and Defender plans |
| Key Vault Administrator | Key Vault | Full KV data-plane access |
| Key Vault Secrets User | Key Vault | Read secrets only |

### Scope Hierarchy
```
Management Group
  └── Subscription
        └── Resource Group
              └── Resource
```
- Roles assigned at a higher scope **inherit** down.
- A Deny assignment overrides Allow.

### Custom Roles
```json
{
  "Name": "VM Operator",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/powerOff/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "AssignableScopes": ["/subscriptions/<sub-id>"]
}
```

> **Exam tip:** `Actions` vs `DataActions` — `Actions` control management plane; `DataActions` control data plane (e.g., reading blob content).

---

## 6. Privileged Identity Management (PIM)

PIM provides **just-in-time** (JIT) privileged access to Azure AD roles and Azure resource roles.

### Assignment Types
| Type | Access | Duration |
|------|--------|----------|
| **Eligible** | Must activate; can require MFA, justification, approval | Configurable |
| **Active** | Always active | Configurable (time-bound supported) |

### Activation Workflow
1. User navigates to PIM → My roles → Activate.
2. User provides justification and (optionally) ticket number.
3. If approval required, approver gets notified.
4. On approval, role becomes active for configured duration (e.g., 8 hours).

### PIM Settings (per role)
- **Maximum activation duration** (1–24 hours)
- **Require MFA on activation** ← common exam scenario
- **Require justification**
- **Require approval** — requires at least one approver

### Access Reviews in PIM
- Periodic review of who has eligible/active assignments.
- Reviewers can be: self, manager, specific users.
- On review completion: auto-apply or manual apply.

> **Exam tip:** PIM requires **Entra ID P2** or **Microsoft Entra ID Governance**.

---

## 7. Conditional Access

Conditional Access is an **if-then** policy engine: *if* signal conditions are met, *then* enforce controls.

### Signals (Conditions)
| Signal | Examples |
|--------|---------|
| User/Group | Specific users, roles, or groups |
| Cloud App | Microsoft 365, Azure portal, custom apps |
| Device platform | iOS, Android, Windows, macOS |
| Location | Named locations, countries |
| Sign-in risk | Low, medium, high (requires P2) |
| User risk | Low, medium, high (requires P2) |
| Device compliance | Intune-compliant, Hybrid joined |

### Grant Controls
| Control | Description |
|---------|-------------|
| Block access | Deny entirely |
| Require MFA | Prompt for second factor |
| Require compliant device | Device must be Intune-compliant |
| Require hybrid Entra join | Must be joined to on-prem AD |
| Require approved client app | Only certain apps allowed |
| Require app protection policy | MAM policy required |

### Session Controls
- Sign-in frequency (re-authenticate after N hours/days)
- Persistent browser session
- Application-enforced restrictions (SharePoint, Exchange)
- Conditional Access App Control (proxy via Defender for Cloud Apps)

### Named Locations
```
Trusted IP ranges  →  used to exclude corporate network from MFA
Country/Region     →  block access from specific countries
```

> **Exam tip:** Always create a **break-glass account** excluded from Conditional Access to avoid lockouts.

---

## 8. Identity Protection

Automates detection and remediation of identity-based risks.

### Risk Types
| Type | Description | Examples |
|------|-------------|---------|
| **Sign-in risk** | Probability this sign-in is not the legitimate user | Atypical travel, anonymous IP, malware-linked IP |
| **User risk** | Probability the user account is compromised | Leaked credentials, Entra ID threat intelligence |

### Risk Levels
`Low → Medium → High`

### Risk Policies (in Identity Protection)
| Policy | Recommended Minimum Trigger | Action |
|--------|----------------------------|--------|
| Sign-in risk policy | Medium and above | Require MFA |
| User risk policy | High | Require password change |

> **Exam tip:** Identity Protection policies are **older** approach. **Conditional Access with Identity Protection signals** (risk-based CA) is the recommended modern approach.

---

## 9. Access Reviews & Entitlement Management

### Access Reviews
- Review membership of groups, application access, or Azure AD/resource role assignments.
- Reviewers: Self, Group owners, Specified reviewers, Manager.
- On completion: Auto-apply decisions (remove access if no response).

### Entitlement Management
- **Access packages** — bundle of resources (groups, apps, SharePoint sites) with policies.
- **Catalogs** — container for access packages.
- **Policies** — who can request, who approves, expiration.

```
Access Package Policy:
  ├── Who can request: All users / specific groups / connected orgs
  ├── Approval: Single or multi-stage
  ├── Expiration: Date / number of days / never
  └── Access review: Frequency / reviewers
```

---

## 10. External Identities (B2B/B2C)

### B2B Collaboration
- Invite external users to your tenant as **Guest** accounts.
- They authenticate with their home IdP (Microsoft, Google, SAML, etc.).
- Access is controlled via Conditional Access and entitlement management.

### Cross-Tenant Access Settings
| Setting | Description |
|---------|-------------|
| Inbound | Control what external tenants' users can access in your tenant |
| Outbound | Control what your users can access in external tenants |
| Trust settings | Trust MFA, compliant device claims from partner tenant |

### B2C
- Customer-facing identity — separate tenant type.
- Not a primary AZ-500 topic, but know the conceptual difference from B2B.

---

## Key Exam Points

- [ ] PIM requires **Entra ID P2** — don't recommend PIM when only P1 is licensed.
- [ ] **System-assigned managed identity** is deleted automatically with the resource; **user-assigned** is not.
- [ ] **Conditional Access** > per-user MFA — always recommend CA for modern deployments.
- [ ] A **Deny assignment** always takes precedence over any Allow role assignment.
- [ ] Know the difference between `Actions` (management plane) and `DataActions` (data plane) in RBAC.
- [ ] **Break-glass accounts** must be excluded from Conditional Access and use long, complex passwords + hardware keys.
- [ ] **Access reviews** in PIM automatically revoke access when reviewers do not respond if configured to do so.
- [ ] **Workload Identity Federation** (federated credentials) is the most secure option for CI/CD pipelines — no secrets to rotate.
