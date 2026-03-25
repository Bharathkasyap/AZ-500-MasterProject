# Domain 2 — Study Notes: Secure Networking

> Deep-dive reference notes for exam preparation

---

## User-Defined Routes (UDR)

Azure uses system routes by default. UDRs override system routes to control traffic flow.

### Route Table
```
Route Table: RouteToFirewall
  Address Prefix: 0.0.0.0/0
  Next Hop Type:  Virtual Appliance
  Next Hop IP:    10.0.0.4  (Azure Firewall private IP)

Associate with: app-tier subnet, data-tier subnet
```

### Next Hop Types
| Type | Description |
|------|-------------|
| **Virtual network** | Stay within VNet |
| **Internet** | Route via internet gateway |
| **Virtual appliance** | Route to a specific IP (NVA or Azure Firewall) |
| **Virtual network gateway** | Route to VPN/ER gateway |
| **None** | Drop the traffic (blackhole) |

### Common Patterns
- **Force all subnet traffic through Azure Firewall**: Route 0.0.0.0/0 → Virtual Appliance (Firewall IP)
- **Disable BGP route propagation**: Prevent VPN gateway from advertising routes to subnet

---

## Azure Firewall — Deep Dive

### FQDN Filtering
Azure Firewall can filter traffic based on FQDNs (domain names):

**Application rule example:**
```
Rule Collection: AllowWindowsUpdate
  Rule: WindowsUpdate
    Source: 10.0.0.0/16
    Protocol/Port: HTTPS:443
    Target FQDN: *.update.microsoft.com
                 *.windowsupdate.com
```

### DNS Proxy
- Azure Firewall can act as DNS proxy for VNet clients
- Enables FQDN filtering in Network rules
- Required for Private DNS Zone resolution through Firewall

### IDPS (Azure Firewall Premium)
- Intrusion Detection and Prevention System
- **Alert mode**: Log but allow suspicious traffic
- **Alert and Deny mode**: Log and block suspicious traffic
- Based on signatures for known threats
- 50,000+ signatures, updated continuously

### TLS Inspection (Azure Firewall Premium)
- Decrypt HTTPS traffic for deep inspection
- Re-encrypt before forwarding
- Requires an **intermediate CA certificate** in Key Vault
- Managed identity for Firewall to access Key Vault

### Firewall Manager
- Centrally manage Azure Firewalls across multiple VNets/subscriptions
- Manage Firewall Policies (parent/child hierarchy)
- Integration with Virtual WAN hubs
- DDoS Protection plans

---

## Virtual WAN (vWAN)

- **Hub-spoke** network architecture managed by Microsoft
- Central hub with automatic routing
- Integrates VPN Gateway, ExpressRoute, Azure Firewall
- Two SKUs: **Basic** (VPN only) and **Standard** (all services)
- Use case: Large-scale, multi-region hub-spoke networks

---

## Network Virtual Appliance (NVA)

- Third-party firewall/router deployed as a VM in Azure
- Vendors: Palo Alto, Fortinet, Check Point, Cisco
- More features than Azure Firewall (e.g., advanced IPS, SSL decryption)
- More management overhead; use when advanced features required
- Requires UDR to route traffic through NVA

---

## Azure Application Gateway

### Components
- **Frontend**: Public or private IP, listeners
- **Routing rules**: Path-based or host-based routing
- **Backend pools**: VMs, VMSS, App Service, IPs/FQDNs
- **HTTP settings**: Protocol, port, cookie affinity, connection draining
- **Health probes**: Custom or default

