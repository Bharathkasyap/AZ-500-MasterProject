# AZ-500 Hands-On Labs

> **Prerequisites**: An Azure subscription (free trial with $200 credit is sufficient). All labs use the Azure portal and Azure CLI. Expected total time: 6–8 hours.

---

## Lab Environment Setup

### Option 1: Azure Free Trial
1. Go to [https://azure.microsoft.com/free](https://azure.microsoft.com/free)
2. Sign up with a Microsoft account (new accounts get $200 credit + 12 months of free services)
3. No credit card charges during the free trial period

### Option 2: Microsoft Learn Sandbox
- Some labs can be completed using the free [Microsoft Learn Sandbox](https://learn.microsoft.com/en-us/training/)
- Sandbox environments are temporary and reset after each session

### Azure CLI Setup

```bash
# Install Azure CLI (macOS)
brew install azure-cli

# Install Azure CLI (Windows)
winget install Microsoft.AzureCLI

# Install Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Log in to Azure
az login

# Set your default subscription
az account set --subscription "<subscription-id>"

# Verify
az account show
```

---

## Lab 1: Identity and Access Management

**Estimated time**: 45 minutes  
**Objective**: Configure Conditional Access, MFA, and PIM for a test user

### Lab 1.1 — Create a Test User and Group

```bash
# Variables
RG="az500-lab-rg"
LOCATION="eastus"
DOMAIN=$(az ad signed-in-user show --query "userPrincipalName" -o tsv | cut -d@ -f2)

# Create test user
az ad user create \
  --display-name "AZ500 Test User" \
  --user-principal-name "az500testuser@$DOMAIN" \
  --password "SecureP@ssw0rd123!" \
  --force-change-password-next-sign-in false

# Get user object ID
USER_OID=$(az ad user show --id "az500testuser@$DOMAIN" --query id -o tsv)
echo "Test user OID: $USER_OID"

# Create a security group
az ad group create \
  --display-name "AZ500-Lab-Users" \
  --mail-nickname "AZ500LabUsers"

GROUP_OID=$(az ad group show --group "AZ500-Lab-Users" --query id -o tsv)

# Add user to group
az ad group member add \
  --group "AZ500-Lab-Users" \
  --member-id $USER_OID
```

### Lab 1.2 — Assign RBAC Role with Limited Scope

```bash
# Create a resource group for testing
az group create --name $RG --location $LOCATION

# Assign Reader role at resource group scope
az role assignment create \
  --assignee $USER_OID \
  --role "Reader" \
  --scope /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG

# Verify role assignment
az role assignment list \
  --assignee $USER_OID \
  --scope /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG \
  --output table
```

### Lab 1.3 — Create a Custom RBAC Role

```bash
# Get subscription ID
SUB_ID=$(az account show --query id -o tsv)

# Create custom role JSON
cat > /tmp/custom-role.json << EOF
{
  "Name": "AZ500 VM Start/Stop Operator",
  "Description": "Can start and stop VMs but not create or delete them",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/$SUB_ID"
  ]
}
EOF

# Create the custom role
az role definition create --role-definition @/tmp/custom-role.json

# Verify
az role definition list --custom-role-only true --output table
```

### Lab 1.4 — Configure a Managed Identity

```bash
# Create a VM (we'll use it for managed identity labs)
az vm create \
  --name az500-lab-vm \
  --resource-group $RG \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Standard

# Enable system-assigned managed identity
az vm identity assign \
  --name az500-lab-vm \
  --resource-group $RG

# Get the principal ID of the managed identity
MANAGED_ID_PID=$(az vm show \
  --name az500-lab-vm \
  --resource-group $RG \
  --query "identity.principalId" -o tsv)
echo "VM Managed Identity Principal ID: $MANAGED_ID_PID"
```

---

## Lab 2: Azure Key Vault

**Estimated time**: 30 minutes  
**Objective**: Create and secure a Key Vault, store secrets, and grant managed identity access

### Lab 2.1 — Create Key Vault with RBAC

```bash
VAULT_NAME="az500-kv-$(date +%s)"

# Create Key Vault with RBAC authorization model
az keyvault create \
  --name $VAULT_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --retention-days 90

echo "Key Vault Name: $VAULT_NAME"
VAULT_ID=$(az keyvault show --name $VAULT_NAME --query id -o tsv)
```

### Lab 2.2 — Store a Secret

```bash
# Assign yourself the Key Vault Secrets Officer role
MY_OID=$(az ad signed-in-user show --query id -o tsv)

az role assignment create \
  --assignee $MY_OID \
  --role "Key Vault Secrets Officer" \
  --scope $VAULT_ID

# Wait a moment for role propagation, then create a secret
sleep 30

az keyvault secret set \
  --vault-name $VAULT_NAME \
  --name "db-password" \
  --value "SuperSecretDBPassword123!"

az keyvault secret set \
  --vault-name $VAULT_NAME \
  --name "api-key" \
  --value "sk-1234567890abcdef"

# List secrets (metadata only, not values)
az keyvault secret list --vault-name $VAULT_NAME --output table
```

### Lab 2.3 — Grant VM Managed Identity Access to Key Vault

```bash
# Assign Key Vault Secrets User to the VM's managed identity (least privilege)
az role assignment create \
  --assignee $MANAGED_ID_PID \
  --role "Key Vault Secrets User" \
  --scope $VAULT_ID

# Verify
az role assignment list --scope $VAULT_ID --output table
```

### Lab 2.4 — Test Secret Access from VM

```bash
# SSH into the VM (if using Azure CLI from your machine)
VM_IP=$(az vm list-ip-addresses \
  --name az500-lab-vm \
  --resource-group $RG \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)

echo "VM IP: $VM_IP"

# Connect via SSH and test managed identity access
# ssh azureuser@$VM_IP

# On the VM, run:
# TOKEN=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
# curl -s "https://${VAULT_NAME}.vault.azure.net/secrets/db-password?api-version=7.4" -H "Authorization: Bearer $TOKEN"
```

### Lab 2.5 — Enable Purge Protection

```bash
# Enable purge protection (this cannot be undone)
az keyvault update \
  --name $VAULT_NAME \
  --resource-group $RG \
  --enable-purge-protection true

# Verify settings
az keyvault show --name $VAULT_NAME \
  --query "{softDelete:properties.enableSoftDelete, purgeProtection:properties.enablePurgeProtection, retention:properties.softDeleteRetentionInDays}"
```

---

## Lab 3: Network Security

**Estimated time**: 45 minutes  
**Objective**: Configure NSGs, Azure Bastion, and Private Endpoints

### Lab 3.1 — Create a Virtual Network with Subnets

```bash
# Create VNet
az network vnet create \
  --name az500-lab-vnet \
  --resource-group $RG \
  --location $LOCATION \
  --address-prefixes 10.0.0.0/16

# Create VM subnet
az network vnet subnet create \
  --vnet-name az500-lab-vnet \
  --resource-group $RG \
  --name vm-subnet \
  --address-prefixes 10.0.1.0/24

# Create AzureBastionSubnet (must be this exact name)
az network vnet subnet create \
  --vnet-name az500-lab-vnet \
  --resource-group $RG \
  --name AzureBastionSubnet \
  --address-prefixes 10.0.2.0/26
```

### Lab 3.2 — Create and Configure an NSG

```bash
# Create NSG
az network nsg create \
  --name az500-lab-nsg \
  --resource-group $RG \
  --location $LOCATION

# View default rules
az network nsg show \
  --name az500-lab-nsg \
  --resource-group $RG \
  --query "defaultSecurityRules[]" \
  --output table

# Add a rule to block all inbound internet traffic (RDP and SSH)
# (Default deny-all is already there at priority 65500)

# Add a custom rule to allow HTTPS from Internet
az network nsg rule create \
  --nsg-name az500-lab-nsg \
  --resource-group $RG \
  --name AllowHTTPS \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 \
  --protocol Tcp \
  --access Allow \
  --direction Inbound

# Associate NSG with VM subnet
az network vnet subnet update \
  --vnet-name az500-lab-vnet \
  --name vm-subnet \
  --resource-group $RG \
  --network-security-group az500-lab-nsg
```

### Lab 3.3 — Test with IP Flow Verify

```bash
# First, get the VM's NIC
NIC_ID=$(az vm show \
  --name az500-lab-vm \
  --resource-group $RG \
  --query "networkProfile.networkInterfaces[0].id" -o tsv)

VM_NIC_NAME=$(echo $NIC_ID | cut -d'/' -f9)

# Run IP Flow Verify — test if HTTP is allowed (should be denied)
az network watcher test-ip-flow \
  --vm az500-lab-vm \
  --direction Inbound \
  --local "$(az vm list-ip-addresses --name az500-lab-vm --resource-group $RG --query '[0].virtualMachine.network.privateIpAddresses[0]' -o tsv):80" \
  --remote "203.0.113.1:*" \
  --protocol TCP \
  --resource-group $RG

# Test HTTPS (should be allowed)
az network watcher test-ip-flow \
  --vm az500-lab-vm \
  --direction Inbound \
  --local "$(az vm list-ip-addresses --name az500-lab-vm --resource-group $RG --query '[0].virtualMachine.network.privateIpAddresses[0]' -o tsv):443" \
  --remote "203.0.113.1:*" \
  --protocol TCP \
  --resource-group $RG
```

### Lab 3.4 — Deploy Azure Bastion

```bash
# Create public IP for Bastion (Standard SKU required)
az network public-ip create \
  --name az500-bastion-pip \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard \
  --allocation-method Static

# Deploy Azure Bastion (Basic SKU for lab — takes 5-10 minutes)
az network bastion create \
  --name az500-bastion \
  --resource-group $RG \
  --vnet-name az500-lab-vnet \
  --public-ip-address az500-bastion-pip \
  --location $LOCATION \
  --sku Basic

echo "Bastion deployment in progress... (5-10 minutes)"
```

### Lab 3.5 — Create Private Endpoint for Key Vault

```bash
# Create a private endpoint subnet
az network vnet subnet create \
  --vnet-name az500-lab-vnet \
  --resource-group $RG \
  --name private-endpoint-subnet \
  --address-prefixes 10.0.3.0/24

# Create private endpoint for Key Vault
az network private-endpoint create \
  --name az500-kv-pe \
  --resource-group $RG \
  --vnet-name az500-lab-vnet \
  --subnet private-endpoint-subnet \
  --private-connection-resource-id $VAULT_ID \
  --group-id vault \
  --connection-name az500-kv-connection

# Create Private DNS Zone for Key Vault
az network private-dns zone create \
  --resource-group $RG \
  --name "privatelink.vaultcore.azure.net"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group $RG \
  --zone-name "privatelink.vaultcore.azure.net" \
  --name az500-kv-dns-link \
  --virtual-network az500-lab-vnet \
  --registration-enabled false

# Create DNS record for the private endpoint
PRIVATE_IP=$(az network private-endpoint show \
  --name az500-kv-pe \
  --resource-group $RG \
  --query "customDnsConfigs[0].ipAddresses[0]" -o tsv)

az network private-dns record-set a add-record \
  --resource-group $RG \
  --zone-name "privatelink.vaultcore.azure.net" \
  --record-set-name $VAULT_NAME \
  --ipv4-address $PRIVATE_IP

# Disable public access on Key Vault
az keyvault update \
  --name $VAULT_NAME \
  --resource-group $RG \
  --default-action Deny \
  --bypass AzureServices
```

---

## Lab 4: Storage Security

**Estimated time**: 30 minutes  
**Objective**: Secure an Azure Storage account and configure WORM immutability

### Lab 4.1 — Create a Secure Storage Account

```bash
STORAGE_NAME="az500stor$(date +%s | tail -c 8)"

# Create storage account with secure defaults
az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --https-only true \
  --default-action Deny

echo "Storage account: $STORAGE_NAME"

# Verify security settings
az storage account show \
  --name $STORAGE_NAME \
  --resource-group $RG \
  --query "{publicAccess:allowBlobPublicAccess, tlsVersion:minimumTlsVersion, httpsOnly:supportsHttpsTrafficOnly, networkAction:networkRuleSet.defaultAction}"
```

### Lab 4.2 — Generate a User Delegation SAS

```bash
# Allow yourself to create a user delegation key
az role assignment create \
  --assignee $MY_OID \
  --role "Storage Blob Data Contributor" \
  --scope $(az storage account show --name $STORAGE_NAME --resource-group $RG --query id -o tsv)

# Allow Azure services to access the storage account (for the portal)
az storage account update \
  --name $STORAGE_NAME \
  --resource-group $RG \
  --bypass AzureServices

# Create a container
az storage container create \
  --name secure-data \
  --account-name $STORAGE_NAME \
  --auth-mode login

# Upload a test file
echo "Hello AZ-500" > /tmp/test-file.txt
az storage blob upload \
  --account-name $STORAGE_NAME \
  --container-name secure-data \
  --name test-file.txt \
  --file /tmp/test-file.txt \
  --auth-mode login

# Generate a User Delegation SAS (more secure than Account SAS)
EXPIRY=$(date -u -d "1 hour" +"%Y-%m-%dT%H:%MZ" 2>/dev/null || date -u -v+1H +"%Y-%m-%dT%H:%MZ")

az storage blob generate-sas \
  --account-name $STORAGE_NAME \
  --container-name secure-data \
  --name test-file.txt \
  --permissions r \
  --expiry $EXPIRY \
  --auth-mode login \
  --as-user \
  --https-only
```

### Lab 4.3 — Configure Immutable WORM Storage

```bash
# Create a new container for compliance data
az storage container create \
  --name compliance-records \
  --account-name $STORAGE_NAME \
  --auth-mode login

# Enable versioning (required for container-level WORM)
az storage account blob-service-properties update \
  --account-name $STORAGE_NAME \
  --resource-group $RG \
  --enable-versioning true

# Set a time-based immutability policy (7 days for lab; use 2555 days for 7-year compliance)
az storage container immutability-policy create \
  --account-name $STORAGE_NAME \
  --container-name compliance-records \
  --resource-group $RG \
  --period 7

# View the policy
az storage container immutability-policy show \
  --account-name $STORAGE_NAME \
  --container-name compliance-records \
  --resource-group $RG
```

### Lab 4.4 — Enable Soft Delete

```bash
# Enable blob soft delete (7-day retention)
az storage account blob-service-properties update \
  --account-name $STORAGE_NAME \
  --resource-group $RG \
  --enable-delete-retention true \
  --delete-retention-days 7

# Enable container soft delete
az storage account blob-service-properties update \
  --account-name $STORAGE_NAME \
  --resource-group $RG \
  --enable-container-delete-retention true \
  --container-delete-retention-days 7

# Verify
az storage account blob-service-properties show \
  --account-name $STORAGE_NAME \
  --resource-group $RG \
  --query "{blobSoftDelete:deleteRetentionPolicy, containerSoftDelete:containerDeleteRetentionPolicy}"
```

---

## Lab 5: Azure SQL Security

**Estimated time**: 30 minutes  
**Objective**: Configure SQL authentication, TDE, auditing, and Defender for SQL

### Lab 5.1 — Create SQL Server with Entra ID Authentication

```bash
SQL_SERVER="az500-sql-$(date +%s | tail -c 8)"
DB_NAME="az500-db"

# Create SQL Server
az sql server create \
  --name $SQL_SERVER \
  --resource-group $RG \
  --location $LOCATION \
  --admin-user sqladmin \
  --admin-password "SQLSecure@2024!"

echo "SQL Server: $SQL_SERVER"

# Set Entra ID administrator
az sql server ad-admin create \
  --server-name $SQL_SERVER \
  --resource-group $RG \
  --display-name "SQL Entra Admin" \
  --object-id $MY_OID

# Create a database
az sql db create \
  --server $SQL_SERVER \
  --resource-group $RG \
  --name $DB_NAME \
  --edition GeneralPurpose \
  --family Gen5 \
  --capacity 2 \
  --backup-storage-redundancy Local
```

### Lab 5.2 — Configure SQL Auditing

```bash
# Configure SQL Server auditing to Log Analytics
az sql server audit-policy update \
  --name $SQL_SERVER \
  --resource-group $RG \
  --state Enabled \
  --storage-account $STORAGE_NAME

# Alternatively, audit to Log Analytics workspace (preferred)
# az sql server audit-policy update \
#   --name $SQL_SERVER \
#   --resource-group $RG \
#   --state Enabled \
#   --log-analytics-workspace-resource-id <workspace-id>

# Verify
az sql server audit-policy show \
  --name $SQL_SERVER \
  --resource-group $RG \
  --query "{state:state, storageEndpoint:storageEndpoint}"
```

### Lab 5.3 — Enable Defender for SQL

```bash
# Enable Microsoft Defender for SQL at server level
az sql server threat-policy update \
  --server $SQL_SERVER \
  --resource-group $RG \
  --state Enabled \
  --storage-account $STORAGE_NAME \
  --email-account-admins Enabled

# Run a vulnerability assessment
az sql db threat-policy update \
  --server $SQL_SERVER \
  --resource-group $RG \
  --database $DB_NAME \
  --state Enabled
```

### Lab 5.4 — Configure Dynamic Data Masking

```bash
# Add a masking rule for a column (requires a table to exist in the DB)
# This example shows the CLI command structure:
az sql db tde show \
  --server $SQL_SERVER \
  --resource-group $RG \
  --database $DB_NAME

# View TDE status (enabled by default on Azure SQL)
az sql db tde show \
  --server $SQL_SERVER \
  --resource-group $RG \
  --database $DB_NAME \
  --query "{state:status}"
```

---

## Lab 6: Microsoft Defender for Cloud

**Estimated time**: 30 minutes  
**Objective**: Explore Defender for Cloud, review Secure Score, and configure a Defender plan

### Lab 6.1 — Enable Defender for Cloud

```bash
# Enable Defender for Cloud on your subscription
az security pricing create \
  --name "VirtualMachines" \
  --tier "Standard"

# Check current pricing tiers
az security pricing list --output table

# Enable Defender for Storage (per-storage account pricing)
az security pricing create \
  --name "StorageAccounts" \
  --tier "Standard"
```

### Lab 6.2 — View Secure Score and Recommendations

```bash
# View Secure Score
az security secure-scores list \
  --query "[].{Name:name, Score:properties.score.current, MaxScore:properties.score.max, Percentage:properties.score.percentage}" \
  --output table

# View top recommendations
az security assessment list \
  --query "[?properties.status.code=='Unhealthy'] | sort_by(@, &properties.metadata.severity) | [:10].{Name:properties.metadata.displayName, Severity:properties.metadata.severity, Resource:name}" \
  --output table
```

### Lab 6.3 — Configure JIT VM Access

```bash
# Enable JIT policy on the VM
az security jit-policy create \
  --name "default" \
  --resource-group $RG \
  --location $LOCATION \
  --virtual-machines "[
    {
      \"id\": \"/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/az500-lab-vm\",
      \"ports\": [
        {
          \"number\": 22,
          \"protocol\": \"TCP\",
          \"allowedSourceAddressPrefix\": \"*\",
          \"maxRequestAccessDuration\": \"PT3H\"
        }
      ]
    }
  ]"

echo "JIT policy created. SSH port 22 is now blocked by default."
echo "To access the VM, request JIT access via the Azure portal or CLI."

# Request JIT access
az security jit-policy initiate \
  --resource-group $RG \
  --name "default" \
  --virtual-machines "[
    {
      \"id\": \"/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/az500-lab-vm\",
      \"ports\": [
        {
          \"number\": 22,
          \"endTimeUtc\": \"$(date -u -d '3 hours' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+3H +%Y-%m-%dT%H:%M:%SZ)\",
          \"allowedSourceAddressPrefix\": \"$(curl -s ifconfig.me)\"
        }
      ]
    }
  ]"
```

---

## Lab 7: Microsoft Sentinel (Basic Setup)

**Estimated time**: 30 minutes  
**Objective**: Create a Sentinel workspace, add a data connector, and create an analytics rule

### Lab 7.1 — Create Log Analytics Workspace and Enable Sentinel

```bash
# Create Log Analytics workspace
WORKSPACE_NAME="az500-sentinel-ws"

az monitor log-analytics workspace create \
  --workspace-name $WORKSPACE_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --sku PerGB2018 \
  --retention-time 90

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --workspace-name $WORKSPACE_NAME \
  --resource-group $RG \
  --query id -o tsv)

echo "Workspace ID: $WORKSPACE_ID"

# Enable Microsoft Sentinel on the workspace
az sentinel workspace create \
  --workspace-name $WORKSPACE_NAME \
  --resource-group $RG 2>/dev/null || \
az rest --method put \
  --url "https://management.azure.com${WORKSPACE_ID}/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2022-12-01-preview" \
  --body '{"properties":{}}'
```

### Lab 7.2 — Connect Entra ID Logs to Sentinel

> **Note**: This step requires Entra ID P1/P2 licensing and must be done in the Azure portal.

**Portal Steps:**
1. Go to **Microsoft Sentinel** → your workspace
2. Click **Content hub** → search for "Microsoft Entra ID"
3. Install the **Microsoft Entra ID** solution
4. Go to **Data connectors** → **Microsoft Entra ID**
5. Click **Open connector page**
6. Check: **Azure Active Directory Sign-in logs** and **Audit logs**
7. Click **Apply Changes**

### Lab 7.3 — Create a Sentinel Analytics Rule (KQL)

> **Portal Steps** (Sentinel doesn't support full analytics rule creation via basic CLI):

1. Go to **Microsoft Sentinel** → **Analytics**
2. Click **+ Create** → **Scheduled query rule**
3. **Name**: Multiple Failed Sign-ins
4. **Severity**: Medium
5. **Query**:

```kql
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != "0"
| summarize FailureCount = count() by UserPrincipalName, IPAddress, bin(TimeGenerated, 5m)
| where FailureCount > 5
| extend AccountCustomEntity = UserPrincipalName
| extend IPCustomEntity = IPAddress
```

6. **Run query every**: 5 minutes
7. **Lookup data from the last**: 1 Hour
8. **Alert threshold**: Greater than 0
9. **Entity mapping**: Account → UserPrincipalName, IP → IPAddress
10. Click **Review + create**

### Lab 7.4 — Create an Automation Rule

> **Portal Steps**:

1. Go to **Microsoft Sentinel** → **Automation**
2. Click **+ Create** → **Automation rule**
3. **Name**: Auto-assign High Severity Incidents
4. **Trigger**: When incident is created
5. **Conditions**: Incident severity equals High
6. **Actions**: Assign owner → select yourself
7. Click **Apply**

---

## Lab Cleanup

> **Important**: Delete all lab resources to avoid charges.

```bash
# Delete the resource group (deletes all resources within it)
az group delete \
  --name $RG \
  --yes \
  --no-wait

# Delete the Key Vault (soft-deleted; purge if needed)
# az keyvault purge --name $VAULT_NAME --location $LOCATION

# Delete test user
az ad user delete --id "az500testuser@$DOMAIN"

# Delete custom RBAC role
az role definition delete --name "AZ500 VM Start/Stop Operator"

# Delete Entra ID group
az ad group delete --group "AZ500-Lab-Users"

echo "Cleanup initiated. Resource group deletion may take several minutes."
```

---

## Lab Summary

| Lab | Key Skills Practiced |
|-----|---------------------|
| Lab 1 | User creation, RBAC, custom roles, managed identities |
| Lab 2 | Key Vault, RBAC model, secrets, purge protection, private endpoints |
| Lab 3 | NSGs, IP Flow Verify, Azure Bastion, private endpoints, private DNS |
| Lab 4 | Storage security, User Delegation SAS, WORM, soft delete |
| Lab 5 | SQL security, Entra ID admin, auditing, TDE, Defender for SQL |
| Lab 6 | Defender for Cloud, Secure Score, JIT VM Access |
| Lab 7 | Microsoft Sentinel, Log Analytics, KQL analytics rules, automation |

---

## Additional Practice Scenarios

### Scenario A: Investigate a Compromised Account

1. Disable the test user account in Entra ID
2. Revoke all active sessions: `az ad user revoke-sessions --id <user-id>`
3. Check sign-in logs for suspicious activity in Log Analytics
4. Reset the user's password
5. Review all recent role assignments by the user in the Activity Log

### Scenario B: Secure a Storage Account After Accidental Public Access

1. Set `allowBlobPublicAccess` to false
2. Review and revoke any long-lived SAS tokens
3. Enable Defender for Storage
4. Enable audit logging to Log Analytics
5. Add network rules to restrict access to specific VNets

### Scenario C: Deploy a Zero-Trust VM Environment

1. Create VM with no public IP
2. Enable Azure Bastion for management access
3. Enable JIT VM Access for emergency RDP/SSH
4. Enable system-assigned managed identity
5. Grant managed identity Key Vault Secrets User role
6. Enable Defender for Servers Plan 2
7. Configure vulnerability assessment

---

*← [Practice Questions](../practice-questions/practice-exam.md) | [Quick Reference Cheat Sheet →](../quick-reference/cheat-sheet.md)*
