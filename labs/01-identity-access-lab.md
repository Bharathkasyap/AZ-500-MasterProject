# Lab 01 — Identity and Access

**Estimated Time:** 60–90 minutes  
**Prerequisite:** Azure subscription with Owner or User Access Administrator + Global Administrator on Entra ID tenant  
**Mapped Exam Domain:** Domain 1 — Manage Identity and Access

---

## Learning Objectives

- Create and manage Entra ID users and groups
- Assign Azure RBAC roles at resource-group scope
- Configure Privileged Identity Management (PIM) for an Azure resource role
- Create and test a Conditional Access policy requiring MFA

---

## Part 1 — Entra ID Users and Groups

### Step 1.1 — Create a test user

**Portal:**
1. Navigate to **Microsoft Entra ID** → **Users** → **+ New user** → **Create new user**
2. Fill in:
   - Username: `labuser1@<your-domain>.onmicrosoft.com`
   - Display name: `Lab User 1`
   - Password: Auto-generate (copy it)
3. Click **Create**

**CLI:**
```bash
az ad user create \
  --display-name "Lab User 1" \
  --user-principal-name labuser1@<your-domain>.onmicrosoft.com \
  --password "TempPass@2024!" \
  --force-change-password-next-sign-in true
```

### Step 1.2 — Create a security group

```bash
az ad group create \
  --display-name "AZ500-Lab-Readers" \
  --mail-nickname "AZ500LabReaders"

# Add user to group
az ad group member add \
  --group "AZ500-Lab-Readers" \
  --member-id $(az ad user show --id labuser1@<your-domain>.onmicrosoft.com --query id -o tsv)
```

---

## Part 2 — Azure RBAC Role Assignment

### Step 2.1 — Create a resource group and assign Reader role

```bash
# Create resource group
az group create --name lab-identity-rg --location eastus

# Get group object ID
GROUP_OID=$(az ad group show --group "AZ500-Lab-Readers" --query id -o tsv)

# Assign Reader role to the Entra group at RG scope
az role assignment create \
  --assignee-object-id $GROUP_OID \
  --assignee-principal-type Group \
  --role "Reader" \
  --scope /subscriptions/$(az account show --query id -o tsv)/resourceGroups/lab-identity-rg
```

### Step 2.2 — Validate the assignment

```bash
az role assignment list \
  --scope /subscriptions/$(az account show --query id -o tsv)/resourceGroups/lab-identity-rg \
  --output table
```

**Validation check:** The output should show `Reader` assigned to `AZ500-Lab-Readers` group.

---

## Part 3 — User-Assigned Managed Identity

### Step 3.1 — Create and assign a managed identity

```bash
# Create managed identity
az identity create \
  --name lab-managed-id \
  --resource-group lab-identity-rg

# Get principal ID
MI_PRINCIPAL=$(az identity show \
  --name lab-managed-id \
  --resource-group lab-identity-rg \
  --query principalId -o tsv)

echo "Managed Identity Principal ID: $MI_PRINCIPAL"
```

### Step 3.2 — Create Key Vault and assign Secrets User role

```bash
# Create Key Vault with RBAC mode
az keyvault create \
  --name lab-kv-$(date +%s) \
  --resource-group lab-identity-rg \
  --location eastus \
  --enable-rbac-authorization true \
  --enable-soft-delete true

KV_NAME=$(az keyvault list --resource-group lab-identity-rg --query "[0].name" -o tsv)
KV_SCOPE=$(az keyvault show --name $KV_NAME --query id -o tsv)

# Assign Key Vault Secrets User to managed identity
az role assignment create \
  --assignee-object-id $MI_PRINCIPAL \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope $KV_SCOPE

echo "Key Vault Secrets User role assigned to managed identity"
```

### Step 3.3 — Store a test secret

```bash
# Assign yourself Key Vault Secrets Officer first
MY_OID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --assignee-object-id $MY_OID \
  --assignee-principal-type User \
  --role "Key Vault Secrets Officer" \
  --scope $KV_SCOPE

# Create a secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "db-password" \
  --value "SuperSecret@2024"

echo "Secret stored in Key Vault"
```

**Validation check:** Confirm the secret is listed:
```bash
az keyvault secret list --vault-name $KV_NAME --output table
```

---

## Part 4 — Conditional Access (Portal Only)

> **Note:** Conditional Access configuration requires at least Entra ID P1 and cannot be automated via CLI in a straightforward way. Use the portal for this step.

### Step 4.1 — Create a Conditional Access policy (Report-only mode first)

1. Navigate to **Microsoft Entra ID** → **Security** → **Conditional Access** → **+ New policy**
2. Name: `Lab-Require-MFA-for-LabUsers`
3. **Assignments:**
   - Users: Include → Select `AZ500-Lab-Readers` group
   - Cloud apps: Include → All cloud apps
4. **Conditions:** Leave defaults (no additional conditions)
5. **Grant:**
   - Select **Grant access**
   - Check **Require multifactor authentication**
6. **Enable policy:** Set to **Report-only** (safe for testing)
7. Click **Create**

### Step 4.2 — Review Conditional Access sign-in impact

1. Navigate to **Entra ID** → **Sign-in logs**
2. Filter by `labuser1`
3. Click a sign-in event → **Conditional Access** tab
4. Verify the `Lab-Require-MFA-for-LabUsers` policy shows as **Report-only: Would require MFA**

---

## Part 5 — Verify and Validate

### Checklist

- [ ] `labuser1` created in Entra ID
- [ ] `AZ500-Lab-Readers` group created with `labuser1` as member
- [ ] `Reader` role assigned to the group on `lab-identity-rg`
- [ ] User-assigned managed identity `lab-managed-id` created
- [ ] Managed identity has `Key Vault Secrets User` role on the Key Vault
- [ ] Secret `db-password` stored in Key Vault
- [ ] Conditional Access policy `Lab-Require-MFA-for-LabUsers` created (report-only)

---

## Cleanup

```bash
# Remove role assignments (optional — will be removed with RG deletion)
az group delete --name lab-identity-rg --yes --no-wait

# Delete Entra ID user and group (optional)
az ad user delete --id labuser1@<your-domain>.onmicrosoft.com
az ad group delete --group "AZ500-Lab-Readers"
```

---

## Key Takeaways

1. RBAC assignments should target **groups**, not individual users.
2. Managed identities eliminate the need for stored credentials.
3. Key Vault RBAC mode provides granular, auditable access control.
4. Always test Conditional Access policies in **report-only mode** before enforcement.
