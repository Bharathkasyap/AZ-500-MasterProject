# Domain 1 — Study Notes: Manage Identity and Access

> Deep-dive reference notes for exam preparation

---

## Microsoft Entra ID Connect (Hybrid Identity)

### Sync Options
| Method | Description |
|--------|-------------|
| **Password Hash Sync (PHS)** | Hash of on-prem password synced to cloud; simplest; most resilient |
| **Pass-through Authentication (PTA)** | Auth request forwarded to on-prem AD; password never in cloud |
| **Federation (AD FS)** | Authentication handled by on-prem AD FS; most complex |

### Key Components
- **Azure AD Connect agent**: Installed on-premises to sync objects
- **Provisioning agent**: Lightweight agent for cloud-only provisioning (HR-driven)
- **Seamless SSO**: Sign in to cloud apps without re-entering credentials on domain-joined machines

> **Exam tip:** PHS is the recommended method for most organizations. It provides the best availability and also enables **Identity Protection leaked credentials** detection.

---

## Entra ID Roles vs. Azure RBAC Roles

| Aspect | Entra ID Roles | Azure RBAC Roles |
|--------|----------------|------------------|
| Scope | Entra ID tenant | Azure resource hierarchy |
| Purpose | Manage directory objects | Manage Azure resources |
| Assignment UI | Entra ID portal | Azure portal (IAM blade) |
| Example roles | Global Admin, Security Admin | Owner, Contributor, Reader |
| Custom roles | Yes (Entra ID P1+) | Yes |

> **Important:** A **Global Administrator** can elevate to **User Access Administrator** on Azure root scope to manage all subscriptions. This is the "break-glass" procedure.

### Entra ID Built-in Role Highlights
| Role | Key Permissions |
|------|----------------|
| **Global Administrator** | Full control over entire tenant |
| **Privileged Role Administrator** | Manage role assignments, configure PIM |
| **Security Administrator** | Manage security features, Identity Protection, Defender |
| **Conditional Access Administrator** | Create/manage Conditional Access policies |
| **Application Administrator** | Register and manage all app registrations |
| **Cloud Application Administrator** | Same as Application Admin but excludes App Proxy |
| **User Administrator** | Create/manage users and groups |
| **Groups Administrator** | Create/manage groups |
| **Authentication Administrator** | Reset auth methods for non-admin users |
| **Helpdesk Administrator** | Reset passwords for non-admin users |

---

## Conditional Access — Deep Dive

### Policy Modes
- **Report-only**: Evaluate policy impact without enforcing it (great for testing)
- **On**: Enforce the policy
- **Off**: Policy disabled

### Named Locations
```
Entra ID → Security → Named Locations
```
- **IP ranges**: Define trusted IPs as CIDR blocks
- **Countries/Regions**: Define trusted geographies
- **Mark as trusted**: Excluded from MFA requirements when used in policies

### Continuous Access Evaluation (CAE)
- Real-time enforcement of Conditional Access policy changes
- Supported in Exchange Online and SharePoint Online
- If a token is revoked (user disabled, password changed), access revoked within minutes instead of hours

### Authentication Strength
- Newer Conditional Access control (replacing "Require MFA")
- Define specific authentication method requirements
- Built-in strengths: MFA, Passwordless MFA, Phishing-resistant MFA
- Custom strengths can be created

### Terms of Use
- Require users to accept terms before accessing apps
- Can be scoped to specific apps or users
- Tracks acceptance; re-acceptance can be required periodically

---

## Privileged Identity Management — Deep Dive

### PIM Workflow
```
User requests role activation
    → Provides justification
    → Completes MFA (if required)
    → Approval notification sent to approver(s) (if required)
    → Approver approves/denies
    → Role becomes active for configured duration
    → Role expires automatically
```

### PIM Settings per Role
- **Max activation duration** (1–24 hours)
- **Require justification on activation**
- **Require MFA on activation**
- **Require approval** + select approvers
- **Notification emails** to admins when role is activated
- **Incident/request ticket required** (custom text field)

### PIM for Azure Resources
- Assign eligible Owner/Contributor on subscriptions
- Works at management group, subscription, resource group, or resource level
- Supports **role inheritance** from parent scopes

### PIM Audit Log
- Full audit trail of all activations, assignments, and reviews
- Available in: Entra ID → Privileged Identity Management → Audit logs

### Access Reviews in PIM
- Periodic review of who has eligible/active PIM assignments
- Review scope: All roles, specific role, specific users
- Reviewers: Self-review, manager, specific users
- On no response: Approve, Deny, or No change
- Recommendations: Based on last sign-in activity

---

## Identity Protection — Deep Dive

### Risk Signal Sources
- Microsoft processes **trillions of signals daily** across Microsoft services
- Threat intelligence from: Microsoft, law enforcement, security researchers
- Leaked credentials checked against dark web databases

### Sign-in Risk Detections
| Detection | Description | Risk Level |
|-----------|-------------|-----------|
| Anonymous IP address | Tor browser, anonymizing proxies | Medium/High |
| Atypical travel | Impossible travel between locations | Medium |
| Malware-linked IP | IP associated with botnet | Medium |
| Unfamiliar sign-in properties | New location, device, browser | Low/Medium |
| Password spray | Multiple accounts, few passwords | Medium/High |
| Suspicious inbox manipulation | Post-compromise email rules | Medium |
| Suspicious browser | Same session accessing multiple tenants | Medium |
| Token issuer anomaly | Anomalous token properties | Medium |

