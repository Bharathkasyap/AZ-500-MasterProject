# VPN Gateway and ExpressRoute

## 📌 Overview

Both Azure VPN Gateway and ExpressRoute provide connectivity between on-premises networks and Azure. They differ significantly in security, reliability, and use cases.

| Feature | VPN Gateway | ExpressRoute |
|---------|------------|--------------|
| **Connection type** | Encrypted tunnel over internet | Private dedicated circuit |
| **Internet transit** | Yes (encrypted) | No (private MPLS/Ethernet) |
| **Bandwidth** | Up to 10 Gbps | Up to 100 Gbps |
| **Latency** | Variable (internet) | Consistent, low |
| **SLA** | 99.9–99.95% | 99.95% |
| **Encryption** | IPsec/IKE (built-in) | Not built-in (MACsec or IPsec option) |
| **Cost** | Lower | Higher |
| **Use case** | Branch offices, remote users | Enterprise hybrid cloud |

---

## 🔒 Azure VPN Gateway

### VPN Types

| Type | Description |
|------|-------------|
| **Route-based** | Uses routing table for traffic; required for Point-to-Site and IKEv2; supports coexistence with ExpressRoute |
| **Policy-based** | Uses static routing policies; limited to specific SKUs; legacy |

### VPN Gateway SKUs

| SKU | Throughput | S2S Tunnels | P2S Tunnels |
|-----|-----------|-------------|-------------|
| **Basic** | 100 Mbps | 10 | 128 |
| **VpnGw1** | 650 Mbps | 30 | 250 |
| **VpnGw2** | 1 Gbps | 30 | 500 |
| **VpnGw3** | 1.25 Gbps | 30 | 1000 |
| **VpnGw4** | 5 Gbps | 100 | 5000 |
| **VpnGw5** | 10 Gbps | 100 | 10000 |

> ⚠️ **Exam Note**: Basic SKU does NOT support IKEv2, BGP, or active-active configuration. Avoid for new deployments.

---

## 🔗 Connection Types

### Site-to-Site (S2S)
- Connects on-premises network to Azure VNet
- Requires an **on-premises VPN device** (hardware or software)
- Uses **IPsec/IKE** tunnel
- Always-on connection

```bash
# Create S2S VPN connection
az network vpn-connection create \
  --resource-group MyRG \
  --name S2SConnection \
  --vnet-gateway1 MyVNetGateway \
  --local-gateway2 MyLocalNetworkGateway \
  --shared-key "SuperSecretPSK123!" \
  --connection-type IPsec
```

### Point-to-Site (P2S)
- Connects individual devices to Azure VNet
- Use case: Remote workers, home offices
- **Authentication options**:
  - Azure Certificate Authentication
  - Microsoft Entra ID (Azure AD) Authentication
  - RADIUS with AD
- **Tunnel protocols**:
  - OpenVPN (SSL/TLS) — Multi-platform support
  - IKEv2 — macOS, Windows, Linux
  - SSTP — Windows only

```bash
# Configure P2S with Entra ID authentication
az network vnet-gateway update \
  --resource-group MyRG \
  --name MyVNetGateway \
  --vpn-auth-type AAD \
  --aad-tenant "https://login.microsoftonline.com/{tenant-id}/" \
  --aad-audience "41b23e61-6c1e-4545-b367-cd054e0ed4b4" \
  --aad-issuer "https://sts.windows.net/{tenant-id}/"
```

### VNet-to-VNet
- Connects two Azure VNets (same or different regions/subscriptions)
- Alternative to VNet peering (especially for cross-subscription encrypted connections)

---

## 🛡️ VPN Gateway Security Features

### Custom IPsec/IKE Policy
Control the exact cryptographic algorithms used:

```bash
az network vpn-connection ipsec-policy add \
  --resource-group MyRG \
  --connection-name S2SConnection \
  --ike-encryption AES256 \
  --ike-integrity SHA256 \
  --dh-group DHGroup14 \
  --ipsec-encryption GCMAES256 \
  --ipsec-integrity GCMAES256 \
  --pfs-group PFS2048 \
  --sa-lifetime 27000 \
  --sa-data-size 102400000
```

