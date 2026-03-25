# Lab 01: Identity and Access Management

> **Estimated Time:** 60–90 minutes  
> **Domain:** 1 — Manage Identity and Access  
> **Prerequisites:** Azure subscription, Azure CLI or Azure Portal access, Azure AD P2 license (for PIM exercises)

---

## Lab Overview

In this lab, you will:
1. Create and manage Azure AD users and groups
2. Configure Azure RBAC custom role and assignments
3. Enable and configure Privileged Identity Management (PIM)
4. Create a Conditional Access policy requiring MFA
5. Configure a managed identity for an Azure resource

---

## Exercise 1: Azure AD User and Group Management

### Task 1.1: Create an Azure AD user via the portal

1. Sign in to the [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** → **Users** → **+ New user** → **Create user**
3. Fill in the following:
   - **User principal name:** `lab-reader@<yourdomain>.onmicrosoft.com`
   - **Display name:** `Lab Reader`
   - **Password:** Auto-generate and copy the temporary password
4. Click **Create**

### Task 1.2: Create a security group

1. Navigate to **Azure Active Directory** → **Groups** → **+ New group**
2. Configure:
   - **Group type:** Security
   - **Group name:** `AZ500-Lab-Readers`
   - **Membership type:** Assigned
3. Under **Members**, add the `Lab Reader` user
4. Click **Create**

### Task 1.3: Verify group membership

```bash
# Verify via CLI
az ad group member list \
  --group "AZ500-Lab-Readers" \
  --query "[].userPrincipalName" \
  --output table
```

✅ **Validation:** The `lab-reader` user should appear in the group member list.

---

## Exercise 2: Azure RBAC Custom Role and Assignment

### Task 2.1: Create a custom role

1. In the Azure Portal, navigate to **Subscriptions** → select your subscription
2. Click **Access control (IAM)** → **+ Add** → **Add custom role**
3. Start from **Start from scratch** and configure:
   - **Name:** `VM Operator (AZ500 Lab)`
   - **Description:** `Can start, stop, and view VMs but cannot create or delete`
4. Under **Permissions**, click **+ Add permissions**:
   - Search for `Microsoft.Compute/virtualMachines` and add:
     - `Microsoft.Compute/virtualMachines/start/action`
     - `Microsoft.Compute/virtualMachines/deallocate/action`
     - `Microsoft.Compute/virtualMachines/read`
     - `Microsoft.Compute/virtualMachines/*/read`
5. Set **Assignable scopes** to your subscription
6. Click **Review + create** → **Create**

Alternatively via CLI:
```bash
cat > /tmp/vm-operator-role.json << 'EOF'
{
  "Name": "VM Operator (AZ500 Lab)",
  "Description": "Can start, stop, and view VMs but cannot create or delete",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/*/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read"
  ],
  "NotActions": [],
  "AssignableScopes": [
    "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
  ]
}
EOF

az role definition create --role-definition /tmp/vm-operator-role.json
```

### Task 2.2: Assign the custom role

```bash
# Get the Lab Reader user's object ID
USER_OID=$(az ad user show --id "lab-reader@<yourdomain>.onmicrosoft.com" --query id --output tsv)

# Assign the custom role on a resource group
az role assignment create \
  --assignee "$USER_OID" \
  --role "VM Operator (AZ500 Lab)" \
  --resource-group "rg-az500-compute-lab"
```

### Task 2.3: Verify effective permissions

```bash
az role assignment list \
  --assignee "$USER_OID" \
  --all \
  --output table
```

✅ **Validation:** The `VM Operator (AZ500 Lab)` role assignment should appear.

---

## Exercise 3: Privileged Identity Management (PIM)

> ⚠️ **Requires:** Azure AD Premium P2 license

### Task 3.1: Enable PIM for an Azure AD role

1. Navigate to **Azure Active Directory** → **Identity Governance** → **Privileged Identity Management**
2. Click **Azure AD roles** → **Roles**
3. Find the **Security Reader** role → Click on it → **+ Add assignments**
4. Configure:
   - **Select member(s):** `Lab Reader`
   - **Assignment type:** Eligible
   - **Assignment start/end:** Set 30-day window
5. Click **Assign**

### Task 3.2: Configure activation settings

1. In PIM, go to **Azure AD roles** → **Settings**
2. Find **Security Reader** → Click **Edit**
3. Configure:
   - **Activation maximum duration:** 2 hours
   - **On activation, require:** Multi-factor authentication
   - **Require justification on activation:** Enabled
4. Click **Update**

### Task 3.3: Test activation (as the Lab Reader user)

1. Sign in to the portal as `lab-reader@<yourdomain>.onmicrosoft.com`
2. Navigate to **PIM** → **My roles** → **Azure AD roles**
3. Find **Security Reader** → Click **Activate**
4. Provide a justification and complete MFA
5. The role becomes active for up to 2 hours

✅ **Validation:** The activation request appears in PIM → **Azure AD roles** → **Audit history**.

---

## Exercise 4: Conditional Access Policy

### Task 4.1: Create a policy requiring MFA from outside trusted locations

1. Navigate to **Azure Active Directory** → **Security** → **Conditional Access** → **+ New policy**
2. Configure:
   - **Name:** `Require MFA - External Locations`
   - **Users:** All users (or target a specific group like `AZ500-Lab-Readers`)
   - **Cloud apps:** All cloud apps
   - **Conditions** → **Locations**:
     - **Include:** Any location
     - **Exclude:** All trusted locations (or define a named location for your office IP)
   - **Grant:** Require multi-factor authentication
3. **Enable policy:** Report-only (safe for lab; use On for production)
4. Click **Create**

### Task 4.2: Create a Named Location (corporate network)

1. In Conditional Access, click **Named locations** → **+ IP ranges location**
2. Configure:
   - **Name:** `Corporate Network`
   - **Mark as trusted location:** ✅
   - **IP ranges:** Enter your current public IP (find it at https://whatismyip.com)
3. Click **Create**

✅ **Validation:** Policy appears in Conditional Access with "Report-only" state. Sign-in logs show the policy evaluation.

---

## Exercise 5: Managed Identity

### Task 5.1: Create a VM and enable system-assigned managed identity

```bash
# Create a test resource group
az group create --name rg-az500-id-lab --location eastus

# Create VM with system-assigned identity
az vm create \
  --resource-group rg-az500-id-lab \
  --name vm-identity-test \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --assign-identity "[system]" \
  --public-ip-address "" \
  --output none

# Get the managed identity's principal ID
VM_PRINCIPAL_ID=$(az vm show \
  --resource-group rg-az500-id-lab \
  --name vm-identity-test \
  --query "identity.principalId" \
  --output tsv)

echo "VM Principal ID: $VM_PRINCIPAL_ID"
```

### Task 5.2: Grant the managed identity access to a Key Vault secret

```bash
# Create a Key Vault
az keyvault create \
  --resource-group rg-az500-id-lab \
  --name kv-idlab-$(openssl rand -hex 4) \
  --enable-rbac-authorization true \
  --output none

KV_NAME=$(az keyvault list --resource-group rg-az500-id-lab --query "[0].name" --output tsv)

# Grant the VM identity Key Vault Secrets User
az role assignment create \
  --assignee "$VM_PRINCIPAL_ID" \
  --role "Key Vault Secrets User" \
  --scope "$(az keyvault show --name $KV_NAME --query id --output tsv)"

# Store a secret
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "my-secret" \
  --value "Hello-from-ManagedIdentity"
```

### Task 5.3: Retrieve the secret using managed identity (from inside the VM)

SSH into the VM (or use Azure Bastion) and run:
```bash
# Get an access token using the metadata endpoint (IMDS)
TOKEN=$(curl -s \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net" \
  -H "Metadata:true" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Use the token to get the secret from Key Vault
curl -s \
  "https://<KV_NAME>.vault.azure.net/secrets/my-secret?api-version=7.4" \
  -H "Authorization: Bearer $TOKEN" | python3 -c "import sys,json; print(json.load(sys.stdin)['value'])"
```

✅ **Validation:** The secret value `Hello-from-ManagedIdentity` is returned without any credentials stored on the VM.

---

## Lab Cleanup

```bash
# Delete resource groups
az group delete --name rg-az500-id-lab --yes --no-wait
az group delete --name rg-az500-identity-lab --yes --no-wait

# Delete test user and group
az ad user delete --id "lab-reader@<yourdomain>.onmicrosoft.com"
az ad group delete --group "AZ500-Lab-Readers"

# Delete custom role
az role definition delete --name "VM Operator (AZ500 Lab)"
```

---

## Lab Summary

| Concept | What You Practiced |
|---|---|
| Azure AD user/group management | Creating users and groups via portal and CLI |
| Azure RBAC | Custom role definition, assignment at resource group scope |
| PIM | Eligible assignment, activation settings (MFA + justification + time limit) |
| Conditional Access | Policy requiring MFA from external locations |
| Managed Identity | System-assigned identity, Key Vault RBAC, token acquisition via IMDS |

---

*Back to [README](../README.md) | Next: [Lab 02 — Secure Networking →](lab-02-secure-networking.md)*
