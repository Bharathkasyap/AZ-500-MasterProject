# Practice Questions — Domain 2: Secure Networking

> **Back to [README](../README.md)**  
> **Domain Weight**: 20–25% of AZ-500 exam

---

### Question 1

**You need to allow inbound HTTP (port 80) traffic to VMs in a subnet, but only from your corporate network (IP range 203.0.113.0/24). All other inbound internet traffic must be blocked.**

**Which NSG rule configuration is correct?**

A. Priority 100: Allow TCP 80 from 203.0.113.0/24. No deny rule needed — internet is blocked by default.  
B. Priority 100: Allow TCP 80 from 203.0.113.0/24. Priority 200: Deny TCP 80 from Internet.  
C. Priority 100: Deny TCP 80 from Internet. Priority 200: Allow TCP 80 from 203.0.113.0/24.  
D. Priority 100: Allow TCP 80 from 203.0.113.0/24. Priority 200: Deny Any from Internet.  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: A — Priority 100 Allow TCP 80 from 203.0.113.0/24. No additional deny rule needed.**

NSGs have a **default deny rule** at priority 65500 (`DenyAllInBound`) that blocks all inbound traffic not explicitly allowed. Since port 80 from Internet is not explicitly allowed, it will be denied by the default rule.

- **B is incorrect**: The deny rule is redundant — the default rule already denies everything else.
- **C is incorrect**: The deny rule at priority 100 would block ALL port 80 traffic before the allow rule at priority 200 is evaluated. Priority 100 is processed before 200.
- **D is incorrect**: Priority 200 "Deny Any from Internet" is redundant due to default rules.

</details>

---

### Question 2

**What is the key difference between Azure Private Endpoints and VNet Service Endpoints?**

A. Private Endpoints work only with Microsoft PaaS services; Service Endpoints work with any service  
B. Private Endpoints assign a private IP from your VNet; Service Endpoints extend the VNet identity but use the service's public IP  
C. Service Endpoints provide stronger isolation than Private Endpoints  
D. Private Endpoints require DNS changes; Service Endpoints do not  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Private Endpoints assign a private IP from your VNet; Service Endpoints extend VNet identity but use the service's public IP**

- **Private Endpoint**: Creates a NIC in your VNet with a private IP. Traffic to the service goes over the Azure backbone using the private IP — the service is never accessible from the public internet if you disable public access.
- **Service Endpoint**: Adds the VNet identity to the service's firewall rules. Traffic still routes over the Azure backbone but uses the service's public endpoint IP address.

- **A is incorrect**: Private Endpoints are available for many third-party services via Private Link.
- **C is incorrect**: Private Endpoints provide stronger isolation (no public IP exposure).
- **D is incorrect**: Both may require DNS changes; Private Endpoints typically require private DNS zones.

</details>

---

### Question 3

**You deploy Azure Firewall in your hub VNet. VMs in a spoke VNet should have all internet-bound traffic inspected by the firewall.**

**What must you configure?**

A. VNet peering between hub and spoke with gateway transit  
B. A Network Security Group on the spoke subnet with a deny-internet outbound rule  
C. A User-Defined Route (UDR) on the spoke subnet with 0.0.0.0/0 pointing to the firewall's private IP as the next hop  
D. Azure DDoS Protection Standard on the spoke VNet  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — UDR with 0.0.0.0/0 → Firewall private IP**

User-Defined Routes override Azure's default system routes. By creating a route table with `0.0.0.0/0 → Virtual Appliance (Firewall IP)` and associating it with the spoke subnet, all outbound internet traffic is redirected through Azure Firewall for inspection.

- **A is incorrect**: VNet peering is needed for connectivity but doesn't force traffic through the firewall.
- **B is incorrect**: Denying internet outbound via NSG would block all internet traffic, not inspect it.
- **D is incorrect**: DDoS protection is for inbound volumetric attacks, not outbound traffic inspection.

</details>

---

### Question 4

**Your security team needs to connect to VMs via SSH without exposing the VMs' public IP addresses to the internet.**

**What is the recommended solution?**

A. Install OpenVPN on the VMs and connect via VPN  
B. Create NSG rules allowing SSH only from your office IP address  
C. Deploy Azure Bastion and remove public IP addresses from the VMs  
D. Configure Just-in-Time VM access for port 22  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Deploy Azure Bastion and remove public IP addresses**

Azure Bastion provides secure RDP/SSH directly from the Azure Portal browser session without requiring public IPs on VMs. It deploys in the `AzureBastionSubnet` and acts as an HTML5-based jump server over HTTPS (port 443).

- **A is incorrect**: OpenVPN requires managing another service and doesn't eliminate all public exposure.
- **B is incorrect**: Still requires a public IP on the VM (just restricted by IP).
- **D is incorrect**: JIT opens management ports temporarily but still requires a public IP or network path to the port.

Note: The best answer for "no public IP at all" is Azure Bastion (C). JIT (D) is also a valid security control but doesn't fully eliminate public IP requirements.

</details>

---

### Question 5

**You need to protect your web application against SQL injection and cross-site scripting (XSS) attacks.**

**Which Azure service should you use?**

A. Azure DDoS Protection  
B. Azure Firewall  
C. Network Security Groups (NSGs)  
D. Azure Web Application Firewall (WAF)  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: D — Azure Web Application Firewall (WAF)**

WAF specifically protects against OWASP Top 10 web vulnerabilities including SQL injection and XSS. It operates at Layer 7 (HTTP/HTTPS) and can be deployed on Azure Application Gateway, Azure Front Door, or Azure CDN.