### Features
| Feature | Description |
|---------|-------------|
| **SSL/TLS offload** | Terminate SSL at gateway; backend uses HTTP |
| **End-to-end SSL** | Re-encrypt traffic to backend |
| **SSL policy** | Minimum TLS version, cipher suites |
| **WAF** | OWASP rule sets + custom rules |
| **URL-based routing** | /images/* → image servers |
| **Multi-site hosting** | Multiple sites on same gateway |
| **Autoscaling** | Scale v2 based on traffic |
| **Zone redundancy** | v2 supports availability zones |

### Application Gateway SKUs
- **Standard v1**: Legacy; manual scaling
- **Standard v2**: Autoscaling, zone-redundant, header rewrite
- **WAF v1**: v1 + WAF
- **WAF v2**: v2 + WAF (recommended)

---

## Azure Load Balancer

Layer-4 load balancer (TCP/UDP).

### SKU Comparison
| Feature | Basic | Standard |
|---------|-------|----------|
| Backend pool | VMSS or availability set | Any VM, VMSS, IPs |
| Zone redundant | ❌ | ✅ |
| Outbound rules | ❌ | ✅ |
| HTTPS health probes | ❌ | ✅ |
| Diagnostics | ❌ | ✅ |
| SLA | None | 99.99% |

> **Security exam note:** Standard SKU requires **Standard Public IPs** which are **secure by default** (all inbound blocked; NSG required to allow traffic).

---

## NSG Flow Logs — Advanced

### Configuring Flow Logs
```powershell
# Enable NSG flow logs (PowerShell)
Set-AzNetworkWatcherFlowLog `
  -NetworkWatcherName NetworkWatcher_eastus `
  -ResourceGroupName NetworkWatcherRG `
  -TargetResourceId /subscriptions/.../resourceGroups/.../NSG-Name `
  -StorageAccountId /subscriptions/.../storageAccounts/storageName `
  -Enabled $true `
  -RetentionPolicyEnabled $true `
  -RetentionPolicyDays 30
```

### Log Record Format (Version 2)
```json
{
  "time": "2024-01-15T12:00:00Z",
  "systemId": "...",
  "macAddress": "...",
  "category": "NetworkSecurityGroupFlowEvent",
  "resultType": "FlowLogsFlowEvent",
  "operationName": "NetworkSecurityGroupFlowEvents",
  "properties": {
    "Version": 2,
    "flows": [{
      "rule": "DefaultRule_AllowInternetOutBound",
      "flows": [{
        "mac": "...",
        "flowTuples": ["timestamp,srcIP,dstIP,srcPort,dstPort,protocol,direction,action,state,packetsFromSrc,bytesFromSrc,packetsFromDst,bytesFromDst"]
      }]
    }]
  }
}
```

---

## Private DNS Zones

### DNS Integration with Private Endpoints
When you create a private endpoint, Azure creates a DNS A record:

| Service | Private DNS Zone | FQDN |
|---------|-----------------|------|
| Azure Blob Storage | `privatelink.blob.core.windows.net` | `storageaccount.privatelink.blob.core.windows.net` |
| Azure Key Vault | `privatelink.vaultcore.azure.net` | `keyvaultname.privatelink.vaultcore.azure.net` |
| Azure SQL Database | `privatelink.database.windows.net` | `server.privatelink.database.windows.net` |
| Azure Container Registry | `privatelink.azurecr.io` | `registry.privatelink.azurecr.io` |
| Azure Service Bus | `privatelink.servicebus.windows.net` | `namespace.privatelink.servicebus.windows.net` |

### Hub-Spoke DNS Architecture
```
Hub VNet:
  └── Private DNS Resolver (inbound/outbound endpoints)
      └── Linked to all Private DNS Zones

Spoke VNets:
  └── DNS points to Hub's Private DNS Resolver
      → Queries forwarded to hub → resolves private endpoints
```

---

## Hybrid Networking — Security Considerations

### VPN Best Practices
- Use **IKEv2** (over IKEv1)
- Use **route-based VPN** (over policy-based)
- Enable **BGP** for dynamic routing
- Use **strong pre-shared key** or **Azure certificate authentication**
- Enable **Azure VPN Gateway active-active** for HA

### ExpressRoute Security
- ExpressRoute itself is a private connection (no internet exposure)
- For encryption: Use **MACsec** (Layer 2) or **IPsec over ExpressRoute** (Layer 3)
- Use **ExpressRoute Circuit Authorization** to control which VNets can connect

---

## Network Security Practice Scenarios

### Scenario 1: Secure Multi-tier Application
**Requirements:** Web tier exposed to internet; app tier only accessible from web tier; database tier only from app tier; no direct internet to backend.

```
Architecture:
  NSG-WebTier:
    Inbound: Allow 443 from Internet
    Inbound: Allow 80 from Internet (redirect to 443 via App Gateway)
    Outbound: Allow 8080 to AppTier

  NSG-AppTier:
    Inbound: Allow 8080 from WebTier-ASG only
    Outbound: Allow 1433 to DbTier

  NSG-DbTier:
    Inbound: Allow 1433 from AppTier-ASG only
    Inbound: Deny everything else

  Route Table (AppTier, DbTier):
    0.0.0.0/0 → Azure Firewall (for outbound internet egress control)
```

### Scenario 2: Secure Storage Access
**Requirements:** Application VMs must access Azure Storage without going over internet; storage must not be publicly accessible.

```
Solution: Private Endpoint

1. Create Private Endpoint for Storage Account in App Subnet
2. Configure Private DNS Zone: privatelink.blob.core.windows.net
3. Link DNS zone to App VNet
4. Disable public network access on Storage Account
5. VM resolves storage.blob.core.windows.net → private IP
```

### Scenario 3: Centralized Outbound Filtering
**Requirements:** All outbound internet traffic must go through Azure Firewall for logging and URL filtering.

```
1. Deploy Azure Firewall in hub VNet (AzureFirewallSubnet)
2. Create Route Table: 0.0.0.0/0 → Azure Firewall (virtual appliance)
3. Associate route table with all spoke subnets
4. Configure Application Rules (FQDN-based allow list)
5. Enable Firewall Diagnostics → Log Analytics
6. Alert on suspicious traffic in Log Analytics
```

---

## Key CLI/PowerShell Commands for Networking

```bash
# Create NSG
az network nsg create --name my-nsg --resource-group myRG --location eastus

# Add NSG rule
az network nsg rule create \
  --nsg-name my-nsg \
  --resource-group myRG \
  --name AllowHTTPS \
  --priority 100 \
  --source-address-prefixes '*' \
  --destination-port-ranges 443 \
  --protocol Tcp \
  --access Allow \
  --direction Inbound

# Associate NSG with subnet
az network vnet subnet update \
  --vnet-name my-vnet \
  --resource-group myRG \
  --name web-subnet \
  --network-security-group my-nsg

# Create Private Endpoint
az network private-endpoint create \
  --name myPrivateEndpoint \
  --resource-group myRG \
  --vnet-name my-vnet \
  --subnet app-subnet \
  --private-connection-resource-id <resource-id> \
  --connection-name myConnection \
  --group-id blob
```

---

[← Back to Domain Overview](README.md) | [Practice Questions →](../../practice-questions/domain2-networking.md)
