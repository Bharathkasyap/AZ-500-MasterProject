# Domain 2 Practice Questions — Secure Networking

> 20 questions covering Azure network security. Answers at the bottom.

---

## Questions

**Q1.** You need to allow HTTPS traffic from the internet to a web application hosted on Azure VMs, but block all other inbound traffic. The NSG rule to allow HTTPS is set to priority 100. What is the correct configuration?

A) Set source as `Any`, destination as `VirtualNetwork`, port `443`, action `Allow`, priority `100`  
B) Set source as `Internet`, destination as `*`, port `443`, action `Allow`, priority `100`  
C) Set source as `Internet`, destination as the VM's IP, port `443`, action `Allow`, priority `100`; the default `DenyAllInBound` at priority `65500` blocks everything else  
D) No additional rules needed; Azure allows HTTPS by default  

---

**Q2.** An administrator needs to determine why traffic from a VM is being blocked by an NSG. What Network Watcher tool should they use?

A) Connection Monitor  
B) IP Flow Verify  
C) Next Hop  
D) Packet Capture  

---

**Q3.** You are designing a hub-spoke network topology. You need to ensure that all outbound internet traffic from spoke VNets is inspected and filtered by Azure Firewall deployed in the hub VNet. What must you configure in the spoke VNets?

A) VNet peering with gateway transit enabled  
B) User-defined routes (UDR) with a default route pointing to the Azure Firewall's private IP  
C) NSG rules blocking direct internet access on all spoke subnets  
D) Service endpoints to Azure Firewall  

---

**Q4.** An application running in a VNet needs to access Azure Blob Storage. You need to ensure the traffic does NOT leave the Azure network and cannot be accessed from the public internet. What should you implement?

A) Storage service endpoint + storage account firewall rule allowing the VNet  
B) Private endpoint for the Storage Account + disable public network access  
C) VNet integration on the storage account  
D) NSG rule allowing traffic from VNet to storage  

---

**Q5.** Your Azure Firewall is in Standard SKU. You need to block access to social media websites by category (e.g., "Social Networking") rather than listing individual FQDNs. What is required?

A) Upgrade to Azure Firewall Premium; only Premium supports web categories  
B) Create application rules with FQDNs for each social media site  
C) Use Azure Firewall Standard with web filtering enabled  
D) Configure a custom DNS policy  

---

**Q6.** You need to provide secure RDP access to Azure VMs without exposing port 3389 to the internet. The VMs do NOT have public IP addresses. Which solution meets these requirements with the LEAST administrative effort?

A) Configure a VPN Gateway with Point-to-Site connectivity  
B) Deploy Azure Bastion in the VNet  
C) Add an NSG rule allowing RDP from a jump server's IP  
D) Configure Just-in-Time VM access in Defender for Cloud  

---

**Q7.** An organization needs to protect their internet-facing web application against SQL injection and XSS attacks. The application is deployed behind Azure Application Gateway. What should you configure?

A) Azure DDoS Protection Standard  
B) NSG rules to block suspicious source IPs  
C) Web Application Firewall (WAF) on Application Gateway in Prevention mode  
D) Azure Firewall with IDPS signatures  

---

**Q8.** What is the MINIMUM subnet size required for the `AzureBastionSubnet`?

A) /29  
B) /28  
C) /27  
D) /26  

---

**Q9.** Your company has an ExpressRoute circuit connecting on-premises to Azure. Security requirements state that all ExpressRoute traffic must be encrypted at Layer 2. Which technology achieves this?

A) IPsec over ExpressRoute  
B) MACsec  
C) VPN Gateway in coexistence mode  
D) Azure Private Link  

---

**Q10.** You have configured a Network Security Group on a subnet (Subnet-NSG) and another NSG on the NIC of a VM (NIC-NSG). For INBOUND traffic to the VM, which NSG is evaluated FIRST?

A) Subnet-NSG  
B) NIC-NSG  
C) Both are evaluated simultaneously  
D) The NSG with the lowest priority rule number  

---

**Q11.** An organization wants to expose an internal load-balanced service to partner organizations through Azure Private Link. Partners will create private endpoints in their own VNets to access the service. What Azure component must the organization deploy?

A) Azure API Management (internal mode)  
B) Azure Private Link Service  
C) Azure Traffic Manager  
D) Azure Front Door with private origin  

---

**Q12.** Which statement about VNet Service Endpoints is CORRECT?

A) Service endpoints create a private IP address in the VNet for the service  
B) Service endpoints allow access from on-premises networks when connected via VPN  
C) Service endpoints optimize routing and allow VNet-specific firewall rules on services  
D) Service endpoints are free and replace Private Endpoints in all scenarios  

---

**Q13.** You need to configure NSG rules for an application. The web tier VMs should accept traffic from the internet on port 443. The app tier VMs should only accept traffic from web tier VMs. The database VMs should only accept traffic from app tier VMs. You want to avoid IP address management as VMs are added or removed. What should you use?

A) Service tags in NSG rules  
B) Application Security Groups (ASGs)  
C) Custom route tables  
D) Azure Firewall application rules  

---

**Q14.** Azure DDoS Protection Standard is enabled on a VNet. A volumetric DDoS attack occurs against a public IP address in the VNet. Mitigation starts automatically. What additional benefit does DDoS Protection Standard provide that the free infrastructure protection does NOT?

