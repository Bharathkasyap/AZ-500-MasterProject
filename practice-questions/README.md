# AZ-500 Practice Questions

← [Back to main README](../README.md)

This section contains **100+ practice questions** organized by domain, with detailed answers and explanations. Use these to test your knowledge and identify weak areas.

---

## How to Use This Section

1. Read each question carefully
2. Choose your answer before reading the explanation
3. Review the explanation to understand **why** each answer is correct or incorrect
4. Pay attention to the "Exam Tip" notes — these highlight common exam traps

---

## Domain 1: Manage Identity and Access

---

### Q1. Your organization requires that all Global Administrator role activations be approved by at least one approver and recorded. Which Azure AD feature should you implement?

**A)** Azure AD Conditional Access  
**B)** Azure AD Identity Protection  
**C)** Azure AD Privileged Identity Management (PIM)  
**D)** Azure AD Access Reviews  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Azure AD Privileged Identity Management (PIM)**

PIM provides just-in-time privileged access with configurable approval workflows. You can require that an eligible user obtain approval before activating the Global Administrator role, and all activations are logged in the PIM audit history.

- **A** is incorrect: Conditional Access enforces access policies but does not manage role activation approval workflows.
- **B** is incorrect: Identity Protection detects and responds to identity risks; it does not manage privileged role activation.
- **D** is incorrect: Access Reviews periodically review who has access, but do not manage the activation approval workflow.

> **Exam Tip**: PIM requires **Azure AD P2**. Know the difference between Eligible (JIT) and Active (permanent) role assignments.

</details>

---

### Q2. A developer needs to authenticate an Azure Function to Azure Key Vault without storing credentials in code or configuration. What is the MOST secure approach?

**A)** Create an Azure AD app registration and store the client secret in the Function's application settings  
**B)** Use a system-assigned managed identity on the Azure Function and grant it Key Vault Secrets User role  
**C)** Enable the storage account key rotation and reference the key in the Function  
**D)** Use a service principal with a certificate stored in the Function's file system  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — System-assigned managed identity**

Managed identities eliminate the need to store any credentials. The identity is automatically managed by Azure AD and associated with the Function's lifecycle. Granting `Key Vault Secrets User` role allows the Function to read secret values.

- **A** is incorrect: Storing client secrets in application settings is better than code, but still exposes a credential that can be leaked.
- **C** is incorrect: Storage account keys are not used for Key Vault authentication.
- **D** is incorrect: Storing certificates in the file system is risky; managed identity is the preferred approach.

</details>

---

### Q3. You need to block sign-ins from legacy authentication protocols for all users except five specific service accounts. What should you configure?

**A)** Azure AD Identity Protection user risk policy  
**B)** A Conditional Access policy with a condition for "Legacy authentication clients" and an exclusion for the five service accounts  
**C)** Azure AD Security defaults  
**D)** Per-user MFA for all users except the five service accounts  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Conditional Access policy with legacy auth condition and exclusion**

Conditional Access allows you to target "Legacy authentication clients" as a client app condition and apply a Block access grant control. You can exclude specific users (the five service accounts) from the policy.

- **A** is incorrect: Identity Protection user risk policy does not target authentication protocol type.
- **C** is incorrect: Security defaults block legacy auth for ALL users with no exceptions; you cannot exclude specific accounts.
- **D** is incorrect: Per-user MFA does not block legacy auth — it requires MFA on sign-in, but legacy auth cannot complete MFA challenges, so those sign-ins would fail rather than being explicitly blocked.

</details>

---

### Q4. An access review is configured for a Microsoft 365 group with "Auto-apply results" enabled and "If reviewers don't respond" set to "Remove access." After the review period ends, what happens to members whose reviewer did not submit a decision?

**A)** They retain access until manually reviewed  
**B)** They are removed from the group automatically  
**C)** They receive an email notification to self-certify  
**D)** Their access is suspended pending a new review  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — They are removed from the group automatically**

