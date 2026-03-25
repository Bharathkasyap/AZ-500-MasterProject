# Azure Bastion

## 📌 What is Azure Bastion?

**Azure Bastion** is a fully managed PaaS service that provides secure, seamless RDP and SSH access to Azure VMs directly through the **Azure portal over TLS** — without exposing VMs to the public internet.

### Key Benefits
- **No public IP** needed on VMs
- **No inbound NSG rules** for RDP (3389) or SSH (22) on VMs
- **No jump servers** or bastion host VMs to manage
- **Browser-based access** via Azure portal (HTML5)
- **Session recordings** (Premium SKU)
- **Audit logs** via Azure Monitor

---

## 🏢 Azure Bastion SKUs

| Feature | Developer | Basic | Standard | Premium |
|---------|-----------|-------|----------|---------|
| **RDP/SSH over portal** | ✅ | ✅ | ✅ | ✅ |
| **Native client support** | ❌ | ❌ | ✅ | ✅ |
| **IP-based connection** | ❌ | ❌ | ✅ | ✅ |
| **Shareable links** | ❌ | ❌ | ✅ | ✅ |
| **Session recording** | ❌ | ❌ | ❌ | ✅ |
| **Private-only deployment** | ❌ | ❌ | ❌ | ✅ |
| **File upload/download** | ❌ | ❌ | ✅ | ✅ |
| **Scale units** | 1 (fixed) | 2 (fixed) | 2–50 | 2–50 |
| **Cost** | Free (preview) | Lower | Medium | Higher |

> ⚠️ **Exam Note**: **Standard SKU** (or Premium) is required for native client support, IP-based connection, and file transfer. Most exam scenarios involving advanced features require Standard.

---

## 🏗️ Deployment Architecture

```
Internet (HTTPS port 443)
        ↓
AzureBastionSubnet (/26 minimum)
  └── Azure Bastion Host
        ↓
Private IP connectivity within VNet
  ├── VM-1 (no public IP)
  ├── VM-2 (no public IP)
  └── VM-3 (no public IP)
```

### Required Components

1. **AzureBastionSubnet** — Must be named exactly `AzureBastionSubnet`
   - Minimum size: **/26** (64 addresses)
   - No other resources should be deployed to this subnet
2. **Public IP** on the Bastion host (Standard SKU public IP, static)
3. **NSG on AzureBastionSubnet** — Specific rules required

---

## 🔒 NSG Rules for AzureBastionSubnet

### Required Inbound Rules

| Priority | Source | Source Port | Destination | Dest Port | Protocol | Action |
|----------|--------|-------------|-------------|-----------|----------|--------|
| 100 | Internet | * | * | 443 | TCP | **Allow** |
| 110 | GatewayManager | * | * | 443 | TCP | **Allow** |
| 120 | AzureLoadBalancer | * | * | 443 | TCP | **Allow** |
| 130 | VirtualNetwork | * | * | 8080, 5701 | TCP | **Allow** |

### Required Outbound Rules

| Priority | Source | Source Port | Destination | Dest Port | Protocol | Action |
|----------|--------|-------------|-------------|-----------|----------|--------|
| 100 | * | * | VirtualNetwork | 3389, 22 | TCP | **Allow** |
| 110 | * | * | AzureCloud | 443 | TCP | **Allow** |
| 120 | * | * | Internet | 80 | TCP | **Allow** |
| 130 | * | * | VirtualNetwork | 8080, 5701 | TCP | **Allow** |

> 💡 **Tip**: Block inbound RDP (3389) and SSH (22) from Internet on VM subnets when using Bastion.

---

## ⚙️ Deploying Azure Bastion

```bash
# Create the subnet (already in VNet)
az network vnet subnet create \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --name AzureBastionSubnet \
  --address-prefix 10.0.255.0/26

# Create public IP for Bastion
az network public-ip create \
  --resource-group MyRG \
  --name BastionPublicIP \
  --sku Standard \
  --allocation-method Static \
  --location eastus

# Create Azure Bastion
az network bastion create \
  --resource-group MyRG \
  --name MyBastion \
  --public-ip-address BastionPublicIP \
  --vnet-name MyVNet \
  --location eastus \
  --sku Standard
```

---

## 🖥️ Connecting to VMs via Bastion

### Via Azure Portal (Browser-based)
1. Navigate to VM in Azure portal
2. Click **Connect** → **Bastion**
3. Enter credentials
4. Browser-based RDP/SSH session opens in new tab

### Via Native Client (Standard/Premium SKU)

```bash
# Tunnel RDP via Bastion (native client)
az network bastion rdp \
  --resource-group MyRG \
  --name MyBastion \
  --target-resource-id /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Compute/virtualMachines/MyVM

# Tunnel SSH via Bastion
az network bastion ssh \
  --resource-group MyRG \
  --name MyBastion \
  --target-resource-id /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Compute/virtualMachines/MyVM \
  --auth-type password \
  --username azureuser

# Create a tunnel for other tools (e.g., SQL Server Management Studio)
az network bastion tunnel \
  --resource-group MyRG \
  --name MyBastion \
  --target-resource-id /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Compute/virtualMachines/MyVM \
  --resource-port 3389 \
  --port 50000
```

---

## 📊 Bastion vs Jump Server vs Public IP Access

| Method | Security | Complexity | Management Overhead |
|--------|----------|------------|---------------------|
| **Azure Bastion** | High | Low | Low (PaaS managed) |
| **Jump Server (VM)** | Medium | Medium | High (VM patching) |
| **Public IP on VM** | Low | Low | High (exposed surface) |

---

## 🔍 Bastion Diagnostic Logs

```kql
// View Bastion connection sessions
AzureDiagnostics
| where ResourceType == "BASTIONHOSTS"
| where OperationName == "BastionAuditLogs"
| project TimeGenerated, userName_s, clientIpAddress_s, protocol_s, targetVMIPAddress_s
| order by TimeGenerated desc
```

Logs include:
- User who connected
- Source IP address
- Target VM
- Session duration
- Protocol (RDP/SSH)

---

## ❓ Practice Questions

1. A company wants to allow administrators to RDP to Azure VMs without exposing them to the internet or requiring a public IP on each VM. What should they implement?
   - A) A jump server (bastion VM) with a public IP
   - **B) Azure Bastion** ✅
   - C) VPN Gateway with point-to-site VPN
   - D) NSG rules allowing RDP from specific admin IP addresses

2. What is the minimum subnet size for the AzureBastionSubnet?
   - A) /28
   - B) /27
   - **C) /26** ✅
   - D) /24

3. An administrator needs to use native RDP client (not the browser) to connect to a VM through Azure Bastion. Which SKU is required?
   - A) Basic SKU
   - **B) Standard SKU** ✅
   - C) Developer SKU
   - D) Any SKU supports native client

4. What inbound NSG rule is required on the AzureBastionSubnet to allow user access?
   - A) Allow inbound RDP (3389) from Internet
   - **B) Allow inbound HTTPS (443) from Internet** ✅
   - C) Allow inbound SSH (22) from Internet
   - D) Allow inbound RDP (3389) from GatewayManager

---

## 📚 References

- [Azure Bastion Documentation](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
- [Azure Bastion SKUs](https://learn.microsoft.com/en-us/azure/bastion/configuration-settings#skus)
- [NSG for Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg)
- [Bastion Native Client](https://learn.microsoft.com/en-us/azure/bastion/native-client)
