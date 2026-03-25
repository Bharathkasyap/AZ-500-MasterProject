# Multi-Factor Authentication (MFA) and Self-Service Password Reset (SSPR)

## 📌 Multi-Factor Authentication (MFA)

**MFA** requires users to prove their identity using two or more verification factors:

1. **Something you know** — Password
2. **Something you have** — Phone, authenticator app, hardware token
3. **Something you are** — Biometrics (fingerprint, face)

> 💡 **Exam Note**: MFA is the single most effective control against identity-based attacks (99.9% of account compromise attacks are blocked by MFA).

---

## 🔑 MFA Verification Methods

| Method | Security Level | Notes |
|--------|---------------|-------|
| **Microsoft Authenticator app (push notification)** | High | Recommended; supports number matching |
| **OATH TOTP (Authenticator app code)** | High | Time-based one-time passwords |
| **FIDO2 Security Key** | Very High | Phishing-resistant |
| **Windows Hello for Business** | Very High | Phishing-resistant |
| **Certificate-based authentication** | Very High | Smart cards, PIV |
| **SMS text message** | Low-Medium | Vulnerable to SIM swap; avoid if possible |
| **Voice call** | Low-Medium | Less preferred |
| **Hardware OATH tokens** | High | Physical token |

> ⚠️ **Exam Note**: SMS and voice call are the least secure MFA methods. Microsoft recommends moving away from them.

---

## 🏢 How to Enable MFA

### Option 1: Security Defaults (Free tier)
- Enables MFA for all users (all admins required, others prompted)
- Cannot be customized
- Blocks legacy authentication
- Suitable for small organizations with no P1/P2 license

### Option 2: Per-User MFA (Legacy method)
- Enable MFA per individual user account
- Three states: **Disabled**, **Enabled**, **Enforced**
- Not recommended — use Conditional Access instead

### Option 3: Conditional Access (Recommended)
- Granular control: who, what app, what conditions
- Requires Entra ID P1 license
- Most flexible approach

---

## 🔐 Microsoft Authenticator — Number Matching

**Number matching** prevents MFA fatigue attacks (push notification spam):
- The sign-in screen shows a 2-digit number
- User must enter that number in the Authenticator app
- Enabled by default for all users

**Additional context** (optional):
- Shows the application being signed into
- Shows the geographic location of the sign-in request

---

## 🛡️ MFA Trusted IPs / Skip MFA

In **Conditional Access Named Locations**:
- Mark corporate IP ranges as trusted
- Policies can be set to not require MFA from trusted locations

In legacy **MFA settings**:
- **Trusted IPs** — Skip MFA for defined IPv4 ranges
- **Remember MFA on device** — Skip MFA for up to 90 days on trusted devices

---

## 🔄 Self-Service Password Reset (SSPR)

**SSPR** allows users to reset their own passwords without IT helpdesk intervention.

### SSPR Authentication Methods

| Method | Notes |
|--------|-------|
| **Mobile app notification** | Microsoft Authenticator push |
| **Mobile app code** | TOTP code from authenticator |
| **Email** | Code sent to alternate email |
| **Mobile phone** | SMS code or voice call |
| **Office phone** | Voice call |
| **Security questions** | Least secure; not recommended alone |

### SSPR Requirements
- **Number of methods required**: 1 or 2 (configurable)
- **License**: Entra ID P1 (for cloud-only) or P2; Free for limited scenarios
- **Admin accounts**: Require 2 methods and cannot use security questions

---

## ⚙️ SSPR Configuration

```
Azure Portal → Entra ID → Password reset

Key settings:
- Self-service password reset enabled: None / Selected / All
- Authentication methods: Select which methods users can register
- Registration: Require users to register at sign-in
- Notifications: Notify users on password reset, notify admins on admin resets
- Customization: Custom helpdesk link
```

---

## 🔗 SSPR Writeback (Hybrid)

For hybrid environments, **password writeback** sends password resets back to on-premises AD:

- Requires **Microsoft Entra Connect**
- Requires Entra ID **P1 or P2**
- Enables users to reset on-prem passwords from the cloud
- Supports on-prem password complexity policies

```bash
# Verify password writeback is configured in Entra Connect
# In Entra Connect wizard: Optional Features → Password writeback (enable)
```

---

## 📋 SSPR vs MFA Registration

| Feature | Combined Registration |
|---------|----------------------|
| **Combined security info registration** | Registers SSPR and MFA methods in one place |
| **URL** | https://mysignins.microsoft.com/security-info |
| **Benefit** | Single registration experience for both MFA and SSPR |

---

## 📊 Authentication Strength Policies

**Authentication Strength** is a Conditional Access control that specifies which MFA methods are acceptable:

| Strength | Methods Included |
|----------|-----------------|
| **Multifactor authentication** | All MFA methods |
| **Passwordless MFA** | Authenticator app, FIDO2, Windows Hello |
| **Phishing-resistant MFA** | FIDO2, Windows Hello, certificate-based auth |
| **Custom strength** | Define specific combination |

---

## 🚨 MFA Fraud Alert (Legacy) / Report Suspicious Activity

Users can report suspicious MFA prompts they didn't initiate:
- In **Authenticator app**: Report "This isn't me"
- In **legacy fraud alert**: Dial `0#` during voice verification
- Reported users can be automatically blocked (configurable)

---

## ❓ Practice Questions

1. A user reports receiving repeated Microsoft Authenticator push notifications they did not initiate. Which MFA feature should you enable to mitigate this attack?
   - A) Passwordless authentication
   - **B) Number matching** ✅
   - C) FIDO2 security keys
   - D) Certificate-based authentication

2. You need to allow users to reset their on-premises Active Directory passwords using the cloud-based SSPR. What is required?
   - A) Entra ID Free + Azure AD Connect
   - **B) Entra ID P1 + Entra Connect with password writeback** ✅
   - C) Entra ID P2 only
   - D) Microsoft Intune

3. Which SSPR authentication method is considered the LEAST secure?
   - A) Mobile app notification
   - B) Email
   - **C) Security questions** ✅
   - D) Mobile phone (SMS)

4. Your company has Entra ID Free licenses. How can you enforce MFA for all users?
   - A) Per-user MFA
   - **B) Enable Security Defaults** ✅
   - C) Conditional Access
   - D) Authentication policies

5. A Conditional Access policy requires phishing-resistant MFA for all admin sign-ins. Which authentication method would satisfy this requirement?
   - A) Microsoft Authenticator push notification
   - B) SMS text message
   - **C) FIDO2 security key** ✅
   - D) OATH TOTP code

---

## 📚 References

- [MFA Documentation](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks)
- [SSPR Documentation](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks)
- [Authentication Methods Policy](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)
- [Authentication Strength](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-authentication-strengths)
