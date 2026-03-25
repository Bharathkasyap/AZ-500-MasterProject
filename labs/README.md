# AZ-500 Hands-On Labs

← [Back to main README](../README.md)

This section provides **step-by-step lab instructions** mapped directly to AZ-500 exam objectives. Complete these labs in the Azure portal using a free trial or pay-as-you-go subscription.

> **Prerequisites**: An active Azure subscription. Most labs stay within the Azure free tier or cost less than $1 USD if resources are deleted after the lab.

---

## Lab Overview

| # | Lab Name | Domain | Est. Time |
|---|---|---|---|
| 1 | [Configure Azure AD and PIM](#lab-1-configure-azure-ad-and-privileged-identity-management-pim) | Identity | 45 min |
| 2 | [Implement Conditional Access Policies](#lab-2-implement-conditional-access-policies) | Identity | 30 min |
| 3 | [Configure Network Security Groups and Azure Firewall](#lab-3-configure-network-security-groups-and-azure-firewall) | Networking | 60 min |
| 4 | [Implement Private Endpoints and Azure Bastion](#lab-4-implement-private-endpoints-and-azure-bastion) | Networking | 45 min |
| 5 | [Configure Microsoft Defender for Cloud](#lab-5-configure-microsoft-defender-for-cloud) | Compute | 30 min |
| 6 | [Implement Azure Key Vault](#lab-6-implement-azure-key-vault) | Compute | 45 min |
| 7 | [Deploy Microsoft Sentinel](#lab-7-deploy-microsoft-sentinel) | Operations | 60 min |
| 8 | [Configure Security Monitoring and Alerts](#lab-8-configure-security-monitoring-and-alerts) | Operations | 45 min |

---

## Lab 1: Configure Azure AD and Privileged Identity Management (PIM)

**Exam Objectives Covered**: Manage Azure AD identities, implement PIM, configure access reviews

### Prerequisites
- Azure AD P2 license (available via Azure AD trial: 30 days free)
- Global Administrator role in your test tenant

### Part A: Create a Test User

1. Sign in to the [Azure portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** → **Users** → **+ New user**
3. Create a user:
   - Username: `pimtest@<yourdomain>.onmicrosoft.com`
   - Name: PIM Test User
   - Auto-generate password (note the password)
4. Click **Create**

### Part B: Enable PIM for Global Administrator Role

1. Navigate to **Azure Active Directory** → **Privileged Identity Management**
2. Click **Manage** → **Azure AD roles**
3. Click **Roles** → Select **Global Administrator**
4. Click **Settings** → Edit:
   - Activation maximum duration: **2 hours**
   - Require MFA on activation: **Yes**
   - Require justification: **Yes**
   - Require approval: **Yes**
   - Approvers: Add yourself as approver
5. Click **Update**

### Part C: Make a User Eligible for Global Administrator

1. In PIM → Azure AD roles, click **Assignments** → **+ Add assignments**
2. Select **Global Administrator** role
3. Select member: `PIM Test User`
4. Assignment type: **Eligible**
5. Assignment duration: Set start/end dates (e.g., 30 days)
6. Click **Assign**

### Part D: Activate the Role (Test User Perspective)

1. Open an **InPrivate/Incognito** browser window
2. Sign in to Azure portal as `pimtest@<yourdomain>.onmicrosoft.com`
3. Navigate to **Privileged Identity Management** → **My roles** → **Azure AD roles**
4. You should see **Global Administrator** listed as Eligible
5. Click **Activate**
6. Provide justification: "Testing PIM activation for lab"
7. Note that approval is required — the activation is pending

### Part E: Approve the Activation

1. Return to your original browser (Global Admin)
2. Navigate to **PIM** → **Approve requests**
3. Find the pending request from PIM Test User
4. Click **Approve** with a comment
5. Verify the test user's role is now **Active** for 2 hours

### Part F: Configure an Access Review

1. In PIM → **Azure AD roles** → **Access reviews** → **+ New**
2. Review name: "Global Admin Quarterly Review"
3. Role: Global Administrator
4. Reviewers: Self (users review their own access)
5. Duration: 14 days
6. Recurrence: Quarterly
7. On no response: **Remove access**
8. Auto-apply results: **Enable**
9. Click **Start**

### ✅ Lab 1 Validation
- [ ] PIM is configured with approval and MFA requirements for Global Administrator
- [ ] Test user appears as Eligible (not Active) for Global Administrator
- [ ] Access review is scheduled and running

---

## Lab 2: Implement Conditional Access Policies

**Exam Objectives Covered**: Configure Conditional Access, named locations, report-only mode

### Part A: Create a Named Location

1. Navigate to **Azure Active Directory** → **Security** → **Conditional Access** → **Named locations**
2. Click **+ IP ranges location**
3. Name: "Corporate Office"
4. Check **Mark as trusted location**
5. Add your current public IP address (find it at [whatismyip.com](https://whatismyip.com)) as the IP range (add /32 for a single IP)
6. Click **Create**

### Part B: Create a Conditional Access Policy — Require MFA for Azure Management

1. Navigate to **Conditional Access** → **+ New policy**
2. Name: "Require MFA for Azure Management"
3. **Assignments**:
   - Users: Include **All users**; Exclude your break-glass admin account
   - Cloud apps: Select **Microsoft Azure Management**
   - Conditions: None (applies to all conditions)
4. **Access controls** → **Grant**:
   - Select **Grant access**
   - Check **Require multi-factor authentication**
5. **Enable policy**: **Report-only** (to test before enforcing)
6. Click **Save**

### Part C: Create a Conditional Access Policy — Block Legacy Authentication

1. Create another new policy: "Block Legacy Authentication"
2. **Assignments**:
   - Users: **All users**
   - Cloud apps: **All cloud apps**
   - Conditions → Client apps: Check **Exchange ActiveSync clients** and **Other clients**
3. **Access controls** → **Grant**: **Block access**
4. Enable policy: **Report-only**
5. Click **Save**

### Part D: Review Report-Only Results

1. Sign in and perform a few Azure portal actions
2. Navigate to **Azure Active Directory** → **Sign-in logs**
3. Click on a recent sign-in
4. Click the **Conditional Access** tab
5. You will see both policies listed with their **report-only** result (what would have happened)

### Part E: Enable the MFA Policy

1. When satisfied with report-only results, edit the "Require MFA for Azure Management" policy
2. Change "Enable policy" from **Report-only** to **On**
3. Save the policy
4. Test by signing out and signing back in to the Azure portal — you should be prompted for MFA

### ✅ Lab 2 Validation
- [ ] Named location "Corporate Office" created with your IP
- [ ] MFA required for Azure Management is enforced (not just report-only)
- [ ] Legacy auth blocking policy is in place (at minimum report-only)

---

## Lab 3: Configure Network Security Groups and Azure Firewall

**Exam Objectives Covered**: Configure NSG rules, service tags, ASGs, Azure Firewall rules

### Part A: Create VNet and Subnets

1. Create a new **Virtual Network**: `lab-vnet` (address space: 10.0.0.0/16) in a new resource group `az500-lab`
2. Create subnets:
   - `WebSubnet`: 10.0.1.0/24
   - `AppSubnet`: 10.0.2.0/24
   - `AzureFirewallSubnet`: 10.0.3.0/26 (must be named exactly this)

### Part B: Create and Configure an NSG

1. Create an NSG: `web-nsg` in `az500-lab`
2. Add an **inbound** rule:
   - Priority: 100, Name: `Allow-HTTPS-Inbound`
   - Source: `Internet`, Destination: `Any`
   - Protocol: TCP, Port: 443
   - Action: **Allow**
3. Add an **inbound** rule:
   - Priority: 200, Name: `Deny-HTTP-Inbound`
   - Source: `Internet`, Destination: `Any`
   - Protocol: TCP, Port: 80
   - Action: **Deny**
4. Associate `web-nsg` to `WebSubnet`

### Part C: Create Application Security Groups

1. Create ASG: `WebServerASG` in `az500-lab`
2. Create ASG: `AppServerASG` in `az500-lab`
3. Create an NSG: `app-nsg`
4. Add rule to `app-nsg`:
   - Priority: 100, Name: `Allow-Web-to-App`
   - Source: `WebServerASG`, Destination: `AppServerASG`
   - Protocol: TCP, Port: 8080
   - Action: Allow
5. Associate `app-nsg` to `AppSubnet`

### Part D: Deploy Azure Firewall

1. Create an Azure Firewall in `AzureFirewallSubnet` (Standard SKU, new public IP)
2. Navigate to the firewall → **Rules** → **Application rule collection** → **+ Add**:
   - Name: `AllowWebBrowsing`
   - Priority: 100
   - Action: Allow
   - Rules:
     - Name: `AllowMicrosoft`
     - Source: `10.0.0.0/16`
     - Protocol: HTTP:80, HTTPS:443
     - Target FQDNs: `*.microsoft.com`
3. Add a **Network rule collection**:
   - Name: `AllowDNS`
   - Priority: 100
   - Rules:
     - Name: `AllowDNS`
     - Protocol: UDP
     - Source: `10.0.0.0/16`
     - Destination: `8.8.8.8`, Port: 53
     - Action: Allow

### ✅ Lab 3 Validation
- [ ] NSG blocks HTTP (port 80) while allowing HTTPS (port 443) on WebSubnet
- [ ] ASGs created; app-nsg uses ASG names in rules
- [ ] Azure Firewall deployed with application and network rules

---

## Lab 4: Implement Private Endpoints and Azure Bastion

**Exam Objectives Covered**: Configure Private Endpoints, Private DNS zones, Azure Bastion

### Part A: Create a Storage Account with Private Endpoint

1. Create a storage account `az500labstorage<random>` in `az500-lab`
2. During creation, on the **Networking** tab:
   - Connectivity method: **Disable public access and use private access**
3. After creation, navigate to the storage account → **Networking** → **Private endpoint connections** → **+ Private endpoint**
4. Configure:
   - Name: `storage-pe`
   - Resource type: `Microsoft.Storage/storageAccounts`
   - Target sub-resource: `blob`
   - Virtual network: `lab-vnet`, Subnet: `AppSubnet`
   - Integrate with private DNS zone: **Yes** (creates `privatelink.blob.core.windows.net`)
5. Click **Create**

### Part B: Verify Private DNS

1. Navigate to **Private DNS zones** in Azure
2. Find `privatelink.blob.core.windows.net`
3. Click **Virtual network links** → Verify `lab-vnet` is linked
4. Click **Overview** → Verify an A record exists pointing to the private IP (e.g., `10.0.2.x`)

### Part C: Deploy Azure Bastion

1. In `lab-vnet`, go to **Subnets** → **+ Subnet**
2. Name: `AzureBastionSubnet`, Address range: `10.0.4.0/26` (minimum /26)
3. Search for **Azure Bastion** → **Create**:
   - Name: `lab-bastion`
   - Virtual network: `lab-vnet`
   - Subnet: `AzureBastionSubnet` (auto-selected)
   - Public IP: Create new `lab-bastion-pip`
   - SKU: Basic
4. Click **Review + create** → **Create** (takes ~5 minutes)

### Part D: Test Bastion Connection

1. Create a test VM in `WebSubnet` (no public IP, no RDP/SSH in NSG)
2. Navigate to the VM → **Connect** → **Bastion**
3. Enter credentials — you should connect via browser without public IP or open ports

### ✅ Lab 4 Validation
- [ ] Storage account has private endpoint with private IP in AppSubnet
- [ ] Private DNS zone has correct A record
- [ ] Azure Bastion deployed in AzureBastionSubnet
- [ ] Able to connect to VM via Bastion without public IP

---

## Lab 5: Configure Microsoft Defender for Cloud

**Exam Objectives Covered**: Enable Defender plans, configure JIT VM access, review Secure Score

### Part A: Enable Defender for Cloud and Review Secure Score

1. Navigate to **Microsoft Defender for Cloud**
2. Note your current **Secure Score** percentage
3. Click **Recommendations** and review the list — note which controls have the most impact

### Part B: Enable Defender for Servers Plan 2

1. Navigate to **Defender for Cloud** → **Environment settings**
2. Select your subscription
3. Find **Servers** → Click **On** → Select **Plan 2**
4. Click **Save**
5. Wait a few minutes, then check that VMs show up under **Inventory**

### Part C: Configure Just-in-Time VM Access

1. Navigate to **Defender for Cloud** → **Workload protections** → **Just-in-time VM access**
2. Click the **Not Configured** tab
3. Select your test VM → Click **Enable JIT on 1 VM**
4. Review the default rules (RDP 3389, SSH 22, WinRM 5985/5986)
5. Modify the RDP rule:
   - Max request time: 3 hours
   - Allowed source IPs: **My IP** (restricts to your IP)
6. Click **Save**

### Part D: Request JIT Access

1. Click the **Configured** tab → Select your VM → **Request access**
2. Toggle on port 3389
3. Source IP: **My IP**
4. Time range: 1 hour
5. Click **Open ports**
6. Verify in the VM's NSG that a temporary allow rule was added

### Part E: Review Regulatory Compliance

1. Navigate to **Defender for Cloud** → **Regulatory compliance**
2. Review the **Microsoft Cloud Security Benchmark** compliance status
3. Click on a failing control to see specific recommendations

### ✅ Lab 5 Validation
- [ ] Defender for Servers Plan 2 is enabled on the subscription
- [ ] JIT is configured on the test VM
- [ ] Successfully requested JIT access and verified temporary NSG rule
- [ ] Reviewed regulatory compliance dashboard

---

## Lab 6: Implement Azure Key Vault

**Exam Objectives Covered**: Create Key Vault, configure RBAC access, store and retrieve secrets, enable soft delete and purge protection

### Part A: Create Key Vault

1. Create a Key Vault:
   - Name: `az500-kv-<random>`
   - Region: Same as other resources
   - Pricing tier: Standard
   - **Soft-delete**: Enabled (default, cannot be disabled)
   - **Purge protection**: Enable
   - Access: **Azure role-based access control (RBAC)** (recommended over access policies)
2. Click **Review + create**

### Part B: Assign RBAC Roles

1. Navigate to your Key Vault → **Access control (IAM)** → **+ Add role assignment**
2. Assign yourself **Key Vault Administrator** role
3. Create a second assignment:
   - Role: **Key Vault Secrets User**
   - Assign to: A different test user (or a service principal)

### Part C: Add a Secret

1. Navigate to Key Vault → **Secrets** → **+ Generate/Import**
2. Name: `DatabaseConnectionString`
3. Value: `Server=myserver;Database=mydb;User=admin;Password=SecretPass123!`
4. Click **Create**

### Part D: Test Access Levels

1. Sign in as the user with **Key Vault Secrets User** role
2. Navigate to the Key Vault → **Secrets**
3. Click on `DatabaseConnectionString` → **Show Secret Value**
4. Verify the user can see the value

5. Try to create a new secret as `Key Vault Secrets User` — this should fail (Secrets Officer role is required to create/delete)

### Part E: Configure Private Endpoint for Key Vault

1. Navigate to Key Vault → **Networking** → **Private endpoint connections** → **+ Private endpoint**
2. Target sub-resource: `vault`
3. Connect to `lab-vnet`, `AppSubnet`
4. Integrate with private DNS zone: Yes (`privatelink.vaultcore.azure.net`)
5. Create the private endpoint

6. Under **Networking** → **Firewalls and virtual networks**:
   - Set to **Disable public access**
7. Verify you can still access Key Vault from within the VNet but not from the public internet

### ✅ Lab 6 Validation
- [ ] Key Vault created with RBAC access model, soft delete, and purge protection
- [ ] Secret stored and accessible by Secrets User role
- [ ] Secrets User cannot create/delete secrets (Secrets Officer required)
- [ ] Private endpoint configured; public access disabled

---

## Lab 7: Deploy Microsoft Sentinel

**Exam Objectives Covered**: Enable Sentinel, configure data connectors, create analytics rules, create a playbook

### Part A: Create Log Analytics Workspace and Enable Sentinel

1. Create a **Log Analytics workspace**: `sentinel-workspace` in `az500-lab`
2. Navigate to **Microsoft Sentinel** → **+ Create**
3. Select `sentinel-workspace` → **Add**
4. Sentinel is now enabled

### Part B: Configure Data Connectors

1. In Sentinel → **Configuration** → **Data connectors**
2. Find and configure **Azure Active Directory**:
   - Click **Open connector page** → Check:
     - ☑ Sign-in logs
     - ☑ Audit logs
   - Click **Apply changes**
3. Find and configure **Azure Activity**:
   - Click **Open connector page** → Click **Launch Azure Policy Assignment wizard**
   - Assign the policy to your subscription → **Review + create**

### Part C: Create an Analytics Rule

1. Navigate to Sentinel → **Configuration** → **Analytics** → **+ Create** → **Scheduled query rule**
2. Configure the rule:
   - **Name**: "Multiple Failed Sign-ins"
   - **Description**: Detects users with more than 5 failed sign-ins in 30 minutes
   - **Severity**: Medium
   - **MITRE ATT&CK**: Tactic = Credential Access, Technique = Brute Force

3. **Set rule logic**:
```kusto
SigninLogs
| where TimeGenerated > ago(30m)
| where ResultType != "0"
| summarize FailedAttempts = count() by UserPrincipalName, bin(TimeGenerated, 5m)
| where FailedAttempts > 5
```

4. **Alert enhancement**:
   - Entity mapping:
     - Entity type: Account → Column: UserPrincipalName
5. **Query scheduling**: Run every 5 minutes, look up last 30 minutes
6. **Incident settings**: Enable incident creation; group alerts into single incidents by Account entity
7. **Review and create**

### Part D: Create a Playbook (Logic App)

1. Navigate to Sentinel → **Configuration** → **Automation** → **+ Create** → **Playbook with incident trigger**
2. Name: `Disable-User-On-High-Alert`
3. In the Logic App designer, add actions:
   - **Get incident details** (already added by trigger)
   - **Add comment to incident** (Sentinel connector):
     - Message: "Automated investigation started"
   - **Send email notification** (Office 365 Outlook or Gmail connector):
     - Subject: "HIGH SEVERITY Sentinel Incident: @{triggerBody()?['object']?['properties']?['title']}"
     - Body: Include incident URL, severity, and description
4. Save the Logic App

5. Back in Sentinel → **Automation rules** → **+ Create**:
   - Trigger: When incident is created
   - Condition: Incident severity equals High
   - Action: Run playbook → Select `Disable-User-On-High-Alert`
   - Click **Apply**

### ✅ Lab 7 Validation
- [ ] Sentinel enabled on Log Analytics workspace
- [ ] Azure AD and Azure Activity data connectors active
- [ ] Analytics rule created and enabled
- [ ] Playbook created and automation rule configured

---

## Lab 8: Configure Security Monitoring and Alerts

**Exam Objectives Covered**: Configure Azure Monitor alerts, diagnostic settings, NSG flow logs

### Part A: Configure Diagnostic Settings for Azure AD

1. Navigate to **Azure Active Directory** → **Diagnostic settings** → **+ Add diagnostic setting**
2. Name: `AAD-to-LogAnalytics`
3. Check: ☑ SignInLogs, ☑ AuditLogs, ☑ RiskyUsers, ☑ UserRiskEvents
4. Destination: **Send to Log Analytics workspace** → Select `sentinel-workspace`
5. Click **Save**

### Part B: Configure NSG Flow Logs

1. Navigate to **Network Watcher** → **NSG flow logs** → **+ Create**
2. Select `web-nsg`
3. Storage account: Create new or use existing
4. Retention: 30 days
5. Traffic analytics: **Enabled** → Select `sentinel-workspace`
6. Flow Logs Version: **Version 2**
7. Click **Create**

### Part C: Create a Resource Deletion Alert

1. Navigate to **Azure Monitor** → **Alerts** → **+ Create** → **Alert rule**
2. **Scope**: Your subscription
3. **Condition**: Click **Add condition** → Search for "Delete" → Select **All Administrative operations**
   - Filter: OperationName contains "delete"
4. **Actions**: Create an action group:
   - Name: `SecurityTeam`
   - Action: Email → Your email address
5. **Alert rule details**:
   - Name: "Azure Resource Deletion Alert"
   - Severity: Sev 2
6. Click **Review + create**

### Part D: Test the Alert

1. Create a test resource (e.g., a resource group with a tag)
2. Delete the test resource
3. Wait 2–5 minutes
4. Verify the alert fires in Azure Monitor → **Alerts**
5. Verify you received an email notification

### Part E: Query NSG Flow Logs with KQL

After Traffic Analytics has collected some data (wait ~30 minutes):

1. Navigate to **Log Analytics workspace** → **Logs**
2. Run this query to see blocked traffic:
```kusto
AzureNetworkAnalytics_CL
| where TimeGenerated > ago(1h)
| where FlowType_s == "MaliciousFlow" or FlowStatus_s == "D"
| project TimeGenerated, SrcIP_s, DestIP_s, DestPort_d, FlowStatus_s
| take 50
```

### ✅ Lab 8 Validation
- [ ] Azure AD diagnostic settings sending logs to Log Analytics
- [ ] NSG flow logs enabled with Traffic Analytics
- [ ] Activity log alert fires when resources are deleted
- [ ] KQL queries return data from NSG flow logs

---

## Cleanup

To avoid ongoing charges, delete the resource group when labs are complete:

```bash
az group delete --name az500-lab --yes --no-wait
```

Also:
- Disable Defender for Servers to avoid hourly charges
- Remove Sentinel (go to Sentinel → Settings → Remove Microsoft Sentinel)
- Delete the Log Analytics workspace

---

## Additional Lab Resources

- [Microsoft Learn: AZ-500 Hands-on Labs](https://microsoftlearning.github.io/AZ500-AzureSecurityTechnologies/)
- [GitHub: AZ-500 Lab Files](https://github.com/MicrosoftLearning/AZ500-AzureSecurityTechnologies)
- [Azure Security Center Labs (GitHub)](https://github.com/Azure/Microsoft-Defender-for-Cloud/tree/main/Labs)
