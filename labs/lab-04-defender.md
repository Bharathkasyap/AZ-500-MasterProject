# Lab 04 — Enable Microsoft Defender for Cloud

> **Estimated time:** 45–60 minutes  
> **Prerequisites:** Azure subscription, Security Admin or Owner rights  
> **Skills practiced:** Domain 4 — Manage Security Operations

---

## Objectives

By the end of this lab you will be able to:

1. Enable Microsoft Defender for Cloud (Foundational CSPM — free).
2. Enable enhanced Defender plans for specific workloads.
3. Understand and improve your Secure Score.
4. Remediate a security recommendation.
5. Configure Just-in-Time (JIT) VM access.
6. Enable and use Adaptive Application Controls.
7. Set up email alerts for high-severity security alerts.
8. Export alerts to Log Analytics for further analysis.

---

## Architecture

```
Azure Subscription
  │
  └── Microsoft Defender for Cloud
        ├── CSPM (Foundational — Free)
        │     ├── Secure Score
        │     ├── Recommendations
        │     └── Regulatory Compliance
        └── Defender Plans (Enhanced — Paid)
              ├── Defender for Servers P2
              ├── Defender for Storage
              ├── Defender for SQL
              └── Defender for Key Vault
```

---

## Part 1 — Enable Defender for Cloud

### Via Portal

1. Navigate to **Microsoft Defender for Cloud** in the Azure portal.
2. If prompted, click **Upgrade** to enable the free tier.
3. Go to **Environment settings** → Select your subscription.
4. View the **Defender plans** page.

### Via CLI

```bash
# Register the Defender for Cloud resource provider
az provider register --namespace Microsoft.Security

# Check current pricing tier for all resource types
az security pricing list -o table
```

---

## Part 2 — Enable Defender Plans

```bash
# Enable Defender for Servers Plan 2
az security pricing create \
  --name VirtualMachines \
  --tier Standard \
  --subplan P2

# Enable Defender for Storage
az security pricing create \
  --name StorageAccounts \
  --tier Standard

# Enable Defender for Key Vault
az security pricing create \
  --name KeyVaults \
  --tier Standard

# Enable Defender for SQL (covers Azure SQL)
az security pricing create \
  --name SqlServers \
  --tier Standard

# Verify
az security pricing list --query "[].{Name:name, Tier:pricingTier, SubPlan:subPlan}" -o table
```

### Via Portal (Alternative)

1. **Environment settings** → Select subscription → **Defender plans**.
2. Enable:
   - ✅ Servers → **Plan 2**
   - ✅ Storage
   - ✅ Key Vault
   - ✅ SQL servers on machines
3. Click **Save**.

---

## Part 3 — Review Secure Score and Recommendations

### View Secure Score

```bash
# Get current Secure Score
az security secure-score list -o table

# Get score details per control
az security secure-score-control-definitions list \
  --query "[].{DisplayName:displayName, MaxScore:maxScore}" -o table
```

### Portal Walkthrough

1. Navigate to **Defender for Cloud** → **Secure Score**.
2. Review your overall score (goal: > 70%).
3. Click **View recommendations** to see all actionable items.
4. Filter by **Severity: High** to prioritize.
5. Click on a high-severity recommendation to see:
   - Affected resources
   - Remediation steps
   - Policy definition
   - Azure Secure Score impact

---

## Part 4 — Remediate a Recommendation

### Example: Enable MFA for accounts with Owner permissions

This is a common high-impact recommendation.

1. Navigate to **Defender for Cloud** → **Recommendations**.
2. Search for: **"MFA should be enabled on accounts with owner permissions"**.
3. Click the recommendation.
4. Under **Affected resources**, see which accounts are non-compliant.
5. For each affected account:
   - Navigate to **Entra ID** → **Users** → Select user.
   - Go to **Authentication methods**.
   - Ensure MFA is configured.

### Example: Enable Auditing on SQL Server

```bash
# Enable auditing on an Azure SQL server (if you have one)
az sql server audit-policy update \
  --resource-group <your-rg> \
  --server <your-sql-server> \
  --state Enabled \
  --storage-account <your-storage-account> \
  --retention-days 90
```

### Quick Fix (Portal)
Many recommendations support **Quick Fix**:
1. Click a recommendation with the ⚡ Quick fix label.
2. Select all affected resources.
3. Click **Fix** / **Remediate**.
4. Review the changes that will be made.
5. Click **Confirm**.

> **Note:** Secure Score updates may take up to **24 hours** to reflect remediation.

---

## Part 5 — Configure Just-in-Time VM Access

> Requires Defender for Servers Plan 1 or higher.

### Enable JIT via Portal

1. Navigate to **Defender for Cloud** → **Workload protections** → **Just-in-time VM access**.
2. Click the **Not configured** tab to see VMs without JIT.
3. Select your VM → Click **Enable JIT on 1 VM**.
4. Review the default ports:
   - Port 22 (SSH) — allow source: Any
   - Port 3389 (RDP) — allow source: Any