A) Protection against application-layer (L7) attacks  
B) Adaptive tuning, attack metrics, DDoS Rapid Response team access, and cost protection  
C) Protection for all Azure services globally, not just VNets  
D) Automatic blocking of all traffic during an attack  

---

**Q15.** You need to capture and analyze all network traffic processed by NSGs in a subscription for compliance purposes. Where are NSG flow logs stored?

A) Azure Monitor Metrics  
B) Azure Storage Account (blob containers)  
C) Log Analytics Workspace automatically  
D) Azure Event Hubs  

---

**Q16.** An Azure Firewall blocks traffic to `api.example.com` even though an application rule exists allowing it. The application uses HTTPS. What is the MOST likely cause?

A) Azure Firewall Premium is required for HTTPS filtering  
B) DNS resolution is failing; Azure Firewall cannot resolve the FQDN  
C) The application rule has a higher priority number than a network deny rule  
D) HTTPS traffic requires a separate network rule in addition to the application rule  

---

**Q17.** You need to allow a third-party monitoring tool running in your on-premises data center to access an Azure SQL Database server. The SQL server should NOT be accessible from the public internet. VPN connectivity between on-premises and Azure is already established. What is the BEST solution?

A) Configure a firewall rule on the SQL server to allow the on-premises IP range  
B) Create a service endpoint for SQL on the on-premises VPN connected subnet  
C) Deploy a private endpoint for the SQL server in the Azure VNet connected to on-premises via VPN  
D) Enable Azure AD authentication on the SQL server  

---

**Q18.** Which Azure Firewall rule type is used to translate an inbound request from a public IP on port 443 to an internal VM's private IP on port 443?

A) Application rule  
B) Network rule  
C) DNAT rule  
D) NAT gateway rule  

---

**Q19.** A company runs a globally distributed web application. They want to use a single Azure service that provides global load balancing, DDoS protection, WAF, SSL offloading, and CDN caching for static content. Which service should they use?

A) Azure Application Gateway with WAF  
B) Azure Traffic Manager + Application Gateway  
C) Azure Front Door with WAF policy  
D) Azure CDN + Azure Load Balancer  

---

**Q20.** You need to ensure that a critical application's NSG rules are audited over time and any changes are logged. Which solution is BEST?

A) Azure Policy with Audit effect on NSG resources  
B) Azure Activity Log with an alert rule on NSG write operations  
C) Network Watcher Flow Logs  
D) Microsoft Defender for Cloud NSG recommendations  

---

## ✅ Answers

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | C | The Internet service tag as source + specific destination + Allow at priority 100; the default DenyAllInBound (65500) blocks everything else. |
| 2 | B | IP Flow Verify tests whether specific traffic is allowed or denied by NSG rules, identifying which rule is responsible. |
| 3 | B | User-defined routes (UDR) with 0.0.0.0/0 pointing to Azure Firewall's private IP force all traffic through the firewall. |
| 4 | B | Private endpoint creates a private IP for storage in your VNet; disabling public access ensures no internet access. Service endpoints (A) don't disable public access. |
| 5 | A | Web categories require Azure Firewall Premium. Standard supports FQDN filtering but not category-based web filtering. |
| 6 | B | Azure Bastion provides browser-based RDP/SSH without public IPs or exposed ports with minimal admin effort. |
| 7 | C | WAF in Prevention mode actively blocks OWASP attacks including SQL injection and XSS. |
| 8 | D | AzureBastionSubnet requires a minimum /26 (64 addresses). |
| 9 | B | MACsec encrypts traffic at Layer 2 on ExpressRoute circuits. IPsec (A) is Layer 3. |
| 10 | A | For inbound traffic: Subnet-NSG is evaluated first, then NIC-NSG. For outbound: NIC-NSG first, then Subnet-NSG. |
| 11 | B | Private Link Service allows organizations to expose their services privately for others to connect via private endpoints. |
| 12 | C | Service endpoints optimize routing and allow configuring VNet-specific access rules on supported services. They do NOT create private IPs (A) or enable on-premises access (B). |
| 13 | B | Application Security Groups (ASGs) allow grouping VMs by role and writing NSG rules referencing the group, eliminating IP management. |
| 14 | B | DDoS Standard adds adaptive tuning, real-time attack metrics, DDoS Rapid Response team, and cost credits. It does NOT protect against L7 attacks (use WAF for that). |
| 15 | B | NSG flow logs are stored in Azure Storage Account blob containers. They can optionally be sent to Log Analytics via Traffic Analytics. |
| 16 | B | If DNS resolution fails, Azure Firewall cannot match the FQDN application rule. Ensure DNS is configured correctly (Azure Firewall DNS proxy recommended). |
| 17 | C | Private endpoint in the Azure VNet makes the SQL server accessible via private IP; accessible from on-premises via VPN. Firewall rules (A) still expose public endpoint. |
| 18 | C | DNAT rules translate inbound connections from a public IP to a private IP (Destination Network Address Translation). |
| 19 | C | Azure Front Door combines global load balancing, WAF, SSL offload, DDoS protection, and CDN in one service. |
| 20 | B | Azure Activity Log records all NSG modifications; alert rules trigger notifications on NSG write operations. Azure Policy (A) audits configuration state, not changes. |

---

[← Domain 2 Guide](../domains/02-secure-networking/README.md) | [Full Mock Exam →](full-mock-exam.md)
