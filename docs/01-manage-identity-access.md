# Domain 1 — Manage Identity and Access (25–30%)

---

## 1.1 Microsoft Entra ID (formerly Azure AD)

### Key Concepts

| Concept | Description |
|---|---|
| **Tenant** | A dedicated, isolated instance of Entra ID representing an organisation |
| **Directory** | The identity store within a tenant (users, groups, apps, service principals) |
| **Subscription trust** | An Azure subscription trusts exactly one Entra ID tenant |
| **Guest users (B2B)** | External users invited via Entra B2B collaboration; stored as `#EXT#` UPNs |
| **Domain verification** | Custom domains must be DNS-verified before use as primary UPN suffixes |

### User Account Types

| Type | Creation | Authentication |
|---|---|---|
| Cloud identity | Entra ID portal / Graph API | Entra ID |
| Directory-synced | Microsoft Entra Connect (ADSync) | On-premises AD (password hash / pass-through / federated) |
| Guest (B2B) | Invitation | External IdP or one-time passcode |

### Entra ID Editions

| Feature | Free | P1 | P2 |
|---|---|---|---|
| SSPR | ❌ | ✅ | ✅ |
| Conditional Access | ❌ | ✅ | ✅ |
| Identity Protection | ❌ | ❌ | ✅ |
| Privileged Identity Management | ❌ | ❌ | ✅ |
| Access Reviews | ❌ | ❌ | ✅ |

---

## 1.2 Azure Role-Based Access Control (RBAC)

### Core Concepts

- **Security Principal** — User, Group, Service Principal, or Managed Identity
- **Role Definition** — A collection of permissions (Actions, NotActions, DataActions, NotDataActions)
- **Scope** — Management Group → Subscription → Resource Group → Resource
- **Role Assignment** — Binding of a security principal to a role at a scope

### Built-in Roles (Exam Favourites)

| Role | Key Capability |
|---|---|
| **Owner** | Full access including access management |
| **Contributor** | Full resource management, no access management |
| **Reader** | Read-only view of resources |
| **User Access Administrator** | Manage role assignments *only* |
| **Key Vault Administrator** | Full Key Vault data-plane + management-plane |
| **Key Vault Secrets Officer** | Get, list, set, delete, recover secrets |
| **Key Vault Secrets User** | Read secret values only |
| **Storage Blob Data Contributor** | Read/write blob data |
| **Storage Blob Data Owner** | Full blob data + POSIX ACL management |

### RBAC vs Entra ID Roles

| | Azure RBAC | Entra ID Roles |
|---|---|---|
| Scope | Azure resources (subscription, RG, resource) | Entra ID tenant objects |
| Managed in | Azure portal / ARM | Entra ID portal / Graph |
| Examples | Owner, Contributor, Reader | Global Administrator, Security Reader |
| Inheritance | Yes (down through scope hierarchy) | No scope hierarchy |

### Architecture Decision — Least Privilege

1. Start with the narrowest scope (individual resource).
2. Use built-in roles before creating custom roles.
3. Assign to groups, not individuals, for manageability.
4. Review assignments with **Access Reviews** (P2).

---

## 1.3 Managed Identities

### Types

| Type | Lifecycle | Use Case |
|---|---|---|
| **System-assigned** | Tied to the resource; deleted when resource is deleted | Single-resource access |
| **User-assigned** | Independent; shared across multiple resources | Shared identity pattern |

### How It Works

1. Enable managed identity on resource (VM, App Service, Function, etc.)
2. Entra ID creates a service principal in the tenant.
3. Assign RBAC role to the managed identity on the target resource.
4. App code calls IMDS endpoint (`http://169.254.169.254/metadata/identity/...`) to get access tokens — **no credentials stored anywhere**.

### Common Exam Scenario

> *"A VM needs to read secrets from Key Vault without storing credentials in code."*
> → Enable **system-assigned managed identity** on VM → Assign **Key Vault Secrets User** RBAC role.

---

## 1.4 Conditional Access

### Building Blocks

```
IF  [Assignments: Users/Groups + Cloud Apps + Conditions]
THEN [Grant/Block + Session controls]
```

### Conditions

| Condition | Options |
|---|---|
| **Sign-in risk** | Low, medium, high (requires P2 / Identity Protection) |
| **User risk** | Low, medium, high (requires P2) |
| **Device platform** | Android, iOS, Windows, macOS |
| **Location** | Named locations (IP ranges / countries) |
| **Client apps** | Browser, mobile apps, Exchange ActiveSync |
| **Device state** | Compliant, Hybrid Azure AD joined |

### Grant Controls

| Control | What It Enforces |
|---|---|
| Require MFA | Azure MFA challenge |
| Require compliant device | Intune device compliance |
| Require Hybrid Azure AD join | Domain-joined + Entra registered |
| Require approved client app | MAM-capable apps only |
| Require app protection policy | Intune app protection |

### Architecture Tips

- Use **Report-only mode** first to assess impact before enforcing.
- **Named Locations** for trusted offices → exclude from MFA requirement.
- **Break-glass accounts** should be excluded from all Conditional Access policies.
- **Sign-in frequency** session control forces periodic re-authentication.

---

## 1.5 Privileged Identity Management (PIM)

> Requires **Entra ID P2**.

### PIM Roles Coverage

- Entra ID built-in roles (e.g., Global Administrator)
- Azure RBAC roles (e.g., Owner, Contributor)

### Assignment Types

