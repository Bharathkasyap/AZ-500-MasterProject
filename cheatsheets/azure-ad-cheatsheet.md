# Azure AD & Identity — Quick Reference Cheat Sheet

## Azure AD Editions

| Feature | Free | P1 | P2 |
|---------|------|----|----|
| User/Group management | ✅ | ✅ | ✅ |
| SSO | ✅ | ✅ | ✅ |
| B2B collaboration | ✅ | ✅ | ✅ |
| MFA | ✅ (basic) | ✅ | ✅ |
| Conditional Access | ❌ | ✅ | ✅ |
| PIM | ❌ | ❌ | ✅ |
| Identity Protection | ❌ | ❌ | ✅ |
| Access Reviews | ❌ | ❌ | ✅ |
| Entitlement Management | ❌ | ❌ | ✅ |

---

## Hybrid Identity Methods

| Method | Auth Happens | Password in Cloud |
|--------|-------------|-------------------|
| PHS | Azure AD | Yes (hashed hash) |
| PTA | On-premises AD | No |
| ADFS Federation | On-prem ADFS | No |

---

## MFA Methods by Strength

```
STRONGEST ──────────────────────────────── WEAKEST
FIDO2 key > Windows Hello > Authenticator app push > TOTP code > Voice call > SMS
```

**Phishing-resistant methods**: FIDO2 security keys, Windows Hello for Business, Certificate-based auth (CBA)

---

## Conditional Access — Signal → Control

```
IF (signals)          AND (conditions)       THEN (controls)
User/Group            Location               Require MFA
Device state          App                    Require compliant device
Sign-in risk (P2)     Client app             Block access
User risk (P2)        Device platform        Require Azure AD join
```

**Policy States**: Off | On | Report-only (test without enforcing)

---

## PIM Role States

| State | Description |
|-------|-------------|
| Eligible | Can activate via PIM |
| Active | Currently assigned and usable |
| Permanent Active | Always active (avoid for privileged roles) |
| Expired | Time-limited assignment has expired |

**Activation**: Eligible → Request → (Approval?) → Active (1–8 hr default)

---

## RBAC Key Points

| Role | `*/write` | Role Assign | Deny |
|------|-----------|------------|------|
| Owner | ✅ | ✅ | ❌ |
| Contributor | ✅ | ❌ | ❌ |
| Reader | ❌ | ❌ | ❌ |
| User Access Admin | ❌ | ✅ | ❌ |

**RBAC scope hierarchy**: Management Group → Subscription → Resource Group → Resource

**Inheritance**: Permissions assigned at a higher scope are inherited by child scopes.

**Deny assignments**: Override Allow; used by Azure Blueprints; cannot be created directly by users.

---

## Azure AD Role vs. Azure RBAC Role

| | Azure AD Roles | Azure RBAC Roles |
|---|---|---|
| **Scope** | Directory (tenant) | Azure resources |
| **Examples** | Global Admin, Security Admin | Owner, Contributor |
| **Managed in** | Azure AD portal | Azure portal IAM |
| **Controlled by** | PIM (AD roles) | PIM (Azure roles) |

---

## Managed Identity Quick Reference

| Type | Lifecycle | Use When |
|------|-----------|---------|
| System-assigned | Tied to resource | 1:1 identity per resource |
| User-assigned | Independent | Shared identity across resources |

**Grant access**: Assign RBAC role to the managed identity at required scope.

---

## Identity Protection Risk Levels

| Risk Level | Example Trigger |
|-----------|-----------------|
| Low | Unfamiliar sign-in properties |
| Medium | Password spray, anomalous token |
| High | Anonymous IP, leaked credentials, malware-linked IP |

**Recommended policies**:
- Sign-in risk Medium+ → Require MFA
- User risk High → Require password change

---

## Application Registration Key Concepts

| Concept | Description |
|---------|-------------|
| App Registration | Global object; defines the app's identity |
| Service Principal | Local instance in each tenant |
| Client secret | Expiring password (avoid in production) |
| Certificate | Preferred credential for service principals |
| Managed Identity | No credential management needed |

**Permission types**:
- **Delegated**: Acts as signed-in user
- **Application**: Acts as itself (requires admin consent)

---

## Access Reviews Summary

| Setting | Recommendation |
|---------|---------------|
| Scope | Users, groups, service principals, guests |
| Reviewers | Managers or selected security team members |
| Frequency | Quarterly for privileged roles |
| On no response | Auto-deny (remove access) |
| Upon completion | Auto-apply results |
