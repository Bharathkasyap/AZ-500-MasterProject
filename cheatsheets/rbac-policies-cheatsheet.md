# RBAC & Azure Policy — Quick Reference Cheat Sheet

## Azure RBAC Built-in Roles (Most Tested)

### General Roles

| Role | Read | Write/Create | Delete | Assign Roles |
|------|------|-------------|--------|-------------|
| Owner | ✅ | ✅ | ✅ | ✅ |
| Contributor | ✅ | ✅ | ✅ | ❌ |
| Reader | ✅ | ❌ | ❌ | ❌ |
| User Access Administrator | ✅ | ❌ | ❌ | ✅ |

### Security Roles

| Role | Scope | Permissions |
|------|-------|------------|
| Security Admin | Subscription | View + update security policy; dismiss alerts; apply recommendations |
| Security Reader | Subscription | View security policy, alerts, recommendations (read-only) |
| Security Operator | Subscription | Manage security alerts (cannot change policies) |

### Key Vault RBAC Roles

| Role | Keys | Secrets | Certificates |
|------|------|---------|-------------|
| Key Vault Administrator | Full | Full | Full |
| Key Vault Crypto Officer | CRUD | ❌ | ❌ |
| Key Vault Crypto User | Use (sign/encrypt) | ❌ | ❌ |
| Key Vault Secrets Officer | ❌ | CRUD | ❌ |
| Key Vault Secrets User | ❌ | Read | ❌ |
| Key Vault Certificates Officer | ❌ | ❌ | CRUD |
| Key Vault Reader | Metadata | Metadata | Metadata |

### Storage RBAC Roles

| Role | Data Plane | Control Plane |
|------|-----------|--------------|
| Storage Blob Data Owner | Full blob access | ❌ |
| Storage Blob Data Contributor | Read + Write blobs | ❌ |
| Storage Blob Data Reader | Read blobs | ❌ |
| Storage Account Contributor | Manage account settings | ✅ (but no data access) |

---

## RBAC Role Definition Structure

```json
{
  "Name": "Custom Role Name",
  "Description": "Description of the role",
  "Actions": [
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/start/action"
  ],
  "NotActions": [
    "Microsoft.Compute/virtualMachines/delete"
  ],
  "DataActions": [
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"
  ],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/{subscriptionId}"
  ]
}
```

**Actions** = control plane (manage resources)  
**DataActions** = data plane (read/write data within resources)  
**NotActions** / **NotDataActions** = exclude from wildcard  

---

## Scope Hierarchy (Most → Least Broad)

```
Management Group
    └── Subscription
            └── Resource Group
                    └── Resource
```

- **Inheritance**: Roles assigned at a parent scope are inherited by child scopes.
- **Most specific** assignment does NOT override inherited assignments — they are additive.
- **Deny assignments** DO override allow assignments (used by Blueprints; cannot be user-created).

---

## Azure Policy — Key Concepts

### Policy Definition Structure

```json
{
  "mode": "All",
  "policyRule": {
    "if": {
      "field": "type",
      "equals": "Microsoft.Storage/storageAccounts"
    },
    "then": {
      "effect": "deny"
    }
  }
}
```

### Policy Modes

| Mode | Scope |
|------|-------|
| `All` | Evaluate all resource types and subscriptions |
| `Indexed` | Only evaluate resource types that support tags and location |

### Policy Effects Reference

| Effect | Behavior | Common Use |
|--------|---------|-----------|
| `Disabled` | Policy is off | Temporarily disable a policy |
| `Audit` | Log non-compliance; do not block | Initial assessment |
| `AuditIfNotExists` | Audit if a related resource doesn't exist | Check for companion resources |
| `Deny` | Block non-compliant create/update | Enforce standards |
| `DeployIfNotExists` | Auto-deploy related resource if missing | Auto-configure logging, agents |
| `Modify` | Add/update/remove properties | Enforce tags, settings |
| `Append` | Add fields to request | Add required tags |
| `Manual` | Requires manual remediation attestation | Compliance tracking only |

---

## Initiative Definition (Policy Set)

An initiative groups multiple policy definitions into a single assignment.

```
Initiative: "CIS Microsoft Azure Foundations Benchmark"
    ├── Policy: "MFA should be enabled for accounts with owner permissions"
    ├── Policy: "Diagnostic logs in Key Vault should be enabled"
    ├── Policy: "Storage accounts should restrict network access"
    └── Policy: "Disk encryption should be applied on virtual machines"
```

**Assignment scope**: Apply an initiative to a management group, subscription, or resource group.

---

## Compliance Evaluation Triggers

| Trigger | When |
|---------|------|
| New/updated resource | Evaluated within 30 minutes |
| Policy assigned/updated | On-demand scan + next 24-hour cycle |
| Manual trigger | `az policy state trigger-scan` |
| Daily background scan | Every 24 hours |

---

## Management Groups

```
Root Management Group (tenant root)
    ├── Production MG
    │       ├── Sub-Prod-01
    │       └── Sub-Prod-02
    ├── Development MG
    │       └── Sub-Dev-01
    └── Sandbox MG
            └── Sub-Sandbox-01
```

**Limits**: Up to 6 levels deep (excluding root); max 10,000 management groups.

**Policy inheritance**: Policies assigned to a management group automatically apply to all child management groups and subscriptions.

---

## Deny Assignment vs. Deny Policy

| Aspect | Deny Assignment (RBAC) | Deny Effect (Policy) |
|--------|----------------------|---------------------|
| What it does | Prevents specific actions by principals | Prevents creation/update of non-compliant resources |
| Who can create | Azure Blueprints, Managed Apps | Any user with Policy Contributor |
| Can override Allow | Yes | Yes (blocks creation) |
| Scope | Principal-specific | All principals |

---

## Common Built-in Policy Examples

| Policy Name | Effect | Category |
|------------|--------|---------|
| Require a tag on resources | deny/append | Tags |
| Allowed locations | deny | General |
| Allowed virtual machine SKUs | deny | Compute |
| Diagnostic logs in Key Vault should be enabled | AuditIfNotExists | Key Vault |
| MFA should be enabled for accounts with owner permissions | Audit | Security Center |
| Storage accounts should restrict network access | Audit/Deny | Storage |
| Disk encryption should be applied on VMs | AuditIfNotExists | Compute |
| Kubernetes cluster containers should only use allowed images | deny | Kubernetes |
| Azure Defender for SQL should be enabled | AuditIfNotExists | SQL |
