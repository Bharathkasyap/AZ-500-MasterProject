# Lab 02: RBAC Role Assignments

> **Domain**: Identity and Access | **Difficulty**: Beginner | **Time**: ~25 minutes

---

## Prerequisites

- Azure subscription with Owner or User Access Administrator role
- Azure CLI installed and authenticated (`az login`)

---

## Objectives

By the end of this lab, you will be able to:
- Assign built-in RBAC roles at resource group and subscription scope
- Create and assign a custom RBAC role
- Verify effective permissions
- Remove role assignments

---

## Part 1: Assign Built-in RBAC Roles

### Step 1.1 — Create a Resource Group and Test User

```bash
# Create resource group
az group create --name RBACLabRG --location eastus

# Create test user
az ad user create \
  --display-name "RBAC Test User" \
  --user-principal-name rbactestuser@<your-tenant>.onmicrosoft.com \
  --password "P@ssw0rd123!" \
  --force-change-password-next-sign-in false

# Get user's object ID
USER_ID=$(az ad user show \
  --id rbactestuser@<your-tenant>.onmicrosoft.com \
  --query id --output tsv)
echo "User Object ID: $USER_ID"
```

### Step 1.2 — Assign Reader Role at Resource Group Scope

```bash
# Assign Reader role
az role assignment create \
  --assignee $USER_ID \
  --role "Reader" \
  --resource-group RBACLabRG

# Verify assignment
az role assignment list \
  --assignee $USER_ID \
  --resource-group RBACLabRG \
  --output table
```

### Step 1.3 — Assign Contributor Role at Subscription Scope

```bash
# Get subscription ID
SUB_ID=$(az account show --query id --output tsv)

# Assign Contributor at subscription scope
az role assignment create \
  --assignee $USER_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUB_ID"

# List all assignments for the user
az role assignment list \
  --assignee $USER_ID \
  --all \
  --output table
```

---

## Part 2: Create a Custom RBAC Role

### Step 2.1 — Define the Custom Role

Create a file `/tmp/vm-operator-role.json`:

```json
{
  "Name": "VM Operator",
  "IsCustom": true,
  "Description": "Can start, stop, and restart VMs. Can view VM details.",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/extensions/read",
    "Microsoft.Compute/virtualMachineScaleSets/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Authorization/*/read",
    "Microsoft.Insights/alertRules/*"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/SUBSCRIPTION_ID_PLACEHOLDER"
  ]
}
```

### Step 2.2 — Create the Role

```bash
SUB_ID=$(az account show --query id --output tsv)

# Update subscription ID in the role definition file
sed -i "s/SUBSCRIPTION_ID_PLACEHOLDER/$SUB_ID/g" /tmp/vm-operator-role.json

# Create the custom role
az role definition create --role-definition /tmp/vm-operator-role.json

# Verify creation
az role definition list --name "VM Operator" --output table
```

### Step 2.3 — Assign the Custom Role

```bash
az role assignment create \
  --assignee $USER_ID \
  --role "VM Operator" \
  --resource-group RBACLabRG

# Verify
az role assignment list \
  --assignee $USER_ID \
  --resource-group RBACLabRG \
  --output table
```

---

## Part 3: Check Effective Permissions

### Step 3.1 — View All Role Assignments for a User

```bash
az role assignment list \
  --assignee $USER_ID \
  --all \
  --output json | \
  jq '.[] | {role: .roleDefinitionName, scope: .scope}'
```

### Step 3.2 — Check Permissions via Portal

1. Navigate to **Resource Group** → RBACLabRG → **Access control (IAM)**
2. Click **Check access** tab
3. Search for the test user
4. Review all role assignments and effective permissions

---

## Part 4: Cleanup

```bash
# Remove role assignments
az role assignment delete \
  --assignee $USER_ID \
  --role "Reader" \
  --resource-group RBACLabRG

az role assignment delete \
  --assignee $USER_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUB_ID"

az role assignment delete \
  --assignee $USER_ID \
  --role "VM Operator" \
  --resource-group RBACLabRG

# Delete custom role definition
az role definition delete --name "VM Operator"

# Delete test user
az ad user delete --id rbactestuser@<your-tenant>.onmicrosoft.com

# Delete resource group
az group delete --name RBACLabRG --yes --no-wait
```

---

## ✅ Verification Checklist

- [ ] Test user created successfully
- [ ] Reader role assigned at resource group scope
- [ ] Contributor role assigned at subscription scope
- [ ] Custom VM Operator role created with specific permissions
- [ ] Custom role assigned to test user
- [ ] Effective permissions verified via Portal
- [ ] All resources cleaned up

---

> ⬅️ [Lab 01: MFA](./lab-01-azure-ad-mfa.md) | ➡️ [Lab 03: Key Vault](./lab-03-key-vault.md)
