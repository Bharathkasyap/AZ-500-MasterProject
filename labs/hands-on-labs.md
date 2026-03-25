# AZ-500 Hands-On Labs

> **Step-by-step Azure lab exercises** aligned with all four AZ-500 exam domains.
> 
> **Prerequisites:**
> - An active Azure subscription (free trial at [azure.microsoft.com/free](https://azure.microsoft.com/free))
> - Azure CLI installed or use Azure Cloud Shell at [shell.azure.com](https://shell.azure.com)
> - Entra ID P2 trial for PIM and Identity Protection labs (available in Microsoft 365 E5 trial)

---

## Table of Contents

1. [Lab 1: Configure Conditional Access Policy](#lab-1-configure-conditional-access-policy)
2. [Lab 2: Configure Privileged Identity Management (PIM)](#lab-2-configure-privileged-identity-management-pim)
3. [Lab 3: Configure NSG and Azure Bastion](#lab-3-configure-nsg-and-azure-bastion)
4. [Lab 4: Deploy Azure Firewall](#lab-4-deploy-azure-firewall)
5. [Lab 5: Configure Azure Key Vault with Managed Identity](#lab-5-configure-azure-key-vault-with-managed-identity)
6. [Lab 6: Secure Azure Storage Account](#lab-6-secure-azure-storage-account)
7. [Lab 7: Configure Microsoft Defender for Cloud](#lab-7-configure-microsoft-defender-for-cloud)
8. [Lab 8: Set Up Microsoft Sentinel](#lab-8-set-up-microsoft-sentinel)

---

## Lab 1: Configure Conditional Access Policy

**Objective:** Create a Conditional Access policy that requires MFA for all users except those on a trusted corporate network.

**Estimated time:** 20 minutes

### Step 1: Create a Named Location

1. Navigate to **Microsoft Entra ID** → **Security** → **Conditional Access** → **Named locations**
2. Click **+ New location** → **IP ranges location**
3. Configure:
   - Name: `Corporate Network`
   - IP ranges: Add your corporate IP address (e.g., `203.0.113.0/24`) — use your actual public IP
   - Check ✅ **Mark as trusted location**
4. Click **Create**

### Step 2: Create the Conditional Access Policy

1. Navigate to **Conditional Access** → **Policies** → **+ New policy**
2. Configure:
   - **Name:** `Require MFA - External Access`
   - **Users:** Include → All users
   - **Cloud apps or actions:** Include → All cloud apps
   - **Conditions** → **Locations:**
     - Include: Any location
     - Exclude: Corporate Network (the named location you created)
   - **Grant:** Require Multi-factor authentication
   - **Enable policy:** Report-only (test first)
3. Click **Create**

### Step 3: Test the Policy in Report-Only Mode

1. Open the Conditional Access **Insights and reporting** workbook
2. Review what would have happened to recent sign-ins
3. Check for false positives before enabling

### Step 4: Enable the Policy

1. Edit the policy
2. Change **Enable policy** from **Report-only** to **On**
3. Save

### Cleanup
- Delete the named location and policy after the lab

---

## Lab 2: Configure Privileged Identity Management (PIM)

**Objective:** Configure PIM for the Security Administrator role with just-in-time access, MFA requirement, and approval.

**Estimated time:** 25 minutes

**Prerequisites:** Entra ID P2 license

### Step 1: Enable PIM

1. Navigate to **Microsoft Entra ID** → **Identity Governance** → **Privileged Identity Management**
2. Click **Get started** if this is your first time

### Step 2: Configure a Role for JIT Access

1. Navigate to PIM → **Azure AD roles** → **Roles**
2. Search for and select **Security Administrator**
3. Click **Settings** → **Edit**
4. Configure:
   - **Activation maximum duration:** 2 hours
   - **On activation:** Require Azure MFA ✅
   - **Require justification on activation:** ✅
   - **Require approval to activate:** ✅
5. Under **Approvers:** Add a user (yourself or another admin)
6. Click **Update**

### Step 3: Assign an Eligible Role

1. Navigate to PIM → **Azure AD roles** → **Assignments** → **+ Add assignments**
2. Select role: **Security Administrator**
3. Select members: Choose a test user
4. Assignment type: **Eligible**
5. Duration: **Permanently eligible** (or set a time-bound period)
6. Click **Assign**

### Step 4: Activate the Role (as the test user)

1. Sign in as the test user at [myapps.microsoft.com](https://myapps.microsoft.com)
2. Navigate to **PIM** → **My roles** → **Azure AD roles**
3. Find **Security Administrator** → **Activate**
4. Enter a justification
5. Complete MFA
6. Wait for approval (approve it as the approver)
7. Confirm the role is now active

### Step 5: Review PIM Audit Log

1. Navigate to PIM → **Azure AD roles** → **Audit history**
2. Review the activation events

### Cleanup
- Remove the eligible assignment
- Revert role settings to default

---

## Lab 3: Configure NSG and Azure Bastion

**Objective:** Deploy a VM without a public IP, configure an NSG to restrict traffic, and use Azure Bastion for secure RDP access.

**Estimated time:** 30 minutes

### Step 1: Create a VNet with Two Subnets

```bash
# Set variables
RG="rg-az500-lab3"
LOCATION="eastus"
VNET="vnet-lab3"

# Create resource group
az group create --name $RG --location $LOCATION

# Create VNet with VM subnet
az network vnet create \
  --resource-group $RG \
  --name $VNET \
  --address-prefix 10.0.0.0/16 \
  --subnet-name VMSubnet \
  --subnet-prefix 10.0.1.0/24

# Add AzureBastionSubnet (must be /26 minimum)
az network vnet subnet create \
  --resource-group $RG \
  --vnet-name $VNET \
  --name AzureBastionSubnet \
  --address-prefix 10.0.2.0/26
```

### Step 2: Create an NSG for VM Subnet

```bash
# Create NSG
az network nsg create \
  --resource-group $RG \
  --name nsg-vmsubnet

# Add a rule to deny all inbound traffic (explicit)
az network nsg rule create \
  --resource-group $RG \
  --nsg-name nsg-vmsubnet \
  --name DenyAllInbound \
  --priority 4000 \
  --direction Inbound \
  --access Deny \
  --protocol "*" \
  --source-address-prefix "*" \
  --destination-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range "*"

# Associate NSG with VM subnet
az network vnet subnet update \
  --resource-group $RG \
  --vnet-name $VNET \
  --name VMSubnet \
  --network-security-group nsg-vmsubnet
```

### Step 3: Deploy a VM without Public IP

```bash
# Create VM (no public IP)
az vm create \
  --resource-group $RG \
  --name vm-lab3 \
  --image Win2019Datacenter \
  --vnet-name $VNET \
  --subnet VMSubnet \
  --public-ip-address "" \
  --admin-username azureadmin \
  --admin-password "P@ssw0rd1234!" \
  --nsg ""
```

### Step 4: Deploy Azure Bastion

```bash
# Create public IP for Bastion
az network public-ip create \
  --resource-group $RG \
  --name pip-bastion \
  --sku Standard \
  --allocation-method Static

# Deploy Bastion
az network bastion create \
  --resource-group $RG \
  --name bastion-lab3 \
  --public-ip-address pip-bastion \
  --vnet-name $VNET \
  --location $LOCATION
```

### Step 5: Connect via Bastion

1. In the Azure Portal, navigate to the VM `vm-lab3`
2. Click **Connect** → **Bastion**
3. Enter credentials and click **Connect**
4. Confirm you can access the VM via browser without needing RDP port open

### Cleanup

```bash
az group delete --name $RG --yes --no-wait
```

---

## Lab 4: Deploy Azure Firewall

**Objective:** Deploy Azure Firewall and configure application rules to control outbound internet access from VMs.

**Estimated time:** 30 minutes

### Step 1: Create the Network Infrastructure

```bash
RG="rg-az500-lab4"
LOCATION="eastus"

az group create --name $RG --location $LOCATION

# Create hub VNet with required subnets
az network vnet create \
  --resource-group $RG \
  --name vnet-hub \
  --address-prefix 10.0.0.0/16 \
  --subnet-name AzureFirewallSubnet \
  --subnet-prefix 10.0.1.0/26

az network vnet subnet create \
  --resource-group $RG \
  --vnet-name vnet-hub \
  --name WorkloadSubnet \
  --address-prefix 10.0.2.0/24
```

### Step 2: Deploy Azure Firewall

```bash
# Create public IP for Firewall
az network public-ip create \
  --resource-group $RG \
  --name pip-firewall \
  --sku Standard \
  --allocation-method Static

# Deploy Azure Firewall
az network firewall create \
  --resource-group $RG \
  --name azfw-lab4 \
  --location $LOCATION \
  --sku-name AZFW_VNet \
  --sku-tier Standard

# Add IP configuration
az network firewall ip-config create \
  --resource-group $RG \
  --firewall-name azfw-lab4 \
  --name fw-ipconfig \
  --public-ip-address pip-firewall \
  --vnet-name vnet-hub
```

### Step 3: Configure Application Rules

```bash
# Get Firewall private IP
FW_PRIVATE_IP=$(az network firewall show \
  --resource-group $RG \
  --name azfw-lab4 \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

# Create application rule to allow Microsoft Updates
az network firewall application-rule create \
  --resource-group $RG \
  --firewall-name azfw-lab4 \
  --collection-name AllowMicrosoftUpdates \
  --name AllowWindowsUpdate \
  --protocols Https=443 \
  --source-addresses 10.0.2.0/24 \
  --target-fqdns "*.microsoft.com" "*.windowsupdate.com" \
  --priority 100 \
  --action Allow
```

### Step 4: Create a Route Table to Force Traffic Through Firewall

```bash
# Create route table
az network route-table create \
  --resource-group $RG \
  --name rt-workload

# Add default route to firewall
az network route-table route create \
  --resource-group $RG \
  --route-table-name rt-workload \
  --name DefaultRoute \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $FW_PRIVATE_IP

# Associate route table with workload subnet
az network vnet subnet update \
  --resource-group $RG \
  --vnet-name vnet-hub \
  --name WorkloadSubnet \
  --route-table rt-workload
```

### Cleanup

```bash
az group delete --name $RG --yes --no-wait
```

---

## Lab 5: Configure Azure Key Vault with Managed Identity

**Objective:** Create a Key Vault, store a secret, deploy a VM with a managed identity, and configure the VM to read the secret without any stored credentials.

**Estimated time:** 25 minutes

### Step 1: Create Key Vault and Store a Secret

```bash
RG="rg-az500-lab5"
LOCATION="eastus"
KV_NAME="kv-az500-lab5-$(date +%s)"  # Unique name

az group create --name $RG --location $LOCATION

# Create Key Vault with RBAC authorization model
az keyvault create \
  --resource-group $RG \
  --name $KV_NAME \
  --location $LOCATION \
  --enable-rbac-authorization true \
  --sku standard

# Store a secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "DatabasePassword" \
  --value "SuperSecret123!"

echo "Key Vault: $KV_NAME"
```

### Step 2: Deploy a VM with System-Assigned Managed Identity

```bash
# Create VM with managed identity enabled
az vm create \
  --resource-group $RG \
  --name vm-lab5 \
  --image UbuntuLTS \
  --assign-identity \
  --admin-username azureadmin \
  --generate-ssh-keys \
  --size Standard_B1s

# Get the VM's managed identity principal ID
IDENTITY_ID=$(az vm show \
  --resource-group $RG \
  --name vm-lab5 \
  --query "identity.principalId" -o tsv)

echo "Managed Identity Principal ID: $IDENTITY_ID"
```

### Step 3: Grant Managed Identity Access to Key Vault

```bash
# Get Key Vault resource ID
KV_ID=$(az keyvault show --resource-group $RG --name $KV_NAME --query id -o tsv)

# Assign Key Vault Secrets User role to the VM's managed identity
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee-object-id $IDENTITY_ID \
  --assignee-principal-type ServicePrincipal \
  --scope $KV_ID
```

### Step 4: Test Secret Access from the VM

SSH into the VM and run:

```bash
# Get access token using managed identity (IMDS)
TOKEN=$(curl -s -H "Metadata: true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

# Use token to access Key Vault secret
SECRET=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://$KV_NAME.vault.azure.net/secrets/DatabasePassword?api-version=7.3" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['value'])")

echo "Secret value: $SECRET"
```

### Cleanup

```bash
az group delete --name $RG --yes --no-wait
```

---

## Lab 6: Secure Azure Storage Account

**Objective:** Configure storage account security including private endpoint, Defender for Storage, and SAS token generation.

**Estimated time:** 25 minutes

### Step 1: Create a Secure Storage Account

```bash
RG="rg-az500-lab6"
LOCATION="eastus"
SA_NAME="staz500lab6$(date +%s | tail -c 6)"  # Unique name

az group create --name $RG --location $LOCATION

# Create storage account with security best practices
az storage account create \
  --resource-group $RG \
  --name $SA_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2

echo "Storage Account: $SA_NAME"
```

### Step 2: Enable Defender for Storage

```bash
# Enable Microsoft Defender for Storage
az security atp storage update \
  --resource-group $RG \
  --storage-account $SA_NAME \
  --is-enabled true
```

### Step 3: Configure Storage Firewall

```bash
# Get your current public IP
MY_IP=$(curl -s ifconfig.me)

# Set storage account to deny all, then allow your IP
az storage account update \
  --resource-group $RG \
  --name $SA_NAME \
  --default-action Deny

az storage account network-rule add \
  --resource-group $RG \
  --account-name $SA_NAME \
  --ip-address $MY_IP

echo "Storage firewall configured. Your IP $MY_IP is allowed."
```

### Step 4: Create a User Delegation SAS Token

```bash
# Login with az login first to ensure user context
# Get storage account key for demo (in practice, use RBAC)
SA_KEY=$(az storage account keys list \
  --resource-group $RG \
  --account-name $SA_NAME \
  --query "[0].value" -o tsv)

# Create a container
az storage container create \
  --account-name $SA_NAME \
  --account-key $SA_KEY \
  --name "secure-container"

# Upload a test file
echo "Test content" > /tmp/test.txt
az storage blob upload \
  --account-name $SA_NAME \
  --account-key $SA_KEY \
  --container-name "secure-container" \
  --name "test.txt" \
  --file /tmp/test.txt

# Generate a SAS token (expires in 1 hour, HTTPS only, read permission only)
EXPIRY=$(date -u -d "+1 hour" +%Y-%m-%dT%H:%MZ 2>/dev/null || \
         date -u -v+1H +%Y-%m-%dT%H:%MZ)

az storage blob generate-sas \
  --account-name $SA_NAME \
  --account-key $SA_KEY \
  --container-name "secure-container" \
  --name "test.txt" \
  --permissions r \
  --expiry $EXPIRY \
  --https-only \
  --output tsv
```

### Cleanup

```bash
az group delete --name $RG --yes --no-wait
```

---

## Lab 7: Configure Microsoft Defender for Cloud

**Objective:** Enable Defender for Cloud plans, review secure score, and configure Just-in-Time VM Access.

**Estimated time:** 20 minutes

### Step 1: Review Defender for Cloud Dashboard

1. Navigate to **Microsoft Defender for Cloud** in the Azure Portal
2. Review the **Overview** page:
   - Note your current **Secure Score**
   - Review the **Security alerts** count
   - Review **Active recommendations**

### Step 2: Enable Defender Plans

```bash
# Enable Defender for Servers on a subscription
az security pricing create \
  --name VirtualMachines \
  --tier Standard

# Enable Defender for Storage
az security pricing create \
  --name StorageAccounts \
  --tier Standard

# Enable Defender for Key Vault
az security pricing create \
  --name KeyVaults \
  --tier Standard
```

### Step 3: Configure Just-in-Time VM Access

1. Navigate to **Defender for Cloud** → **Workload protections** → **Just-in-time VM access**
2. Review the **Not configured** tab — these VMs can benefit from JIT
3. Select a VM → **Enable JIT on 1 VM**
4. Configure JIT rules:
   - **Port 22 (SSH):** Allow from My IP, max 3 hours
   - **Port 3389 (RDP):** Allow from My IP, max 3 hours
5. Click **Save**

### Step 4: Request JIT Access

1. Select the JIT-enabled VM → **Request access**
2. Toggle port 22 or 3389 to **On**
3. Set duration (e.g., 1 hour)
4. Click **Open ports**
5. Verify the NSG now has a temporary rule for your IP
6. After the time expires, verify the rule is removed

### Step 5: Review Security Recommendations

1. Navigate to **Defender for Cloud** → **Recommendations**
2. Filter by **High** severity
3. Review a recommendation (e.g., "MFA should be enabled on accounts with owner permissions")
4. Click **Remediate** or **Quick fix** if available

---

## Lab 8: Set Up Microsoft Sentinel

**Objective:** Deploy Microsoft Sentinel, connect Azure AD and Activity Log data sources, and create an analytics rule to detect brute force attacks.

**Estimated time:** 30 minutes

### Step 1: Create Log Analytics Workspace

```bash
RG="rg-az500-lab8"
LOCATION="eastus"
LAW_NAME="law-sentinel-lab8"

az group create --name $RG --location $LOCATION

az monitor log-analytics workspace create \
  --resource-group $RG \
  --workspace-name $LAW_NAME \
  --location $LOCATION \
  --sku PerGB2018

LAW_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG \
  --workspace-name $LAW_NAME \
  --query id -o tsv)

echo "Log Analytics Workspace ID: $LAW_ID"
```

### Step 2: Enable Microsoft Sentinel

```bash
# Enable Sentinel on the workspace
az sentinel workspace onboard \
  --resource-group $RG \
  --workspace-name $LAW_NAME
```

Or via portal:
1. Navigate to **Microsoft Sentinel** → **+ Create**
2. Select the Log Analytics workspace you created
3. Click **Add Microsoft Sentinel**

### Step 3: Connect Data Sources (Portal)

1. Navigate to **Sentinel** → **Data connectors**
2. Connect **Azure Active Directory**:
   - Select **Azure Active Directory** connector
   - Click **Open connector page**
   - Enable **Sign-in Logs** and **Audit Logs**
   - Click **Apply Changes**
3. Connect **Azure Activity**:
   - Select **Azure Activity** connector
   - Click **Open connector page**
   - Click **Launch Azure Policy Assignment Wizard**
   - Configure policy to send Activity Logs to your workspace

### Step 4: Create an Analytics Rule (Brute Force Detection)

1. Navigate to **Sentinel** → **Analytics** → **+ Create** → **Scheduled query rule**
2. Configure:
   - **Name:** `Brute Force Attack - Failed Sign-ins`
   - **Description:** Detects more than 5 failed sign-in attempts within 10 minutes
   - **Tactics:** Credential Access (MITRE ATT&CK)
   - **Severity:** Medium

3. In the **Rule query** section, enter:

```kql
SigninLogs
| where TimeGenerated > ago(10m)
| where ResultType != 0
| summarize FailedAttempts = count(), IPAddresses = make_set(IPAddress) 
    by UserPrincipalName, bin(TimeGenerated, 10m)
| where FailedAttempts >= 5
| extend AlertDetail = strcat("User ", UserPrincipalName, 
    " had ", FailedAttempts, " failed sign-ins from IPs: ", tostring(IPAddresses))
| project TimeGenerated, UserPrincipalName, FailedAttempts, IPAddresses, AlertDetail
```

4. Configure:
   - **Query scheduling:** Run every 10 minutes, Lookup last 10 minutes
   - **Alert threshold:** Generate alert when: number of results is greater than 0
5. **Entity mapping:**
   - Account → UserPrincipalName
   - IP → IPAddresses (first element)
6. Click **Review and Create** → **Create**

### Step 5: Create a Simple Playbook (Optional)

1. Navigate to **Sentinel** → **Automation** → **+ Create** → **Playbook with incident trigger**
2. This opens the Logic App designer
3. Add an action: **Send an email** (Office 365 / Outlook connector)
4. Configure email notification for new high-severity incidents
5. Save the playbook
6. In **Automation rules**, create a rule to trigger the playbook on new incidents

### Cleanup

```bash
az group delete --name $RG --yes --no-wait
```

---

## Lab Summary

| Lab | Domain | Key Skills Practiced |
|---|---|---|
| Lab 1: Conditional Access | Domain 1 | Named locations, CA policies, report-only mode |
| Lab 2: PIM Configuration | Domain 1 | JIT access, eligible assignments, approval workflow |
| Lab 3: NSG and Bastion | Domain 2 | NSG rules, AzureBastionSubnet, secure VM access |
| Lab 4: Azure Firewall | Domain 2 | Firewall deployment, application rules, route tables |
| Lab 5: Key Vault + Managed Identity | Domain 3 | Key Vault RBAC, managed identity, IMDS token |
| Lab 6: Storage Security | Domain 3 | HTTPS enforcement, firewall rules, SAS tokens |
| Lab 7: Defender for Cloud | Domain 3/4 | Secure score, JIT VM access, recommendations |
| Lab 8: Microsoft Sentinel | Domain 4 | SIEM setup, data connectors, KQL analytics rules |

---

*Back to: [README — Project Overview](../README.md)*
