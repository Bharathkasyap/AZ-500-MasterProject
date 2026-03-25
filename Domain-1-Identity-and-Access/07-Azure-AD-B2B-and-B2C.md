# Azure AD B2B and B2C (External Identities)

## 📌 Overview of Azure External Identities

Microsoft Entra **External Identities** enables organizations to work securely with people outside the organization:

| Solution | Use Case |
|----------|---------|
| **B2B (Business-to-Business)** | Collaborate with external business partners, vendors, contractors |
| **B2C (Business-to-Customer)** | Consumer-facing apps with millions of external users |

---

## 👥 Azure AD B2B Collaboration

### What is B2B?

B2B allows **guest users** from external organizations (or personal accounts) to access your organization's applications and resources. Guest users sign in with their own identity provider credentials.

### Supported Identity Providers for B2B Guests
- Microsoft work or school accounts
- Microsoft personal accounts (Outlook.com, Hotmail)
- Google accounts
- Facebook accounts
- Email one-time passcode (for any email address without an existing identity provider)
- SAML/WS-Fed identity providers (custom configuration)

### B2B Guest User Flow

```
1. Admin invites external user (or user self-registers via access request)
2. Guest receives invitation email with redemption link
3. Guest redeems invitation — links their external identity to your tenant
4. Guest account created in your tenant as "Member type: Guest"
5. Guest can access apps/resources you've granted access to
```

---

## ⚙️ B2B Configuration Settings

### External Collaboration Settings

Located at **Entra ID → External Identities → External Collaboration Settings**:

| Setting | Options |
|---------|---------|
| **Guest invite permissions** | Anyone can invite / Member users and admins / Admins only |
| **Guest user access restrictions** | Full access / Limited access / Most restricted |
| **Collaboration restrictions** | Allow all / Allow specific domains / Block specific domains |

### Cross-Tenant Access Settings (New Model)

- **Inbound access** — Control which external organizations' users can access YOUR tenant
- **Outbound access** — Control which of YOUR users can access external tenants
- **Trust settings** — Whether to trust MFA claims from external tenants
- **B2B direct connect** — Enables shared channels in Microsoft Teams with specific orgs

---

## 🔐 B2B Security Considerations

### MFA for B2B Guests

Options for requiring MFA for guest users:
1. **Trust the guest's home tenant MFA** — If guest completed MFA at home tenant, no re-prompt
2. **Require MFA via Conditional Access** — Apply CA policy to guest users (All guests and external users)

```
Conditional Access policy example:
IF: Users = All guests and external users
    Cloud apps = Office 365
THEN: Require MFA
```

### Entitlement Management (Access Packages)

**Access Packages** automate B2B guest lifecycle:
- Bundle of access (apps, groups, SharePoint sites)
- Self-service request by guests
- Approval workflows
- Automatic expiration/removal
- **Access reviews** to periodically validate continued access

---

## 🔄 B2B vs Guest Direct Access Comparison

| Feature | B2B Collaboration | Direct Federation |
|---------|------------------|-------------------|
| **Identity provider** | Guest's own IdP | Custom SAML/WS-Fed IdP |
| **Account in tenant** | Guest account created | No account in tenant |
| **Use case** | External partners | Specific organization federation |

---

## 🌐 Azure AD B2C (Business-to-Customer)

### What is B2C?

**Azure AD B2C** is a separate, customer identity access management (CIAM) service designed for **consumer-facing applications** with potentially millions of users.

> ⚠️ **Important**: B2C is a **separate tenant** from your organization's Entra ID tenant. It is NOT the same as B2B guest access.

### Key B2C Features

| Feature | Description |
|---------|-------------|
| **Social identity providers** | Google, Facebook, Apple, Amazon, Twitter |
| **Local accounts** | Username/email + password stored in B2C |
| **Custom policies** | XML-based Identity Experience Framework (IEF) for complex flows |
| **User flows** | Pre-built configurable flows for sign-up, sign-in, profile editing, password reset |
| **Branding** | Fully customizable UI/UX for each application |
| **Scalable** | Designed for millions of external customers |
| **MFA** | Phone (SMS), email OTP, TOTP authenticator |

### B2C User Flows (Built-in)

| Flow | Description |
|------|-------------|
| **Sign-up and sign-in** | Combined flow for new/existing users |
| **Sign-in** | Existing users only |
| **Sign-up** | New users only |
| **Profile editing** | Allow users to update profile attributes |
| **Password reset** | Self-service password reset |
| **Phone sign-in** | Passwordless sign-in with phone |

### B2C Custom Policies (Identity Experience Framework)

Custom policies use XML files to define complex authentication scenarios:
- Multi-step MFA
- REST API integrations
- Claims transformations
- Custom UI with JavaScript
- Social + local account linking

```
Custom policy files:
- TrustFrameworkBase.xml       (base framework — don't modify)
- TrustFrameworkLocalization.xml
- TrustFrameworkExtensions.xml (your customizations)
- SignUpOrSignin.xml           (specific flow)
- PasswordReset.xml
- ProfileEdit.xml
```

---

## 📊 B2B vs B2C Comparison

| Aspect | B2B | B2C |
|--------|-----|-----|
| **Target users** | Business partners, vendors | Consumers, customers |
| **Scale** | Hundreds to thousands | Millions |
| **Tenant** | Your organization's Entra ID tenant | Separate B2C tenant |
| **Identity providers** | Work/school/personal accounts | Social + local accounts |
| **Customization** | Limited branding | Full UI customization |
| **User management** | Managed as guest accounts | Managed in B2C directory |
| **License cost** | Based on MAU for premium features | Based on MAU (first 50k free) |

---

## ❓ Practice Questions

1. A consulting firm needs external contractors from a partner company to access internal SharePoint sites. The partner company uses their own Microsoft 365 tenant. What solution should you implement?
   - A) Azure AD B2C
   - **B) Azure AD B2B Collaboration** ✅
   - C) Create local accounts for contractors
   - D) Configure SAML federation

2. You are building a consumer mobile app that needs to support sign-in with Google, Facebook, and local email accounts for millions of users. What should you use?
   - A) Azure AD B2B
   - **B) Azure AD B2C** ✅
   - C) Entra ID External Collaboration
   - D) Microsoft Account only

3. Your organization invites a guest user from a partner company. The guest attempts to access your tenant and is prompted for MFA. Your Conditional Access policy requires MFA for all guest users. The guest already completed MFA at their home tenant. How can you avoid the double MFA prompt?
   - A) Disable MFA for guest users
   - B) Exclude the guest user from the Conditional Access policy
   - **C) Configure cross-tenant access trust settings to trust the partner tenant's MFA** ✅
   - D) Convert the guest to a member user

4. In Azure AD B2C, what is the difference between User Flows and Custom Policies?
   - A) User flows support social sign-in; custom policies support local accounts only
   - **B) User flows are pre-built configurable templates; custom policies are XML-based for complex scenarios** ✅
   - C) Custom policies don't support MFA
   - D) User flows can only be used for consumer apps

---

## 📚 References

- [External Identities Overview](https://learn.microsoft.com/en-us/entra/external-id/external-identities-overview)
- [B2B Collaboration](https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b)
- [Azure AD B2C Documentation](https://learn.microsoft.com/en-us/azure/active-directory-b2c/overview)
- [Entitlement Management](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-overview)
