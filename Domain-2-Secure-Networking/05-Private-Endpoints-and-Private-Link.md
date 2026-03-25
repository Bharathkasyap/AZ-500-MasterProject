# Private Endpoints and Private Link

## 📌 What is Azure Private Link?

**Azure Private Link** provides private connectivity from a VNet to Azure PaaS services (like Storage, Key Vault, SQL) or customer-owned services — **over the Microsoft backbone network, without traversing the public internet**.

Two components:
1. **Private Endpoint** — A private IP in your VNet that maps to an Azure service
2. **Private Link Service** — Expose your own service to other VNets/customers via Private Link

---

## 🔑 Private Endpoint

A **Private Endpoint** is a network interface that:
- Gets a **private IP address** from your VNet's address space
- Connects to a specific Azure PaaS service or Private Link service
- Routes traffic to the service privately (not over public internet)

### Supported Services (examples)

| Service | Resource Type |
|---------|--------------|
| Azure Storage (Blob, File, Queue, Table) | `Microsoft.Storage/storageAccounts` |
| Azure Key Vault | `Microsoft.KeyVault/vaults` |
| Azure SQL Database | `Microsoft.Sql/servers` |
| Azure Cosmos DB | `Microsoft.DocumentDB/databaseAccounts` |
| Azure Service Bus | `Microsoft.ServiceBus/namespaces` |
| Azure Event Hub | `Microsoft.EventHub/namespaces` |
| Azure App Service (Web Apps) | `Microsoft.Web/sites` |
| Azure Kubernetes Service | `Microsoft.ContainerService/managedClusters` |
| Azure Container Registry | `Microsoft.ContainerRegistry/registries` |

---

## ⚙️ Creating a Private Endpoint

```bash
# Get the resource ID of the service to connect to
STORAGE_ID=$(az storage account show \
  --resource-group MyRG \
  --name mystorageaccount \
  --query id -o tsv)

# Create the private endpoint
az network private-endpoint create \
  --resource-group MyRG \
  --name MyPrivateEndpoint \
  --vnet-name MyVNet \
  --subnet PrivateEndpointSubnet \
  --private-connection-resource-id $STORAGE_ID \
  --group-id blob \
  --connection-name MyStorageConnection

# Disable network policies on the subnet first (required for private endpoints)
az network vnet subnet update \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --name PrivateEndpointSubnet \
  --disable-private-endpoint-network-policies true
```

---

## 🔗 DNS Configuration (Critical!)

When a private endpoint is created, the public DNS name of the service (e.g., `mystorageaccount.blob.core.windows.net`) must resolve to the **private IP** instead of the public IP.

### DNS Resolution Methods

#### 1. Azure Private DNS Zone (Recommended)

```bash
# Create private DNS zone for blob storage
az network private-dns zone create \
  --resource-group MyRG \
  --name "privatelink.blob.core.windows.net"

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group MyRG \
  --zone-name "privatelink.blob.core.windows.net" \
  --name MyDNSLink \
  --virtual-network MyVNet \
  --registration-enabled false

# Create DNS record for the private endpoint
az network private-endpoint dns-zone-group create \
  --resource-group MyRG \
  --endpoint-name MyPrivateEndpoint \
  --name MyZoneGroup \
  --private-dns-zone "privatelink.blob.core.windows.net" \
  --zone-name blob
```

#### 2. Custom DNS Server (for hybrid environments)
- On-premises DNS server forwards `privatelink.*` zones to Azure DNS (168.63.129.16)
- Configure conditional forwarders for each private DNS zone

### Private DNS Zone Names by Service

| Service | Private DNS Zone |
|---------|-----------------|
| Blob Storage | `privatelink.blob.core.windows.net` |
| File Storage | `privatelink.file.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| Azure SQL | `privatelink.database.windows.net` |
| Cosmos DB | `privatelink.documents.azure.com` |
| Service Bus | `privatelink.servicebus.windows.net` |
| Container Registry | `privatelink.azurecr.io` |

---

## 🔒 Disabling Public Access

After creating a private endpoint, **disable public access** to the service:

```bash
# Disable public access to Storage Account
az storage account update \
  --resource-group MyRG \
  --name mystorageaccount \
  --public-network-access Disabled

# Or restrict to specific VNets only (if you need public + private)
az storage account network-rule add \
  --resource-group MyRG \
  --account-name mystorageaccount \
  --vnet-name MyVNet \
  --subnet PrivateEndpointSubnet
```

---

## 🏗️ Private Link Service (Expose Your Own Service)

**Private Link Service** allows you to expose your own service (behind an Azure Standard Load Balancer) to other VNets or customers:

```
Your VNet:
  Service VMs → Standard Load Balancer → Private Link Service

Customer's VNet:
  Private Endpoint → Private Link Service (approved connection)
```

Use cases:
- SaaS providers exposing services to customers
- Cross-subscription/cross-tenant private connectivity
- Custom services without public internet exposure

---

## 📊 Private Endpoint vs Service Endpoint

| Feature | Private Endpoint | Service Endpoint |
|---------|-----------------|-----------------|
| **Private IP** | Yes (VNet IP) | No (still uses public IP of service) |
| **Route** | Microsoft backbone (private IP) | Microsoft backbone (but service's public IP) |
| **On-prem access** | Yes (via VPN/ExpressRoute) | No |
| **Disables public access** | When combined with firewall rule | No |
| **DNS** | Requires private DNS zone | No DNS change needed |
| **Cost** | Charged per endpoint | Free |
| **Recommendation** | Preferred for security-sensitive workloads | Legacy — use Private Endpoint instead |

---

## ❓ Practice Questions

1. A VM in a VNet needs to access Azure Key Vault without traffic leaving the Azure network. After creating a private endpoint, the VM cannot resolve the Key Vault's hostname. What is missing?
   - A) A route in the route table
   - B) NSG rules to allow port 443
   - **C) A private DNS zone for `privatelink.vaultcore.azure.net` linked to the VNet** ✅
   - D) A VPN gateway

2. You need to access an Azure Storage account from on-premises over ExpressRoute without using public endpoints. Which feature enables this?
   - **A) Private Endpoint with private DNS zone, accessible from on-premises via ExpressRoute** ✅
   - B) Service Endpoint with VNet rules
   - C) VNet peering
   - D) Azure Firewall application rules

3. After creating a private endpoint for an Azure SQL database, you want to prevent any access via the public internet. What should you do?
   - **A) Set the SQL server's public network access to "Disabled"** ✅
   - B) Create an NSG rule blocking inbound internet traffic
   - C) Delete the public IP address of the SQL server
   - D) Private endpoints automatically disable public access

4. What must be disabled on the subnet before creating a private endpoint?
   - A) Service endpoints
   - **B) Private endpoint network policies** ✅
   - C) NSG rules
   - D) Route table associations

---

## 📚 References

- [Private Link Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview)
- [Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Private DNS Zone Integration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- [Private Link Service](https://learn.microsoft.com/en-us/azure/private-link/private-link-service-overview)