### User Risk Detections
| Detection | Description | Risk Level |
|-----------|-------------|-----------|
| Leaked credentials | Credentials found on dark web | High |
| Entra ID threat intelligence | Microsoft internal threat intel | High |
| Anomalous user activity | Unusual user behavior | Medium |

### Risk-Based Conditional Access (Recommended Approach)
```
CA Policy 1 (High User Risk):
  Users: All
  Condition: User risk = High
  Grant: Block OR Require password change + MFA

CA Policy 2 (Medium/High Sign-in Risk):
  Users: All
  Condition: Sign-in risk = Medium or High
  Grant: Require MFA

CA Policy 3 (MFA Registration):
  Users: All
  Condition: None (but target new users)
  Grant: Require MFA registration
```

---

## Workload Identities — Deep Dive

### Service Principal Authentication Methods
| Method | Security | Notes |
|--------|----------|-------|
| **Client secret** | Lower | Manually rotated; can expire |
| **Certificate** | Higher | Auto-rotation possible via Key Vault |
| **Federated credential** | Highest | Workload Identity Federation; no secrets |

### Workload Identity Federation
- Allows external identity providers (GitHub Actions, Kubernetes) to authenticate as an Entra ID service principal **without secrets**
- Configure a federated identity credential on the app registration
- The external identity presents its token; Azure validates it and issues an Entra ID token
- Use case: GitHub Actions deploying to Azure without storing secrets

### Managed Identity IMDS Endpoint
```
http://169.254.169.254/metadata/identity/oauth2/token
  ?api-version=2019-08-01
  &resource=https://vault.azure.net
```
- Available only within Azure (VM, App Service, etc.)
- No credentials needed; Azure handles token issuance

---

## Access Reviews

### Scope Options
- **Group membership**: Review who is in specific groups
- **App assignments**: Review who has access to enterprise apps
- **Azure resource roles**: Review RBAC assignments
- **Entra ID roles (via PIM)**: Review eligible/active PIM assignments

### Review Settings
- **Duration**: 1–180 days
- **Recurrence**: One-time, weekly, monthly, quarterly, semi-annual, annual
- **Reviewers**: Specific users, group owners, managers, self
- **Helper**: Show recommendations based on last sign-in
- **Auto-apply results**: Automatically remove access if denied

### Use Cases
- Quarterly review of Guest (B2B) user access
- Annual review of Global Administrator assignments
- Monthly review of sensitive group memberships

---

## Azure AD Connect Health

- Monitoring service for on-premises identity infrastructure
- Monitors: AD FS servers, Sync (Connect) servers, AD Domain Services
- Shows sync errors, latency, active users
- Requires agents installed on-premises
- Requires **Entra ID P1**

---

## Key Terms & Acronyms

| Term | Meaning |
|------|---------|
| **PHS** | Password Hash Synchronization |
| **PTA** | Pass-Through Authentication |
| **PIM** | Privileged Identity Management |
| **CA** | Conditional Access |
| **SSPR** | Self-Service Password Reset |
| **RBAC** | Role-Based Access Control |
| **MFA** | Multi-Factor Authentication |
| **FIDO2** | Fast Identity Online 2 (hardware security key standard) |
| **CAE** | Continuous Access Evaluation |
| **IMDS** | Instance Metadata Service |
| **B2B** | Business-to-Business (partner/guest collaboration) |
| **B2C** | Business-to-Consumer (customer identity) |
| **JIT** | Just-In-Time (PIM activation) |
| **SPN** | Service Principal Name |
| **UPN** | User Principal Name (user@domain.com) |

---

## Practice Scenarios

### Scenario 1: Secure Admin Access
**Requirement:** Global Administrators must use MFA from trusted locations; from untrusted locations, require MFA + compliant device.
```
Policy 1 — Admins from trusted locations:
  Users: Global Administrators group
  Location: All trusted named locations
  Grant: Require MFA

Policy 2 — Admins from untrusted locations:
  Users: Global Administrators group
  Location: All locations EXCEPT trusted named locations
  Grant: Require MFA AND Require compliant device
```

### Scenario 2: JIT Admin Access
**Requirement:** No user should have permanently active Global Administrator role. Access should be time-limited and require approval.
```
PIM Configuration for Global Administrator:
  Assignment type: Eligible only
  Max activation duration: 4 hours
  Require MFA on activation: Yes
  Require justification: Yes
  Require approval: Yes
  Approver: Security team DL
```

### Scenario 3: Guest User Access
**Requirement:** Guest users from partner company must use MFA and can only access approved apps.
```
Conditional Access Policy:
  Users: Guest and external users
  Cloud apps: SharePoint Online, Teams
  Grant: Require MFA

Cross-tenant access settings:
  Inbound B2B: Trust MFA from partner tenant
  (Optional — reduces MFA friction for partners)
```

---

[← Back to Domain Overview](README.md) | [Practice Questions →](../../practice-questions/domain1-identity-access.md)
