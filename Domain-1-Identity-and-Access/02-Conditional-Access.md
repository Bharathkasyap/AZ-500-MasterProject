# Conditional Access

## 📌 What is Conditional Access?

**Conditional Access** is Microsoft Entra ID's policy engine that enforces access controls based on signals. It implements the **Zero Trust** principle of "verify explicitly" — access decisions consider identity, device, location, application, and risk.

> 💡 **Exam Note**: Conditional Access requires **Entra ID P1** or P2 license.

---

## 🔄 How Conditional Access Works

```
User Sign-In Attempt
        ↓
  Signals Collected
  (user, device, location, app, risk)
        ↓
  Policy Evaluation
  (IF [conditions] THEN [controls])
        ↓
  Access Decision:
  Allow | Block | Require MFA | Require Compliant Device
```

---

## 🎯 Policy Components

### Assignments (Conditions — "IF")

#### Users and Groups
- Specific users or groups
- All users (broad policy)
- Directory roles
- **Exclude**: Emergency access accounts (break-glass) should always be excluded

#### Cloud Apps or Actions
- All cloud apps
- Specific apps (e.g., Microsoft 365, Azure portal)
- User actions (e.g., register security info)

#### Conditions
| Condition | Description |
|-----------|-------------|
| **Sign-in risk** | Risk level from Identity Protection (High, Medium, Low) |
| **User risk** | Compromised account risk level |
| **Device platforms** | iOS, Android, Windows, macOS, Linux |
| **Locations** | Named locations (IP ranges or countries) |
| **Client apps** | Browser, mobile apps, desktop apps, legacy auth |
| **Filter for devices** | Custom device properties |

---

### Access Controls (Grant and Session)

#### Grant Controls ("THEN")
| Control | Description |
|---------|-------------|
| **Block access** | Deny access entirely |
| **Require MFA** | Prompt for additional verification |
| **Require compliant device** | Intune compliance required |
| **Require Hybrid Entra ID joined device** | Domain-joined and Entra-joined |
| **Require approved client app** | Specific Microsoft apps only |
| **Require app protection policy** | Intune MAM policy |
| **Require password change** | Force password reset |

> Controls can use **"Require one of the selected controls" (OR)** or **"Require all selected controls" (AND)**.

#### Session Controls
| Control | Description |
|---------|-------------|
| **App enforced restrictions** | SharePoint/Exchange enforce session limits |
| **Conditional Access App Control** | Use Microsoft Defender for Cloud Apps proxy |
| **Sign-in frequency** | How often re-authentication is required |
| **Persistent browser session** | Control "Stay signed in" behavior |
| **Disable resilience defaults** | Strictest enforcement, no fallback |

---

## 📍 Named Locations

Named Locations allow policies based on network location:

### IP-Based Named Locations
- Define trusted IP ranges (corporate network, VPN)
- Mark as **trusted location** — reduces risk score
- Use CIDR notation

### Country-Based Named Locations
- Block or require MFA from specific countries
- Based on IP geolocation

```bash
# Create a named location (IP ranges)
az ad conditional-access named-location create \
  --display-name "Corporate Network" \
  --ip-ranges "203.0.113.0/24" "198.51.100.0/24" \
  --is-trusted true
```

---

## ⚠️ Common Policy Scenarios

### Block Legacy Authentication
```
IF: Client apps = Legacy authentication clients
THEN: Block access
```
> Legacy protocols (POP3, IMAP, SMTP AUTH) cannot support MFA — block them.

### Require MFA for Admins
```
IF: Users = Directory roles (Global Admin, etc.)
THEN: Require MFA
```

### Require MFA Outside Corporate Network
```
IF: Users = All users
    Locations = NOT trusted locations
THEN: Require MFA
```

### Block Access from Specific Countries
```
IF: Users = All users
    Locations = Risky countries (e.g., North Korea)
THEN: Block access
```

### Require Compliant Device for Azure Portal
```
IF: Cloud apps = Microsoft Azure Management
    Users = All users
THEN: Require compliant device OR Require Hybrid Entra joined device
```

---

## 🚨 Emergency Access (Break-Glass) Accounts

Always **exclude** at least one emergency access account from all Conditional Access policies:
- Use long, complex passwords stored securely
- Do NOT enable MFA on break-glass accounts (otherwise you're locked out)
- Monitor with alerts when used
- Test access quarterly

---

## 📊 Policy Modes

| Mode | Behavior |
|------|----------|
| **Report-only** | Evaluate policy but don't enforce — logs what would have happened |
| **On** | Policy is enforced |
| **Off** | Policy is disabled |

> 💡 Always test new policies in **Report-only** mode first.

---

## 🔍 Troubleshooting Conditional Access

- **What If tool** — Simulate policy evaluation for a specific user/app/location
- **Sign-in logs** — Shows which policies applied and why
- **CA Insights workbook** — Overview of policy coverage and impact

---

## 🔗 Useful CLI / PowerShell Commands

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess"

# List all Conditional Access policies
Get-MgIdentityConditionalAccessPolicy

# Get sign-in logs with CA details
Get-MgAuditLogSignIn -Filter "conditionalAccessStatus eq 'failure'"
```

---

## ❓ Practice Questions

1. A Conditional Access policy is configured with Sign-in Risk = High → Block Access. A user with a High risk sign-in attempts to access Teams. What happens?
   - A) They are prompted for MFA
   - B) They are required to reset their password
   - **C) Access is blocked** ✅
   - D) The policy is evaluated in report-only mode

2. You need to allow access to the Azure portal only from managed devices without blocking all cloud apps. What should you scope the policy to?
   - A) All cloud apps
   - **B) Microsoft Azure Management** ✅
   - C) Office 365
   - D) All user actions

3. Which Conditional Access grant control prevents users of legacy email protocols from bypassing MFA?
   - A) Require MFA
   - B) Require compliant device
   - **C) Block access (applied to legacy auth client apps)** ✅
   - D) Require app protection policy

4. Which mode allows you to test a Conditional Access policy without enforcing it?
   - A) Off
   - **B) Report-only** ✅
   - C) Monitor
   - D) Audit

---

## 📚 References

- [Conditional Access Documentation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/)
- [Named Locations](https://learn.microsoft.com/en-us/entra/identity/conditional-access/location-condition)
- [Common Conditional Access Policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policy-common)
