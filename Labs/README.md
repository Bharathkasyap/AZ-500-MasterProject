# Hands-on Labs

← [Back to Main Guide](../README.md)

---

> **Prerequisites**: Active Azure subscription (a free trial works), Azure CLI installed, access to Azure portal. Labs are designed to use resources that fit within the Azure free tier where possible.

---

## Lab Index

| # | Title | Domain | Estimated Time |
|---|---|---|---|
| [Lab 01](#lab-01-configure-azure-ad-privileged-identity-management-pim) | Configure Azure AD PIM | Identity & Access | 30 min |
| [Lab 02](#lab-02-implement-conditional-access-with-mfa) | Implement Conditional Access with MFA | Identity & Access | 20 min |
| [Lab 03](#lab-03-configure-azure-key-vault-with-rbac-and-private-endpoint) | Configure Azure Key Vault | Compute & Storage | 25 min |
| [Lab 04](#lab-04-deploy-azure-firewall-and-configure-forced-tunneling) | Azure Firewall & Forced Tunneling | Networking | 45 min |
| [Lab 05](#lab-05-configure-just-in-time-jit-vm-access) | Configure JIT VM Access | Compute | 20 min |
| [Lab 06](#lab-06-enable-azure-disk-encryption-on-a-vm) | Enable Azure Disk Encryption | Compute | 25 min |
| [Lab 07](#lab-07-configure-nsg-and-application-security-groups) | NSG and Application Security Groups | Networking | 30 min |
| [Lab 08](#lab-08-enable-microsoft-defender-for-cloud) | Enable Microsoft Defender for Cloud | Security Ops | 20 min |
| [Lab 09](#lab-09-deploy-microsoft-sentinel-and-create-analytics-rules) | Deploy Microsoft Sentinel | Security Ops | 45 min |
| [Lab 10](#lab-10-configure-azure-storage-security) | Configure Azure Storage Security | Compute & Storage | 30 min |
| [Lab 11](#lab-11-secure-azure-sql-database) | Secure Azure SQL Database | Databases | 30 min |
| [Lab 12](#lab-12-configure-azure-bastion) | Configure Azure Bastion | Networking | 20 min |

---

## Lab 01: Configure Azure AD Privileged Identity Management (PIM)

**Objective**: Configure PIM for the Global Administrator role, create an eligible assignment, and activate the role.

**Prerequisites**: Azure AD Premium P2 license (trial available), Global Administrator access

### Steps

**Step 1: Enable PIM**

```bash
# Navigate to Azure Portal → Microsoft Entra ID → Identity Governance → Privileged Identity Management
```

1. Open the Azure portal and navigate to **Microsoft Entra ID**
2. Select **Identity Governance** → **Privileged Identity Management**
3. Select **Azure AD roles**

**Step 2: Configure the Global Administrator Role Settings**

1. In PIM, click **Roles** and find **Global Administrator**
2. Click **Settings** (the gear icon)
3. Configure the following:
   - **Activation maximum duration**: 4 hours
   - **On activation, require**: Azure MFA
   - **Require justification on activation**: Yes
   - **Require approval to activate**: Yes (add an approver)
4. Click **Update**

**Step 3: Create an Eligible Assignment**

1. Click **Assignments** → **Add assignments**
2. Select **Global Administrator** as the role
3. Select a test user
4. Set **Assignment type**: Eligible
5. Set end date: 30 days from now
6. Click **Assign**

**Step 4: Activate the Role (as the test user)**

1. Sign in as the test user
2. Navigate to **PIM** → **My roles** → **Azure AD roles**
3. Find **Global Administrator** in Eligible roles
4. Click **Activate**
5. Enter justification
6. Submit for approval
7. (As approver) Approve the request in PIM → **Approve requests**

**Step 5: Verify Audit History**

1. In PIM, navigate to **Azure AD roles** → **Audit history**
2. Review the activation event with user, time, and justification

**Cleanup**: Revoke the eligible assignment after the lab.

---

## Lab 02: Implement Conditional Access with MFA

**Objective**: Create a Conditional Access policy requiring MFA when users access the Azure portal from outside named locations.

**Prerequisites**: Azure AD Premium P1 license, Global Administrator or Conditional Access Administrator role

### Steps

**Step 1: Create a Named Location (Corporate Network)**

1. Navigate to **Microsoft Entra ID** → **Security** → **Conditional Access** → **Named locations**
2. Click **+ IP ranges location**
3. Name: "Corporate Network"
4. Add your current public IP address in CIDR notation (e.g., `203.0.113.0/32`)
5. Check **Mark as trusted location**
6. Save

**Step 2: Create the Conditional Access Policy**

1. Go to **Conditional Access** → **Policies** → **+ New policy**
2. Name: "Require MFA outside corporate network"
3. **Users**: Select "All users" (or a test group)
4. **Target resources**: Select "Azure Management" (or all cloud apps)
5. **Conditions** → **Locations**:
   - Include: **Any location**
   - Exclude: **All trusted locations**
6. **Grant**: Select **Grant access** → Check **Require multi-factor authentication**
7. Set policy to **Report-only** first (not On)
8. Click **Create**

**Step 3: Test in Report-Only Mode**

1. Sign in to the Azure portal from the corporate network
2. Navigate to **Microsoft Entra ID** → **Sign-in logs**
3. Find your sign-in and check the **Conditional Access** tab
4. Verify the policy would have required MFA (report-only result)

**Step 4: Switch to Enforcement Mode**

1. Edit the policy and change from **Report-only** to **On**
2. Test again from a non-trusted network (e.g., mobile hotspot)
3. Verify MFA is prompted

**Cleanup**: Set policy back to Report-only or delete after the lab.

---

## Lab 03: Configure Azure Key Vault with RBAC and Private Endpoint

**Objective**: Create a Key Vault, configure RBAC authorization, add secrets, and configure a private endpoint.

### Steps

**Step 1: Create a Key Vault**

```bash
# Variables
RESOURCE_GROUP="rg-keyvault-lab"
LOCATION="eastus"
KEY_VAULT_NAME="kv-az500-lab-$RANDOM"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Key Vault with RBAC authorization and soft delete
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --retention-days 90 \
  --enable-purge-protection true
```

**Step 2: Assign RBAC Roles**

```bash
# Get your user ID
USER_ID=$(az ad signed-in-user show --query id -o tsv)

# Assign Key Vault Administrator role
az role assignment create \
  --assignee $USER_ID \
  --role "Key Vault Administrator" \
  --scope $(az keyvault show --name $KEY_VAULT_NAME --query id -o tsv)
```

**Step 3: Create Secrets**

```bash
# Create a secret
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "DatabasePassword" \
  --value "P@ssw0rd123SecureSecret!"

# List secrets (shows names, not values)
az keyvault secret list --vault-name $KEY_VAULT_NAME

# Show secret value
az keyvault secret show \
  --vault-name $KEY_VAULT_NAME \
  --name "DatabasePassword" \
  --query value -o tsv
```

**Step 4: Create Private Endpoint**

```bash
# Create a VNet for the private endpoint
az network vnet create \
  --name vnet-lab \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-private \
  --subnet-prefix 10.0.1.0/24

# Disable network policies on the subnet for private endpoint
az network vnet subnet update \
  --name subnet-private \
  --vnet-name vnet-lab \
  --resource-group $RESOURCE_GROUP \
  --disable-private-endpoint-network-policies true

# Create Private Endpoint
KV_ID=$(az keyvault show --name $KEY_VAULT_NAME --query id -o tsv)

az network private-endpoint create \
  --name pe-keyvault \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-lab \
  --subnet subnet-private \
  --private-connection-resource-id $KV_ID \
  --group-id vault \
  --connection-name pe-kv-connection

# Disable public network access
az keyvault update \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --public-network-access Disabled
```

**Step 5: Configure Private DNS**

```bash
# Create Private DNS Zone
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name "privatelink.vaultcore.azure.net"

# Link DNS Zone to VNet
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name "privatelink.vaultcore.azure.net" \
  --name dns-link-kv \
  --virtual-network vnet-lab \
  --registration-enabled false

# Create DNS record for the private endpoint
az network private-endpoint dns-zone-group create \
  --endpoint-name pe-keyvault \
  --resource-group $RESOURCE_GROUP \
  --name kv-dns-group \
  --private-dns-zone "privatelink.vaultcore.azure.net" \
  --zone-name vault
```

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Lab 04: Deploy Azure Firewall and Configure Forced Tunneling

**Objective**: Deploy Azure Firewall in a hub VNet and configure forced tunneling from a spoke VNet.

### Steps

**Step 1: Create Hub VNet with Azure Firewall Subnet**

```bash
RESOURCE_GROUP="rg-firewall-lab"
LOCATION="eastus"

az group create --name $RESOURCE_GROUP --location $LOCATION

# Create hub VNet
az network vnet create \
  --name vnet-hub \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16

# Add AzureFirewallSubnet (required name, minimum /26)
az network vnet subnet create \
  --name AzureFirewallSubnet \
  --vnet-name vnet-hub \
  --resource-group $RESOURCE_GROUP \
  --address-prefix 10.0.1.0/26

# Create spoke VNet
az network vnet create \
  --name vnet-spoke \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.1.0.0/16 \
  --subnet-name subnet-vms \
  --subnet-prefix 10.1.1.0/24
```

**Step 2: Deploy Azure Firewall**

```bash
# Create Public IP for firewall
az network public-ip create \
  --name pip-firewall \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --allocation-method Static \
  --sku Standard

# Create Azure Firewall
az network firewall create \
  --name fw-lab \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Configure firewall IP
az network firewall ip-config create \
  --firewall-name fw-lab \
  --name fw-ipconfig \
  --public-ip-address pip-firewall \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-hub

# Get private IP of firewall
FW_PRIVATE_IP=$(az network firewall show \
  --name fw-lab \
  --resource-group $RESOURCE_GROUP \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)
echo "Firewall private IP: $FW_PRIVATE_IP"
```

**Step 3: Create VNet Peering**

```bash
# Peer hub to spoke
HUB_ID=$(az network vnet show --name vnet-hub --resource-group $RESOURCE_GROUP --query id -o tsv)
SPOKE_ID=$(az network vnet show --name vnet-spoke --resource-group $RESOURCE_GROUP --query id -o tsv)

az network vnet peering create \
  --name hub-to-spoke \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-hub \
  --remote-vnet $SPOKE_ID \
  --allow-vnet-access

az network vnet peering create \
  --name spoke-to-hub \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-spoke \
  --remote-vnet $HUB_ID \
  --allow-vnet-access
```

**Step 4: Create Route Table for Forced Tunneling**

```bash
# Create route table
az network route-table create \
  --name rt-spoke \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Add route: all internet traffic → Azure Firewall
az network route-table route create \
  --name route-to-firewall \
  --resource-group $RESOURCE_GROUP \
  --route-table-name rt-spoke \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $FW_PRIVATE_IP

# Associate route table with spoke subnet
az network vnet subnet update \
  --name subnet-vms \
  --vnet-name vnet-spoke \
  --resource-group $RESOURCE_GROUP \
  --route-table rt-spoke
```

**Step 5: Configure Firewall Application Rules**

```bash
# Create a Firewall Policy
az network firewall policy create \
  --name fw-policy \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Create Rule Collection Group
az network firewall policy rule-collection-group create \
  --name DefaultRuleCollectionGroup \
  --policy-name fw-policy \
  --resource-group $RESOURCE_GROUP \
  --priority 100

# Allow HTTPS to Microsoft domains
az network firewall policy rule-collection-group collection add-filter-collection \
  --name AllowMicrosoft \
  --collection-group-name DefaultRuleCollectionGroup \
  --policy-name fw-policy \
  --resource-group $RESOURCE_GROUP \
  --rule-type ApplicationRule \
  --priority 100 \
  --action Allow \
  --rule-name AllowMicrosoftHTTPS \
  --protocols Https=443 \
  --source-addresses "*" \
  --target-fqdns "*.microsoft.com" "*.azure.com"
```

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Lab 05: Configure Just-in-Time (JIT) VM Access

**Objective**: Enable JIT VM access via Microsoft Defender for Cloud and test the access request workflow.

**Prerequisites**: Microsoft Defender for Servers (Plan 1 or 2) enabled; a running Azure VM

### Steps

**Step 1: Enable Defender for Servers**

1. Navigate to **Microsoft Defender for Cloud** → **Environment settings**
2. Select your subscription → **Defender plans**
3. Enable **Servers** plan (Plan 1 is sufficient)
4. Save

**Step 2: Configure JIT on a VM**

**Using the Portal:**
1. Navigate to **Defender for Cloud** → **Workload protections** → **Just-in-time VM access**
2. Click the **Not configured** tab and find your VM
3. Click on the VM → **Enable JIT on 1 VM**
4. Review the default rules (port 22/SSH and 3389/RDP)
5. Customize: set max request time to 3 hours, allowed source IPs to "My IP"
6. Click **Save**

**Using Azure CLI:**
```bash
VM_NAME="vm-test"
RESOURCE_GROUP="rg-jit-lab"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
VM_ID=$(az vm show --name $VM_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)

az rest --method PUT \
  --uri "https://management.azure.com${VM_ID}/providers/Microsoft.Security/jitNetworkAccessPolicies/default?api-version=2020-01-01" \
  --body '{
    "kind": "Basic",
    "properties": {
      "virtualMachines": [{
        "id": "'"$VM_ID"'",
        "ports": [{
          "number": 3389,
          "protocol": "*",
          "allowedSourceAddressPrefix": "My IP",
          "maxRequestAccessDuration": "PT3H"
        }]
      }]
    }
  }'
```

**Step 3: Request JIT Access**

1. In Defender for Cloud → **JIT VM access** → **Configured** tab
2. Find your VM → Click **Request access**
3. Check the port you need (3389 or 22)
4. Set time limit (e.g., 1 hour)
5. Enter your source IP (or use "My IP")
6. Click **Open ports**

**Step 4: Verify the Temporary NSG Rule**

1. Navigate to the NSG associated with the VM
2. Observe the temporary inbound rule for RDP/SSH with your IP and expiry time
3. After the time expires, the rule is automatically removed

**Step 5: Review JIT Activity in Audit Logs**

1. In Defender for Cloud → **JIT VM access** → Select your VM
2. Click **Activity log** to see all JIT access requests

---

## Lab 06: Enable Azure Disk Encryption on a VM

**Objective**: Enable ADE on an Azure VM using a Key Vault for key storage.

### Steps

**Step 1: Create Prerequisites**

```bash
RESOURCE_GROUP="rg-ade-lab"
LOCATION="eastus"
KEY_VAULT_NAME="kv-ade-$RANDOM"
VM_NAME="vm-ade-test"

az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Key Vault (ADE requires soft delete; do NOT enable purge protection for ADE)
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enabled-for-disk-encryption true \
  --enable-soft-delete true

# Create a test VM
az vm create \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --image Win2022AzureEditionCore \
  --admin-username azureuser \
  --admin-password "ComplexP@ss123!" \
  --size Standard_B2s
```

**Step 2: Enable Azure Disk Encryption**

```bash
# Enable ADE on the VM
az vm encryption enable \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --disk-encryption-keyvault $KEY_VAULT_NAME \
  --volume-type All

# Monitor encryption status
az vm encryption show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP
```

**Step 3: Verify Encryption Status**

```bash
# Check encryption status (wait until "succeeded")
az vm encryption show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "disks[].statuses[].displayStatus" -o table
```

**Step 4: Verify via Portal**

1. Navigate to the VM → **Disks**
2. Check the OS disk — **Encryption** should show "Azure Disk Encryption enabled"
3. Navigate to the Key Vault → **Keys** to see the Key Encryption Key (KEK)

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Lab 07: Configure NSG and Application Security Groups

**Objective**: Create NSGs and ASGs to allow only specific traffic between web and database tiers.

### Steps

**Step 1: Create Resource Group and VNet**

```bash
RESOURCE_GROUP="rg-nsg-lab"
LOCATION="eastus"

az group create --name $RESOURCE_GROUP --location $LOCATION

az network vnet create \
  --name vnet-app \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --name subnet-db \
  --vnet-name vnet-app \
  --resource-group $RESOURCE_GROUP \
  --address-prefix 10.0.2.0/24
```

**Step 2: Create Application Security Groups**

```bash
# Create ASGs for web servers and database servers
az network asg create \
  --name asg-web-servers \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

az network asg create \
  --name asg-db-servers \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION
```

**Step 3: Create and Configure NSG**

```bash
# Create NSG
az network nsg create \
  --name nsg-app \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Allow HTTPS inbound to web servers from internet
az network nsg rule create \
  --name Allow-HTTPS-Inbound \
  --nsg-name nsg-app \
  --resource-group $RESOURCE_GROUP \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-asgs asg-web-servers \
  --destination-port-ranges 443

# Allow SQL from web servers to database servers
az network nsg rule create \
  --name Allow-SQL-WebToDB \
  --nsg-name nsg-app \
  --resource-group $RESOURCE_GROUP \
  --priority 200 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-asgs asg-web-servers \
  --destination-asgs asg-db-servers \
  --destination-port-ranges 1433

# Deny all other inbound to DB
az network nsg rule create \
  --name Deny-All-DB \
  --nsg-name nsg-app \
  --resource-group $RESOURCE_GROUP \
  --priority 4000 \
  --direction Inbound \
  --access Deny \
  --protocol "*" \
  --destination-asgs asg-db-servers \
  --destination-port-ranges "*"

# Associate NSG with subnets
az network vnet subnet update \
  --name subnet-web \
  --vnet-name vnet-app \
  --resource-group $RESOURCE_GROUP \
  --network-security-group nsg-app

az network vnet subnet update \
  --name subnet-db \
  --vnet-name vnet-app \
  --resource-group $RESOURCE_GROUP \
  --network-security-group nsg-app
```

**Step 4: Associate VMs with ASGs**

```bash
# After creating VMs, associate their NICs with the appropriate ASG
# For a web server VM:
az network nic ip-config update \
  --name ipconfigWeb \
  --nic-name <web-vm-nic-name> \
  --resource-group $RESOURCE_GROUP \
  --application-security-groups asg-web-servers

# For a database server VM:
az network nic ip-config update \
  --name ipconfigDB \
  --nic-name <db-vm-nic-name> \
  --resource-group $RESOURCE_GROUP \
  --application-security-groups asg-db-servers
```

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Lab 08: Enable Microsoft Defender for Cloud

**Objective**: Enable Microsoft Defender for Cloud, review recommendations, and configure email notifications.

### Steps

**Step 1: Enable Defender for Cloud**

1. Open the Azure portal and search for **Microsoft Defender for Cloud**
2. If not already onboarded, you'll see the Getting Started screen
3. Click **Upgrade** to enable enhanced security features (30-day trial)

**Step 2: Enable Defender Plans**

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Enable Defender for Servers Plan 2
az security pricing create \
  --name VirtualMachines \
  --tier Standard \
  --subscription $SUBSCRIPTION_ID

# Enable Defender for Storage
az security pricing create \
  --name StorageAccounts \
  --tier Standard \
  --subscription $SUBSCRIPTION_ID

# Enable Defender for SQL
az security pricing create \
  --name SqlServers \
  --tier Standard \
  --subscription $SUBSCRIPTION_ID

# Enable Defender for Key Vault
az security pricing create \
  --name KeyVaults \
  --tier Standard \
  --subscription $SUBSCRIPTION_ID
```

**Step 3: Configure Auto-provisioning**

1. In Defender for Cloud → **Environment settings** → Select subscription
2. Click **Settings & monitoring**
3. Enable **Log Analytics agent** auto-provisioning
4. Select your Log Analytics workspace (or create a new one)
5. Enable **Microsoft Defender for Endpoint** agent provisioning
6. Save

**Step 4: Configure Email Notifications**

1. In Defender for Cloud → **Environment settings** → Select subscription
2. Click **Email notifications**
3. Add your email address
4. Set notification for: **High severity alerts**
5. Enable "Also send email notifications to subscription owners"
6. Save

**Step 5: Review Security Recommendations**

1. In Defender for Cloud → **Recommendations**
2. Sort by **Secure Score impact** (descending)
3. Review the top 5 recommendations
4. Click on one recommendation to see:
   - Affected resources
   - Remediation steps
   - Quick Fix option (if available)

**Step 6: Review Secure Score**

1. In Defender for Cloud → **Secure Score**
2. Note the current score
3. Click on a security control to see its recommendations
4. Implement one recommendation and observe the score change (may take up to 24 hours)

---

## Lab 09: Deploy Microsoft Sentinel and Create Analytics Rules

**Objective**: Deploy Microsoft Sentinel, connect data sources, and create an analytics rule to detect suspicious sign-ins.

### Steps

**Step 1: Create Log Analytics Workspace**

```bash
RESOURCE_GROUP="rg-sentinel-lab"
LOCATION="eastus"
WORKSPACE_NAME="law-sentinel-$RANDOM"

az group create --name $RESOURCE_GROUP --location $LOCATION

az monitor log-analytics workspace create \
  --name $WORKSPACE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --retention-time 90
```

**Step 2: Enable Microsoft Sentinel**

```bash
# Install the Sentinel solution on the workspace
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --name $WORKSPACE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

az sentinel onboarding-state create \
  --workspace-name $WORKSPACE_NAME \
  --resource-group $RESOURCE_GROUP \
  --name default
```

**Step 3: Connect Azure AD Data Connector (Portal)**

1. In Sentinel → **Content management** → **Content hub**
2. Search for "Azure Active Directory"
3. Install the solution (includes data connector + analytics rules + workbooks)
4. Navigate to **Configuration** → **Data connectors**
5. Find **Microsoft Entra ID** → **Open connector page**
6. Enable: **Sign-in logs**, **Audit logs**, **Non-interactive user sign-in logs**
7. Click **Apply changes**

**Step 4: Connect Azure Activity (CLI)**

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create diagnostic setting to send Azure Activity to Sentinel workspace
az monitor diagnostic-settings create \
  --name "send-activity-to-sentinel" \
  --resource "/subscriptions/$SUBSCRIPTION_ID" \
  --workspace $WORKSPACE_ID \
  --logs '[{"category": "Administrative", "enabled": true}, {"category": "Security", "enabled": true}, {"category": "Alert", "enabled": true}]'
```

**Step 5: Create an Analytics Rule for Brute Force Detection**

1. In Sentinel → **Configuration** → **Analytics**
2. Click **+ Create** → **Scheduled query rule**
3. Configure:
   - **Name**: "Multiple Failed Sign-ins from Same IP"
   - **Tactics**: Credential Access
   - **Techniques**: T1110 (Brute Force)
   - **Severity**: Medium

4. **Set rule logic** with this KQL:

```kql
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != 0  // Failed sign-ins
| summarize
    FailureCount = count(),
    DistinctUsers = dcount(UserPrincipalName),
    FirstFailure = min(TimeGenerated),
    LastFailure = max(TimeGenerated),
    UserList = make_set(UserPrincipalName, 10)
  by IPAddress
| where FailureCount >= 10 and DistinctUsers >= 3
| extend Description = strcat("Multiple users targeted from IP: ", IPAddress)
| project-reorder IPAddress, FailureCount, DistinctUsers, UserList, FirstFailure, LastFailure
```

5. **Alert enhancement** — Entity mapping:
   - Entity: **IP** → Column: **IPAddress**

6. **Query scheduling**:
   - Run query every: 15 minutes
   - Lookup data from last: 1 hour

7. **Alert threshold**: Generate alert when number of query results is greater than 0

8. **Event grouping**: Group all events into a single alert

9. **Incident settings**: Enable "Create incidents from alerts"

10. Click **Review + create** → **Save**

**Step 6: Create a Hunting Query**

1. In Sentinel → **Threat management** → **Hunting**
2. Click **+ New query**
3. Name: "Admin Role Assignments"
4. KQL:
```kql
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName == "Add member to role"
| extend
    TargetUser = tostring(TargetResources[0].userPrincipalName),
    RoleName = tostring(TargetResources[0].modifiedProperties[0].newValue),
    InitiatedByUser = tostring(InitiatedBy.user.userPrincipalName)
| where RoleName contains "Administrator"
| project TimeGenerated, InitiatedByUser, TargetUser, RoleName
| order by TimeGenerated desc
```

5. Add Tactics: Privilege Escalation
6. Save and run

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Lab 10: Configure Azure Storage Security

**Objective**: Secure an Azure Storage account by disabling public access, enabling encryption with CMK, and configuring Private Endpoint.

### Steps

**Step 1: Create Storage Account**

```bash
RESOURCE_GROUP="rg-storage-lab"
LOCATION="eastus"
STORAGE_NAME="stor${RANDOM}az500"

az group create --name $RESOURCE_GROUP --location $LOCATION

az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --https-only true \
  --min-tls-version TLS1_2
```

**Step 2: Disable Public Access and Configure Firewall**

```bash
# Update storage to deny all public network access (except Azure services)
az storage account update \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --default-action Deny \
  --bypass AzureServices Logging Metrics

# Add your current IP to the firewall (to allow your access)
MY_IP=$(curl -s ifconfig.me)
az storage account network-rule add \
  --account-name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --ip-address $MY_IP
```

**Step 3: Generate and Use SAS Token**

```bash
# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "[0].value" -o tsv)

# Create a container
az storage container create \
  --name uploads \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

# Generate a SAS token (write-only, expires in 48 hours)
EXPIRY=$(date -u -d '48 hours' '+%Y-%m-%dT%H:%MZ')
az storage container generate-sas \
  --name uploads \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY \
  --permissions w \
  --expiry $EXPIRY \
  --https-only \
  --output tsv
```

**Step 4: Enable Soft Delete and Versioning**

```bash
# Enable blob soft delete (7-day retention)
az storage account blob-service-properties update \
  --account-name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --enable-delete-retention true \
  --delete-retention-days 7 \
  --enable-versioning true
```

**Step 5: Verify Security Posture in Defender for Cloud**

1. Navigate to **Defender for Cloud** → **Inventory**
2. Find your storage account
3. Review security recommendations
4. Note: "Secure transfer should be enabled" should be **Healthy** (we set --https-only)
5. Note: "Public access should be disabled" should be **Healthy**

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Lab 11: Secure Azure SQL Database

**Objective**: Configure Azure SQL Database with Azure AD authentication, auditing, Defender for SQL, and TDE with CMK.

### Steps

**Step 1: Create SQL Server and Database**

```bash
RESOURCE_GROUP="rg-sql-lab"
LOCATION="eastus"
SQL_SERVER_NAME="sql-az500-$RANDOM"
DB_NAME="db-az500"
ADMIN_USER="sqladmin"
ADMIN_PASSWORD="SecureP@ssw0rd123!"

az group create --name $RESOURCE_GROUP --location $LOCATION

# Create SQL Server
az sql server create \
  --name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $ADMIN_USER \
  --admin-password $ADMIN_PASSWORD

# Create Database
az sql db create \
  --name $DB_NAME \
  --server $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --edition GeneralPurpose \
  --compute-model Serverless \
  --family Gen5 \
  --capacity 1
```

**Step 2: Configure Azure AD Admin**

```bash
# Get current user's UPN
CURRENT_USER_UPN=$(az ad signed-in-user show --query userPrincipalName -o tsv)
CURRENT_USER_OID=$(az ad signed-in-user show --query id -o tsv)

# Set Azure AD admin on SQL Server
az sql server ad-admin create \
  --server-name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --display-name $CURRENT_USER_UPN \
  --object-id $CURRENT_USER_OID
```

**Step 3: Enable Azure AD-Only Authentication**

```bash
# Enable Azure AD-only auth (disables SQL authentication)
az sql server ad-only-auth enable \
  --resource-group $RESOURCE_GROUP \
  --name $SQL_SERVER_NAME
```

**Step 4: Enable SQL Auditing**

```bash
# Create storage account for audit logs
AUDIT_STORAGE="sqladit$RANDOM"
az storage account create \
  --name $AUDIT_STORAGE \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Enable auditing on the SQL server
az sql server audit-policy update \
  --name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --state Enabled \
  --storage-account $AUDIT_STORAGE \
  --retention-days 90
```

**Step 5: Enable Microsoft Defender for SQL**

```bash
# Enable Defender for SQL on the server
az sql server microsoft-support-auditing-policy update \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --state Enabled
```

Via Portal:
1. Navigate to the SQL Server → **Microsoft Defender for Cloud**
2. Enable **Microsoft Defender for SQL**
3. Configure vulnerability assessment storage account

**Step 6: Configure Network Access**

```bash
# Deny all public network access (use private endpoint for production)
az sql server update \
  --name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --restrict-outbound-network-access true

# For lab: add your current IP to connect
MY_IP=$(curl -s ifconfig.me)
az sql server firewall-rule create \
  --name AllowMyIP \
  --server $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP
```

**Step 7: Review TDE Status**

```bash
# TDE is enabled by default; verify
az sql db tde show \
  --database $DB_NAME \
  --server $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP
```

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Lab 12: Configure Azure Bastion

**Objective**: Deploy Azure Bastion and use it to connect to a VM without a public IP.

### Steps

**Step 1: Create VNet with Bastion Subnet**

```bash
RESOURCE_GROUP="rg-bastion-lab"
LOCATION="eastus"

az group create --name $RESOURCE_GROUP --location $LOCATION

# Create VNet
az network vnet create \
  --name vnet-bastion \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-vms \
  --subnet-prefix 10.0.1.0/24

# Create AzureBastionSubnet (required name, minimum /26)
az network vnet subnet create \
  --name AzureBastionSubnet \
  --vnet-name vnet-bastion \
  --resource-group $RESOURCE_GROUP \
  --address-prefix 10.0.2.0/26
```

**Step 2: Create Test VM (No Public IP)**

```bash
# Create VM without public IP
az vm create \
  --name vm-private \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --image Win2022AzureEditionCore \
  --admin-username azureuser \
  --admin-password "ComplexP@ss123!" \
  --vnet-name vnet-bastion \
  --subnet subnet-vms \
  --public-ip-address "" \
  --size Standard_B2s
```

**Step 3: Deploy Azure Bastion**

```bash
# Create public IP for Bastion
az network public-ip create \
  --name pip-bastion \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --allocation-method Static \
  --sku Standard

# Deploy Bastion (Standard SKU for full features)
az network bastion create \
  --name bastion-lab \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --vnet-name vnet-bastion \
  --public-ip-address pip-bastion \
  --sku Standard

# Note: Bastion deployment takes 5-10 minutes
```

**Step 4: Connect to VM via Bastion**

1. Navigate to the VM in the Azure portal
2. Click **Connect** → **Bastion**
3. Enter credentials (azureuser / ComplexP@ss123!)
4. Click **Connect** — a browser-based RDP session opens
5. Verify you can interact with the VM through the browser

**Step 5: Verify No Public IP on VM**

```bash
# Confirm VM has no public IP
az vm show \
  --name vm-private \
  --resource-group $RESOURCE_GROUP \
  --query "networkProfile.networkInterfaces[].id" -o tsv | \
  xargs -I {} az network nic show --ids {} --query "ipConfigurations[].publicIPAddress" -o tsv
# Output should be empty (no public IP)
```

**Cleanup**:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Performance-Based Lab Tips

The AZ-500 exam may include a **performance-based lab** with approximately 12 sub-tasks in a live Azure environment. Key tips:

1. **Read ALL tasks before starting** — some tasks may depend on others; do them in logical order
2. **Use the portal for unfamiliar tasks** — it's slower but less error-prone than CLI
3. **Verify each task** — check the resource was created/configured correctly before moving on
4. **Common lab tasks include**:
   - Enabling Defender for Cloud plans
   - Creating and assigning RBAC roles
   - Configuring Key Vault access policies or RBAC
   - Setting up NSG rules
   - Enabling diagnostic settings
   - Creating Conditional Access policies
   - Configuring SQL auditing or TDE
5. **Time management**: You typically have 30–45 minutes; don't spend more than 5 minutes on any single sub-task
6. **Partial credit**: You receive credit for each sub-task you complete, even if you don't finish all of them

---

← [Back to Main Guide](../README.md) | [Study Tips →](../Study-Tips.md)
