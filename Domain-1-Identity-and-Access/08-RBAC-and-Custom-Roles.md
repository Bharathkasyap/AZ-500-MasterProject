# Azure RBAC and Custom Roles

## 📌 What is Azure RBAC?

**Azure Role-Based Access Control (RBAC)** is the authorization system for managing access to Azure resources. It answers: "Who can do what on which resources?"

Three key elements:
1. **Security principal** — Who (user, group, managed identity, service principal)
2. **Role definition** — What (set of permissions)
3. **Scope** — Which resources

---

## 🏗️ RBAC Components

### Scope Hierarchy

```
Management Group
    └── Subscription
            └── Resource Group
                    └── Resource
```

- Role assignments are **inherited downward**
- Assignment at subscription level applies to all resource groups and resources within
- Assignment at a specific resource applies only to that resource
- **More specific scope = more precise control**

### Role Assignment

A **role assignment** = Security Principal + Role Definition + Scope

```bash
# Assign a role to a user
az role assignment create \
  --assignee user@contoso.com \
  --role "Contributor" \
  --resource-group MyRG

# Assign to a group (recommended over individual users)
az role assignment create \
  --assignee <group-object-id> \
  --role "Reader" \
  --subscription <subscription-id>

# Assign managed identity to a role
az role assignment create \
  --assignee <managed-identity-principal-id> \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{vault}"
```

---

## 📋 Built-In Roles (Key Roles for AZ-500)

### Broad Roles

| Role | Permissions |
|------|------------|
| **Owner** | Full access to all resources AND can manage access (assign roles) |
| **Contributor** | Full access to all resources, CANNOT manage access |
| **Reader** | Read-only access to all resources |
| **User Access Administrator** | Can manage access (assign roles) but no resource permissions |

### Security-Specific Roles

| Role | Permissions |
|------|------------|
| **Security Admin** | Manage security policies, view security state, dismiss alerts |
| **Security Reader** | Read-only access to Defender for Cloud, alerts, policies |
| **Security Operator** | Manage and dismiss Defender for Cloud alerts |

### Storage Roles

| Role | Permissions |
|------|------------|
| **Storage Blob Data Owner** | Full access to Blob storage (data plane) |
| **Storage Blob Data Contributor** | Read/write/delete Blob storage data |
| **Storage Blob Data Reader** | Read-only access to Blob storage data |
| **Storage Queue Data Contributor** | Read/write/delete Queue messages |

### Key Vault Roles

| Role | Permissions |
|------|------------|
| **Key Vault Administrator** | Full access to all Key Vault operations |
| **Key Vault Secrets Officer** | Create and manage secrets (not keys or certs) |
| **Key Vault Secrets User** | Read secret values (most common for apps) |
| **Key Vault Crypto Officer** | Manage keys |
| **Key Vault Crypto User** | Use keys for crypto operations |

---

## 🔑 Role Definition Structure

Every role definition has:
- **Id** — Unique GUID
- **Name** — Display name
- **Actions** — Allowed management plane operations
- **NotActions** — Excluded from Actions
- **DataActions** — Allowed data plane operations
- **NotDataActions** — Excluded from DataActions
- **AssignableScopes** — Where the role can be assigned

```json
{
  "Name": "Virtual Machine Operator",
  "Id": null,
  "IsCustom": true,
  "Description": "Can start and stop virtual machines",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/{subscription-id}"
  ]
}
```

---

## 🛠️ Custom Roles

When built-in roles don't meet requirements, create a **custom role**.

### When to Use Custom Roles
- A built-in role has too many permissions (violates least privilege)
- A built-in role doesn't have specific permissions needed
- Need to combine permissions from multiple roles

### Custom Role Limits
- Maximum **5,000 custom roles** per Entra ID tenant
- Can be assigned at management group, subscription, or resource group scope
- **AssignableScopes** determines where the role appears in the portal

### Creating a Custom Role