With "Auto-apply results" enabled and "If reviewers don't respond: Remove access," any member without a reviewer decision is automatically removed from the group when the review period ends.

</details>

---

### Q5. Which Azure AD license tier is the MINIMUM required to use Conditional Access policies?

**A)** Azure AD Free  
**B)** Microsoft 365 Apps  
**C)** Azure AD P1  
**D)** Azure AD P2  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Azure AD P1**

Conditional Access requires at minimum Azure AD P1 (or Microsoft 365 E3/Business Premium which includes P1). Azure AD P2 also includes Conditional Access (plus PIM and Identity Protection).

- **A/B** are incorrect: Free and M365 Apps editions do not include Conditional Access.
- **D** is incorrect: P2 works, but P1 is the minimum required.

</details>

---

### Q6. A user with the Security Reader role in Azure AD tries to dismiss a security alert in Microsoft Defender for Cloud. What happens?

**A)** The alert is dismissed  
**B)** The user is prompted to provide a justification, then the alert is dismissed  
**C)** The action fails because Security Reader is read-only  
**D)** The alert is moved to the "Under review" state  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — The action fails because Security Reader is read-only**

The **Security Reader** role provides read-only access to security center data. To dismiss alerts, the user needs at minimum **Security Admin** role (which has write access to security policies and alerts).

</details>

---

### Q7. Your organization needs users from a partner company (different Azure AD tenant) to collaborate in Microsoft Teams and access some SharePoint sites, while using their own company credentials. What feature should you use?

**A)** Azure AD B2C  
**B)** Azure AD B2B collaboration  
**C)** Azure AD External Identities with SAML federation  
**D)** Create duplicate accounts in your tenant for each partner user  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Azure AD B2B collaboration**

Azure AD B2B allows you to invite external users from other organizations to collaborate as **guest users** in your tenant. They authenticate with their own identity (their company Azure AD, Microsoft account, Google, etc.) and access your resources.

- **A** is incorrect: B2C is for customer-facing applications (consumers), not business partner collaboration.
- **C** is incorrect: SAML federation can be used for B2B but is not the primary mechanism described.
- **D** is incorrect: Creating duplicate accounts creates credential management overhead and is a security risk.

</details>

---

### Q8. Which permission type in Azure AD app registrations ALWAYS requires an admin to provide consent?

**A)** Delegated permissions  
**B)** Application permissions  
**C)** Scope permissions  
**D)** User-consented permissions  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Application permissions**

Application permissions (used by apps running without a signed-in user, like daemons/services) always require admin consent because they grant the app direct access to data, not on behalf of a user. Delegated permissions *may* require admin consent if the permission is sensitive, but many delegated permissions allow user consent.

</details>

---

## Domain 2: Secure Networking

---

### Q9. An NSG has the following inbound rules:
- Priority 100: Allow TCP port 443 from Internet to AppSubnet
- Priority 200: Deny all from Internet to AppSubnet
- Priority 65500: Deny all (default rule)

A request comes in on port 80 from the internet to a VM in AppSubnet. What happens?

**A)** Allowed by rule 100  
**B)** Denied by rule 200  
**C)** Denied by the default rule 65500  
**D)** Allowed because there is no explicit deny for port 80  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Denied by rule 200**

Rule 100 allows port 443 only. Port 80 does not match rule 100. The next rule (priority 200) denies **all** traffic from Internet to AppSubnet, which matches the port 80 request. Evaluation stops here.

> **Exam Tip**: NSG rules are evaluated in priority order (lowest number first). The first matching rule wins. "All" in the protocol/port means ANY.

</details>

---

### Q10. You need to restrict all Azure Storage account access so that only traffic from a specific subnet can reach it, while the storage account's public DNS name still resolves to a public IP. What should you configure?

**A)** A Private Endpoint for the storage account  
**B)** A VNet Service Endpoint on the subnet and a service firewall rule on the storage account  
**C)** A Network Security Group rule on the storage account  
**D)** An Azure Firewall application rule for the storage account FQDN  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — VNet Service Endpoint and service firewall rule**

