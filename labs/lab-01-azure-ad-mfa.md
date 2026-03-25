# Lab 01 — Enable MFA and Conditional Access Policy

## Objective

By the end of this lab you will be able to:
- Enable per-user MFA in Azure AD
- Configure a Conditional Access policy that requires MFA for all users accessing the Azure portal
- Create a named location to exclude a trusted IP range from MFA
- Test policy behaviour with a pilot user

---

## Prerequisites

- An Azure subscription with an Azure AD tenant
- **Azure AD Premium P1** license (free 30-day trial available via [aka.ms/tryAADP1](https://aka.ms/tryAADP1))
- A test user account (create one in Azure AD if needed)
- The Microsoft Authenticator app installed on your mobile device

---

## Part 1 — Create a Test User

1. Navigate to [portal.azure.com](https://portal.azure.com) → **Azure Active Directory** → **Users** → **New user**.
2. Select **Create user**.
3. Fill in:
   - **User principal name**: `mfatestuser@<yourdomain>.onmicrosoft.com`
   - **Display name**: `MFA Test User`
   - **Password**: auto-generated (note it down)
4. Under **Assignments**, assign the **Azure AD Premium P1** license.
5. Click **Create**.

---

## Part 2 — Create a Named Location (Trusted IP)

This step excludes a known trusted IP from MFA requirements.

1. Azure AD → **Security** → **Named locations** → **+ IP ranges location**.
2. Name: `Corporate Office`
3. Add your current public IP address (check [whatismyip.com](https://whatismyip.com)) in CIDR notation, e.g., `203.0.113.10/32`.
4. Check **Mark as trusted location**.
5. Click **Create**.

---

## Part 3 — Create a Conditional Access Policy

1. Azure AD → **Security** → **Conditional Access** → **+ New policy**.
2. **Name**: `Require MFA - Azure Portal`
3. **Assignments**:
   - **Users**: Include → **Selected users and groups** → select your test user.
   - **Cloud apps**: Include → **Select apps** → search for and select **Microsoft Azure Management**.
   - **Conditions** → **Locations** → Configure: **Yes** → Include: **Any location** → Exclude: **All trusted locations**.
4. **Access controls** → **Grant**:
   - Select **Grant access**
   - Check **Require multi-factor authentication**
   - Click **Select**
5. **Enable policy**: Set to **On** (or **Report-only** for safe testing first).
6. Click **Create**.

> **Best practice**: Always test new policies in **Report-only** mode before enabling them to prevent accidental lockouts.

---

## Part 4 — Register MFA for the Test User

1. Open a new **InPrivate/Incognito** browser window.
2. Navigate to [portal.azure.com](https://portal.azure.com).
3. Sign in as `mfatestuser@<yourdomain>.onmicrosoft.com`.
4. You will be prompted to **"More information required"** — click **Next**.
5. Follow the wizard to register the **Microsoft Authenticator** app:
   - Open Authenticator → **+** → **Work or school account** → **Scan QR code**
   - Scan the QR code shown in the browser
   - Complete the approval notification

---

## Part 5 — Verify MFA is Enforced

1. Open a new InPrivate browser window and sign in as `mfatestuser`.
2. Access [portal.azure.com](https://portal.azure.com).
3. You should be prompted for MFA:
   - Approve the notification in Microsoft Authenticator
4. Verify you can access the Azure portal **only after** completing MFA.

### Expected Result
- Access from outside the trusted IP → MFA required ✅
- Access from the trusted IP (your corporate network) → MFA not required ✅

---

## Part 6 — Review Sign-in Logs

1. Azure AD → **Monitoring** → **Sign-in logs**.
2. Filter by the test user's UPN.
3. Click a sign-in event and review:
   - **Conditional Access** tab — which policies applied
   - **Authentication Details** tab — which MFA method was used
4. Note the **Report-only** policy status if you enabled that mode.

---

## Cleanup

To avoid unexpected charges or locked-out users:
1. Set the Conditional Access policy to **Off** or delete it.
2. Delete the test user if it was created only for this lab.

---

## Key Takeaways

- Conditional Access policies are evaluated **at authentication time** — no restart needed.
- **Named locations** allow fine-grained control based on network.
- **Report-only mode** is essential for safely testing policies.
- MFA registration can be enforced via the **MFA Registration Policy** in Identity Protection (P2).
