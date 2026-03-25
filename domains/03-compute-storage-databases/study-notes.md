# Domain 3 — Study Notes: Secure Compute, Storage, and Databases

> Deep-dive reference notes for exam preparation

---

## Azure Key Vault — Advanced Topics

### Key Vault Certificates — Lifecycle
```
Certificate Lifecycle:
  Create (self-signed or with CA) →
    Active (used by apps) →
      Near Expiry (auto-renewal triggered) →
        Renewed (new version created) →
          Old version soft-deleted (if policy set)
```

### Certificate Issuance with Integrated CA
```
Key Vault → Request Certificate → DigiCert/GlobalSign CA
CA validates domain ownership →
CA issues certificate →
Key Vault stores certificate + private key
App references Key Vault certificate (auto-renewed)
```

### Key Vault References in App Service / Functions
App settings can reference Key Vault secrets directly:
```
AppSetting: MY_CONNECTION_STRING
Value: @Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/mySecret/version)
```
or (always latest version):
```
Value: @Microsoft.KeyVault(VaultName=myvault;SecretName=mySecret)
```
Requires: Managed Identity with `Key Vault Secrets User` role.

### Key Vault Monitoring
```
Diagnostic Settings → Enable:
  - AuditEvent (all data plane operations)
  - AllMetrics (availability, latency)

Send to: Log Analytics Workspace

KQL Query for failed access attempts:
AzureDiagnostics
| where ResourceType == "VAULTS"
| where ResultType == "Unauthorized"
| project TimeGenerated, CallerIPAddress, id_s, requestUri_s
```

---

## Azure Disk Encryption — Deep Dive

### ADE vs. SSE Comparison
| Feature | ADE | SSE |
|---------|-----|-----|
| Encryption location | Within OS (BitLocker/dm-crypt) | Storage layer |
| Key storage | Azure Key Vault (BEK/KEK) | Azure Key Vault (CMK) or Microsoft |
| Requires agent | Yes (VM extension) | No |
| Protects from storage admin | Yes | Partial |
| Protects from Azure admin | No (Azure admin can access VM) | No |
| Encrypts temp disk | Yes (with special flag) | No |

### ADE Setup (Windows VM)
```powershell
# Set up Key Vault for disk encryption
$keyVaultName = "myKeyVault"
$resourceGroup = "myRG"
$location = "eastus"

Set-AzKeyVaultAccessPolicy `
  -VaultName $keyVaultName `
  -ResourceGroupName $resourceGroup `
  -EnabledForDiskEncryption

# Optional: Create Key Encryption Key (KEK)
$kek = Add-AzKeyVaultKey `
  -VaultName $keyVaultName `
  -Name "myKEK" `
  -Destination Software

# Enable encryption
Set-AzVMDiskEncryptionExtension `
  -ResourceGroupName $resourceGroup `
  -VMName "myVM" `
  -DiskEncryptionKeyVaultUrl "https://$keyVaultName.vault.azure.net/" `
  -DiskEncryptionKeyVaultId "/subscriptions/.../resourceGroups/$resourceGroup/providers/Microsoft.KeyVault/vaults/$keyVaultName" `
  -KeyEncryptionKeyUrl $kek.Key.Kid `
  -KeyEncryptionKeyVaultId "/subscriptions/.../resourceGroups/$resourceGroup/providers/Microsoft.KeyVault/vaults/$keyVaultName" `
  -VolumeType All