Service endpoints route traffic from the subnet to Azure Storage over the Azure backbone while the storage account's public IP is still used (public DNS name still resolves to public IP). The firewall rule on the storage account restricts access to only the configured subnet.

- **A** is incorrect: Private Endpoints assign a private IP and change DNS resolution to the private IP — the public DNS name no longer resolves to the public IP when properly configured.
- **C** is incorrect: You cannot attach NSG rules directly to storage accounts.
- **D** is incorrect: Azure Firewall rules control traffic flow but do not restrict storage account access itself.

</details>

---

### Q11. Azure Firewall processes rules in which order?

**A)** Application rules → Network rules → DNAT rules  
**B)** Network rules → Application rules → DNAT rules  
**C)** DNAT rules → Network rules → Application rules  
**D)** DNAT rules → Application rules → Network rules  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — DNAT rules → Network rules → Application rules**

Azure Firewall processes rules in this strict order:
1. DNAT rules (inbound translation)
2. Network rules (L3/L4 IP/port filtering)
3. Application rules (L7 FQDN filtering)

Once a rule matches, processing stops for that traffic.

</details>

---

### Q12. Your company wants to allow employees to connect to Azure VMs for administration without opening RDP or SSH ports in NSGs or assigning public IPs to VMs. What Azure service should you deploy?

**A)** Azure VPN Gateway Point-to-Site  
**B)** Azure Bastion  
**C)** Azure Application Gateway  
**D)** Just-in-Time VM Access  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Azure Bastion**

Azure Bastion provides RDP/SSH access to VMs via the Azure portal over TLS 443, without requiring public IPs or open NSG ports on the VMs. It's a fully managed PaaS service deployed in a dedicated subnet.

- **A** is incorrect: P2S VPN provides network-level access but still requires open RDP/SSH ports on the VMs once connected.
- **C** is incorrect: Application Gateway is a load balancer with WAF for web apps, not VM administration.
- **D** is incorrect: JIT opens NSG ports temporarily — it still uses RDP/SSH ports, just time-limited.

</details>

---

### Q13. You configure a WAF on Azure Application Gateway. Security alerts are being logged but attacks are not being blocked. What is the likely cause?

**A)** The WAF rule set is outdated  
**B)** The WAF is in Detection mode instead of Prevention mode  
**C)** The WAF requires a dedicated public IP  
**D)** Custom WAF rules are overriding managed rules  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Detection mode instead of Prevention mode**

WAF's default mode is **Detection** — it logs threats but does not block them. To actively block attacks, you must switch the WAF policy to **Prevention mode**.

</details>

---

### Q14. Which DDoS protection tier includes adaptive tuning based on your traffic patterns, a rapid response team, and a cost protection guarantee?

**A)** Infrastructure Protection (free tier)  
**B)** DDoS IP Protection  
**C)** DDoS Network Protection  
**D)** Azure Firewall Premium  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — DDoS Network Protection**

DDoS Network Protection (formerly DDoS Standard) is the paid per-VNet tier that includes:
- Adaptive ML-based tuning
- Attack analytics and telemetry
- Microsoft DDoS rapid response team
- SLA-backed cost protection guarantee for scaling costs during attacks

- **A** is incorrect: Free tier only provides basic volumetric mitigation, no adaptive tuning or SLA.
- **B** is incorrect: DDoS IP Protection is a per-IP tier with basic mitigation; no adaptive tuning or rapid response team.

</details>

---

### Q15. Which tool in Azure Network Watcher would you use to determine WHY traffic from VM-A to VM-B is being blocked, and WHICH NSG rule is responsible?

**A)** Connection Monitor  
**B)** NSG Flow Logs  
**C)** IP Flow Verify  
**D)** Next Hop  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — IP Flow Verify**

