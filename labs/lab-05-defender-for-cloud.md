# Lab 05: Microsoft Defender for Cloud

> **Domain**: Security Operations | **Difficulty**: Intermediate | **Time**: ~30 minutes

---

## Prerequisites

- Azure subscription with Security Admin or Contributor access
- Resources already deployed (or use the free trial resources)
- Azure CLI installed and authenticated

---

## Objectives

By the end of this lab, you will be able to:
- Enable Defender for Cloud plans
- Review and improve your Secure Score
- Understand and act on security recommendations
- Configure regulatory compliance standards
- Set up workflow automation for security alerts

---

## Part 1: Enable Microsoft Defender for Cloud

### Step 1.1 — Enable Defender Plans

```bash
# Enable Defender for Servers (Plan 2 — includes JIT, Defender for Endpoint, FIM)
az security pricing create \
  --name VirtualMachines \
  --tier Standard \
  --subscription-id $(az account show --query id --output tsv)

# Enable Defender for Storage
az security pricing create \
  --name StorageAccounts \
  --tier Standard

# Enable Defender for Key Vault
az security pricing create \
  --name KeyVaults \
  --tier Standard

# Enable Defender for SQL (Azure SQL servers)
az security pricing create \
  --name SqlServers \
  --tier Standard

# Verify enabled plans
az security pricing list \
  --output table \
  --query "[].{Name:name, Tier:pricingTier}"
```

### Step 1.2 — Configure Auto-Provisioning

Auto-provisioning automatically installs the Log Analytics agent (or Azure Monitor Agent) on VMs:

```
Azure Portal → Defender for Cloud → Environment Settings
  → Select subscription → Settings & monitoring
  → Log Analytics agent / Azure Monitor Agent → On
  → Configure workspace → Select or create workspace
  → Save
```

---

## Part 2: Review Secure Score and Recommendations

### Step 2.1 — View Secure Score

```bash
# Get Secure Score
az security secure-score show \
  --name ascScore \
  --query "{score: score.current, max: score.max, percentage: score.percentage}"
```

Or navigate to:
```
Defender for Cloud → Overview → Secure Score → See all recommendations
```

### Step 2.2 — Explore Recommendations

```bash
# List all active recommendations
az security assessment list \
  --output table \
  --query "[?properties.status.code!='Healthy'].{Name:properties.displayName, Status:properties.status.code, Severity:properties.metadata.severity}" \
  | head -30
```

### Step 2.3 — Remediate a High-Severity Recommendation

Let's remediate "Storage accounts should restrict network access":

```bash
# Find a storage account to remediate (replace with actual name)
STORAGE_ACCOUNT="yourstorageaccount"
RG="yourresourcegroup"

# Apply fix: disable public network access
az storage account update \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG \
  --public-network-access Disabled

# Alternative: set to firewall rules only
az storage account update \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG \
  --default-action Deny \
  --bypass AzureServices Logging Metrics
```

---

## Part 3: Configure Regulatory Compliance

### Step 3.1 — Add Compliance Standard

```
Defender for Cloud → Regulatory compliance → Manage compliance policies
  → Select subscription
  → + Add more standards
  → Enable: "CIS Microsoft Azure Foundations Benchmark v2.0.0"
  → Save
```

### Step 3.2 — Review Compliance Controls

```bash
# List compliance results (regulatory compliance assessments)
az security regulatory-compliance-standards list \
  --output table \
  --query "[].{Standard:name, State:state, PassedControls:passedControls, FailedControls:failedControls}"
```

---

## Part 4: Configure Just-In-Time VM Access

### Step 4.1 — Enable JIT on a VM

```
Defender for Cloud → Workload protections → Just-in-time VM access
  → Select VM from list (if VM doesn't appear, it needs Defender for Servers enabled)
  → Configure JIT access
```

Configure JIT ports:
- **Port 22 (SSH)**: Max request time: 3 hours, Allowed source IPs: My IP
- **Port 3389 (RDP)**: Max request time: 3 hours, Allowed source IPs: My IP

Click **Save**.

### Step 4.2 — Request JIT Access

```
Defender for Cloud → Just-in-time VM access → Configured VMs
  → Select VM → Request access
  → Port 22: Time: 2 hours, My IP: <auto-detected>
  → Request access
```

```bash
# Or via CLI:
az security jit-policy create \
  --resource-group $RG \
  --name default \
  --virtual-machines '[{
    "id": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<vmname>",
    "ports": [
      {"number": 22, "protocol": "TCP", "allowedSourceAddressPrefix": "*", "maxRequestAccessDuration": "PT3H"},
      {"number": 3389, "protocol": "TCP", "allowedSourceAddressPrefix": "*", "maxRequestAccessDuration": "PT3H"}
    ]
  }]'
```

---

## Part 5: Set Up Workflow Automation

### Step 5.1 — Create a Logic App for Alert Notifications

1. Navigate to **Azure Portal** → **Logic Apps** → **+ Add**
2. Name: `DefenderAlertNotification`
3. Resource Group: your lab RG
4. Plan type: Consumption
5. Click **Review + create** → **Create**

### Step 5.2 — Configure the Logic App

After creation, open the Logic App Designer:

1. Trigger: Search for **"Microsoft Sentinel"** or **"Security Center"** → **When a Microsoft Defender for Cloud alert is created**
2. Add action: **Office 365 Outlook** → **Send an email** (or **Teams** → **Post a message**)
3. Configure email:
   - To: security-team@contoso.com
   - Subject: `[SECURITY ALERT] @{triggerBody()?['AlertDisplayName']} - @{triggerBody()?['Severity']}`
   - Body: Include alert details from dynamic content
4. Save the Logic App

### Step 5.3 — Connect Logic App to Defender for Cloud

```
Defender for Cloud → Workflow automation → + Add workflow automation
  → Name: NotifyOnHighSeverityAlerts
  → Trigger: Security alert
  → Alert severity: High
  → Action: Select Logic App → DefenderAlertNotification
  → Create
```

---

## Part 6: Generate a Test Alert

### Step 6.1 — Trigger a Sample Alert

```bash
# This command simulates a threat detection alert for testing
az security alerts simulate \
  --resource-group $RG \
  --location $LOCATION \
  --alert-type "VM_SuspectExecutablePath"
```

Or use the built-in sample alert generator:
```
Defender for Cloud → Security alerts → Sample alerts → Select alert types → Create sample alerts
```

### Step 6.2 — Investigate the Alert

```
Defender for Cloud → Security alerts → Click on the new alert
  → Overview: Description, severity, MITRE tactics, affected resource
  → Take action: Inspect the resource, Trigger automated response, Export to Sentinel
```

---

## ✅ Verification Checklist

- [ ] Defender for Servers, Storage, Key Vault, and SQL enabled
- [ ] Secure Score reviewed and at least one recommendation remediated
- [ ] CIS Benchmark compliance standard added
- [ ] JIT VM access configured on a virtual machine
- [ ] Workflow automation created to notify on high-severity alerts
- [ ] Sample alert generated and investigated

---

> ⬅️ [Lab 04: NSG & Firewall](./lab-04-nsg-afd.md) | ➡️ [Lab 06: Microsoft Sentinel](./lab-06-sentinel.md)
