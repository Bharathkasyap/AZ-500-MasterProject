# Network Security Groups (NSGs)

## 📌 What are Network Security Groups?

**Network Security Groups (NSGs)** act as a distributed virtual firewall for Azure resources. They filter inbound and outbound network traffic using security rules based on:
- Source/destination IP address
- Source/destination port
- Protocol (TCP, UDP, Any)

NSGs can be applied to:
- **Subnet** — All resources in the subnet inherit the rules
- **Network Interface Card (NIC)** — Rules apply to a specific VM

> 💡 **Exam Note**: When an NSG is applied to both a subnet AND a NIC, traffic must pass through BOTH NSG rule sets. Inbound: subnet NSG first → NIC NSG. Outbound: NIC NSG first → subnet NSG.

---

## 🔄 Rule Processing

### Rule Priority
- Rules are processed **lowest priority number first** (100 processes before 200)
- Priority range: **100 to 4096**
- Once a rule matches, processing stops (first match wins)
- Each rule must have a unique priority per direction (inbound/outbound)

### Default Rules (Cannot be deleted, only overridden)

**Default Inbound Rules:**
| Priority | Name | Source | Destination | Port | Action |
|----------|------|--------|-------------|------|--------|
| 65000 | AllowVnetInBound | VirtualNetwork | VirtualNetwork | Any | Allow |
| 65001 | AllowAzureLoadBalancerInBound | AzureLoadBalancer | Any | Any | Allow |
| 65500 | DenyAllInBound | Any | Any | Any | **Deny** |

**Default Outbound Rules:**
| Priority | Name | Source | Destination | Port | Action |
|----------|------|--------|-------------|------|--------|
| 65000 | AllowVnetOutBound | VirtualNetwork | VirtualNetwork | Any | Allow |
| 65001 | AllowInternetOutBound | Any | Internet | Any | Allow |
| 65500 | DenyAllOutBound | Any | Any | Any | **Deny** |

---

## ⚙️ NSG Rule Components

| Field | Values |
|-------|--------|
| **Priority** | 100–4096 |
| **Name** | Descriptive name |
| **Source** | IP/CIDR, Service Tag, Application Security Group |
| **Source Port Range** | Port number, range (80-443), or `*` |
| **Destination** | IP/CIDR, Service Tag, Application Security Group |
| **Destination Port Range** | Port number, range, or `*` |
| **Protocol** | TCP, UDP, ICMP, Any |
| **Direction** | Inbound / Outbound |
| **Action** | Allow / Deny |

---

## 🏷️ Service Tags

**Service Tags** represent groups of IP address prefixes for Azure services — Microsoft manages them automatically:

| Service Tag | Represents |
|-------------|-----------|
| **VirtualNetwork** | VNet address space + on-prem connected spaces |
| **AzureLoadBalancer** | Azure infrastructure load balancer (168.63.129.16) |
| **Internet** | All public IP addresses outside VNet |
| **AzureCloud** | All Azure datacenter IPs |
| **Storage** | Azure Storage service IPs |
| **Sql** | Azure SQL service IPs |
| **AppService** | Azure App Service outbound IPs |
| **AzureMonitor** | Azure Monitor IPs |
| **GatewayManager** | VPN/App Gateway management IPs |

> 💡 Use service tags instead of hardcoding IP ranges — Microsoft keeps them updated.

---

## 🔒 Application Security Groups (ASGs)

**ASGs** allow you to group VMs logically and use those groups in NSG rules — no need to manage IP addresses:

```bash
# Create ASGs
az network asg create --resource-group MyRG --name WebServers
az network asg create --resource-group MyRG --name DatabaseServers

# Associate a NIC with an ASG
az network nic update \
  --resource-group MyRG \
  --name MyVM-NIC \
  --application-security-groups WebServers

# NSG rule using ASG
az network nsg rule create \
  --resource-group MyRG \
  --nsg-name MyNSG \
  --name Allow-SQL-from-Web \
  --priority 100 \
  --source-asgs WebServers \
  --destination-asgs DatabaseServers \
  --destination-port-ranges 1433 \
  --protocol Tcp \
  --access Allow
```