IP Flow Verify checks whether a specific flow (defined by source IP, destination IP, port, protocol) is allowed or denied for a VM's NIC, and identifies the specific NSG rule that is making the decision.

- **A** is incorrect: Connection Monitor tests ongoing connectivity but doesn't identify specific NSG rules.
- **B** is incorrect: NSG Flow Logs record traffic but require manual analysis to find which rule applied.
- **D** is incorrect: Next Hop identifies the routing path (which UDR or default route applies), not NSG rule details.

</details>

---

## Domain 3: Secure Compute, Storage, and Databases

---

### Q16. What is the MINIMUM Microsoft Defender for Cloud plan required to use Just-in-Time VM Access?

**A)** Defender for Cloud Free (CSPM only)  
**B)** Defender for Servers Plan 1  
**C)** Defender for Servers Plan 2  
**D)** Defender for Resource Manager  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Defender for Servers Plan 2**

JIT VM Access is a feature of **Defender for Servers Plan 2**. Plan 1 includes Defender for Endpoint integration but not JIT access, file integrity monitoring, or adaptive application controls.

</details>

---

### Q17. A developer stored a connection string as a Key Vault secret. They have the **Key Vault Reader** role assigned. When they try to retrieve the secret value in the Azure portal, what happens?

**A)** They can read the secret value  
**B)** They can see the secret exists (its name) but cannot read its value  
**C)** They receive an "Access Denied" error and cannot see the secret at all  
**D)** They can read the secret value but cannot see its metadata  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — They can see the secret exists but cannot read its value**

The **Key Vault Reader** role allows reading metadata (secret names, properties) but does NOT allow reading secret values. To read values, they need the **Key Vault Secrets User** role.

> **Exam Tip**: This is a commonly tested distinction. Reader = metadata only; Secrets User = can read values.

</details>

---

### Q18. You need to ensure that a Key Vault secret cannot be permanently deleted for at least 90 days after deletion, even by a Global Administrator. What should you enable?

**A)** Soft delete with a 90-day retention period  
**B)** Soft delete AND Purge protection  
**C)** Key Vault logging  
**D)** Private endpoint for the Key Vault  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Soft delete AND Purge protection**

- **Soft delete** alone allows recovery for the retention period, but a user with sufficient permissions can still permanently delete (purge) the object.
- **Purge protection** prevents ANY user (including Global Admins and vault owners) from permanently deleting objects during the retention period.

Both are needed to prevent permanent deletion for 90 days.

</details>

---

### Q19. An Azure SQL Database has Transparent Data Encryption (TDE) enabled with a customer-managed key (BYOK) stored in Azure Key Vault. The Key Vault key is accidentally deleted. What happens to the database?

**A)** The database continues to operate normally using a cached copy of the key  
**B)** The database becomes inaccessible immediately  
**C)** TDE automatically falls back to service-managed encryption  
**D)** The database is automatically backed up before becoming inaccessible  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — The database becomes inaccessible immediately**

When the TDE protector (CMK in Key Vault) is deleted or access is revoked, Azure SQL cannot decrypt the TDE encryption keys, making the database inaccessible. This is why **Purge protection on Key Vault is critical** for databases using BYOK TDE.

</details>

---

### Q20. A junior developer needs to be able to encrypt and decrypt data using an Azure Key Vault key, but should NOT be able to create, delete, or view key material. Which built-in RBAC role should you assign?

**A)** Key Vault Administrator  
**B)** Key Vault Crypto Officer  
**C)** Key Vault Crypto User  
**D)** Key Vault Reader  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Key Vault Crypto User**

**Key Vault Crypto User** can perform cryptographic operations (encrypt, decrypt, sign, verify, wrap/unwrap) but cannot manage keys (create, delete, update). This follows the principle of least privilege.

- **B** is incorrect: Crypto Officer can create, delete, and update keys.

</details>

---

### Q21. Which Azure Storage SAS type uses Azure AD credentials for signing and does NOT expose the storage account key?

