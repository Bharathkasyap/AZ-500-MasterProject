# Domain 2 — Practice Questions: Secure Networking

> **Instructions**: Choose the best answer(s) for each question. Answers and explanations are at the bottom of the file.

---

## Questions

### Q1
A company wants to protect their web application from OWASP Top 10 attacks. They are using an Azure Application Gateway as their load balancer. Which feature should they enable?

A) Azure DDoS Protection Standard  
B) Web Application Firewall (WAF) on Application Gateway  
C) Azure Firewall Premium  
D) Network Security Group (NSG) with custom rules

---

### Q2
An Azure VM must be accessible via RDP for administrative purposes. The security team does not want a public IP address assigned to the VM, and they want to avoid using a VPN. What is the BEST solution?

A) Create an NSG rule allowing RDP from any source  
B) Deploy Azure Bastion in the same VNet  
C) Assign a private IP to the VM and use a Point-to-Site VPN  
D) Enable Just-in-Time VM access via Defender for Servers

---

### Q3
A company uses an Azure Firewall to filter outbound internet traffic. They want to block all websites except for a specific list of trusted FQDNs. Which rule type should they configure?

A) Network rules with IP-based filtering  
B) DNAT rules with FQDN-based destination  
C) Application rules with FQDN targets  
D) NAT rules with URL path filtering

---

### Q4
A team deploys an NSG with the following inbound rules:
- Priority 100: Allow TCP 443 from Internet
- Priority 200: Allow TCP 22 from 10.0.0.0/8
- Priority 300: Deny TCP 22 from Any

A developer tries to SSH into a VM using a public IP. What happens?

A) SSH is allowed because port 22 is only denied from Any, not from public IPs  
B) SSH is blocked by the Deny rule at priority 300  
C) SSH is blocked by the default DenyAllInBound rule  
D) SSH is allowed because the Allow rule at priority 200 takes precedence over priority 300

---

### Q5
An organization wants to prevent Azure Storage accounts in a specific VNet from being accessed via the public internet. Which approach uses a PRIVATE IP address for the storage endpoint?

A) VNet Service Endpoint  
B) Private Endpoint  
C) Storage account firewall with selected networks  
D) NSG with outbound deny rules for public storage IPs

---

### Q6
A company's web application is receiving volumetric DDoS attacks exceeding 10 Gbps. They are currently using **Azure DDoS Basic (Infrastructure)**. What should they do?

A) Add more Azure Firewall rules to block attack traffic  
B) Scale up their Application Gateway SKU  
C) Enable **Azure DDoS Network Protection** on the VNet  
D) Configure an NSG to block traffic from the attacking IPs

---

### Q7
A company uses **Azure Virtual WAN** and wants to centralize security policy management for multiple Azure Firewalls. Which Azure service should they use?

A) Azure Policy  
B) Azure Firewall Manager  
C) Azure Monitor  
D) Microsoft Defender for Cloud

---

### Q8
A developer needs to allow on-premises servers to connect to an Azure SQL Database using a private connection, without the traffic traversing the internet. The DNS resolution from on-premises must also resolve to the private IP. Which combination of features is required?

A) Service endpoint on the VNet + Azure SQL firewall rule  
B) Private endpoint + private DNS zone linked to the on-premises DNS server  
C) Azure VPN Gateway + Azure SQL public endpoint  
D) ExpressRoute + NSG inbound rule on the SQL subnet

---

### Q9
An Azure Firewall is deployed in a hub VNet. The team notices that it is using the Standard SKU but needs to inspect TLS-encrypted HTTPS traffic for malware. What action should they take?

A) Add an Application rule in the existing Standard firewall for HTTPS  
B) Enable Threat Intelligence on the Standard firewall  
C) Upgrade to Azure Firewall Premium and enable TLS inspection  
D) Deploy a WAF policy on Application Gateway

---

### Q10
An administrator creates an NSG and applies it to a subnet. The subnet contains two VMs: VM-A and VM-B. The NSG has a rule that denies all inbound traffic from the internet. VM-A also has an NSG applied directly to its NIC that allows RDP from the internet. Can the administrator RDP into VM-A from the internet?

A) Yes — NIC-level NSGs override subnet-level NSGs  
B) No — subnet-level NSGs are evaluated first and take precedence  
C) No — traffic is denied by both NSGs; the deny at the subnet level blocks it  
D) Yes — but only if there is a route table entry pointing to the NIC's public IP

---

### Q11
What is the MINIMUM subnet size required to deploy Azure Bastion in a VNet?

A) /28  
B) /27  
C) /26  
D) /24

