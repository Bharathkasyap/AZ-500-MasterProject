# Microsoft Entra ID Identity Protection

## 📌 What is Identity Protection?

**Microsoft Entra ID Identity Protection** uses machine learning to detect suspicious sign-in behaviors and potential identity compromises. It automatically:

- Detects **risky sign-ins** (anomalous sign-in patterns)
- Detects **risky users** (potentially compromised accounts)
- Enables **automated remediation** via risk-based Conditional Access policies
- Provides **investigation** tools for security teams

> ⚠️ **Exam Note**: Identity Protection requires **Microsoft Entra ID P2** license.

---

## 🔍 Risk Detections

### Sign-in Risk
Probability that the sign-in request was NOT made by the account owner.

| Detection | Risk Level | Description |
|-----------|------------|-------------|
| **Atypical travel** | Medium | Sign-in from geographically distant locations within impossible timeframe |
| **Anonymous IP address** | Medium | Sign-in from Tor or anonymous proxy |
| **Malware-linked IP address** | High | Sign-in from IP associated with malware botnet |
| **Unfamiliar sign-in properties** | Medium | New location, device, or browser never used before |
| **Admin confirmed user compromised** | High | Admin manually marked user as compromised |
| **Password spray** | High | Brute-force attack using common passwords across many accounts |
| **Impossible travel** | Medium | Sign-in from two locations impossible to travel between |
| **Verified threat actor IP** | High | Microsoft Threat Intelligence identifies the IP |
| **Anomalous Token** | High | Unusual token characteristics |

### User Risk
Probability that the user account has been compromised.

| Detection | Risk Level | Description |
|-----------|------------|-------------|
| **Leaked credentials** | High | Credentials found in dark web / paste sites |
| **Entra ID Threat Intelligence** | High/Medium | Microsoft internal threat signals |
| **Suspicious API traffic** | Medium | Unusual Graph API usage patterns |

---

## 📊 Risk Levels

| Level | Description |
|-------|-------------|
| **Low** | Suspicious but not confirmed |
| **Medium** | Some indicators of compromise |
| **High** | Strong indicators of compromise |

---

## 🔄 Risk-Based Conditional Access Policies

Identity Protection integrates with Conditional Access to automatically respond to risk:

### Sign-in Risk Policy
```
IF: Sign-in risk = Medium or higher
THEN: Require MFA (self-remediation — user completes MFA to clear risk)
```

### User Risk Policy
```
IF: User risk = High
THEN: Require password change
```

> 💡 **Best Practice**: Configure these policies in **Conditional Access** (not the legacy Identity Protection blade) for more control.

---

## ⚙️ Configuring Identity Protection

### Via Conditional Access (Recommended)

1. Navigate to **Entra ID → Security → Conditional Access**
2. Create new policy
3. **Conditions → User risk** or **Sign-in risk** → Select risk level
4. **Grant** → Require MFA (for sign-in risk) or Require password change (for user risk)

### Via Identity Protection Blade (Legacy)
- **Sign-in risk policy** — Similar configuration, less flexible
- **User risk policy** — Can block or require password change
- **MFA registration policy** — Ensure users register MFA methods

---

## 🔎 Investigation Tools

### Risky Users Report
- Lists users with current or historical risk
- Actions: Confirm compromised, Dismiss risk, Reset password, Block sign-in
- Shows risk events that contributed to user risk

### Risky Sign-ins Report
- Lists sign-ins flagged as risky
- Can confirm safe (false positive) or confirm compromise
- Shows detection details

### Risk Detections Report
- Detailed log of all individual risk detections
- Useful for forensic analysis

---

## 🛡️ Admin Actions in Identity Protection

| Action | Description |
|--------|-------------|
| **Confirm user compromised** | Escalates user risk to High; triggers response policies |
| **Dismiss user risk** | Marks detections as false positives; clears risk level |
| **Confirm sign-in safe** | Marks a risky sign-in as legitimate |
| **Confirm sign-in compromised** | Marks a sign-in as confirmed malicious |
| **Block user** | Prevents all sign-ins for the user |
| **Reset password** | Admin resets the user's password |

---

## 🔄 Risk Remediation

### User Self-Remediation (Automated)
- **MFA completion** → Clears sign-in risk
- **Password change** → Clears user risk (when required by policy)
- User does this without IT intervention

### Admin Remediation (Manual)
- Admin dismisses risk (false positive)
- Admin resets user password
- Admin blocks/unblocks user

---

## 📋 Identity Protection + Microsoft Sentinel Integration

Identity Protection risk data can be exported to:
- **Microsoft Sentinel** — Via Entra ID data connector
- **Azure Monitor** — Logs sent to Log Analytics workspace
- **Security Information and Event Management (SIEM)** tools via Azure Monitor

---

## 🔗 Useful Queries (Log Analytics / KQL)

```kql
// Risky sign-ins in the last 7 days
AADRiskySignins
| where TimeGenerated > ago(7d)
| where RiskLevelDuringSignIn in ("high", "medium")
| project TimeGenerated, UserPrincipalName, RiskLevelDuringSignIn, RiskDetail
| order by TimeGenerated desc

// Users with high user risk
AADRiskyUsers
| where RiskLevel == "high"
| project UserPrincipalName, RiskLevel, RiskDetail, RiskLastUpdatedDateTime
```

---

## ❓ Practice Questions

1. A user's credentials were found in a data breach and are being sold on the dark web. What Identity Protection detection type would be triggered?
   - A) Atypical travel
   - B) Anonymous IP address
   - **C) Leaked credentials** ✅
   - D) Password spray

2. You want Identity Protection to automatically require users to change their password when their user risk is High. What is the recommended approach?
   - A) Configure the User Risk policy in the Identity Protection blade
   - **B) Create a Conditional Access policy with User Risk condition and Require password change grant control** ✅
   - C) Enable SSPR for all users
   - D) Configure MFA for all users

3. A security analyst reviews a sign-in that was flagged as risky and determines it was a legitimate sign-in by the user working from a hotel. What action should the analyst take?
   - A) Confirm user compromised
   - B) Block the user temporarily
   - **C) Confirm sign-in safe** ✅
   - D) Reset the user's password

4. What license is required to use Microsoft Entra ID Identity Protection?
   - A) Entra ID Free
   - B) Entra ID P1
   - **C) Entra ID P2** ✅
   - D) Microsoft 365 Business Basic

---

## 📚 References

- [Identity Protection Documentation](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- [Risk Detections Reference](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-risks)
- [Remediate Risks](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-remediate-unblock)
