# Lab 04 — Enable Microsoft Defender for Cloud

## Objective

By the end of this lab you will be able to:
- Enable Microsoft Defender for Cloud on a subscription
- Enable specific Defender plans for workloads
- Review and remediate Secure Score recommendations
- Configure Just-in-Time (JIT) VM access
- Enable auto-provisioning of the Log Analytics agent
- Explore security alerts

---

## Prerequisites

- An Azure subscription (Owner or Security Admin role)
- A running Windows or Linux VM (or create one during the lab)
- A Log Analytics workspace (reuse from Lab 03 or create a new one)

---

## Part 1 — Enable Microsoft Defender for Cloud

### Using the Azure Portal

1. Navigate to [portal.azure.com](https://portal.azure.com).
2. Search for **Microsoft Defender for Cloud**.
3. Click **Getting started** → **Upgrade** to enable the enhanced security features (30-day free trial available).
4. Select your subscription and click **Upgrade**.

### Review the Overview Dashboard

1. In Defender for Cloud, click **Overview**.
2. Review:
   - **Secure Score** — your current posture percentage
   - **Regulatory compliance** — compliance against built-in standards
   - **Workload protections** — which plans are enabled/disabled
   - **Active recommendations** — items to fix

---

## Part 2 — Enable Defender Plans

1. Defender for Cloud → **Environment settings** → expand your subscription.
2. Click your subscription.
3. On the **Defender plans** page, enable the following (each has a free trial):
   - ✅ **Servers** (Plan 2 for full features including JIT)
   - ✅ **Storage**
   - ✅ **Key Vault**
   - ✅ **Resource Manager**
   - ✅ **DNS**
4. Click **Save**.

---

## Part 3 — Configure Auto-Provisioning

Auto-provisioning automatically installs the Log Analytics agent on VMs.

1. **Environment settings** → your subscription → **Settings** → **Auto provisioning**.
2. Enable:
   - ✅ **Log Analytics agent for Azure VMs** → point to your Log Analytics workspace
   - ✅ **Log Analytics agent for Arc-enabled servers** (if applicable)
   - ✅ **Vulnerability assessment for machines**
3. Click **Save**.

---

## Part 4 — Review and Remediate Recommendations

1. Defender for Cloud → **Recommendations**.
2. Filter by **Severity: High**.
3. Click on a recommendation (e.g., *"Management ports should be closed on your virtual machines"*).
4. Review:
   - **Description** — what the recommendation is
   - **Affected resources** — which VMs are impacted
   - **Remediation steps** — what action to take
5. For the management ports recommendation, click **Fix** → review the automated remediation → **Fix 1 resource**.

### Secure Score Impact
- Each remediated control increases your Secure Score
- Track improvement on the **Secure Score** dashboard

---

## Part 5 — Configure Just-in-Time (JIT) VM Access

JIT locks management ports (RDP 3389, SSH 22) and opens them only on demand.

### Enable JIT on a VM

1. Defender for Cloud → **Workload protections** → **Just-in-time VM access**.
2. Click the **Not configured** tab.
3. Select your VM → **Enable JIT on 1 VM**.
4. Review the default policy:
   - Port 22 (SSH) — max 3 hours, allowed source: Any
   - Port 3389 (RDP) — max 3 hours, allowed source: Any
5. For better security, change **Allowed source IP** to **My IP**.
6. Click **Save**.

### Request JIT Access

1. On the **Configured** tab, select your VM → **Request access**.
2. Set **Toggle** to On for the port you need.
3. Set **Allowed source IP** to **My IP**.
4. Set **Time range** to 1 hour.
5. Click **Open ports**.
6. Verify you can RDP/SSH into the VM.

### Verify the NSG Rule

1. Navigate to your VM's NIC → **Network security group**.
2. Observe the **JIT** rule created with a 1-hour expiry.
3. After 1 hour, the rule is automatically removed.

---

## Part 6 — Explore Security Alerts

1. Defender for Cloud → **Security alerts**.
2. Review any existing alerts.
3. Click an alert to see:
   - **Alert details** — what triggered it
   - **Affected resources** — which resource is impacted
   - **Related entities** — users, IPs, processes involved
   - **Next steps** — recommended investigation and remediation

### Simulate a Test Alert

Run the following command from a VM in your subscription to trigger a test Defender alert:

```powershell
# On a Windows VM — triggers a test alert for suspicious PowerShell activity
# NOTE: This is a test command; it does NOT cause any harm
$testAlertScript = "Invoke-WebRequest -Uri 'http://13.68.98.14'"
# This IP is in Defender's test alert list and will trigger a "Communication with suspicious IP" alert
```

Or on Linux:
```bash
# Trigger test alert for suspicious process
sudo curl -s http://13.68.98.14
```

> Wait 5–15 minutes for the alert to appear in Defender for Cloud.

---

## Part 7 — Review the Regulatory Compliance Dashboard

1. Defender for Cloud → **Regulatory compliance**.
2. The default standard is **Azure Security Benchmark**.
3. Click on a control (e.g., **NS-1: Implement network segmentation boundaries**).
4. Review the automated assessments and their current compliance state.
5. Click **+ Add more standards** to add PCI DSS, ISO 27001, NIST SP 800-53, etc.

---

## Part 8 — Configure Workflow Automation

Automatically respond to Defender alerts or recommendations using Logic Apps.

1. Defender for Cloud → **Environment settings** → your subscription → **Workflow automation**.
2. Click **+ Add workflow automation**.
3. Fill in:
   - **Name**: `auto-notify-high-severity`
   - **Resource group**: your lab resource group
   - **Defender for Cloud data types**: Security alerts
   - **Alert severity**: High
   - **Logic App**: create or select an existing one
4. Click **Create**.

---

## Cleanup

1. Defender for Cloud → **Environment settings** → your subscription.
2. Disable the Defender plans you enabled (to stop billing after the trial period).
3. Delete the test VM if created during this lab.

---

## Key Takeaways

- **Defender for Cloud** provides both CSPM (recommendations, Secure Score) and CWPP (threat alerts).
- **Auto-provisioning** ensures agents are deployed to all VMs automatically.
- **JIT VM Access** significantly reduces the attack surface on management ports.
- **Regulatory Compliance** dashboard maps controls to industry standards automatically.
- **Workflow automation** enables no-code incident response via Logic Apps.
- Enabling Defender plans incurs costs — **enable only what you need** and use the free trial for labs.