5. Modify max request time to **3 hours**.
6. Click **Save**.

### Request JIT Access via CLI

```bash
# Request JIT access for your IP
MY_IP=$(curl -s https://ipinfo.io/ip)
VM_ID=$(az vm show --resource-group <rg> --name <vm-name> --query id -o tsv)

az security jit-policy initiate \
  --resource-group <rg> \
  --name "default" \
  --vm-requests "[{\"id\":\"$VM_ID\",\"ports\":[{\"number\":22,\"duration\":\"PT3H\",\"allowedSourceAddressPrefix\":\"$MY_IP\"}]}]"
```

### Request JIT Access via Portal

1. Navigate to the VM → **Connect** → **SSH**.
2. Note the **Request access** option.
3. Click **Request access** → Enter justification.
4. The NSG is temporarily updated to allow your IP on port 22.
5. Access expires after 3 hours automatically.

---

## Part 6 — Configure Adaptive Application Controls

1. Navigate to **Defender for Cloud** → **Workload protections** → **Adaptive application controls**.
2. Review the **Recommended** tab (groups of VMs with similar usage patterns).
3. Select a group → Review the suggested allowed applications.
4. Add/remove applications as needed.
5. Set mode:
   - **Audit** — logs violations; does not block.
   - **Enforce** — blocks unlisted applications (use carefully).
6. Click **Audit** to start in monitoring mode.

> **Exam tip:** Adaptive application controls use **AppLocker** (Windows) or **auditd** (Linux).

---

## Part 7 — Configure Security Alerts and Email Notifications

### Set Up Email Notifications

```bash
# Configure security contact for high-severity alerts
az security contact create \
  --name "default" \
  --email "security-team@yourcompany.com" \
  --phone "+1-555-0100" \
  --alert-notifications On \
  --alerts-to-admins On
```

### Via Portal

1. **Defender for Cloud** → **Environment settings** → Subscription → **Email notifications**.
2. Set:
   - **All users with the following Azure roles**: Owner, Contributor
   - **Additional email addresses**: security-team@yourcompany.com
   - **Notification types**: High severity alerts ✅, Weekly digest ✅
3. Click **Save**.

---

## Part 8 — Export Alerts to Log Analytics

### Continuous Export Configuration

```bash
# Create a Log Analytics workspace for Defender data
RG="rg-az500-lab04"
LOCATION="eastus"
LA_NAME="law-az500-lab04"

az group create --name $RG --location $LOCATION

az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name $LA_NAME \
  --location $LOCATION

LA_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name $LA_NAME \
  --query id -o tsv)

# Configure continuous export of security alerts
az security auto-provisioning-setting update \
  --name mma \
  --auto-provision on
```

### Via Portal

1. **Defender for Cloud** → **Environment settings** → Subscription → **Continuous export**.
2. Enable **Log Analytics workspace** tab.
3. Select what to export:
   - ✅ Security alerts (all severities)
   - ✅ Secure Score
   - ✅ Recommendations
4. Select your Log Analytics workspace.
5. Click **Save**.

### Query Defender Alerts in Log Analytics

```kql
// All security alerts in the last 7 days
SecurityAlert
| where TimeGenerated > ago(7d)
| project TimeGenerated, AlertSeverity, AlertName, Description, CompromisedEntity
| order by TimeGenerated desc

// High-severity alerts only
SecurityAlert
| where AlertSeverity == "High"
| summarize Count = count() by AlertName
| order by Count desc

// JIT access requests
AzureActivity
| where OperationNameValue contains "MICROSOFT.SECURITY/LOCATIONS/JITNETWORKACCESSPOLICIES/INITIATE/ACTION"
| project TimeGenerated, Caller, ResourceGroup, Properties
```

---

## Part 9 — Review Regulatory Compliance

1. **Defender for Cloud** → **Regulatory compliance**.
2. Default standard shown: **Azure Security Benchmark**.
3. Click **+ Add more standards**.
4. Add **PCI DSS** or **ISO 27001** (if available for your subscription).
5. Review compliance percentage per control domain.
6. Click on a failed control to see the underlying recommendations.

---

## Cleanup

```bash
# Disable paid Defender plans to avoid charges
az security pricing create --name VirtualMachines --tier Free
az security pricing create --name StorageAccounts --tier Free
az security pricing create --name KeyVaults --tier Free
az security pricing create --name SqlServers --tier Free

# Delete resource group
az group delete --name $RG --yes --no-wait
```

---

## Key Takeaways

- **Foundational CSPM is free** — always enable it to get Secure Score and recommendations.
- **JIT VM Access** is available in **Defender for Servers Plan 1** (not just Plan 2).
- Remediating all recommendations within a **security control** awards full points for that control.
- **Continuous export** sends Defender for Cloud data to Log Analytics — required for Sentinel integration.
- **Adaptive application controls** use machine learning to build application allowlists — start in Audit mode.
- **Quick Fix** remediates recommendations in one click for supported resource types.
