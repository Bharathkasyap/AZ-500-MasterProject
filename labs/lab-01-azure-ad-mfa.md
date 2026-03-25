# Lab 01: Enable Multi-Factor Authentication (MFA)

> **Domain**: Identity and Access | **Difficulty**: Beginner | **Time**: ~20 minutes

---

## Prerequisites

- Azure subscription with Global Administrator role
- Microsoft Entra ID P1 or P2 license (or Microsoft 365 E3/E5)
- A test user account

---

## Objectives

By the end of this lab, you will be able to:
- Configure Conditional Access to require MFA for a user group
- Register MFA methods as a test user
- Verify MFA enforcement at sign-in

---

## Part 1: Create a Test User and Group

### Step 1.1 — Create a Test User

```bash
az ad user create \
  --display-name "MFA Test User" \
  --user-principal-name mfatestuser@<your-tenant>.onmicrosoft.com \
  --password "P@ssw0rd123!" \
  --force-change-password-next-sign-in false
```

### Step 1.2 — Create a Security Group

```bash
az ad group create \
  --display-name "MFA-Required-Users" \
  --mail-nickname "mfa-required"

# Add test user to group
az ad group member add \
  --group "MFA-Required-Users" \
  --member-id $(az ad user show --id mfatestuser@<your-tenant>.onmicrosoft.com --query id --output tsv)
```

---

## Part 2: Configure Conditional Access Policy

### Step 2.1 — Create MFA Conditional Access Policy (Portal)

1. Sign in to the [Azure Portal](https://portal.azure.com) as Global Administrator
2. Navigate to **Microsoft Entra ID** → **Security** → **Conditional Access**
3. Click **+ New policy**
4. Name: `Require MFA for MFA-Required-Users`
5. **Assignments**:
   - **Users**: Include → Select users and groups → Groups → `MFA-Required-Users`
6. **Target resources**:
   - Cloud apps or actions → All cloud apps
7. **Access controls**:
   - Grant → **Require multi-factor authentication**
8. **Enable policy**: **On**
9. Click **Save**

> ⚠️ **Important**: Make sure you are not locking yourself out. Exclude your own admin account from the policy.

---

## Part 3: Register MFA Methods as Test User

### Step 3.1 — Register Authentication Methods

1. Open a **new InPrivate/Incognito** browser window
2. Sign in to [https://mysignins.microsoft.com/security-info](https://mysignins.microsoft.com/security-info) as the test user
3. Click **+ Add sign-in method**
4. Choose **Authenticator app**
5. Follow the prompts to:
   - Download Microsoft Authenticator app (or use any TOTP app)
   - Scan the QR code
   - Verify with a code

---

## Part 4: Verify MFA Enforcement

### Step 4.1 — Test Sign-In

1. In your InPrivate browser, sign out and sign back in as the test user
2. After entering the password, you should be prompted for MFA
3. Approve the MFA prompt in the Authenticator app
4. Confirm successful sign-in

### Step 4.2 — Review Sign-In Logs

```bash
# View recent sign-in logs for the test user
az ad user list \
  --filter "userPrincipalName eq 'mfatestuser@<your-tenant>.onmicrosoft.com'" \
  --query "[].id" --output tsv

# In Portal: Entra ID → Monitoring → Sign-in logs
# Filter by user and check "Authentication requirement" column
```

---

## Cleanup

```bash
# Remove test user
az ad user delete --id mfatestuser@<your-tenant>.onmicrosoft.com

# Remove test group
az ad group delete --group "MFA-Required-Users"

# Delete the Conditional Access policy via Portal:
# Entra ID → Security → Conditional Access → Select policy → Delete
```

---

## ✅ Verification Checklist

- [ ] Test user and group created successfully
- [ ] Conditional Access policy created targeting the test group
- [ ] Test user successfully registered MFA method
- [ ] MFA was prompted at sign-in
- [ ] Sign-in logs show MFA requirement and success

---

> ⬅️ [Back to README](../README.md) | ➡️ [Lab 02: RBAC Role Assignments](./lab-02-rbac-assignments.md)
