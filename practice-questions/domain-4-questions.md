# Domain 4 — Practice Questions: Manage Security Operations

> **Instructions**: Choose the best answer(s) for each question. Answers and explanations are at the bottom of the file.

---

## Questions

### Q1
A security analyst wants to find all failed Azure AD sign-in attempts in the last 24 hours using Microsoft Sentinel. Which KQL query is CORRECT?

A)
```kql
AzureActivity | where OperationName == "Sign-in failed" | where TimeGenerated > ago(24h)
```

B)
```kql
SigninLogs | where TimeGenerated > ago(24h) | where ResultType != "0"
```

C)
```kql
AuditLogs | where TimeGenerated > ago(24h) | where Status == "Failed"
```

D)
```kql
SecurityEvent | where TimeGenerated > ago(24h) | where EventID == 4624
```

---

### Q2
A company wants to automatically block an IP address in Azure Firewall when Microsoft Sentinel raises a high-severity alert. Which Sentinel feature should they use?

A) Analytics rule with a scheduled query  
B) Workbook with alert thresholds  
C) Playbook triggered by the analytics rule  
D) UEBA with IP entity tracking

---

### Q3
An organization wants to measure their security posture against the **NIST SP 800-53** framework using Microsoft Defender for Cloud. What should they do?

A) Create a custom Azure Policy initiative that maps to NIST controls  
B) In the Regulatory Compliance dashboard, add the NIST SP 800-53 standard  
C) Configure Azure Monitor alerts based on NIST control categories  
D) Enable Microsoft Sentinel with the NIST SP 800-53 workbook

---

### Q4
A security team uses Microsoft Defender for Cloud and notices that the **Secure Score** has decreased by 5%. What is the MOST likely cause?

A) New VMs were deployed without completing all security recommendations  
B) A playbook failed to execute  
C) The Log Analytics workspace was deleted  
D) A Conditional Access policy was disabled

---

### Q5
A company wants to ensure that all Azure resources in a subscription have **diagnostic logs** sent to a central Log Analytics workspace. They want this to be enforced automatically on new resources. Which solution achieves this?

A) Create an Azure Monitor alert for each resource type  
B) Use the Azure Policy **DeployIfNotExists** effect to auto-deploy diagnostic settings  
C) Manually configure diagnostic settings for each resource via the Azure portal  
D) Use Azure Security Center's workflow automation to configure logging

---

### Q6
An analytics rule in Microsoft Sentinel is generating too many false positive incidents. The security team wants to suppress incidents that match a specific IP address for a period of time. Which Sentinel feature should they use?

A) Automation rule to close incidents from that IP  
B) Modify the analytics rule KQL to exclude the IP  
C) Create a watchlist containing the trusted IP and use it in the analytics rule's KQL  
D) Disable the analytics rule entirely

---

### Q7
A company ingests 50 GB of logs per day into Microsoft Sentinel. Which pricing model typically provides the LOWEST cost at this volume?

A) Pay-as-you-go (per GB ingested)  
B) Commitment tier (e.g., 50 GB/day commitment)  
C) Free tier (first 5 GB per month free)  
D) Microsoft 365 E5 Security bundle pricing

---

### Q8
A Defender for Cloud recommendation states: *"Endpoint protection should be installed on your virtual machines."* The operations team has already installed a third-party EDR solution on the VMs, but Defender still shows them as non-compliant. What should the security team do?

A) Install Microsoft Antimalware alongside the third-party EDR  
B) Exempt the VMs from the recommendation using a Defender for Cloud exemption  
C) Disable the endpoint protection recommendation in Defender for Cloud  
D) Uninstall the third-party EDR and use Defender for Endpoint only

---

### Q9
A Microsoft Sentinel analytics rule should fire when **more than 5 failed login attempts** occur from the **same IP address** within **10 minutes**. Which KQL construct is needed?

A) `join` — to correlate events across two tables  
B) `summarize count() by IPAddress` combined with a `where count_ > 5` filter  
C) `extend` — to add a new calculated column  
D) `project` — to select specific columns

---

### Q10
An administrator configures a **DeployIfNotExists** Azure Policy to automatically enable Microsoft Defender for Storage on all storage accounts. The policy evaluates successfully, but some existing storage accounts are still non-compliant. What should the administrator do?

A) Wait — the policy will deploy automatically within 24 hours  
B) Trigger a **remediation task** on the policy assignment  
C) Delete and recreate the non-compliant storage accounts  
D) Change the policy effect from DeployIfNotExists to Modify

---

### Q11
A company uses Microsoft Sentinel and wants to detect when a user logs in from two different countries within a 1-hour period (impossible travel). Which Sentinel feature detects this WITHOUT writing a custom KQL rule?

A) Scheduled analytics rule  
B) Fusion rule  
C) UEBA anomaly detection  
D) Microsoft Security analytics rule

---

