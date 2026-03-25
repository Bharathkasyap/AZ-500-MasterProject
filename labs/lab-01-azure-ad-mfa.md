# Lab 01 — Configure MFA and Conditional Access

> **Estimated time:** 45–60 minutes  
> **Prerequisites:** Azure subscription (free tier works), Entra ID P2 trial activated  
> **Skills practiced:** Domain 1 — Manage Identity and Access

---

## Objectives

By the end of this lab you will be able to:

1. Create a test user in Microsoft Entra ID.
2. Enable per-user MFA (legacy method — for comparison only).
3. Create a Conditional Access policy requiring MFA for Azure portal access.
4. Configure a named location (trusted IP range) to exclude corporate IPs.
5. Configure a Privileged Identity Management (PIM) eligible role assignment.
6. Test the end-to-end experience as the test user.

---

## Architecture

```
Test User (user@domain.onmicrosoft.com)
  │
  ▼ Sign-in attempt to Azure portal
  │
Conditional Access Engine
  ├── Condition: Target app = Microsoft Azure Management
  ├── Condition: Not in Trusted Locations
  └── Grant Control: Require MFA
        │
        ▼
  MFA Prompt (Microsoft Authenticator / phone)
        │
        ▼
  Access Granted
```

---

## Part 1 — Create a Test User

### Azure Portal Steps

1. Navigate to **Microsoft Entra ID** → **Users** → **New user** → **Create new user**.
2. Fill in:
   - **User principal name**: `az500-testuser@<yourtenant>.onmicrosoft.com`
   - **Display name**: `AZ500 Test User`
   - **Password**: Auto-generate (copy it)
   - **Usage location**: United States (required for license assignment)
3. Click **Create**.

### Azure CLI Alternative

```bash
az ad user create \
  --display-name "AZ500 Test User" \
  --user-principal-name "az500-testuser@<yourtenant>.onmicrosoft.com" \
  --password "TempP@ssw0rd123!" \
  --force-change-password-next-sign-in true
```

---

## Part 2 — Configure a Named Location (Trusted IP)

1. Navigate to **Entra ID** → **Security** → **Conditional Access** → **Named locations**.
2. Click **+ IP ranges location**.
3. Name: `Corporate Network`
4. Add your current public IP (check https://whatismyip.com).
5. Check **Mark as trusted location**.
6. Click **Create**.

---

## Part 3 — Create a Conditional Access Policy

### Goal: Require MFA for Azure portal access when NOT on the corporate network.

1. Navigate to **Entra ID** → **Security** → **Conditional Access** → **Policies** → **+ New policy**.
2. **Name**: `Require MFA for Azure Portal`
3. **Assignments**:
   - **Users**: Include → `AZ500 Test User`
4. **Target resources**:
   - **Cloud apps** → Include → Select apps → **Microsoft Azure Management**
5. **Conditions**:
   - **Locations** → Configure: Yes
     - Include: **Any location**
     - Exclude: **All trusted locations** (← this excludes the corporate network)
6. **Grant**:
   - **Grant access** → Check **Require multi-factor authentication**
7. **Enable policy**: **Report-only** first (safe testing mode), then **On** after verification.
8. Click **Create**.

---

## Part 4 — Register MFA for the Test User

1. Open an **InPrivate / Incognito** browser window.
2. Navigate to `https://aka.ms/mfasetup`.
3. Sign in as `az500-testuser@<yourtenant>.onmicrosoft.com`.
4. Complete the MFA setup wizard (use Microsoft Authenticator app or phone number).
5. Sign out.

---

## Part 5 — Test the Conditional Access Policy

1. In the InPrivate window, navigate to `https://portal.azure.com`.
2. Sign in as the test user.
3. **Expected**: MFA prompt appears (since the policy applies to Azure Management).
4. Complete MFA.
5. **Expected**: Access to Azure portal is granted.

### Test from Trusted Location
1. If you added your current IP as a trusted location, the MFA prompt should **not** appear.
2. Try from a different network (mobile hotspot) to confirm MFA is required.

---

## Part 6 — Configure PIM Eligible Role Assignment

> Requires Entra ID P2 license assigned to the test user.

1. Navigate to **Entra ID** → **Identity Governance** → **Privileged Identity Management**.
2. Click **Azure AD roles** → **Roles** → **Security Reader**.
3. Click **+ Add assignments** → **Eligible** tab.
4. Select: `AZ500 Test User`.
5. Set **Assignment type**: Eligible.
6. Set **Duration**: 30 days.
7. Click **Assign**.

### Configure PIM Role Settings
1. In PIM → **Azure AD roles** → **Settings** → **Security Reader**.
2. Click **Edit**.
3. Under **Activation**:
   - **Maximum activation duration**: 4 hours
   - **Require MFA on activation**: ✅ Enabled
   - **Require justification**: ✅ Enabled
4. Click **Update**.

### Test PIM Activation
1. Sign in as the test user at `https://portal.azure.com`.
2. Navigate to **PIM** → **My roles** → **Azure AD roles** → **Eligible assignments**.
3. Find **Security Reader** → Click **Activate**.
4. Enter justification text.
5. Complete MFA.
6. Role should become active for up to 4 hours.

---

## Part 7 — Review Sign-in Logs

1. Navigate to **Entra ID** → **Monitoring** → **Sign-in logs**.
2. Find the test user's sign-in entries.
3. Click on a sign-in to see details:
   - **Conditional Access** tab → shows which policies were applied and their result.
   - **Authentication details** tab → shows MFA method used.

---

## Cleanup

```bash
# Delete the test user
az ad user delete --id "az500-testuser@<yourtenant>.onmicrosoft.com"

# Delete the Conditional Access policy (via portal — no CLI for CA policies)
# Navigate to Entra ID → Security → Conditional Access → Delete the policy
```

---

## Key Takeaways

- **Conditional Access** policies are the recommended way to enforce MFA — not legacy per-user MFA.
- **Named locations** allow you to skip MFA for trusted networks.
- **PIM eligible assignments** require users to actively activate their roles — they don't have standing access.
- **MFA on PIM activation** ensures privileged access always requires a second factor.
- **Sign-in logs** are your audit trail for all authentication events.
