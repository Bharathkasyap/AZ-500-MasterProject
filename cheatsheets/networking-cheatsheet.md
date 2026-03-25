# Networking Security — Quick Reference Cheat Sheet

## NSG Rule Evaluation

```
Inbound traffic evaluation order:
  1. Rules applied to the NIC's subnet NSG (lowest priority number first)
  2. Rules applied to the NIC's NSG

Traffic is DENIED if ANY NSG denies it.
Traffic is ALLOWED only if BOTH NSGs allow it (or no deny exists).
```

**Default rules (cannot be deleted)**:

| Priority | Name | In/Out | Action |
|----------|------|--------|--------|
| 65000 | AllowVnetInBound | In | Allow |
| 65001 | AllowAzureLoadBalancerInBound | In | Allow |
| 65500 | DenyAllInBound | In | **Deny** |
| 65000 | AllowVnetOutBound | Out | Allow |
| 65001 | AllowInternetOutBound | Out | Allow |
| 65500 | DenyAllOutBound | Out | **Deny** |

---

## Azure Firewall — Rule Evaluation Order

```
1. DNAT Rules       (inbound NAT — expose internal services)
2. Network Rules    (Layer 3/4 — IP/port/protocol)
3. Application Rules(Layer 7 — FQDN, HTTP/HTTPS)

Lower priority number = evaluated FIRST
If no rule matches → DENY (default deny)
```

### Standard vs. Premium

| Feature | Standard | Premium |
|---------|----------|---------|
| FQDN filtering | ✅ | ✅ |
| Threat Intelligence | ✅ | ✅ |
| IDPS | ❌ | ✅ |
| TLS Inspection | ❌ | ✅ |
| Web Categories | ❌ | ✅ |
| URL Filtering | ❌ | ✅ |

---

## WAF Quick Reference

| Mode | Action |
|------|--------|
| Detection | Log only (no blocking) |
| Prevention | Block + Log |

**Rule sets**: OWASP 3.2 (latest), OWASP 3.1/3.0, Microsoft DRS (Front Door)

**Custom rules** evaluated BEFORE managed rule sets.

**Deployment points**: Application Gateway (regional) | Azure Front Door (global) | Azure CDN

---

## Private Endpoint vs. Service Endpoint

| Aspect | Service Endpoint | Private Endpoint |
|--------|-----------------|-----------------|
| Private IP in VNet | ❌ | ✅ |
| Works from on-prem | ❌ | ✅ |
| DNS change needed | ❌ | ✅ |
| Disables public IP | ❌ | Via separate setting |
| Cost | Free | Per-hour + data |

**Private DNS zones** (common):
- Blob: `privatelink.blob.core.windows.net`
- Key Vault: `privatelink.vaultcore.azure.net`
- SQL: `privatelink.database.windows.net`
- ACR: `privatelink.azurecr.io`

---

## DDoS Protection Tiers

| Tier | Protection | Cost |
|------|-----------|------|
| Basic (Infrastructure) | Azure platform only | Free |
| DDoS IP Protection | Per-public IP, no rapid response | Per-IP/month |
| DDoS Network Protection | Per-VNet, adaptive tuning, rapid response, cost guarantee | Per-VNet/month |

---

## Azure Bastion Requirements

- Subnet name: **AzureBastionSubnet** (exactly)
- Minimum subnet size: **/26** (64 addresses)
- Standard public IP (static, required)
- NSG: allow TCP 443 inbound from Internet + GatewayManager

| Feature | Basic | Standard |
|---------|-------|---------|
| Browser RDP/SSH | ✅ | ✅ |
| Native client | ❌ | ✅ |
| File transfer | ❌ | ✅ |
| Session recording | ❌ | ✅ |

---

## VPN Key Points

| Protocol | SKU Support | Notes |
|----------|-----------|-------|
| IKEv1 | Basic only | Legacy — avoid |
| IKEv2 | VpnGw1+ | Recommended |

**Cipher recommendations**: AES-256, SHA-256/384, DH Group 14+

**P2S auth methods**: Certificate | Azure AD (OpenVPN) | RADIUS

---

## Hub-and-Spoke — What Goes Where

| Component | Hub | Spoke |
|-----------|-----|-------|
| Azure Firewall | ✅ | ❌ |
| VPN/ExpressRoute Gateway | ✅ | ❌ |
| Azure Bastion | ✅ | ❌ (or per-spoke) |
| Application VMs | ❌ | ✅ |
| Databases | ❌ | ✅ |

---

## Service Tags (Common)

| Tag | Represents |
|-----|-----------|
| `Internet` | Any public IP not in VirtualNetwork |
| `VirtualNetwork` | All VNet address spaces + peered + on-prem |
| `AzureLoadBalancer` | Azure health probes |
| `GatewayManager` | Azure Bastion, VPN Gateway control |
| `AzureCloud` | All Azure datacenter IPs |
| `Sql` | Azure SQL, Synapse |
| `Storage` | Azure Storage |
| `AppService` | App Service outbound IPs |