---

### Q12
A company wants to implement a hub-and-spoke network topology in Azure. Which of the following should be deployed in the HUB VNet? *(Select all that apply)*

A) Azure Firewall  
B) Application workload VMs  
C) VPN Gateway / ExpressRoute Gateway  
D) Azure Bastion  
E) Production databases

---

### Q13
A company is connecting their on-premises data center to Azure using ExpressRoute. To comply with regulatory requirements, they need to encrypt the ExpressRoute connection at Layer 2. Which technology should they use?

A) IPsec over ExpressRoute  
B) MACsec  
C) TLS over ExpressRoute  
D) Site-to-Site VPN over ExpressRoute

---

### Q14
Which of the following is a key DIFFERENCE between Azure Firewall and NSGs?

A) NSGs can filter by FQDN; Azure Firewall cannot  
B) Azure Firewall is a stateful, managed service with logging and FQDN support; NSGs are stateful packet filters without FQDN support  
C) Azure Firewall operates at Layer 4 only; NSGs operate at Layer 7  
D) NSGs can only be applied to VMs; Azure Firewall can be applied to subnets

---

### Q15
A security team needs to detect and prevent SQL injection attacks against a web application hosted behind an Azure Application Gateway. Which feature should they enable?

A) Azure Firewall Application rules with SQL FQDN  
B) WAF on Application Gateway in **Prevention** mode with OWASP 3.2  
C) Azure DDoS Network Protection with custom rules  
D) NSG application rules with SQL injection signatures

---

## Answers and Explanations

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | **B** | WAF on Application Gateway is purpose-built for Layer 7 HTTP/HTTPS protection including OWASP Top 10. DDoS Protection (A) handles volumetric attacks. Azure Firewall (C) can do some Layer 7 but is not a WAF. |
| 2 | **B** | Azure Bastion provides browser-based RDP/SSH without a public IP or VPN. JIT (D) is also valid but still requires either a public IP or Bastion. Bastion is the best answer because it removes the public IP entirely. |
| 3 | **C** | Application rules in Azure Firewall support FQDN-based filtering for outbound web traffic. Network rules (A) work on IPs/ports, not FQDNs. |
| 4 | **B** | The developer is coming from a public IP, not the 10.0.0.0/8 range. Priority 200 does NOT match public IPs. Priority 300 (Deny TCP 22 from Any) is evaluated next and matches — SSH is denied. |
| 5 | **B** | Private Endpoint creates a NIC with a private IP in your VNet. Service Endpoints (A) keep the traffic on the backbone but the service still has a public IP — no private IP is created in your VNet. |
| 6 | **C** | Azure DDoS Network Protection provides adaptive tuning and rapid response for large-scale volumetric attacks. Basic/Infrastructure protection only protects Azure infrastructure at minimal levels. |
| 7 | **B** | Azure Firewall Manager is specifically designed for centralized security policy management across multiple Azure Firewalls, including those in Azure Virtual WAN. |
| 8 | **B** | Private Endpoint creates a private IP for Azure SQL in the VNet. The private DNS zone must be linked to the on-premises DNS so that the FQDN resolves to the private IP from on-premises as well. |
| 9 | **C** | TLS inspection is a **Premium-only** feature. Standard Azure Firewall cannot decrypt and inspect HTTPS traffic. Upgrading to Premium and enabling TLS inspection allows deep packet inspection of encrypted traffic. |
| 10 | **C** | In Azure, traffic to a VM passes through BOTH the subnet NSG AND the NIC NSG. The subnet-level deny is evaluated first for inbound traffic; since it denies all internet traffic, RDP is blocked regardless of the NIC rule. |
| 11 | **C** | Azure Bastion requires a subnet named **AzureBastionSubnet** with a minimum size of **/26** (64 addresses). |
| 12 | **A, C, D** | The hub hosts shared services: firewall, gateways, and Bastion. Application VMs (B) and databases (E) belong in spoke VNets. |
| 13 | **B** | **MACsec** encrypts at Layer 2 (Ethernet level) on ExpressRoute Direct connections. IPsec (A) operates at Layer 3 (IP level), not Layer 2. |
| 14 | **B** | Azure Firewall is a full Layer 4–7 stateful firewall with FQDN support, threat intelligence, and comprehensive logging. NSGs are Layer 3–4 stateful packet filters — they do not support FQDNs or Layer 7 inspection. |
| 15 | **B** | WAF in Prevention mode with OWASP 3.2 actively blocks SQL injection and other OWASP Top 10 attacks. Detection mode would only log them. |