---

## 📊 NSG Flow Logs

**NSG Flow Logs** capture information about IP traffic flowing through NSGs.

### Version 2 Features (Recommended)
- Logs both allowed and denied flows
- Captures throughput data (bytes and packets per flow)
- Stored in Azure Storage account
- Version 2 adds per-flow byte/packet counts

### Configuration Requirements
- **Network Watcher** must be enabled in the region
- **Azure Storage account** in the same region
- Storage account must be accessible (not behind private endpoint without configuration)

```bash
# Enable NSG flow logs
az network watcher flow-log create \
  --resource-group MyRG \
  --name MyFlowLog \
  --nsg MyNSG \
  --storage-account /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Storage/storageAccounts/mysa \
  --enabled true \
  --format JSON \
  --log-version 2 \
  --retention 90
```

### Traffic Analytics
- Built on NSG flow logs
- Provides visual dashboards in Azure Monitor / Log Analytics
- Identifies top talkers, top ports, allowed/denied flows
- Requires Log Analytics workspace

---

## 🛡️ NSG Best Practices

1. **Apply NSGs at both subnet and NIC level** for defense in depth (optional but layered)
2. **Use the lowest priority** (100–200) for explicitly allowed traffic
3. **Use service tags** instead of hardcoding IP ranges
4. **Use Application Security Groups** for server role-based rules
5. **Enable NSG flow logs** for all NSGs (required for troubleshooting and compliance)
6. **Enable Traffic Analytics** for visibility into traffic patterns
7. **Avoid using wide-open rules** like Any → Any → Allow
8. **Block inbound RDP (3389) and SSH (22)** from the Internet; use Azure Bastion instead

---

## 🔗 CLI Commands

```bash
# Create an NSG
az network nsg create --resource-group MyRG --name MyNSG

# Add an inbound rule
az network nsg rule create \
  --resource-group MyRG \
  --nsg-name MyNSG \
  --name Allow-HTTPS \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-port-ranges 443 \
  --protocol Tcp \
  --access Allow \
  --direction Inbound

# Associate NSG with a subnet
az network vnet subnet update \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --name MySubnet \
  --network-security-group MyNSG

# List NSG rules
az network nsg rule list --resource-group MyRG --nsg-name MyNSG --output table
```

---

## ❓ Practice Questions

1. A VM has an NSG on its NIC with a rule that allows inbound HTTPS (port 443). The subnet NSG has no rule for HTTPS. Can HTTPS traffic reach the VM?
   - A) No — both NSGs must allow the traffic
   - **B) No — the subnet NSG's default DenyAllInBound rule blocks traffic before it reaches the NIC** ✅
   - C) Yes — NIC NSG rules take precedence over subnet NSGs
   - D) Yes — default rules allow HTTPS

2. You need to write an NSG rule that allows web servers to communicate with database servers on port 1433, without specifying IP addresses. Which feature should you use?
   - A) Service Tags
   - **B) Application Security Groups** ✅
   - C) Named Locations
   - D) Azure Firewall rules

3. An NSG has the following inbound rules: Priority 100 — Allow port 80, Priority 200 — Deny port 80. What happens to HTTP traffic?
   - **A) It is allowed (priority 100 rule matches first)** ✅
   - B) It is denied (deny rules always win)
   - C) Both rules are evaluated and traffic is denied
   - D) The conflict causes an error

4. NSG flow logs are stored in which Azure service?
   - **A) Azure Storage account** ✅
   - B) Azure Event Hub
   - C) Azure SQL Database
   - D) Azure Monitor directly

---

## 📚 References

- [NSG Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Service Tags](https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview)
- [NSG Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Application Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups)