### Q12
A security engineer needs to integrate logs from an on-premises Palo Alto firewall into Microsoft Sentinel. The firewall can send logs in CEF (Common Event Format) over Syslog. What is required in Azure?

A) Deploy a Log Analytics workspace agent (AMA) on an Azure VM as a Syslog/CEF forwarder  
B) Configure an Event Hub to receive Syslog messages from the firewall  
C) Use the Azure Sentinel REST API to push logs from the firewall  
D) Connect the firewall directly to the Sentinel workspace using a TAXII connector

---

### Q13
A company's Defender for Cloud Secure Score shows that the control *"Enable MFA"* has a max score of 10 points, but the current earned points is 0. Which remediation action would MOST directly increase the Secure Score for this control?

A) Enable Microsoft Defender for Identity  
B) Enable Conditional Access policies requiring MFA for all users  
C) Enable per-user MFA enforcement in Azure AD legacy MFA settings  
D) Deploy Privileged Identity Management (PIM) for all admin roles

---

### Q14
A security team wants to be notified via email when a new high-severity security alert is raised in Defender for Cloud. What is the CORRECT configuration path?

A) Microsoft Sentinel → Analytics → Create a new analytics rule  
B) Defender for Cloud → Environment Settings → Email notifications  
C) Azure Monitor → Alerts → Create alert rule based on Log Analytics  
D) Azure AD → Security → Identity Protection → Alerts

---

### Q15
An organization uses both Microsoft Sentinel and Microsoft Defender XDR. They want to manage all security incidents from a single portal. Which portal should they use?

A) Azure portal (portal.azure.com)  
B) Microsoft Sentinel workspace portal  
C) Microsoft Defender portal (security.microsoft.com)  
D) Microsoft Purview compliance portal

---

## Answers and Explanations

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | **B** | `SigninLogs` is the correct table for Azure AD sign-in data in Sentinel/Log Analytics. `ResultType != "0"` filters out successful sign-ins (ResultType 0 = success). `AuditLogs` (C) captures directory operations, not sign-ins. `SecurityEvent` (D) captures Windows events; EventID 4624 is a *successful* logon. |
| 2 | **C** | Playbooks (Azure Logic Apps) are the SOAR component of Sentinel. They can be triggered by analytics rules and automate responses such as blocking an IP in Azure Firewall via its REST API. |
| 3 | **B** | The Regulatory Compliance dashboard in Defender for Cloud supports adding industry standards including NIST SP 800-53. This automatically maps recommendations to NIST controls. |
| 4 | **A** | New resources are assessed against security recommendations. If new VMs were deployed with open management ports, missing disk encryption, etc., the Secure Score decreases because the ratio of completed controls decreases. |
| 5 | **B** | `DeployIfNotExists` automatically deploys the diagnostic settings resource on new or updated resources that don't already have it configured. This is the correct Azure Policy effect for this scenario. |
| 6 | **C** | Creating a **watchlist** with trusted IPs and filtering them out in the KQL query is the recommended approach. An **automation rule** (A) can close the incident but wastes resources generating it. Modifying the rule directly (B) is also valid but watchlists are more maintainable. |
| 7 | **B** | At 50 GB/day, a **commitment tier** (50 GB/day) typically provides a significant discount (20–30%) over pay-as-you-go pricing. The free tier only covers 5 GB per month. |
| 8 | **B** | Defender for Cloud allows **exemptions** on recommendations for specific resources. This marks the VMs as "exempt" (rather than non-compliant) and removes them from the Secure Score calculation. |
| 9 | **B** | `summarize count() by IPAddress` counts events per IP. `where count_ > 5` filters to IPs with more than 5 events. `bin(TimeGenerated, 10m)` is also needed to window the 10-minute timeframe. |
| 10 | **B** | `DeployIfNotExists` policies require a **remediation task** to be triggered for existing non-compliant resources. New resources created after the policy assignment are automatically remediated. |
| 11 | **C** | **UEBA anomaly detection** (Anomaly rule type in Sentinel) includes built-in impossible travel detection. Fusion rules (B) correlate low-fidelity signals into high-fidelity incidents (e.g., multi-stage attacks). |
| 12 | **A** | The standard approach is to deploy an Azure VM running the Log Analytics agent (or AMA) configured as a Syslog/CEF forwarder. The firewall sends logs to the VM, and the agent forwards them to the Sentinel workspace. |
| 13 | **B** | Defender for Cloud's "Enable MFA" control is directly mapped to Conditional Access policies requiring MFA. Enabling a CA policy requiring MFA for all users will most directly resolve this recommendation. |
| 14 | **B** | Defender for Cloud → **Environment Settings** → select subscription → **Email notifications** allows configuration of email alerts for high-severity security alerts. |
| 15 | **C** | The **Microsoft Defender portal** (`security.microsoft.com`) is the unified SOC portal that integrates Microsoft Sentinel incidents, Defender XDR alerts, and all Defender product incidents into a single queue. |