```

---

## Just-in-Time VM Access — Deep Dive

### JIT Requirements
- Microsoft Defender for Servers enabled (Plan 1 or Plan 2)
- VM must have a public IP or be reachable via Azure Bastion

### JIT NSG Rule Format
When JIT access is requested:
```
NSG Rule Added Automatically:
  Priority: 100 (or next available)
  Name: SecurityCenter-JIT-{RequestID}
  Source: {Requester's IP address}
  Destination: {VM IP}
  Port: {Requested port, e.g., 3389}
  Protocol: TCP
  Action: Allow
  Expiry: {Current time + duration, e.g., 3 hours}
```

After expiry, rule is automatically deleted.

### JIT via Azure CLI
```bash
# Request JIT access
az security jit-policy create \
  --location eastus \
  --name my-jit-policy \
  --resource-group myRG \
  --vm myVM \
  --ports "3389" "22"

# Initiate JIT request (PowerShell)
Start-AzJitNetworkAccessPolicy `
  -ResourceGroupName myRG `
  -Location eastus `
  -Name default `
  -VirtualMachineRequest @(
    @{
      id = "/subscriptions/.../virtualMachines/myVM"
      ports = @(
        @{ number = 3389; endTimeUtc = (Get-Date).AddHours(3); allowedSourceAddressPrefix = "203.0.113.1" }
      )
    }
  )
```

---

## Container Security — Deep Dive

### AKS Security Hardening Checklist
```
✅ Enable Microsoft Entra ID integration
✅ Enable Azure RBAC for Kubernetes authorization
✅ Use private cluster (private API server)
✅ Enable authorized IP ranges (if public)
✅ Disable local accounts (--disable-local-accounts)
✅ Enable network policies (Calico)
✅ Integrate with ACR using Managed Identity
✅ Enable Microsoft Defender for Containers
✅ Enable Azure Policy for AKS
✅ Use workload identity (not pod identity)
✅ Keep node image versions updated
✅ Use system node pool for system pods
✅ Enable audit logging
```

### Kubernetes RBAC + Azure RBAC Integration
```
AKS with Azure RBAC enabled:
  Azure Role: "Azure Kubernetes Service RBAC Admin"
  → Maps to cluster-admin ClusterRole in Kubernetes

  Azure Role: "Azure Kubernetes Service RBAC Cluster Admin"
  → Full cluster admin

  Azure Role: "Azure Kubernetes Service RBAC Reader"
  → Read-only access to cluster resources

  Custom: Use Azure Role with specific Kubernetes RBAC permissions
```

### Network Policies in AKS
```yaml
# Example: Restrict access to database pods to only app-tier pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-allow-app-only
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: app
    ports:
    - protocol: TCP
      port: 5432
```

### Key Vault CSI Driver for AKS
```yaml
# Mount Key Vault secrets as files or environment variables in pods
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-workload-identity
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: "<managed-identity-client-id>"
    keyvaultName: "<key-vault-name>"
    cloudName: ""
    objects: |
      array:
        - |
          objectName: mySecret
          objectType: secret
          objectVersion: ""
    tenantId: "<tenant-id>"
```

---

## Storage Security — Deep Dive

### Storage Access Tiers (Security Context)
| Tier | Access Frequency | Encryption |
|------|-----------------|-----------|
| Hot | Frequent | SSE (always on) |
| Cool | Infrequent | SSE (always on) |
| Archive | Rare (rehydrate needed) | SSE (always on) |

### Shared Access Signature (SAS) Best Practices
```
✅ Use User Delegation SAS (backed by Entra ID)
✅ Set shortest possible expiry time
✅ Restrict to specific IP addresses when possible
✅ Use HTTPS only (no HTTP)
✅ Grant minimum required permissions
✅ Store SAS generation code; never hardcode SAS URIs
✅ Rotate storage account keys if Account SAS was compromised
```

### Cross-Origin Resource Sharing (CORS)
- Configure allowed origins, methods, and headers for browser-based access
- Principle of least privilege: Only allow necessary origins

### Azure Storage Defender Alerts
| Alert | Description |
|-------|-------------|
| Access from Tor exit node | Suspicious anonymous access |
| Unusual number of failed auth attempts | Brute force |
| Unusual data access from application | Potential credential theft |
| Malware uploaded | Suspicious file in blob container |
| Data exfiltration | Unusual large data download |

---

## SQL Security — Deep Dive

### SQL Server-Level vs. Database-Level Controls
```
Server Level:
  - Logins (SQL Auth or Entra ID)
  - Server-level firewall rules
  - TDE (applies to all databases)
  - Auditing (server-level covers all DBs)
  - Entra ID administrator

Database Level:
  - Users (mapped to server logins or contained users)
  - Database-level firewall rules (override server rules per DB)
  - Dynamic data masking (per column)
  - Row-level security (per table)
  - Always Encrypted (per column)
```

### SQL Auditing to Log Analytics
```bash
# Enable SQL auditing via CLI
az sql server audit-policy update \
  --resource-group myRG \
  --name mySqlServer \
  --state Enabled \
  --log-analytics-target-state Enabled \
  --log-analytics-workspace-resource-id /subscriptions/.../workspaces/myWorkspace
```

### Vulnerability Assessment
- Part of Microsoft Defender for SQL
- Scans for misconfigurations, excessive permissions, unpatched vulnerabilities
- Baseline: Record acceptable findings; alerts on deviations
- Runs on schedule or on-demand

---

## Defender for Cloud Secure Score

### Secure Score Calculation
```
Secure Score = (Points achieved / Max points) × 100%

Each recommendation has:
  - Max points (e.g., 8 points)
  - Points lost if unhealthy resources exist

Points achieved for recommendation =
  Max points × (Healthy resources / Total resources)
```

### Improving Secure Score
Priority recommendations for Domain 3:
1. Enable disk encryption on VMs
2. Remediate vulnerabilities in VM images
3. Enable auditing on SQL servers
4. Enable TDE on SQL databases
5. Enable Defender for Key Vault
6. Enable Defender for Storage
7. Restrict public blob access on Storage accounts

---

## Azure Container Instances (ACI) Security

- Serverless container execution (no cluster management)
- Security considerations:
  - Use **Managed Identity** for authentication
  - Inject secrets via **environment variables** or **volume mounts** (Key Vault)
  - Use **private VNet** deployment to avoid public exposure
  - Enable **container group diagnostics** for logging

---

## Key Configuration Commands

### Key Vault
```bash
# Create Key Vault with RBAC authorization
az keyvault create \
  --name myKeyVault \
  --resource-group myRG \
  --location eastus \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --soft-delete-retention-days 90 \
  --enable-purge-protection true

# Enable diagnostic logging
az monitor diagnostic-settings create \
  --name kv-diagnostics \
  --resource /subscriptions/.../vaults/myKeyVault \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --workspace /subscriptions/.../workspaces/myWorkspace
```

### SQL Security
```bash
# Enable Microsoft Entra admin
az sql server ad-admin create \
  --resource-group myRG \
  --server mySqlServer \
  --display-name "DBA Group" \
  --object-id <AAD-group-object-id>

# Enable TDE with CMK
az sql server tde-key set \
  --resource-group myRG \
  --server mySqlServer \
  --server-key-type AzureKeyVault \
  --kid https://myvault.vault.azure.net/keys/myKey/version
```

---

[← Back to Domain Overview](README.md) | [Practice Questions →](../../practice-questions/domain3-compute-storage.md)