**A)** Account SAS  
**B)** Service SAS  
**C)** User Delegation SAS  
**D)** Stored Access Policy SAS  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — User Delegation SAS**

User Delegation SAS is signed using Azure AD credentials (via `az storage blob generate-sas --auth-mode login`) instead of the storage account key. This is the most secure SAS type because:
- The storage key is never exposed
- The SAS is tied to the Azure AD identity's permissions
- Can be revoked by revoking the Azure AD permissions

</details>

---

### Q22. You need to scan container images in Azure Container Registry (ACR) for known vulnerabilities every time a new image is pushed. What should you enable?

**A)** ACR Content Trust (Notary)  
**B)** Microsoft Defender for Containers  
**C)** ACR geo-replication  
**D)** ACR retention policies  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Microsoft Defender for Containers**

Defender for Containers scans images pushed to ACR for CVE vulnerabilities. It scans on push, on pull (for recently pushed images), and on a periodic schedule.

- **A** is incorrect: Content Trust verifies image signatures but does not scan for vulnerabilities.
- **C/D** are incorrect: Geo-replication and retention policies are operational features, not security scanning.

</details>

---

### Q23. Which feature in Azure SQL Database obfuscates column data in query results for non-privileged users, without changing the actual data stored in the database?

**A)** Transparent Data Encryption (TDE)  
**B)** Always Encrypted  
**C)** Dynamic Data Masking  
**D)** Row-Level Security  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Dynamic Data Masking**

Dynamic Data Masking replaces sensitive column values in query results with masked versions (e.g., credit card `4111 1111 1111 1111` becomes `XXXX XXXX XXXX 1111`) for users without explicit unmask permissions. The actual stored data is unchanged.

- **A** is incorrect: TDE encrypts the database files at rest; it's transparent to all users and doesn't mask query results.
- **B** is incorrect: Always Encrypted encrypts data at the client; the server sees only encrypted values and the data appears encrypted even to DBA accounts.
- **D** is incorrect: Row-Level Security restricts which ROWS a user can see, not column values.

</details>

---

## Domain 4: Manage Security Operations

---

### Q24. You want Microsoft Sentinel to automatically disable a user account in Azure AD when a high-severity "Impossible Travel" incident is created. What should you configure?

**A)** A Sentinel Analytics Rule with a KQL alert condition  
**B)** A Sentinel Playbook triggered by an incident  
**C)** A Sentinel Automation Rule that closes the incident  
**D)** A Defender for Cloud workflow automation  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — A Sentinel Playbook triggered by an incident**

Playbooks (Logic Apps) can be triggered by Sentinel incidents and perform actions via connectors — including disabling Azure AD users. You'd use the Azure AD connector's "Disable user account" action.

- **A** is incorrect: Analytics rules detect threats and create alerts/incidents; they don't perform automated response actions.
- **C** is incorrect: Automation rules can run playbooks, but an automation rule alone cannot disable accounts — it needs a playbook to take that action.
- **D** is incorrect: Defender for Cloud workflow automation is separate from Sentinel; appropriate for Defender-generated alerts.

</details>

---

### Q25. Which KQL query would identify users with more than 10 failed sign-in attempts in the last hour?

**A)**
```kusto
SigninLogs | where TimeGenerated > ago(1h) | where ResultType == "0" | summarize count() by UserPrincipalName | where count_ > 10
```

**B)**
```kusto
SigninLogs | where TimeGenerated > ago(1h) | where ResultType != "0" | summarize FailedAttempts = count() by UserPrincipalName | where FailedAttempts > 10
```

**C)**
```kusto
AuditLogs | where TimeGenerated > ago(1h) | summarize count() by InitiatedBy | where count_ > 10
```

**D)**
```kusto
SecurityAlert | where TimeGenerated > ago(1h) | where AlertSeverity == "High" | summarize count() by UserPrincipalName
```

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B**