| Type | Description |
|---|---|
| **Eligible** | User can activate the role (requires approval/MFA/justification) |
| **Active** | Role is permanently active (no activation needed) |

### Activation Flow

```
Eligible Member → Request Activation → (MFA + Justification + Optional Approval)
→ Time-bound Active Assignment → Automatic Expiry
```

### Settings (per role)

- **Activation duration** — Max hours the role stays active (e.g., 1–8 hrs)
- **Require MFA on activation** — Enforced per-role
- **Require justification** — User must enter a reason
- **Require approval** — Designated approver must approve
- **Notifications** — Email alerts on activation

### Access Reviews in PIM

- Schedule periodic reviews of *eligible* and *active* assignments.
- Reviewers can approve, deny, or leave to auto-expire.

---

## 1.6 Microsoft Entra Identity Protection

> Requires **Entra ID P2**.

### Risk Types

| Risk | Description | Examples |
|---|---|---|
| **Sign-in risk** | Probability that sign-in is not from the legitimate user | Atypical travel, anonymous IP, malware-linked IP |
| **User risk** | Probability that user account is compromised | Leaked credentials, unusual sign-in patterns |

### Policies

| Policy | Trigger | Action |
|---|---|---|
| **Sign-in risk policy** | Sign-in risk ≥ threshold | Require MFA or Block |
| **User risk policy** | User risk ≥ threshold | Require password change or Block |
| **MFA registration policy** | New users | Require MFA registration |

> ⚠️ Identity Protection policies are *simpler* Conditional Access policies. For production, prefer full Conditional Access + Identity Protection integration.

---

## 1.7 Architecture Decision Guidance

| Requirement | Recommended Approach |
|---|---|
| Access Azure resources without credentials in code | Managed Identity + RBAC |
| Enforce MFA for admins only | Conditional Access targeting admin groups |
| Time-bound privileged access | PIM eligible assignments |
| Detect compromised accounts automatically | Identity Protection sign-in/user risk policies |
| Periodic review of privileged users | PIM Access Reviews |
| External partner access to Azure resources | Entra B2B guest + RBAC assignment |

---

## 1.8 CLI Quick Reference

```bash
# Create a user-assigned managed identity
az identity create --name myIdentity --resource-group myRG

# Assign RBAC role to managed identity
az role assignment create \
  --assignee $(az identity show -n myIdentity -g myRG --query principalId -o tsv) \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<sub-id>/resourceGroups/myRG/providers/Microsoft.KeyVault/vaults/myVault

# List role assignments at a scope
az role assignment list --scope /subscriptions/<sub-id> --output table

# Assign PIM eligible role (requires Azure AD PIM PowerShell or MS Graph)
# See: https://learn.microsoft.com/graph/api/resources/privilegedidentitymanagement-overview

# Create Conditional Access policy (MS Graph PowerShell example)
# New-MgIdentityConditionalAccessPolicy -BodyParameter @{ ... }
```

---

## 1.9 Practice Questions

**Q1.** A developer needs to retrieve secrets from Azure Key Vault without storing credentials in the application's source code or configuration files. Which solution meets this requirement?

- A. Create a service principal with a client secret stored in app settings  
- B. Enable a system-assigned managed identity on the app and grant it the Key Vault Secrets User role  
- C. Store the Key Vault access key in Azure Blob Storage and read it at startup  
- D. Use a shared access signature on the Key Vault  

<details><summary>Answer</summary>
**B** — Managed identity eliminates the need to store any credentials. The runtime token is obtained transparently via IMDS.
</details>

---

**Q2.** You need to ensure that members of the `Global Administrators` group must approve before any user can activate the `Owner` role at the subscription scope. Which feature provides this capability?

- A. Conditional Access approval workflow  
- B. Privileged Identity Management (PIM) with approval required  
- C. Azure Policy deny effect  
- D. Entra ID access reviews  

<details><summary>Answer</summary>
**B** — PIM activation settings include an *Require approval* option, with designated approvers.
</details>

---

**Q3.** Which Entra ID license tier is required for Privileged Identity Management?

- A. Free  
- B. P1  
- C. P2  
- D. Microsoft 365 E3  

<details><summary>Answer</summary>
**C** — PIM requires Entra ID P2 (or equivalent bundled license such as Microsoft 365 E5).
</details>

---

**Q4.** A Conditional Access policy uses the condition `Sign-in risk: High` and the grant control `Block access`. A user travelling internationally triggers a high-risk sign-in. What happens?

- A. The user is prompted for MFA  
- B. The user's account is permanently disabled  
- C. The sign-in is blocked, and the user receives an error message  
- D. The user is redirected to complete a password reset  

<details><summary>Answer</summary>
**C** — Block access with risk condition immediately denies the sign-in. The user would need an admin to reset the risk or exclude the location.
</details>

---

**Q5.** An application running on VM-A needs read access to blobs in a storage account. You want to follow least-privilege principles. Which combination is correct?

- A. Enable system-assigned managed identity on VM-A → Assign `Storage Blob Data Reader` to the managed identity  
- B. Enable system-assigned managed identity on VM-A → Assign `Contributor` to the managed identity  
- C. Create a service principal, store the client secret in VM-A's code → Assign `Storage Blob Data Reader`  
- D. Assign `Reader` role at the subscription level to the VM's service principal  

<details><summary>Answer</summary>
**A** — System-assigned managed identity with the `Storage Blob Data Reader` role scoped to the storage account is the least-privilege, credential-free approach.
</details>
