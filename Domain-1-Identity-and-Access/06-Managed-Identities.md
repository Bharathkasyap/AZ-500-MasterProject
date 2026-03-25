# Managed Identities

## 📌 What are Managed Identities?

**Managed Identities** provide Azure services with an automatically managed identity in Microsoft Entra ID. Applications can use managed identities to authenticate to any service that supports Entra ID authentication — **without storing any credentials in code or configuration**.

> 💡 **Key Benefit**: Eliminates the need to manage service principal credentials (client secrets or certificates). Azure manages the identity lifecycle automatically.

---

## 🔄 Types of Managed Identities

### System-Assigned Managed Identity

| Characteristic | Details |
|----------------|---------|
| **Lifecycle** | Tied to the Azure resource — deleted when resource is deleted |
| **Sharing** | Cannot be shared across resources (1:1 with resource) |
| **Management** | Enabled directly on the Azure resource |
| **Use case** | Single-resource workloads, simplest option |

```bash
# Enable system-assigned managed identity on a VM
az vm identity assign \
  --resource-group MyRG \
  --name MyVM

# Enable on creation
az vm create \
  --resource-group MyRG \
  --name MyVM \
  --image Ubuntu2204 \
  --assign-identity
```

### User-Assigned Managed Identity

| Characteristic | Details |
|----------------|---------|
| **Lifecycle** | Independent — must be explicitly deleted |
| **Sharing** | Can be shared across multiple resources |
| **Management** | Created as a standalone Azure resource |
| **Use case** | Multiple resources needing same identity, pre-provisioned identity |

```bash
# Create a user-assigned managed identity
az identity create \
  --resource-group MyRG \
  --name MyManagedIdentity

# Assign to a VM
az vm identity assign \
  --resource-group MyRG \
  --name MyVM \
  --identities /subscriptions/{sub-id}/resourcegroups/MyRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyManagedIdentity
```

---

## 📊 System-Assigned vs User-Assigned Comparison

| Feature | System-Assigned | User-Assigned |
|---------|-----------------|---------------|
| **Creation** | On the resource itself | Separate resource |
| **Lifecycle** | Deleted with resource | Independent lifecycle |
| **Sharing** | One resource only | Multiple resources |
| **Role assignments** | On the identity (tied to resource) | On the identity (portable) |
| **Best for** | Single workload | Shared identities, pre-provisioning |

---

## 🔐 How Authentication Works

When an Azure resource (e.g., VM, App Service) needs to authenticate:

1. Application requests a token from the **Azure Instance Metadata Service (IMDS)** endpoint: `http://169.254.169.254/metadata/identity/oauth2/token`
2. Azure returns an **access token** signed by Entra ID
3. Application uses the token to call Azure services (Key Vault, Storage, SQL, etc.)

```python
# Example: Python application using managed identity to get a Key Vault secret
from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient

credential = ManagedIdentityCredential()
client = SecretClient(vault_url="https://mykeyvault.vault.azure.net/", credential=credential)
secret = client.get_secret("MySecret")
print(secret.value)
```

```csharp
// C# example
var credential = new ManagedIdentityCredential();
var client = new SecretClient(new Uri("https://mykeyvault.vault.azure.net/"), credential);
var secret = await client.GetSecretAsync("MySecret");
```

---

## ✅ Azure Services That Support Managed Identities

**Can have a managed identity (sources):**
- Azure Virtual Machines
- Azure App Service / Azure Functions
- Azure Kubernetes Service (AKS) — via workload identity
- Azure Logic Apps
- Azure Container Instances
- Azure API Management
- Azure Data Factory
- Azure Spring Apps

**Accept managed identity tokens (targets):**
- Azure Key Vault
- Azure Storage
- Azure SQL Database
- Azure Service Bus
- Azure Event Hubs
- Azure Resource Manager
- Any service supporting Entra ID authentication

---

## 🔑 Granting Permissions to Managed Identities

Managed identities need RBAC roles to access Azure resources:

```bash
# Get the managed identity's object/principal ID
IDENTITY_ID=$(az vm identity show --resource-group MyRG --name MyVM --query principalId -o tsv)

# Grant Key Vault Secrets User role
az role assignment create \
  --assignee $IDENTITY_ID \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/{sub-id}/resourceGroups/MyRG/providers/Microsoft.KeyVault/vaults/MyKeyVault"

# Grant Storage Blob Data Reader role
az role assignment create \
  --assignee $IDENTITY_ID \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/{sub-id}/resourceGroups/MyRG/providers/Microsoft.Storage/storageAccounts/MyStorage"
```

---

## 🔐 Managed Identity vs Service Principal

| Feature | Managed Identity | Service Principal |
|---------|-----------------|-------------------|
| **Credential management** | Azure manages automatically | Developer manages (rotate secrets/certs) |
| **Credential exposure risk** | None | Secret/certificate can be leaked |
| **Works with** | Azure services only | Any Entra ID-registered app |
| **Cost** | Free | Free (but credential management has overhead) |
| **Recommended for** | Azure-to-Azure authentication | External apps, CI/CD, cross-cloud |

---

## 🛡️ Security Best Practices

1. **Use managed identities** instead of service principals for Azure-to-Azure communication
2. **Prefer system-assigned** for single-resource workloads (simpler lifecycle)
3. **Prefer user-assigned** when multiple resources need the same permissions
4. **Apply least privilege** — grant only the minimum RBAC roles needed
5. **Never use the VM's managed identity for administrator-level access** without audit controls
6. **Monitor usage** — Review managed identity role assignments periodically

---

## ❓ Practice Questions

1. An Azure function app needs to read secrets from Azure Key Vault without storing any credentials in configuration. What is the recommended approach?
   - A) Store the Key Vault access key in application settings
   - B) Create a service principal and store client secret in Key Vault
   - **C) Enable a system-assigned managed identity and grant it Key Vault Secrets User role** ✅
   - D) Use a connection string with the vault access key

2. You need multiple Azure App Service instances to share the same identity for accessing Azure Storage. Which type of managed identity should you use?
   - A) System-assigned managed identity
   - **B) User-assigned managed identity** ✅
   - C) Service principal with certificate
   - D) Service principal with client secret

3. What happens to a system-assigned managed identity when its associated VM is deleted?
   - A) It continues to exist as an orphaned identity
   - B) It is moved to a different resource
   - **C) It is automatically deleted** ✅
   - D) It must be manually deleted

4. How does an application running on an Azure VM obtain an access token using a managed identity?
   - A) By calling the Azure Active Directory OAuth endpoint
   - B) By reading a stored certificate from the VM disk
   - **C) By requesting a token from the Azure Instance Metadata Service (IMDS)** ✅
   - D) By using a connection string from environment variables

---

## 📚 References

- [Managed Identities Documentation](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview)
- [Managed Identity Best Practices](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/managed-identity-best-practice-recommendations)
- [IMDS Token Endpoint](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token)