In Azure AD sign-in logs, `ResultType = "0"` means **success**. Failed sign-ins have a non-zero ResultType (e.g., 50126 = invalid credentials). Option B correctly filters for failed sign-ins (`!= "0"`), counts them per user, and filters for users with more than 10 failures.

- **A** is incorrect: `ResultType == "0"` counts successful sign-ins, not failures.
- **C** is incorrect: AuditLogs records directory changes, not sign-in events.
- **D** is incorrect: SecurityAlert table shows security alerts, not sign-in events.

</details>

---

### Q26. An Azure Activity Log alert is triggered when a new role assignment is made at the subscription level. Where should you configure this alert?

**A)** Microsoft Sentinel Analytics Rules  
**B)** Azure Monitor Activity Log alert  
**C)** Microsoft Defender for Cloud alert suppression rule  
**D)** Azure AD audit log diagnostic settings  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Azure Monitor Activity Log alert**

Azure Activity Log alerts fire when specific control-plane operations occur, such as `Microsoft.Authorization/roleAssignments/write`. This is natively configured in Azure Monitor.

- **A** is incorrect: Sentinel can also detect this, but the Azure Monitor Activity Log alert is the native, lightweight approach.
- **C** is incorrect: Suppression rules reduce noise; they don't generate alerts.
- **D** is incorrect: Diagnostic settings configure log destinations; they don't create alerts.

</details>

---

### Q27. Microsoft Sentinel has a built-in analytics rule that uses machine learning to correlate multiple low-fidelity signals across different data sources to detect sophisticated multi-stage attacks. What rule type is this?

**A)** Scheduled rule  
**B)** NRT (Near Real-Time) rule  
**C)** Fusion rule  
**D)** Anomaly rule  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Fusion rule**

Fusion uses ML to correlate signals across multiple data sources and detection sources to identify multi-stage attacks (e.g., credential theft followed by lateral movement followed by data exfiltration). It's designed to reduce false positives by requiring multiple correlated signals.

- **D** is incorrect: Anomaly rules detect behavioral deviations for individual entities but don't correlate across multiple attack stages.

</details>

---

### Q28. You need to ensure that all Azure resources in a subscription have a specific tag ("Environment") applied, and that resources cannot be created without it. What Azure feature should you use?

**A)** Azure Policy with Deny effect  
**B)** Azure RBAC custom role  
**C)** Azure Blueprints  
**D)** Azure Resource Manager template  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: A — Azure Policy with Deny effect**

An Azure Policy with the **Deny** effect and a condition that checks for the absence of the "Environment" tag will block resource creation/modification when the tag is not present.

- **B** is incorrect: RBAC controls who can take actions; it doesn't enforce resource configuration.
- **C** is incorrect: Blueprints can include policy assignments, but the underlying mechanism is still Azure Policy.
- **D** is incorrect: ARM templates define resource configurations but don't enforce them on all resources in a subscription.

</details>

---

### Q29. A security analyst needs to investigate a Sentinel incident. They want to see all entities (users, IPs, hosts) involved in the incident and the relationships between them. Which Sentinel feature should they use?

**A)** Threat Hunting queries  
**B)** Investigation graph  
**C)** Workbooks  
**D)** Analytics rule MITRE ATT&CK mapping  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Investigation graph**

The Sentinel Investigation graph provides a visual representation of an incident, showing all mapped entities (users, IPs, hosts, files) and their relationships. Analysts can click on entities to see related events and drill down into the timeline.

</details>

---

### Q30. Which diagnostic log destination should you use if you need to retain Azure AD sign-in logs for 2 years for compliance auditing, and need to be able to query them efficiently?

**A)** Send to Azure Storage account (archive tier)  
**B)** Send to Log Analytics workspace with 2-year retention configured  
**C)** Keep in Azure AD (default retention is sufficient)  
**D)** Send to Azure Event Hub and stream to an on-premises SIEM  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Log Analytics workspace with 2-year retention**

Log Analytics supports data retention up to 730 days (2 years) and enables efficient KQL queries. For compliance purposes where you also need to query the data, Log Analytics is the best choice.

