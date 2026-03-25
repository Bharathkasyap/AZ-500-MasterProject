# AZ-500 Hands-On Labs

> **Back to:** [README](../README.md)

> These labs use the Azure portal, Azure CLI, and PowerShell. Each lab includes prerequisites, step-by-step instructions, and verification steps. Most can be completed in a free Azure trial account.

---

## Lab Index

| Lab | Domain | Estimated Time |
|-----|--------|---------------|
| [Lab 01 — Configure Conditional Access and MFA](#lab-01--configure-conditional-access-and-mfa) | Identity | 30 min |
| [Lab 02 — Enable and Use Privileged Identity Management](#lab-02--enable-and-use-privileged-identity-management) | Identity | 30 min |
| [Lab 03 — Configure Network Security Groups and ASGs](#lab-03--configure-network-security-groups-and-asgs) | Networking | 45 min |
| [Lab 04 — Deploy Azure Firewall and Force-Tunnel Internet Traffic](#lab-04--deploy-azure-firewall-and-force-tunnel-internet-traffic) | Networking | 60 min |
| [Lab 05 — Configure Private Endpoints and Private DNS](#lab-05--configure-private-endpoints-and-private-dns) | Networking | 45 min |
| [Lab 06 — Configure JIT VM Access and Azure Bastion](#lab-06--configure-jit-vm-access-and-azure-bastion) | Networking / Compute | 30 min |
| [Lab 07 — Azure Key Vault: RBAC, Secrets, and Soft Delete](#lab-07--azure-key-vault-rbac-secrets-and-soft-delete) | Compute/Storage | 45 min |
| [Lab 08 — Secure Azure Storage with Private Endpoint and SAS](#lab-08--secure-azure-storage-with-private-endpoint-and-sas) | Storage | 45 min |
| [Lab 09 — Enable Microsoft Defender for Cloud](#lab-09--enable-microsoft-defender-for-cloud) | Security Ops | 30 min |
| [Lab 10 — Configure Microsoft Sentinel](#lab-10--configure-microsoft-sentinel) | Security Ops | 60 min |

---

## Lab 01 — Configure Conditional Access and MFA

**Domain:** Identity and Access  
**Prerequisites:** Entra ID P1 or P2 license, Global Administrator or Conditional Access Administrator role

### Objective
Create a Conditional Access policy that requires MFA for all users accessing the Azure portal, with an exclusion for a break-glass account.

### Steps

**Step 1: Create a break-glass account**
1. Go to Azure portal → **Microsoft Entra ID** → **Users** → **New user**
2. Name: `break-glass-admin`, assign **Global Administrator** role
3. Exclude this account from all Conditional Access policies

**Step 2: Create the Conditional Access policy**
```
Azure Portal → Microsoft Entra ID → Security → Conditional Access → New policy
```
- **Name:** `Require MFA for Azure Portal`
- **Users:** All users (exclude break-glass account and service accounts)
- **Cloud apps:** Select `Microsoft Azure Management`
- **Conditions:** None (applies to all sign-ins to Azure portal)
- **Grant:** Require multi-factor authentication
- **Enable policy:** Report-only (first), then On

**Step 3: Test the policy**
1. Open a new InPrivate/incognito browser window
2. Navigate to https://portal.azure.com
3. Sign in with a test user account
4. Verify: MFA challenge is presented

**Step 4: Review the sign-in log**
```
Microsoft Entra ID → Monitoring → Sign-in logs
```
Filter by the test user and verify: Conditional access = "Success" and MFA requirement met.

### Verification
- Sign-in logs show CA policy "Require MFA for Azure Portal" applied
- MFA was challenged and completed
- Break-glass account can still access portal without MFA requirement

---

## Lab 02 — Enable and Use Privileged Identity Management

**Domain:** Identity and Access  
**Prerequisites:** Entra ID P2 license, Global Administrator role

### Objective
Configure PIM to make the Security Administrator role eligible (not permanent), require MFA and justification on activation.

### Steps

**Step 1: Enable PIM**
```
Azure Portal → Microsoft Entra ID → Identity Governance → Privileged Identity Management
```
Click **Consent to PIM** (first-time setup).

**Step 2: Configure the Security Administrator role**
1. In PIM → **Entra ID roles** → **Roles** → Search for "Security Administrator"
2. Click **Settings** → Edit:
   - Activation maximum duration: **4 hours**
   - Require MFA on activation: **Yes**
   - Require justification: **Yes**
   - Require approval: Optional (configure an approver if desired)
3. Save settings

**Step 3: Create an eligible assignment**
1. PIM → **Entra ID roles** → **Assignments** → **Add assignments**
2. Role: Security Administrator
3. Member: Select a test user
4. Assignment type: **Eligible**
5. Duration: **Permanent** (or set an end date)

**Step 4: Activate the role as the test user**
1. Sign in as the test user
2. Navigate to PIM → **My roles** → **Entra ID roles**
3. Find Security Administrator → Click **Activate**
4. Enter justification, complete MFA
5. Role is now active for up to 4 hours

**Step 5: Review the audit history**
```
PIM → Entra ID roles → Audit history
```
Verify the activation event is recorded.

### Verification
- Role is eligible (not permanently assigned) before activation
- MFA was required during activation
- Audit log shows activation with justification
- Role expires after the configured duration

---

## Lab 03 — Configure Network Security Groups and ASGs

**Domain:** Secure Networking  
**Prerequisites:** Contributor access to a resource group, an existing VNet

### Objective
Create ASGs for a three-tier application (web, app, DB) and configure NSG rules using ASGs.

### Steps (Azure CLI)

**Step 1: Create Application Security Groups**
```bash
# Variables
RG="lab-nsg-rg"
LOCATION="eastus"

az group create --name $RG --location $LOCATION

# Create ASGs
az network asg create --name WebASG --resource-group $RG --location $LOCATION
az network asg create --name AppASG --resource-group $RG --location $LOCATION
az network asg create --name DbASG  --resource-group $RG --location $LOCATION
```

**Step 2: Create NSG with rules**
```bash
az network nsg create --name AppNSG --resource-group $RG --location $LOCATION

# Allow HTTPS from internet to Web tier
az network nsg rule create \
  --nsg-name AppNSG --resource-group $RG \
  --name Allow-HTTPS-To-Web \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-asgs WebASG \
  --destination-port-ranges 443 \
  --protocol Tcp --access Allow --direction Inbound

# Allow app traffic from Web to App tier
az network nsg rule create \
  --nsg-name AppNSG --resource-group $RG \
  --name Allow-Web-To-App \
  --priority 110 \
  --source-asgs WebASG \
  --destination-asgs AppASG \
  --destination-port-ranges 8080 \
  --protocol Tcp --access Allow --direction Inbound

# Allow SQL from App to DB tier
az network nsg rule create \
  --nsg-name AppNSG --resource-group $RG \
  --name Allow-App-To-DB \
  --priority 120 \
  --source-asgs AppASG \
  --destination-asgs DbASG \
  --destination-port-ranges 1433 \
  --protocol Tcp --access Allow --direction Inbound

# Deny all other inbound
az network nsg rule create \
  --nsg-name AppNSG --resource-group $RG \
  --name Deny-All-Inbound \
  --priority 4000 \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*' \
  --protocol '*' --access Deny --direction Inbound
```

**Step 3: Associate NSG with subnet**
```bash
az network vnet subnet update \
  --vnet-name YourVNet \
  --name YourSubnet \
  --resource-group $RG \
  --network-security-group AppNSG
```

**Step 4: Verify with IP Flow Verify**
```
Azure Portal → Network Watcher → IP flow verify
```
Test: Source VM (Web tier) → Destination (App tier port 8080) → Expected: Allowed

### Verification
- Web tier VMs can reach App tier on port 8080
- App tier VMs can reach DB tier on port 1433
- Web tier VMs CANNOT directly reach DB tier (verify with IP Flow Verify)

---

## Lab 04 — Deploy Azure Firewall and Force-Tunnel Internet Traffic

**Domain:** Secure Networking  
**Prerequisites:** Contributor, dedicated resource group, at least a /22 address space available

### Objective
Deploy Azure Firewall, configure an application rule to allow only specific FQDNs, and use a UDR to route all internet traffic through the firewall.

### Steps (Azure CLI)

```bash
RG="lab-firewall-rg"
LOCATION="eastus"
VNET_PREFIX="10.0.0.0/16"
FW_SUBNET="10.0.1.0/26"
WORKLOAD_SUBNET="10.0.2.0/24"

az group create -n $RG -l $LOCATION

# Create VNet with required subnets
az network vnet create -n HubVNet -g $RG -l $LOCATION \
  --address-prefix $VNET_PREFIX \
  --subnet-name AzureFirewallSubnet --subnet-prefix $FW_SUBNET

az network vnet subnet create -n WorkloadSubnet -g $RG \
  --vnet-name HubVNet --address-prefix $WORKLOAD_SUBNET

# Create public IP for firewall
az network public-ip create -n FW-PIP -g $RG -l $LOCATION \
  --allocation-method Static --sku Standard

# Deploy Azure Firewall
az network firewall create -n AzureFirewall -g $RG -l $LOCATION \
  --sku-name AZFW_VNet --sku-tier Standard

az network firewall ip-config create \
  --firewall-name AzureFirewall -g $RG \
  --name FW-Config \
  --public-ip-address FW-PIP \
  --vnet-name HubVNet

# Get firewall private IP
FW_PRIVATE_IP=$(az network firewall show -n AzureFirewall -g $RG \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

# Create application rule to allow only microsoft.com
az network firewall application-rule create \
  --firewall-name AzureFirewall -g $RG \
  --collection-name AllowedSites --priority 100 --action Allow \
  --name AllowMicrosoft \
  --source-addresses $WORKLOAD_SUBNET \
  --target-fqdns "*.microsoft.com" "*.azure.com" \
  --protocols https=443

# Create route table to force internet traffic through firewall
az network route-table create -n WorkloadRT -g $RG -l $LOCATION

az network route-table route create \
  -n RouteToFirewall \
  --route-table-name WorkloadRT -g $RG \
  --next-hop-type VirtualAppliance \
  --address-prefix 0.0.0.0/0 \
  --next-hop-ip-address $FW_PRIVATE_IP

# Associate route table with workload subnet
az network vnet subnet update \
  --vnet-name HubVNet -n WorkloadSubnet -g $RG \
  --route-table WorkloadRT
```

### Verification
From a VM in WorkloadSubnet:
- `curl https://www.microsoft.com` → Should succeed (allowed by firewall rule)
- `curl https://www.google.com` → Should fail (not in allowed FQDNs)
- Check Azure Firewall logs in Azure Monitor for allowed/denied traffic

---

## Lab 05 — Configure Private Endpoints and Private DNS

**Domain:** Secure Networking  
**Prerequisites:** Contributor access, existing VNet, Azure Storage account

### Objective
Disable public access to a Storage account and configure a Private Endpoint with Private DNS zone.

### Steps (Azure CLI)

```bash
RG="lab-pe-rg"
STORAGE_ACCOUNT="mystoragelabrandom"  # must be globally unique
VNET_NAME="MyVNet"
SUBNET_NAME="PrivateEndpointSubnet"

# Disable public network access on storage account
az storage account update \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG \
  --public-network-access Disabled

# Create private endpoint
az network private-endpoint create \
  --name MyStoragePE \
  --resource-group $RG \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --private-connection-resource-id \
    $(az storage account show --name $STORAGE_ACCOUNT -g $RG --query id -o tsv) \
  --group-id blob \
  --connection-name MyStorageConnection \
  --location eastus

# Create Private DNS Zone
az network private-dns zone create \
  --resource-group $RG \
  --name "privatelink.blob.core.windows.net"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group $RG \
  --zone-name "privatelink.blob.core.windows.net" \
  --name MyVNetDNSLink \
  --virtual-network $VNET_NAME \
  --registration-enabled false

# Create DNS record from private endpoint NIC
PE_NIC=$(az network private-endpoint show \
  --name MyStoragePE -g $RG \
  --query "networkInterfaces[0].id" -o tsv)

PE_IP=$(az network nic show --ids $PE_NIC \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

az network private-dns record-set a create \
  --resource-group $RG \
  --zone-name "privatelink.blob.core.windows.net" \
  --name $STORAGE_ACCOUNT

az network private-dns record-set a add-record \
  --resource-group $RG \
  --zone-name "privatelink.blob.core.windows.net" \
  --record-set-name $STORAGE_ACCOUNT \
  --ipv4-address $PE_IP
```

### Verification
From a VM inside the VNet:
```bash
# Should resolve to private IP (10.x.x.x), not public IP (52.x.x.x)
nslookup mystoragelabrandom.blob.core.windows.net

# Should work (access via private IP)
az storage blob list --account-name $STORAGE_ACCOUNT --container-name mycontainer --auth-mode login
```

From outside the VNet:
```bash
# Should fail (public access disabled)
az storage blob list --account-name $STORAGE_ACCOUNT --container-name mycontainer --auth-mode login
# Error: Public network access is disabled
```

---

## Lab 06 — Configure JIT VM Access and Azure Bastion

**Domain:** Networking / Compute  
**Prerequisites:** Defender for Servers Plan 1+ enabled, VM without public IP

### Objective
Enable JIT VM Access on a VM to control when RDP/SSH can be initiated, and deploy Azure Bastion for browser-based access.

### Steps

**Part A: Enable JIT VM Access**
1. Navigate to: **Defender for Cloud** → **Workload protections** → **Just-in-time VM access**
2. Go to **Not Configured** tab → Find your VM → Click **Enable JIT on VM**
3. Configure ports:
   - Port: **22** (SSH) or **3389** (RDP)
   - Protocol: TCP
   - Allowed source IPs: My IP
   - Max request time: 3 hours
4. Click **Save**

**Request JIT access:**
1. **Defender for Cloud** → **Just-in-time VM access** → **Configured** tab
2. Select VM → **Request access**
3. Enter your IP, select port, set time duration (1–3 hours)
4. Click **Open ports**
5. Verify: NSG on the VM's NIC now has a temporary inbound rule for your IP on port 22/3389

**Part B: Deploy Azure Bastion**
```bash
RG="lab-bastion-rg"
VNET_NAME="MyVNet"

# Create AzureBastionSubnet (MUST be named exactly this, minimum /26)
az network vnet subnet create \
  --name AzureBastionSubnet \
  --resource-group $RG \
  --vnet-name $VNET_NAME \
  --address-prefix 10.0.10.0/26

# Create public IP for Bastion
az network public-ip create \
  --name BastionPIP \
  --resource-group $RG \
  --allocation-method Static \
  --sku Standard

# Deploy Bastion (Basic SKU)
az network bastion create \
  --name MyBastion \
  --resource-group $RG \
  --vnet-name $VNET_NAME \
  --public-ip-address BastionPIP \
  --location eastus \
  --sku Basic
```

**Connect via Bastion:**
1. Navigate to the VM in the Azure portal
2. Click **Connect** → **Bastion**
3. Enter username and password (or SSH key)
4. Browser-based RDP/SSH session opens — no public IP on VM required

### Verification
- VM has no public IP assigned
- JIT: Before requesting access, port 3389/22 is blocked in NSG; after requesting, temporary rule appears
- Bastion: Can connect to VM via browser without opening any ports on the VM's NSG

---

## Lab 07 — Azure Key Vault: RBAC, Secrets, and Soft Delete

**Domain:** Compute, Storage, Databases  
**Prerequisites:** Contributor access to a resource group

### Objective
Create a Key Vault with Azure RBAC permission model, store a secret, configure soft delete and purge protection, and verify deletion recovery.

### Steps (Azure CLI)

```bash
RG="lab-kv-rg"
LOCATION="eastus"
KV_NAME="mykeyvaultlab$(date +%s)"  # unique name

az group create -n $RG -l $LOCATION

# Create Key Vault with RBAC authorization model and soft delete
az keyvault create \
  --name $KV_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --soft-delete-retention-days 30 \
  --enable-purge-protection true

# Assign Key Vault Secrets Officer role to yourself
MY_ID=$(az ad signed-in-user show --query id -o tsv)

az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee $MY_ID \
  --scope $(az keyvault show --name $KV_NAME -g $RG --query id -o tsv)

# Create a secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "DatabasePassword" \
  --value "P@ssw0rd!SecureLab"

# Retrieve the secret
az keyvault secret show \
  --vault-name $KV_NAME \
  --name "DatabasePassword" \
  --query "value" -o tsv

# Delete the secret (soft delete — goes to deleted state, not permanently removed)
az keyvault secret delete \
  --vault-name $KV_NAME \
  --name "DatabasePassword"

# List deleted secrets
az keyvault secret list-deleted --vault-name $KV_NAME

# Recover the deleted secret
az keyvault secret recover \
  --vault-name $KV_NAME \
  --name "DatabasePassword"

# Verify recovery
az keyvault secret show \
  --vault-name $KV_NAME \
  --name "DatabasePassword" \
  --query "value" -o tsv
```

### Verification
- Key Vault uses RBAC (not access policies)
- Secret can be stored and retrieved
- Deleted secret appears in `list-deleted` output
- Deleted secret can be recovered via `secret recover`
- Purge protection: attempt to purge should fail (protected)
  ```bash
  az keyvault secret purge --vault-name $KV_NAME --name "DatabasePassword"
  # Error: Purge operation is not allowed — purge protection is enabled
  ```

---

## Lab 08 — Secure Azure Storage with Private Endpoint and SAS

**Domain:** Storage  
**Prerequisites:** Storage account, VNet with empty subnet

### Objective
Generate a User Delegation SAS token and demonstrate the security difference between account key SAS and user delegation SAS.

### Steps (Azure CLI)

```bash
STORAGE_ACCOUNT="mystoragesaslab"
RG="lab-storage-rg"
CONTAINER="secure-data"

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG \
  --location eastus \
  --sku Standard_LRS \
  --allow-blob-public-access false

# Create container
az storage container create \
  --name $CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

# Upload a test file
echo "Sensitive financial data" > /tmp/testfile.txt
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER \
  --name testfile.txt \
  --file /tmp/testfile.txt \
  --auth-mode login

# Generate a User Delegation SAS (signed with Entra ID credentials — most secure)
# NOTE: --as-user flag uses the currently signed-in Entra ID identity (not the account key)
EXPIRY=$(date -u -d "1 hour" '+%Y-%m-%dT%H:%MZ')

USER_DELEGATION_SAS=$(az storage blob generate-sas \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER \
  --name testfile.txt \
  --permissions r \
  --expiry $EXPIRY \
  --https-only \
  --as-user \
  --auth-mode login \
  --output tsv)

echo "User Delegation SAS token: $USER_DELEGATION_SAS"

# Test the SAS URL
BLOB_URL="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER}/testfile.txt?${USER_DELEGATION_SAS}"
curl "$BLOB_URL"

# Demonstrate HTTPS enforcement — attempt HTTP (should fail)
HTTP_URL="http://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER}/testfile.txt?${USER_DELEGATION_SAS}"
curl "$HTTP_URL"
# Error: HTTPS required
```

### Verification
- HTTPS SAS URL returns file content
- HTTP SAS URL is rejected (HTTPS-only enforcement)
- SAS expires after 1 hour (try after expiry — access denied)
- Storage account: anonymous public access is disabled

---

## Lab 09 — Enable Microsoft Defender for Cloud

**Domain:** Security Operations  
**Prerequisites:** Security Admin or Subscription Owner

### Objective
Enable Defender for Cloud, review the Secure Score, and remediate at least one high-severity recommendation.

### Steps

**Step 1: Enable Defender for Cloud**
1. Azure Portal → **Microsoft Defender for Cloud**
2. Review the **Overview** dashboard (Secure Score, Active recommendations, Alerts)
3. Navigate to **Environment Settings** → Select your subscription
4. Enable **Defender CSPM** (enhanced posture management)
5. Enable **Defender for Servers** Plan 1

**Step 2: Review Secure Score**
1. Defender for Cloud → **Secure score**
2. Click on a security control (e.g., "Enable MFA") to see contributing recommendations
3. Note the current score and maximum achievable score

**Step 3: Remediate a recommendation**
```
Defender for Cloud → Recommendations
→ Filter by: Severity = High
→ Select: "Storage accounts should restrict network access"
→ Review affected resources
→ Click "Quick Fix" or follow manual remediation steps
```

**Step 4: Configure Continuous Export**
```
Defender for Cloud → Environment Settings → [Subscription] → Continuous export
→ Export to: Log Analytics workspace
→ Select: Security recommendations, Security alerts
→ Save
```

**Step 5: Review the Regulatory Compliance dashboard**
```
Defender for Cloud → Regulatory compliance
→ Review: Microsoft Cloud Security Benchmark
→ Identify failing controls and their associated recommendations
```

### Verification
- Defender for Cloud shows a Secure Score
- At least one recommendation has been remediated
- Continuous export is configured
- Regulatory compliance dashboard shows benchmark coverage

---

## Lab 10 — Configure Microsoft Sentinel

**Domain:** Security Operations  
**Prerequisites:** Sentinel Contributor role, Log Analytics workspace

### Objective
Enable Sentinel, connect the Azure Activity data connector, create a scheduled analytics rule, and simulate an incident.

### Steps

**Step 1: Enable Sentinel**
1. Azure Portal → **Microsoft Sentinel** → **Create**
2. Select or create a Log Analytics workspace
3. Click **Add Microsoft Sentinel**

**Step 2: Connect data sources**
```
Sentinel → Configuration → Data connectors
→ Search: "Azure Activity"
→ Open connector page → Configure
→ "Connect" (links the subscription's Activity Log to Sentinel)
```
Wait 5–10 minutes for data to flow.

**Step 3: Verify data is flowing**
```
Sentinel → General → Logs
```
Run KQL query:
```kql
AzureActivity
| where TimeGenerated > ago(1h)
| summarize count() by OperationNameValue
| top 10 by count_
```

**Step 4: Create a scheduled analytics rule**
```
Sentinel → Configuration → Analytics → Create → Scheduled query rule
```
- **Name:** `Detect Multiple Resource Deletions`
- **Severity:** Medium
- **Query:**
```kql
AzureActivity
| where OperationNameValue endswith "delete"
| where ActivityStatusValue == "Success"
| summarize DeleteCount = count() by Caller, bin(TimeGenerated, 10m)
| where DeleteCount >= 3
```
- **Run query every:** 5 minutes
- **Lookup data in the last:** 10 minutes
- **Alert threshold:** Greater than 0

**Step 5: Simulate activity to trigger the rule**
```bash
# Delete a few test resources quickly to trigger the rule
az group create -n test-delete-1 -l eastus
az group create -n test-delete-2 -l eastus
az group create -n test-delete-3 -l eastus

az group delete -n test-delete-1 --yes --no-wait
az group delete -n test-delete-2 --yes --no-wait
az group delete -n test-delete-3 --yes --no-wait
```

**Step 6: Review the generated incident**
```
Sentinel → Threat management → Incidents
```
Find the incident generated by your analytics rule.
- Assign the incident to yourself
- Use the Investigation graph to explore related entities
- Close the incident with classification: "True Positive - Suspicious Activity"

### Verification
- AzureActivity table has data from the connector
- Analytics rule runs on schedule
- Incident is generated after the simulated deletions
- Investigation graph shows the caller, resources, and timeline

---

## Clean Up

After completing the labs, delete the resource groups to avoid ongoing costs:

```bash
# Delete all lab resource groups
for rg in lab-nsg-rg lab-firewall-rg lab-pe-rg lab-bastion-rg lab-kv-rg lab-storage-rg; do
  az group delete --name $rg --yes --no-wait
done
```

---

> **Back to:** [README](../README.md) | **Also see:** [Practice Questions →](practice-questions.md) | [Cheat Sheet →](cheat-sheet.md)
