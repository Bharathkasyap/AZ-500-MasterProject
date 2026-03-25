# Network Watcher and Flow Logs

## 📌 What is Azure Network Watcher?

**Azure Network Watcher** is a regional service that provides tools to monitor, diagnose, view metrics, and enable or disable logs for resources in Azure virtual networks.

> 💡 **Exam Note**: Network Watcher is **automatically enabled** when you create or update a virtual network in a subscription (since 2023). Previously required manual enabling.

---

## 🔧 Network Watcher Capabilities

| Category | Tool | Description |
|----------|------|-------------|
| **Monitoring** | Topology | Visual map of VNet resources and connections |
| **Monitoring** | Connection Monitor | Continuous monitoring of network connections |
| **Monitoring** | Network Performance Monitor (legacy) | Hybrid network monitoring |
| **Diagnostic** | IP Flow Verify | Test if traffic is allowed/denied by NSG rules |
| **Diagnostic** | Next Hop | Determine next hop for traffic routing |
| **Diagnostic** | VPN Troubleshoot | Diagnose VPN gateway connection issues |
| **Diagnostic** | Packet Capture | Capture network packets from VMs |
| **Diagnostic** | Connection Troubleshoot | Test connectivity between two endpoints |
| **Diagnostic** | NSG Diagnostics | Check effective NSG rules for a resource |
| **Logs** | NSG Flow Logs | Log IP traffic through NSGs |
| **Logs** | Traffic Analytics | Analyze NSG flow logs with Log Analytics |

---

## 🔍 Key Diagnostic Tools

### 1. IP Flow Verify

Tests if traffic is **allowed or denied** by NSG rules for a specific VM:

```bash
# Test if HTTPS is allowed to a VM
az network watcher test-ip-flow \
  --resource-group MyRG \
  --vm MyVM \
  --direction Inbound \
  --protocol TCP \
  --local 10.0.0.4:443 \
  --remote 203.0.113.1:12345

# Output: Access Allowed or Access Denied + rule that matched
```

Use cases:
- Troubleshoot blocked traffic
- Verify NSG rules are working as expected
- Identify which rule is blocking traffic

### 2. Next Hop

Determines the **routing path** for a packet from a VM:

```bash
# Get next hop for traffic going to 8.8.8.8
az network watcher show-next-hop \
  --resource-group MyRG \
  --vm MyVM \
  --source-ip 10.0.0.4 \
  --dest-ip 8.8.8.8
```

Output includes:
- **Next hop type**: Internet, VirtualAppliance, VnetLocal, VirtualNetworkGateway, None
- **Next hop IP**: The next hop IP address (for virtual appliance)
- **Route table**: Which route table supplied the route

### 3. Packet Capture

Capture network packets from a running VM:

```bash
# Start packet capture
az network watcher packet-capture create \
  --resource-group MyRG \
  --vm MyVM \
  --name MyCapture \
  --storage-account mystorageaccount \
  --time-limit 300 \  # 5 minutes
  --filters "[{\"protocol\":\"TCP\",\"remoteIPAddress\":\"1.1.1.1-255.255.255\",\"localPort\":\"80\"}]"

# Query status
az network watcher packet-capture show \
  --resource-group MyRG \
  --name MyCapture \
  --location eastus
```

> ⚠️ **Requirements**: VM must have the **Network Watcher Agent extension** installed.

### 4. Connection Monitor

Continuously monitors connectivity between:
- Azure VMs to Azure VMs
- Azure VMs to on-premises (via VPN/ExpressRoute)
- Azure VMs to external endpoints (URLs, IPs)

```bash
# Create connection monitor
az network watcher connection-monitor create \
  --resource-group MyRG \
  --name MyMonitor \
  --location eastus \
  --endpoints "[{\"name\":\"Source\",\"type\":\"AzureVM\",\"resourceId\":\"/subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Compute/virtualMachines/MyVM\"}]" \
  --test-configurations "[{\"name\":\"HTTPS-Test\",\"protocol\":\"Tcp\",\"tcpConfiguration\":{\"port\":443}}]" \
  --test-groups "[{\"name\":\"TestGroup\",\"destinations\":[\"Dest\"],\"sources\":[\"Source\"],\"testConfigurations\":[\"HTTPS-Test\"]}]"
```

### 5. NSG Diagnostics (Effective Security Rules)

See all effective NSG rules applied to a VM (combining subnet NSG + NIC NSG):