- **A is incorrect**: DDoS Protection protects against volumetric network attacks (L3/L4), not application-layer attacks.
- **B is incorrect**: Azure Firewall can filter by FQDN but is not designed for HTTP-level web attack detection.
- **C is incorrect**: NSGs operate at L3/L4 (IP/port) and cannot inspect HTTP payload for attacks.

</details>

---

### Question 6

**Your organization wants to allow Azure App Services to connect to a private Azure SQL Database without traversing the public internet.**

**Which TWO options should you implement? (Select TWO)**

A. Deploy a private endpoint for the Azure SQL Database  
B. Enable VNet Integration for the App Service  
C. Add the App Service's outbound IP to the SQL Database firewall  
D. Enable Service Endpoint for Microsoft.Sql on the App Service's delegated subnet  
E. Configure Azure Firewall between the App Service and SQL Database  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: A and B**

To fully private routing:
- **A**: Private endpoint for SQL Database places a private IP in the VNet — SQL is accessible via private IP.
- **B**: VNet Integration for App Services allows the App Service to route outbound traffic into the VNet, enabling access to private endpoints.

- **C is incorrect**: Adding outbound IPs to SQL firewall still uses the public endpoint.
- **D is incorrect**: App Services don't have a "delegated subnet" with service endpoint support in the same way VMs do.
- **E is incorrect**: Firewall adds complexity and is not required for this private connectivity scenario.

</details>

---

### Question 7

**Which Azure Firewall rule type supports filtering traffic by fully qualified domain name (FQDN)?**

A. Network rules  
B. NAT rules  
C. Application rules  
D. Service tag rules  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Application rules**

Application rules in Azure Firewall operate at Layer 7 and support:
- FQDN filtering (e.g., `*.microsoft.com`)
- FQDN tags (pre-defined FQDNs for services like Windows Update)
- HTTP/HTTPS/MSSQL protocols

- **A is incorrect**: Network rules work at L3/L4 (IP address/port) and do NOT support FQDN filtering.
- **B is incorrect**: NAT rules are for DNAT (inbound traffic) and work at L3/L4.
- **D is incorrect**: Service tags group IP ranges for specific Azure services — not FQDN-based.

</details>

---

### Question 8

**Your organization uses Azure Virtual WAN. You need to ensure that branch offices cannot communicate directly with each other — all traffic must flow through a central security inspection point.**

**What should you configure?**

A. NSGs on all branch VNet subnets denying cross-branch traffic  
B. Virtual WAN with routing intent configured to route all traffic through Azure Firewall in the hub  
C. VNet peering between all branch VNets with UDRs  
D. Azure Private DNS zones for all branch VNets  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Virtual WAN routing intent through Azure Firewall in the hub**

Azure Virtual WAN's routing intent feature allows you to configure the hub's routing to send all traffic (internet-bound and private) through an Azure Firewall or third-party NVA in the hub — preventing direct branch-to-branch communication.

- **A is incorrect**: NSGs would need to be manually maintained across all branches and can't block all routing paths.
- **C is incorrect**: This creates direct connectivity between branches.
- **D is incorrect**: Private DNS zones are for name resolution, not traffic routing/control.

</details>

---

### Question 9

**You are setting up NSG flow logs. What information is captured in flow logs?**

A. The content (payload) of network packets  
B. The source IP, destination IP, source port, destination port, protocol, and whether traffic was allowed or denied  
C. Only denied traffic (allowed traffic is not logged by default)  
D. Packet headers including HTTP headers and URLs  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — 5-tuple information and allow/deny decision**

NSG flow logs capture the 5-tuple:
- Source IP, Source port
- Destination IP, Destination port
- Protocol (TCP/UDP)
- Direction (inbound/outbound)
- NSG action (allow/deny)
- Flow state and byte/packet counts (Version 2)

- **A is incorrect**: Flow logs do not capture packet payload (deep packet inspection is a different capability).
- **C is incorrect**: Both allowed AND denied flows are logged.
- **D is incorrect**: HTTP headers and URLs require L7 inspection (Azure Firewall, WAF, etc.).

</details>

---

### Question 10

**Your company recently experienced a 500 Gbps DDoS attack that overwhelmed your Azure resources. Which DDoS protection option provides dedicated mitigation capacity, attack analytics, and post-attack reports?**

A. DDoS Basic (free, built-in protection)  
B. DDoS IP Protection  
C. DDoS Network Protection  
D. Azure Firewall with DDoS signatures  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — DDoS Network Protection**

DDoS Network Protection (formerly Standard) provides:
- Always-on traffic monitoring and real-time mitigation
- Adaptive tuning per application
- Attack analytics, alerts, and post-attack reports
- DDoS rapid response team access
- **Cost protection** (credits for scale-out costs during attacks)
- Significantly higher mitigation capacity than Basic or IP Protection

- **A is incorrect**: DDoS Basic provides platform-level protection but no analytics or dedicated capacity.
- **B is incorrect**: IP Protection is a newer, per-IP option with a subset of Network Protection features.
- **D is incorrect**: Azure Firewall doesn't provide volumetric DDoS protection.

</details>

---

## 📊 Score Yourself

| Score | Performance |
|---|---|
| 9–10 correct | Excellent — Strong networking security knowledge |
| 7–8 correct | Good — Review specific areas of weakness |
| 5–6 correct | Fair — Revisit Domain 2 study guide |
| < 5 correct | Needs work — Re-read and practice |

---

> ⬅️ [Domain 1 Questions](./domain-1-questions.md) | ➡️ [Domain 3 Questions](./domain-3-questions.md)
