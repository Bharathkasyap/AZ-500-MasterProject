# AZ-500 Hands-On Labs

← [Back to README](../README.md)

> **Prerequisites:** An Azure subscription with sufficient permissions (Contributor or Owner on a test subscription). Some labs require Entra ID P2 or Microsoft Defender for Cloud enabled.
>
> ⚠️ **Cost Warning:** Create a dedicated resource group for labs and delete it when done to avoid ongoing charges.

---

## Lab Overview

| Lab | Domain | Key Skills |
|-----|--------|-----------|
| [Lab 1: Configure Conditional Access](#lab-1-configure-conditional-access) | D1 | Conditional Access, MFA |
| [Lab 2: Set Up Privileged Identity Management](#lab-2-set-up-privileged-identity-management-pim) | D1 | PIM, eligible roles |
| [Lab 3: Configure Managed Identity for Azure VM](#lab-3-configure-managed-identity-for-azure-vm) | D1 | Managed identity, RBAC |
| [Lab 4: Implement Azure RBAC Custom Role](#lab-4-implement-azure-rbac-custom-role) | D1 | Custom roles, least privilege |
| [Lab 5: Configure Network Security Groups](#lab-5-configure-network-security-groups) | D2 | NSG rules, ASGs |
| [Lab 6: Deploy Azure Firewall](#lab-6-deploy-azure-firewall) | D2 | Firewall, UDR, FQDN rules |
| [Lab 7: Configure Azure Bastion](#lab-7-configure-azure-bastion) | D2 | Bastion, private access |
| [Lab 8: Set Up Private Endpoint for Storage](#lab-8-set-up-private-endpoint-for-storage) | D2 | Private endpoints, DNS |
| [Lab 9: Enable WAF on Application Gateway](#lab-9-enable-waf-on-application-gateway) | D2 | WAF, Prevention mode |
| [Lab 10: Configure Azure Key Vault with RBAC](#lab-10-configure-azure-key-vault-with-rbac) | D3 | Key Vault, secrets, RBAC |
| [Lab 11: Enable Azure Disk Encryption](#lab-11-enable-azure-disk-encryption) | D3 | ADE, BitLocker, Key Vault |
| [Lab 12: Secure Azure SQL Database](#lab-12-secure-azure-sql-database) | D3 | TDE, auditing, AAD auth |
| [Lab 13: Configure JIT VM Access](#lab-13-configure-just-in-time-jit-vm-access) | D3 | JIT, Defender for Cloud |
| [Lab 14: Set Up Microsoft Sentinel](#lab-14-set-up-microsoft-sentinel) | D4 | Sentinel, data connectors |
| [Lab 15: Create Sentinel Analytics Rule & Playbook](#lab-15-create-sentinel-analytics-rule--playbook) | D4 | KQL rules, Logic Apps |
| [Lab 16: Configure Azure Monitor Alerts](#lab-16-configure-azure-monitor-alerts) | D4 | Activity Log alerts, action groups |

---

## Lab 1: Configure Conditional Access

**Objective:** Create a Conditional Access policy that requires MFA when users access the Azure portal from outside named locations.

**Prerequisites:** Entra ID P1 or P2, Global Administrator or Conditional Access Administrator role.

### Steps

**1. Create a Named Location (Corporate IPs)**
1. Sign in to [Entra admin center](https://entra.microsoft.com)
2. Navigate to **Protection > Conditional Access > Named locations**
3. Click **+ IP ranges location**
4. Name: `Corporate Network`
5. Add your corporate IP range (use `1.2.3.4/32` as a test IP if in a lab)
6. Mark as **trusted location**
7. Click **Create**

**2. Create the Conditional Access Policy**
1. Navigate to **Protection > Conditional Access > Policies**
2. Click **+ New policy**
3. Name: `Require MFA for Azure Portal - Outside Corp Network`
4. **Assignments:**
   - Users: Include **All users**; Exclude: Your emergency access account
   - Target resources: Cloud apps → Select **Microsoft Azure Management**
   - Conditions → Locations: Include **Any location**; Exclude: **Corporate Network**
5. **Grant:** Select **Grant access** → Check **Require multifactor authentication**
6. **Enable policy:** Start with **Report-only** to test; switch to **On** when verified
7. Click **Create**

**3. Test the Policy**
1. Use the **What If** tool (Conditional Access → Policies → What If)
2. Simulate sign-in as a test user from outside corporate IP
3. Verify the policy shows as applying and requiring MFA

**Cleanup:** Set policy to `Off` or delete when done with lab.

---

## Lab 2: Set Up Privileged Identity Management (PIM)

**Objective:** Configure PIM to manage the Security Administrator role with eligible assignments and approval workflow.

**Prerequisites:** Entra ID P2, Global Administrator role.

### Steps

**1. Enable PIM**
1. Sign in to [Entra admin center](https://entra.microsoft.com)
2. Navigate to **Identity governance > Privileged Identity Management**
3. Click **Entra ID roles**

**2. Configure Role Settings**
1. Click **Settings** → Find **Security Administrator** role → Click **Edit**
2. Configure:
   - **Maximum activation duration:** 4 hours
   - **On activation, require:** Azure MFA
   - **On activation, require:** Justification
   - **On activation, require:** Approval
3. Add an approver (yourself or a security manager)
4. Click **Update**

**3. Create an Eligible Assignment**
1. Click **Assignments** → **+ Add assignments**
2. Role: **Security Administrator**
3. Select a test user as the assignee
4. Assignment type: **Eligible**
5. Set duration or leave as permanently eligible
6. Click **Assign**

**4. Test Role Activation** (sign in as the test user)
1. Navigate to **PIM > Entra ID roles > My roles**
2. Find **Security Administrator** (eligible)
3. Click **Activate**
4. Enter justification, select duration (max 4 hours)
5. Submit; approval request is sent to the approver

**5. Approve/Deny (as the approver)**
1. Sign in as the approver
2. Navigate to **PIM > Entra ID roles > Approve requests**
3. Approve the request
4. Verify the test user now has the active role

---

## Lab 3: Configure Managed Identity for Azure VM

**Objective:** Enable a system-assigned managed identity on a VM and grant it access to Azure Key Vault.

### Steps

**Setup: Create Resources**
```bash
# Create resource group
az group create --name az500-lab --location eastus

# Create Key Vault
az keyvault create \
  --name az500lab-kv-$RANDOM \
  --resource-group az500-lab \
  --location eastus \
  --enable-rbac-authorization true

# Store a secret
az keyvault secret set \
  --vault-name <your-kv-name> \
  --name "LabSecret" \
  --value "MySecretValue123"

# Create VM (use a small SKU)
az vm create \
  --resource-group az500-lab \
  --name az500-vm \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_B1s
```

**1. Enable System-Assigned Managed Identity**
```bash
az vm identity assign \
  --resource-group az500-lab \
  --name az500-vm

# Get the managed identity object ID
az vm identity show \
  --resource-group az500-lab \
  --name az500-vm \
  --query principalId -o tsv
```

**2. Grant Key Vault Access via RBAC**
```bash
# Get Key Vault resource ID
KV_ID=$(az keyvault show --name <your-kv-name> --resource-group az500-lab --query id -o tsv)

# Get VM managed identity object ID
MI_ID=$(az vm identity show --resource-group az500-lab --name az500-vm --query principalId -o tsv)

# Assign Key Vault Secrets User role to the VM's managed identity
az role assignment create \
  --assignee "$MI_ID" \
  --role "Key Vault Secrets User" \
  --scope "$KV_ID"
```

**3. Test Access from the VM**
```bash
# SSH into the VM
az vm run-command invoke \
  --resource-group az500-lab \
  --name az500-vm \
  --command-id RunShellScript \
  --scripts "
    # Get access token for Key Vault
    TOKEN=\$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net' -H 'Metadata: true' | python3 -c 'import sys,json; print(json.load(sys.stdin)[\"access_token\"])')
    
    # Read secret using the token
    curl -s 'https://<your-kv-name>.vault.azure.net/secrets/LabSecret?api-version=7.4' \
      -H \"Authorization: Bearer \$TOKEN\"
  "
```

**Expected result:** The VM retrieves the secret value using its managed identity — no credentials stored anywhere.

**Cleanup:**
```bash
az group delete --name az500-lab --yes --no-wait
```

---

## Lab 4: Implement Azure RBAC Custom Role

**Objective:** Create a custom RBAC role that allows users to start and stop VMs but not create or delete them.

### Steps

**1. Create the Custom Role Definition**
```bash
# Create custom role JSON file
cat > /tmp/vm-operator-role.json << 'EOF'
{
  "Name": "VM Start/Stop Operator",
  "Description": "Can start, stop, restart, and view VMs but cannot create or delete.",
  "Actions": [
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/powerOff/action",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Resources/deployments/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/<YOUR-SUBSCRIPTION-ID>"
  ]
}
EOF

# Create the role
az role definition create --role-definition /tmp/vm-operator-role.json
```

**2. Assign the Custom Role**
```bash
# Assign to a test user at resource group scope
az role assignment create \
  --assignee "testuser@yourtenant.onmicrosoft.com" \
  --role "VM Start/Stop Operator" \
  --resource-group az500-lab
```

**3. Verify**
```bash
# List custom roles
az role definition list --custom-role-only true --query "[].{Name:roleName, Description:description}"
```

**Cleanup:**
```bash
# Remove role assignment first, then delete role definition
az role assignment delete --assignee "testuser@yourtenant.onmicrosoft.com" --role "VM Start/Stop Operator"
az role definition delete --name "VM Start/Stop Operator"
```

---

## Lab 5: Configure Network Security Groups

**Objective:** Create an NSG with rules to allow web traffic and block all other inbound traffic. Apply to a subnet.

### Steps

```bash
# Create VNet and subnet
az network vnet create \
  --resource-group az500-lab \
  --name az500-vnet \
  --address-prefix 10.0.0.0/16

az network vnet subnet create \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --name web-subnet \
  --address-prefix 10.0.1.0/24

# Create NSG
az network nsg create \
  --resource-group az500-lab \
  --name web-nsg

# Add rules
# Allow HTTPS from Internet
az network nsg rule create \
  --nsg-name web-nsg \
  --resource-group az500-lab \
  --name Allow-HTTPS \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-port-ranges 443 \
  --protocol TCP \
  --access Allow \
  --direction Inbound

# Allow HTTP from Internet
az network nsg rule create \
  --nsg-name web-nsg \
  --resource-group az500-lab \
  --name Allow-HTTP \
  --priority 110 \
  --source-address-prefixes Internet \
  --destination-port-ranges 80 \
  --protocol TCP \
  --access Allow \
  --direction Inbound

# Deny all other inbound (explicit deny before default deny-all)
az network nsg rule create \
  --nsg-name web-nsg \
  --resource-group az500-lab \
  --name Deny-All-Inbound \
  --priority 4000 \
  --source-address-prefixes '*' \
  --destination-port-ranges '*' \
  --protocol '*' \
  --access Deny \
  --direction Inbound

# Associate NSG with subnet
az network vnet subnet update \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --name web-subnet \
  --network-security-group web-nsg

# Verify NSG rules
az network nsg rule list \
  --nsg-name web-nsg \
  --resource-group az500-lab \
  --output table
```

---

## Lab 6: Deploy Azure Firewall

**Objective:** Deploy Azure Firewall in a hub VNet, create an application rule to allow specific FQDNs, and force traffic through it using UDR.

### Steps

```bash
# Create Firewall subnet (must be named AzureFirewallSubnet)
az network vnet subnet create \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --name AzureFirewallSubnet \
  --address-prefix 10.0.2.0/26

# Create public IP for Firewall
az network public-ip create \
  --resource-group az500-lab \
  --name fw-pip \
  --sku Standard \
  --allocation-method Static

# Create Azure Firewall
az network firewall create \
  --resource-group az500-lab \
  --name az500-firewall \
  --location eastus \
  --sku-tier Standard

# Configure Firewall IP configuration
az network firewall ip-config create \
  --firewall-name az500-firewall \
  --resource-group az500-lab \
  --name fw-ipconfig \
  --public-ip-address fw-pip \
  --vnet-name az500-vnet

# Get Firewall private IP
FW_PRIVATE_IP=$(az network firewall show \
  --name az500-firewall \
  --resource-group az500-lab \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

# Create application rule collection (allow specific FQDNs)
az network firewall application-rule create \
  --firewall-name az500-firewall \
  --resource-group az500-lab \
  --collection-name AllowWebBrowsing \
  --priority 200 \
  --action Allow \
  --name AllowWindowsUpdate \
  --source-addresses 10.0.0.0/16 \
  --target-fqdns "*.microsoft.com" "*.windowsupdate.com" \
  --protocols Http=80 Https=443

# Create route table to force traffic through Firewall
az network route-table create \
  --resource-group az500-lab \
  --name fw-route-table

az network route-table route create \
  --resource-group az500-lab \
  --route-table-name fw-route-table \
  --name ToFirewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address "$FW_PRIVATE_IP"

# Associate route table with workload subnet
az network vnet subnet update \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --name web-subnet \
  --route-table fw-route-table

echo "Azure Firewall private IP: $FW_PRIVATE_IP"
```

---

## Lab 7: Configure Azure Bastion

**Objective:** Deploy Azure Bastion for secure browser-based access to a VM without public IP.

### Steps

```bash
# Create AzureBastionSubnet (must be /26 or larger, must be named exactly AzureBastionSubnet)
az network vnet subnet create \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --name AzureBastionSubnet \
  --address-prefix 10.0.3.0/26

# Create public IP for Bastion
az network public-ip create \
  --resource-group az500-lab \
  --name bastion-pip \
  --sku Standard \
  --allocation-method Static \
  --zone 1

# Deploy Azure Bastion
az network bastion create \
  --name az500-bastion \
  --public-ip-address bastion-pip \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --location eastus \
  --sku Basic

# Connect to a VM via Bastion (browser-based)
# In Azure Portal: VM → Connect → Bastion
# Enter username and password; no public IP or NSG changes needed
```

> **Note:** Bastion deployment takes 10–15 minutes.

---

## Lab 8: Set Up Private Endpoint for Storage

**Objective:** Create a Private Endpoint for Azure Blob Storage and configure Private DNS for name resolution.

### Steps

```bash
# Create storage account
STORAGE_NAME="az500storage$RANDOM"
az storage account create \
  --name $STORAGE_NAME \
  --resource-group az500-lab \
  --location eastus \
  --sku Standard_LRS \
  --https-only true \
  --min-tls-version TLS1_2

# Disable public access
az storage account update \
  --name $STORAGE_NAME \
  --resource-group az500-lab \
  --public-network-access Disabled

# Get storage account resource ID
STORAGE_ID=$(az storage account show \
  --name $STORAGE_NAME \
  --resource-group az500-lab \
  --query id -o tsv)

# Disable private endpoint network policy on subnet (required)
az network vnet subnet update \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --name web-subnet \
  --disable-private-endpoint-network-policies true

# Create private endpoint
az network private-endpoint create \
  --name storage-private-endpoint \
  --resource-group az500-lab \
  --vnet-name az500-vnet \
  --subnet web-subnet \
  --private-connection-resource-id "$STORAGE_ID" \
  --group-id blob \
  --connection-name StorageBlobConnection

# Create Private DNS Zone
az network private-dns zone create \
  --resource-group az500-lab \
  --name "privatelink.blob.core.windows.net"

# Link DNS Zone to VNet
az network private-dns link vnet create \
  --resource-group az500-lab \
  --zone-name "privatelink.blob.core.windows.net" \
  --name StorageDnsLink \
  --virtual-network az500-vnet \
  --registration-enabled false

# Get private endpoint NIC IP and create DNS record
PE_NIC=$(az network private-endpoint show \
  --name storage-private-endpoint \
  --resource-group az500-lab \
  --query "networkInterfaces[0].id" -o tsv)

PE_IP=$(az network nic show --ids "$PE_NIC" \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

# Create A record in private DNS zone
az network private-dns record-set a create \
  --resource-group az500-lab \
  --zone-name "privatelink.blob.core.windows.net" \
  --name "$STORAGE_NAME"

az network private-dns record-set a add-record \
  --resource-group az500-lab \
  --zone-name "privatelink.blob.core.windows.net" \
  --record-set-name "$STORAGE_NAME" \
  --ipv4-address "$PE_IP"

echo "Private endpoint IP: $PE_IP"
echo "Storage FQDN: ${STORAGE_NAME}.blob.core.windows.net"
```

---

## Lab 9: Enable WAF on Application Gateway

**Objective:** Deploy Application Gateway with WAF in Prevention mode and test blocking of SQL injection.

### Steps

```bash
# Create WAF policy
az network application-gateway waf-policy create \
  --name az500-waf-policy \
  --resource-group az500-lab \
  --location eastus

# Configure WAF to Prevention mode
az network application-gateway waf-policy policy-setting update \
  --policy-name az500-waf-policy \
  --resource-group az500-lab \
  --mode Prevention \
  --state Enabled \
  --max-request-body-size-kb 128 \
  --request-body-check true

# View managed rule sets available
az network application-gateway waf-policy managed-rule rule-set list \
  --resource-group az500-lab \
  --policy-name az500-waf-policy

# Test WAF (requires Application Gateway deployed — simplified test)
# Send a request with SQL injection in query string:
# curl "https://<app-gw-ip>/?id=1%20OR%201=1--"
# Expected result: 403 Forbidden (blocked by WAF)
```

---

## Lab 10: Configure Azure Key Vault with RBAC

**Objective:** Create a Key Vault using RBAC authorization, store secrets, and control access with least privilege.

### Steps

```bash
# Create Key Vault with RBAC and purge protection
KV_NAME="az500kv-$RANDOM"
az keyvault create \
  --name $KV_NAME \
  --resource-group az500-lab \
  --location eastus \
  --enable-rbac-authorization true \
  --enable-purge-protection true \
  --retention-days 90 \
  --sku standard

KV_ID=$(az keyvault show --name $KV_NAME --resource-group az500-lab --query id -o tsv)

# Assign yourself as Key Vault Administrator
MY_UPN=$(az ad signed-in-user show --query userPrincipalName -o tsv)
az role assignment create \
  --assignee "$MY_UPN" \
  --role "Key Vault Administrator" \
  --scope "$KV_ID"

# Store secrets
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "AppConnectionString" \
  --value "Server=myserver.database.windows.net;Database=myapp;"

az keyvault secret set \
  --vault-name $KV_NAME \
  --name "ApiKey" \
  --value "super-secret-api-key-value"

# Assign a developer read-only access (Secrets User)
DEV_USER="developer@yourtenant.onmicrosoft.com"
az role assignment create \
  --assignee "$DEV_USER" \
  --role "Key Vault Secrets User" \
  --scope "$KV_ID"

# Verify: Developer can read but not create/delete secrets
az keyvault secret list --vault-name $KV_NAME --query "[].name"

# Enable diagnostics logging
az monitor diagnostic-settings create \
  --resource "$KV_ID" \
  --name "KVAuditLogs" \
  --logs '[{"category":"AuditEvent","enabled":true}]'
```

---

## Lab 11: Enable Azure Disk Encryption

**Objective:** Enable ADE on a VM using a Key Vault to store the encryption key.

### Steps

```bash
# Create Key Vault for ADE (NOTE: ADE requires access policies, not RBAC mode)
ADE_KV_NAME="az500ade-kv-$RANDOM"
az keyvault create \
  --name $ADE_KV_NAME \
  --resource-group az500-lab \
  --location eastus \
  --enabled-for-disk-encryption true \
  --enable-purge-protection true

# Enable ADE on the VM (Linux example)
az vm encryption enable \
  --resource-group az500-lab \
  --name az500-vm \
  --disk-encryption-keyvault $ADE_KV_NAME \
  --volume-type All

# Check encryption status
az vm encryption show \
  --resource-group az500-lab \
  --name az500-vm

# Verify disks are encrypted
az vm show \
  --resource-group az500-lab \
  --name az500-vm \
  --query "storageProfile.osDisk.encryptionSettings"
```

---

## Lab 12: Secure Azure SQL Database

**Objective:** Configure Azure SQL with Entra ID authentication, TDE with CMK, and auditing.

### Steps

```bash
# Create SQL Server
SQL_SERVER="az500sql-$RANDOM"
SQL_ADMIN="sqladmin"
az sql server create \
  --name $SQL_SERVER \
  --resource-group az500-lab \
  --location eastus \
  --admin-user $SQL_ADMIN \
  --admin-password "AZ500@Lab#2025!"

# Create database
az sql db create \
  --resource-group az500-lab \
  --server $SQL_SERVER \
  --name LabDB \
  --service-objective S0

# Set Entra ID admin
az sql server ad-admin create \
  --server-name $SQL_SERVER \
  --resource-group az500-lab \
  --display-name "SQLAdmins" \
  --object-id "$(az ad group show --group 'SQLAdmins' --query id -o tsv)"

# Enable TDE (enabled by default, but verify)
az sql db tde show \
  --resource-group az500-lab \
  --server $SQL_SERVER \
  --database LabDB

# Enable Advanced Threat Protection (Defender for SQL)
az sql server advanced-threat-protection-setting update \
  --resource-group az500-lab \
  --server $SQL_SERVER \
  --state Enabled

# Enable SQL Auditing to Log Analytics
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group az500-lab \
  --workspace-name az500-workspace \
  --query id -o tsv)

az sql server audit-policy update \
  --resource-group az500-lab \
  --name $SQL_SERVER \
  --state Enabled \
  --log-analytics-target-state Enabled \
  --log-analytics-workspace-resource-id "$WORKSPACE_ID"

# Restrict firewall to Azure services only
az sql server firewall-rule create \
  --resource-group az500-lab \
  --server $SQL_SERVER \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

---

## Lab 13: Configure Just-In-Time (JIT) VM Access

**Objective:** Enable JIT VM access via Defender for Cloud to reduce attack surface on management ports.

### Steps

**Via Azure Portal:**
1. Open **Microsoft Defender for Cloud**
2. Navigate to **Workload protections > Just-in-time VM access**
3. Under **Not configured** tab, find your VM
4. Click **Enable JIT on 1 VM**
5. Configure port rules:
   - Port: 3389 (RDP); Protocol: TCP; Allowed source IPs: My IP; Max request time: 3 hours
   - Port: 22 (SSH); Protocol: TCP; Allowed source IPs: My IP; Max request time: 3 hours
6. Click **Save**

**Via Azure CLI:**
```bash
# Configure JIT policy
az security jit-policy create \
  --kind Basic \
  --location eastus \
  --name default \
  --resource-group az500-lab \
  --virtual-machines '[
    {
      "id": "/subscriptions/<sub-id>/resourceGroups/az500-lab/providers/Microsoft.Compute/virtualMachines/az500-vm",
      "ports": [
        {
          "number": 22,
          "protocol": "TCP",
          "allowedSourceAddressPrefix": "MyIP",
          "maxRequestAccessDuration": "PT3H"
        },
        {
          "number": 3389,
          "protocol": "TCP",
          "allowedSourceAddressPrefix": "MyIP",
          "maxRequestAccessDuration": "PT3H"
        }
      ]
    }
  ]'

# Request JIT access
az security jit-policy initiate \
  --resource-group az500-lab \
  --vm-name az500-vm \
  --ports '[{"number":22,"endTimeUtc":"2025-04-01T12:00:00.000Z","allowedSourceAddressPrefix":"<your-ip>"}]'
```

**Verify:** Check the NSG rules — a temporary Allow rule should appear and auto-remove after the requested duration.

---

## Lab 14: Set Up Microsoft Sentinel

**Objective:** Create a Log Analytics workspace, enable Sentinel, and connect key data sources.

### Steps

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group az500-lab \
  --workspace-name az500-sentinel-workspace \
  --location eastus \
  --sku PerGB2018 \
  --retention-time 90

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group az500-lab \
  --workspace-name az500-sentinel-workspace \
  --query id -o tsv)

# Enable Microsoft Sentinel on the workspace
az sentinel onboarding-state create \
  --resource-group az500-lab \
  --workspace-name az500-sentinel-workspace \
  --name default
```

**Connect Data Sources (via Azure Portal):**
1. Open **Microsoft Sentinel** in Azure Portal
2. Select your workspace → **Data connectors**
3. Enable these connectors:
   - **Azure Activity** (subscription operations)
   - **Microsoft Entra ID** (sign-in + audit logs)
   - **Microsoft Defender for Cloud** (security alerts)
   - **Azure Key Vault** (key vault audit events)

**Verify Data Ingestion:**
```kql
// Run in Sentinel Logs (wait 10-15 minutes after enabling connectors)
union AzureActivity, SigninLogs, SecurityAlert
| summarize count() by Type
| order by count_ desc
```

---

## Lab 15: Create Sentinel Analytics Rule & Playbook

**Objective:** Create a scheduled analytics rule that detects failed sign-ins and a playbook that sends an email alert.

### Steps

**1. Create Analytics Rule:**
1. In Sentinel → **Analytics** → **+ Create** → **Scheduled query rule**
2. **General:**
   - Name: `Multiple Failed Sign-ins Detected`
   - Severity: Medium
   - MITRE ATT&CK tactics: Credential Access
3. **Rule query:**
```kql
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != 0
| summarize FailedAttempts = count() by UserPrincipalName, IPAddress, bin(TimeGenerated, 1h)
| where FailedAttempts >= 10
| extend AccountCustomEntity = UserPrincipalName
| extend IPCustomEntity = IPAddress
```
4. **Alert enhancement:** Map `AccountCustomEntity` → Account; `IPCustomEntity` → IP
5. **Query scheduling:** Run every 1 hour; look up data from last 1 hour
6. **Incident settings:** Enable incident creation; group alerts into single incident by `UserPrincipalName`
7. Click **Review + create**

**2. Create a Playbook (Logic App):**
1. Sentinel → **Automation** → **Playbooks** → **+ Create playbook**
2. Choose: **Incident trigger**
3. Name: `Email-Alert-On-Failed-Signins`
4. In Logic App Designer, add steps:
   - Trigger: **When a Microsoft Sentinel incident is created**
   - Action: **Office 365 Outlook – Send an email**
   - To: `soc-team@yourcompany.com`
   - Subject: `[Sentinel Alert] Multiple Failed Sign-ins: @{triggerBody()?['object']?['properties']?['title']}`
   - Body: `Severity: @{triggerBody()?['object']?['properties']?['severity']} \n Incident: @{triggerBody()?['object']?['properties']?['incidentNumber']}`
5. Save the Logic App

**3. Link Playbook to Analytics Rule:**
1. Edit the analytics rule → **Automated response** tab
2. Add the playbook as a response action
3. Save

---

## Lab 16: Configure Azure Monitor Alerts

**Objective:** Create an Activity Log alert to notify when any Key Vault is deleted in the subscription.

### Steps

```bash
# Create action group with email notification
az monitor action-group create \
  --resource-group az500-lab \
  --name SecurityAlerts \
  --short-name SecAlerts \
  --action email security-team security@yourcompany.com

# Get action group resource ID
AG_ID=$(az monitor action-group show \
  --resource-group az500-lab \
  --name SecurityAlerts \
  --query id -o tsv)

# Create Activity Log alert for Key Vault deletion
az monitor activity-log alert create \
  --resource-group az500-lab \
  --name AlertOnKeyVaultDelete \
  --description "Alert when any Key Vault is deleted" \
  --scope "/subscriptions/$(az account show --query id -o tsv)" \
  --condition category=Administrative operationName=Microsoft.KeyVault/vaults/delete \
  --action-group "$AG_ID"
```

**Verify via Portal:**
1. Open **Azure Monitor** → **Alerts** → **Alert rules**
2. Find `AlertOnKeyVaultDelete`
3. Click **Condition** to verify it's monitoring the correct operation

**Test:**
```bash
# Create and delete a test Key Vault to trigger the alert
TEST_KV="az500test-kv-$RANDOM"
az keyvault create --name $TEST_KV --resource-group az500-lab --location eastus
az keyvault delete --name $TEST_KV --resource-group az500-lab
# You should receive an email alert within 5 minutes
```

---

## Lab Cleanup

After completing all labs, delete the resource group to avoid ongoing charges:

```bash
az group delete --name az500-lab --yes --no-wait
echo "Resource group deletion initiated. All lab resources will be removed."
```

---

← [Back to README](../README.md)