```bash
# 1. Export an existing role as a starting point
az role definition list --name "Virtual Machine Contributor" --output json

# 2. Create the custom role from JSON file
az role definition create --role-definition /tmp/custom-role.json

# 3. Verify creation
az role definition list --custom-role-only true --output table
```

```powershell
# PowerShell
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "Virtual Machine Operator"
$role.Description = "Can monitor and restart virtual machines."
$role.Actions.Clear()
$role.Actions.Add("Microsoft.Storage/*/read")
$role.Actions.Add("Microsoft.Network/*/read")
$role.Actions.Add("Microsoft.Compute/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/00000000-0000-0000-0000-000000000000")
New-AzRoleDefinition -Role $role
```

---

## ⚠️ Actions vs DataActions

| Type | Description | Example |
|------|-------------|---------|
| **Actions** | Management plane operations (ARM) | `Microsoft.Storage/storageAccounts/read` (list storage accounts) |
| **DataActions** | Data plane operations | `Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read` (read blob content) |

> 💡 **Exam Note**: Classic admin roles (Service Administrator, Co-Administrator) do NOT have DataActions and cannot access storage data directly. Use RBAC storage data roles instead.

---

## 🔄 Deny Assignments

**Deny assignments** block specific actions regardless of role assignments:
- Created by Azure Blueprints or Managed Applications
- Cannot be directly created by users
- Take precedence over allow actions from RBAC roles
- Useful for locking down critical resources

```
Evaluation order:
1. Check Deny assignments → If deny matches, ACCESS DENIED
2. Check Allow (role) assignments → If allow matches, ACCESS GRANTED
3. No match → ACCESS DENIED (implicit deny)
```

---

## 📊 Management Plane vs Data Plane

| Plane | What it controls | Authentication |
|-------|-----------------|----------------|
| **Management plane** | Resource configuration (ARM API) | Azure RBAC |
| **Data plane** | Data within resources | RBAC + resource-specific access controls |

> **Example**: "Contributor" on a Key Vault lets you manage the vault (management plane) but does NOT let you read secrets (data plane) — you need **Key Vault Secrets User** for that.

---

## 🔐 Best Practices

1. **Assign roles to groups**, not individual users — easier to manage
2. **Use built-in roles** whenever possible
3. **Apply least privilege** — use the most specific role at the most specific scope
4. **Avoid Owner** at subscription level — use specific roles
5. **Use Resource Groups** to scope access logically
6. **Regularly audit** role assignments with **Access reviews** (PIM) or manual review
7. **For automation/scripts**, use managed identities over service principals

---

## ❓ Practice Questions

1. A developer needs to deploy resources to a resource group but must NOT be able to change access control. Which built-in role should you assign?
   - A) Owner
   - **B) Contributor** ✅
   - C) User Access Administrator
   - D) Reader

2. You assign the Contributor role to a user at the subscription level. They report they cannot read secrets from a Key Vault in that subscription. What is the issue?
   - A) The user needs Owner role at subscription level
   - B) The user needs to be added to the Key Vault's access policy
   - **C) Contributor doesn't grant data plane access to Key Vault — the user needs Key Vault Secrets User** ✅
   - D) Key Vault requires separate subscription access

3. A security team needs to view security recommendations in Defender for Cloud but should not be able to modify policies or dismiss alerts. Which role should you assign?
   - A) Security Admin
   - B) Contributor
   - **C) Security Reader** ✅
   - D) Reader

4. You need a custom role that allows users to start and stop VMs but not create or delete them. What should you include in the role definition?
   - A) `Microsoft.Compute/virtualMachines/*`
   - **B) `Microsoft.Compute/virtualMachines/start/action` and `Microsoft.Compute/virtualMachines/deallocate/action`** ✅
   - C) `Microsoft.Compute/*/read`
   - D) Remove `Microsoft.Compute/virtualMachines/delete` from the Contributor role

5. What is the maximum number of custom roles per Entra ID tenant?
   - A) 1,000
   - **B) 5,000** ✅
   - C) 10,000
   - D) Unlimited

---

## 📚 References

- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)
- [Built-in Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Custom Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Understand Role Definitions](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-definitions)