```bash
az network watcher show-security-group-view \
  --resource-group MyRG \
  --vm MyVM
```

---

## 📊 NSG Flow Logs

**NSG Flow Logs** capture metadata about IP traffic flowing through NSGs. Stored in Azure Storage, optionally analyzed by Traffic Analytics.

### Flow Log Data Format

Each flow record contains:
```
Timestamp, SourceIP, SourcePort, DestIP, DestPort, Protocol, 
Direction (Inbound/Outbound), Action (Allow/Deny),
[V2 only: Bytes sent, Bytes received, Packets sent, Packets received]
```

### Enabling Flow Logs

```bash
# Prerequisites: Network Watcher enabled, Storage account in same region

az network watcher flow-log create \
  --resource-group MyRG \
  --name MyFlowLog \
  --nsg /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Network/networkSecurityGroups/MyNSG \
  --storage-account /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Storage/storageAccounts/mystorageaccount \
  --workspace /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.OperationalInsights/workspaces/MyWorkspace \
  --enabled true \
  --format JSON \
  --log-version 2 \
  --retention 90 \
  --traffic-analytics true \
  --traffic-analytics-interval 10
```

### Storage Structure

```
storageaccount/
└── insights-logs-networksecuritygroupflowevent/
    └── resourceId=/SUBSCRIPTIONS/{sub}/RESOURCEGROUPS/{rg}/PROVIDERS/MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/{nsg}/
        └── y=2024/m=01/d=15/h=12/m=00/
            └── PT1H.json
```

---

## 📈 Traffic Analytics

**Traffic Analytics** processes NSG flow logs to provide intelligent insights:

### Features
- **Azure Monitor workbooks** — Interactive dashboards
- **Top talkers** — Most active source IPs
- **Allowed vs blocked traffic** — Visual breakdown
- **Malicious flows** — Flagged against threat intelligence
- **Application port distribution** — Which ports are most used
- **Geographic traffic** — Traffic source locations

### Traffic Analytics Workspace Query (KQL)

```kql
// Top source IPs by traffic volume
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| where FlowType_s == "ExternalPublic"
| summarize TotalBytes = sum(InboundBytes_d + OutboundBytes_d) by SrcIP_s
| top 10 by TotalBytes

// Denied traffic attempts
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| where FlowStatus_s == "D"  // D = Denied
| summarize DeniedFlows = count() by SrcIP_s, DestPort_d
| order by DeniedFlows desc
```

---

## 🗺️ Topology View

View the visual topology of a VNet and its connected resources:

```bash
az network watcher show-topology \
  --resource-group MyRG \
  --location eastus
```

---

## ❓ Practice Questions

1. A network administrator reports that a VM cannot connect to port 8080 of another VM in the same VNet. Which Network Watcher tool should be used to quickly identify which NSG rule is blocking the traffic?
   - A) Next Hop
   - **B) IP Flow Verify** ✅
   - C) Connection Monitor
   - D) Packet Capture

2. You want to continuously monitor and receive alerts when connectivity between two Azure VMs drops below a latency threshold. Which Network Watcher feature should you use?
   - A) IP Flow Verify
   - B) NSG Flow Logs
   - **C) Connection Monitor** ✅
   - D) Network Performance Monitor

3. NSG flow logs are configured with version 2. What additional information does version 2 provide over version 1?
   - A) Source and destination IP addresses
   - B) NSG rule name that matched
   - **C) Bytes and packets sent/received per flow** ✅
   - D) Geographic location of source IPs

4. You need to capture packets from a VM for troubleshooting. What must be installed on the VM for packet capture to work?
   - A) Azure Monitor Agent
   - **B) Network Watcher Agent extension** ✅
   - C) Log Analytics Agent
   - D) Diagnostic extension

5. Traffic Analytics requires NSG flow logs to be sent to which service for processing?
   - A) Azure Event Hubs
   - **B) Azure Log Analytics workspace** ✅
   - C) Azure Blob Storage directly
   - D) Microsoft Sentinel only

---

## 📚 References

- [Network Watcher Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview)
- [NSG Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Traffic Analytics](https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics)
- [IP Flow Verify](https://learn.microsoft.com/en-us/azure/network-watcher/ip-flow-verify-overview)
- [Connection Monitor](https://learn.microsoft.com/en-us/azure/network-watcher/connection-monitor-overview)