- **A** is incorrect: Storage is suitable for long-term archival but querying archived data is cumbersome and not directly supported by KQL.
- **C** is incorrect: Azure AD retains sign-in logs for only 7 days (free) or 30 days (P1/P2).
- **D** is incorrect: Event Hub is designed for real-time streaming, not archival and querying.

</details>

---

## Additional Mixed Questions

---

### Q31. What is the default behavior of a new Azure storage account regarding public blob access?

**A)** All blobs are publicly accessible  
**B)** Container-level access is allowed but individual blob access is blocked  
**C)** Public access is disabled at the storage account level  
**D)** Public access requires a SAS token  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Public access is disabled at the storage account level**

Starting in November 2023, new Azure storage accounts have public blob access disabled by default at the account level. Even if an individual container is configured for public access, the account-level setting overrides it.

</details>

---

### Q32. A Conditional Access policy has the following configuration:
- Users: All users
- Cloud apps: Microsoft Azure Management
- Grant: Block access
- Exclusions: Group "AzureAdmins"

A member of "AzureAdmins" who is also a Global Administrator tries to access the Azure portal. What happens?

**A)** Access is blocked because the policy applies to all users  
**B)** Access is allowed because Global Administrators bypass all Conditional Access policies  
**C)** Access is allowed because the user is in the excluded "AzureAdmins" group  
**D)** Access is blocked and the user must use PIM to activate their role first  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Access is allowed because the user is in the excluded group**

Conditional Access policy exclusions override the user assignment. A user in an excluded group is not subject to the policy, regardless of their other roles or group memberships.

> **Important**: Global Administrators do NOT automatically bypass Conditional Access policies in modern Azure AD configurations. They are subject to CA policies unless explicitly excluded.

</details>

---

### Q33. You need to ensure that virtual machines in a production subscription cannot be created without disk encryption enabled. You want this enforced automatically without manual review. What should you implement?

**A)** Azure Policy with Audit effect  
**B)** Azure Policy with Deny effect  
**C)** Microsoft Defender for Cloud recommendation  
**D)** Azure Blueprints locked assignment  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Azure Policy with Deny effect**

A Policy with **Deny** effect blocks the resource creation/modification operation if the policy condition is not met. This prevents VMs from being created without disk encryption enabled, enforcing it at deployment time.

- **A** is incorrect: Audit reports non-compliance but does not block creation.
- **C** is incorrect: Defender for Cloud recommendations suggest improvements but don't block deployment.
- **D** is incorrect: Blueprints can include denied policies, but the effect is still an Azure Policy Deny.

</details>

---

### Q34. Which Azure AD feature lets you define rules like "Users whose Department equals Engineering are automatically members of the Engineering-Security-Group"?

**A)** Access packages in Azure AD Entitlement Management  
**B)** Dynamic group membership  
**C)** Azure AD Connect group sync  
**D)** Administrative units  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Dynamic group membership**

Dynamic groups use attribute-based rules (e.g., `user.department -eq "Engineering"`) to automatically manage group membership. Requires Azure AD P1 or P2.

</details>

---

### Q35. An attacker has compromised an Azure storage account key. What is the FASTEST way to invalidate the compromised key without disrupting applications that use the other storage account key?

**A)** Delete the storage account and recreate it  
**B)** Regenerate the compromised key (Key 1 or Key 2)  
**C)** Disable public access on the storage account  
**D)** Apply a storage firewall rule to block all IPs  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Regenerate the compromised key**

Azure Storage accounts have two keys (key1 and key2) precisely for rotation without disruption. Regenerating the compromised key (e.g., key1) immediately invalidates it. Applications using key2 continue to work uninterrupted. Then update applications to use the regenerated key1 and rotate key2.

</details>

---

*Continue practicing with official [Microsoft Learn practice assessments](https://learn.microsoft.com/en-us/certifications/exams/az-500) and third-party mock exams listed in the [main README](../README.md).*