### Active-Active VPN Gateway
- Two VPN Gateway instances for high availability
- Two tunnels to on-premises (two public IPs)
- Requires BGP

### BGP (Border Gateway Protocol)
- Dynamic routing — routes automatically learned and propagated
- Required for active-active and coexistence scenarios

---

## ⚡ Azure ExpressRoute

### What is ExpressRoute?

A **private, dedicated network circuit** between your on-premises network and Microsoft's global network — delivered through a **connectivity provider** (AT&T, Equinix, etc.).

### ExpressRoute Circuit Components

```
On-premises Network
    → Router (Customer Edge)
        → ExpressRoute Provider (MPLS/Ethernet)
            → Microsoft Enterprise Edge (MSEE) router
                → Azure Region VNets
```

### ExpressRoute Peering Types

| Peering | Connects To | Use Case |
|---------|------------|---------|
| **Private Peering** | Azure VNets (private IPs) | VMs, Azure services in VNets |
| **Microsoft Peering** | Microsoft 365, Azure PaaS public IPs | O365, Storage, SQL public endpoints |

### ExpressRoute SKUs

| SKU | Description |
|-----|-------------|
| **Local** | Low-cost; only local Azure region |
| **Standard** | Access to geopolitical region |
| **Premium** | Global connectivity + larger route tables |

---

## 🔒 ExpressRoute Security

### MACsec (Layer 2 Encryption)
- Encrypts data at the **Ethernet layer** (Layer 2)
- Protects against physical tapping on the provider network
- Configured on the **Customer Edge (CE) router**
- Keys managed with Azure Key Vault

### IPsec over ExpressRoute
- Add **IPsec tunnels** over ExpressRoute for end-to-end encryption
- Use when you want encryption + ExpressRoute's reliability
- Uses VPN Gateway over ExpressRoute private peering

### ExpressRoute FastPath
- Bypasses the VPN Gateway data path for better performance
- Does not go through the gateway for data plane traffic
- Gateway still required for control plane

---

## 🔄 ExpressRoute + VPN Coexistence

Configure both for:
- **Failover**: VPN as backup if ExpressRoute fails
- **Redundancy**: Route critical workloads over ExpressRoute, others over VPN

Requires:
- **Route-based VPN Gateway** (not policy-based)
- **Specific gateway subnet sizing** (/27 minimum)

---

## ❓ Practice Questions

1. A company needs to connect their on-premises data center to Azure with consistent low latency and high bandwidth for running sensitive financial applications. Public internet connectivity is not acceptable. Which solution is recommended?
   - A) Site-to-Site VPN Gateway
   - **B) ExpressRoute** ✅
   - C) Point-to-Site VPN
   - D) VNet peering

2. Remote employees need to connect to Azure VNets using their personal laptops. Which VPN connection type is appropriate?
   - A) Site-to-Site VPN
   - B) VNet-to-VNet
   - **C) Point-to-Site VPN** ✅
   - D) ExpressRoute Direct

3. A company wants to add end-to-end encryption to their ExpressRoute connection because the circuit provider might have access to the physical layer. Which solution should be implemented?
   - A) Enable TLS on all applications
   - **B) Configure MACsec or IPsec over ExpressRoute** ✅
   - C) Enable DDoS Protection
   - D) Use WAF on Application Gateway

4. Which VPN Gateway SKU should be avoided for new deployments as it doesn't support IKEv2?
   - **A) Basic SKU** ✅
   - B) VpnGw1
   - C) VpnGw2
   - D) All SKUs support IKEv2

---

## 📚 References

- [VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways)
- [ExpressRoute Documentation](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction)
- [IPsec over ExpressRoute](https://learn.microsoft.com/en-us/azure/expressroute/site-to-site-vpn-over-microsoft-peering)
- [MACsec on ExpressRoute](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-howto-macsec)
