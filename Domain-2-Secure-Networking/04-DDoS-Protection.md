# Azure DDoS Protection

## 📌 What is Azure DDoS Protection?

**Azure DDoS Protection** defends Azure resources against Distributed Denial of Service (DDoS) attacks by monitoring traffic and automatically mitigating threats. DDoS attacks flood services with fake traffic to exhaust resources and cause outages.

---

## 🏢 DDoS Protection Tiers

| Tier | Previously Called | Cost | Key Features |
|------|------------------|------|-------------|
| **Network Protection** | Standard | Per protected VNet (~$2,944/month) + data processing fees | Always-on monitoring, adaptive tuning, rapid response team, cost guarantee, mitigation reports |
| **IP Protection** | N/A | Per public IP (~$199/month) | Always-on monitoring for specific public IPs |
| **Infrastructure Protection** | Basic | Free | Built-in, always on, protects Azure infrastructure |

> 💡 **Exam Note**: The tiers were renamed in 2023. Be aware of both old (Basic/Standard) and new (Infrastructure/Network/IP) terminology.

---

## 🔄 How DDoS Protection Works

### Attack Detection
- Monitors network traffic flows across the Azure global network
- Uses machine learning to establish baselines (normal traffic patterns)
- Detects anomalies in real time

### Mitigation
- When attack detected, automatic mitigation begins in **under 30 seconds**
- Traffic scrubbing removes attack traffic while allowing legitimate traffic
- Adaptive thresholds based on the specific resource's traffic patterns

### Attack Types Mitigated

| Layer | Attack Type | Example |
|-------|------------|---------|
| **L3/L4 (Network/Transport)** | Volumetric | UDP floods, ICMP floods |
| **L3/L4** | Protocol attacks | SYN floods, fragmented packet attacks |
| **L7 (Application)** | Application layer* | HTTP floods, DNS query floods |

> ⚠️ **Important**: DDoS Network Protection helps with L3/L4 attacks. For **L7 application attacks**, combine with **WAF** (Azure Front Door or Application Gateway WAF).

---

## ⚙️ DDoS Network Protection Features

### 1. Always-On Monitoring
- Continuous traffic monitoring — no need to enable manually during attacks
- No impact on legitimate traffic (no latency increase)

### 2. Adaptive Real-Time Tuning
- Learns application traffic patterns over time
- Auto-adjusts mitigation thresholds per public IP
- Reduces false positives compared to static thresholds

### 3. Mitigation Reports and Flow Logs
- **Attack mitigation reports** (every 5 minutes during attack, plus post-attack report)
- **Attack mitigation flow logs** — detailed per-flow info
- Logs sent to Log Analytics, Event Hub, or Storage

### 4. DDoS Rapid Response Team
- Access to Microsoft DDoS Rapid Response (DRR) team during active attacks
- Submit support request tagged "DDoS Attack"

### 5. Cost Protection Guarantee
- Azure credits for resource scale-out costs during a confirmed DDoS attack
- Covers VM scale-out, bandwidth overage

### 6. Multi-Vector Attack Protection
- Handles simultaneous attacks on multiple vectors

---

## 🛡️ DDoS Protection Configuration

```bash
# Create a DDoS protection plan
az network ddos-protection create \
  --resource-group MyRG \
  --name MyDDoSPlan \
  --location eastus

# Associate DDoS plan with a VNet
az network vnet update \
  --resource-group MyRG \
  --name MyVNet \
  --ddos-protection-plan MyDDoSPlan \
  --ddos-protection true
```

### Scope
- DDoS Network Protection plan is associated with a **VNet**
- All public IPs associated with resources in that VNet are protected
- One plan can be associated with **multiple VNets** (same or different subscriptions)
- Cost applies per VNet (not per resource)

---

## 📊 DDoS Metrics and Alerts

Key metrics in Azure Monitor:

| Metric | Description |
|--------|-------------|
| **Under DDoS attack or not** | Binary — 1 if attack in progress |
| **Inbound packets dropped DDoS** | Packets dropped during mitigation |
| **Inbound bytes DDoS** | Total inbound bytes |
| **Inbound SYN packets DDoS** | SYN packets (protocol attack indicator) |

```bash
# Create an alert for DDoS attack
az monitor metrics alert create \
  --resource-group MyRG \
  --name DDoS-Attack-Alert \
  --resource /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Network/publicIPAddresses/MyPublicIP \
  --metric-namespace "Microsoft.Network/publicIPAddresses" \
  --metric "IfUnderDDoSAttack" \
  --condition "total > 0" \
  --evaluation-frequency 1m \
  --window-size 5m \
  --severity 0 \
  --action /subscriptions/{sub}/resourceGroups/MyRG/providers/microsoft.insights/actionGroups/SecurityTeam
```

---

## 🔗 DDoS + WAF Integration (Best Practice)

For comprehensive protection:

```
L3/L4 Protection:  DDoS Network Protection
L7 Protection:     WAF (Azure Front Door or Application Gateway)
```

This combination protects against:
- Volumetric network attacks → DDoS Protection
- Protocol attacks → DDoS Protection
- Application layer attacks → WAF

---

## 📋 Infrastructure Protection (Free — Default)

All Azure services are covered by **Infrastructure Protection** at no cost:
- Protects Azure's core infrastructure (not customer-specific workloads)
- Limited mitigation capabilities
- No SLAs, reports, or metrics specific to your resources
- **Always on** — cannot be disabled

---

## ❓ Practice Questions

1. Your organization runs a public-facing web application in Azure. You need to protect it against both volumetric network-layer DDoS attacks and application-layer HTTP flood attacks. What combination should you implement?
   - A) DDoS Network Protection only
   - B) WAF on Application Gateway only
   - **C) DDoS Network Protection + WAF on Application Gateway or Front Door** ✅
   - D) Azure Firewall Premium with IDPS

2. What is the approximate time for Azure DDoS Protection to begin mitigation after an attack is detected?
   - A) 5 minutes
   - **B) Under 30 seconds** ✅
   - C) 1–2 minutes
   - D) Immediate (0 seconds, no detection delay)

3. A company has 5 VNets in different Azure regions. They want to protect all VNets with DDoS Network Protection. What is the most cost-effective configuration?
   - A) Create separate DDoS protection plans in each region
   - **B) Create one DDoS protection plan and associate all VNets with it** ✅
   - C) Enable DDoS Basic for free on each VNet
   - D) Use Azure Firewall in each region instead

4. During a confirmed DDoS attack, a company's application servers scaled out significantly, incurring extra costs. What DDoS Network Protection feature can help with these costs?
   - A) Adaptive real-time tuning
   - B) Mitigation flow logs
   - **C) Cost protection guarantee (Azure credits for scale-out during confirmed attack)** ✅
   - D) DDoS Rapid Response Team assistance

---

## 📚 References

- [Azure DDoS Protection Documentation](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)
- [DDoS Protection Tiers](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-sku-comparison)
- [DDoS Protection Best Practices](https://learn.microsoft.com/en-us/azure/ddos-protection/fundamental-best-practices)
- [DDoS + WAF Integration](https://learn.microsoft.com/en-us/azure/web-application-firewall/shared/application-gateway-waf-ddos)
