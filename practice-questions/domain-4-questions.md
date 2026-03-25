# Practice Questions — Domain 4: Manage Security Operations

> **Back to [README](../README.md)**  
> **Domain Weight**: 25–30% of AZ-500 exam

---

### Question 1

**Your organization uses Microsoft Sentinel for SIEM. A high volume of low-fidelity alerts is being generated, making it difficult for analysts to identify real threats.**

**Which two approaches can help reduce alert fatigue? (Select TWO)**

A. Disable all analytics rules  
B. Configure automation rules to auto-close known false-positive patterns  
C. Increase the severity threshold for alerts  
D. Tune analytics rules with additional conditions to improve precision  
E. Delete the data connectors producing noisy data  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B and D**

- **B**: Automation rules can automatically close incidents that match known false-positive patterns (e.g., alert from a specific trusted IP, known maintenance activity). This reduces analyst workload without losing visibility.
- **D**: Tuning KQL queries with additional filter conditions (e.g., add `| where IPAddress !in (trustedIPs)`) improves signal quality by reducing false positives at the detection level.

- **A is incorrect**: Disabling rules eliminates detection entirely — not a tuning approach.
- **C is incorrect**: "Increasing severity threshold" is not a configurable option in Sentinel — severity is set per rule.
- **E is incorrect**: Deleting connectors eliminates visibility entirely.

</details>

---

### Question 2

**You need to ensure that when a Sentinel incident is created with High severity, it is automatically assigned to a specific analyst and tagged for priority handling.**

**What should you configure?**

A. Analytics rule — alert enrichment  
B. Automation rule with "assign owner" and "add tag" actions  
C. Playbook triggered by any alert  
D. Workbook with auto-refresh enabled  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Automation rule with assign owner and add tag actions**

Automation rules can:
- Trigger when incidents are created or updated
- Filter by conditions (severity = High)
- Execute built-in actions:
  - Assign owner
  - Change severity
  - Add tags
  - Close incident
  - Run a playbook

No custom code needed for these simple triage actions.

- **A is incorrect**: Alert enrichment adds context (entity data) but doesn't assign owners or add tags.
- **C is incorrect**: Playbooks (Logic Apps) are for complex automated actions — overkill for simple owner assignment.
- **D is incorrect**: Workbooks are for visualization, not automation.

</details>

---

### Question 3

**In Microsoft Sentinel, what is the difference between an "Alert" and an "Incident"?**

A. Alerts are from third-party tools; incidents are created by Sentinel  
B. An alert is a single detection event; an incident is a group of correlated alerts investigated together  
C. Alerts require manual creation; incidents are automatic  
D. Incidents are lower severity than alerts  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Alert is a single detection; incident is a group of correlated alerts**

**Alert**: Triggered by an analytics rule when the KQL query returns results. It represents a single suspicious event.

**Incident**: Created when one or more alerts are grouped together. Incidents have:
- A severity, status (New/Active/Closed), and assignee
- An investigation graph showing entity relationships
- Comments, tasks, and audit trail
- The workspace for analyst investigation

Multiple related alerts (e.g., multiple failed logins then a successful login then suspicious file access) can be grouped into one incident for holistic investigation.

</details>

---

### Question 4

**You want to write a KQL query in Microsoft Sentinel to find all failed sign-in attempts in the past 24 hours, grouped by user, showing only users with more than 10 failures.**

**Which query is correct?**

A.
```kql
SigninLogs | where TimeGenerated < ago(24h) | where ResultType != 0
| summarize count() by UserPrincipalName | where count_ > 10
```

B.
```kql
SigninLogs | where TimeGenerated > ago(24h) | where ResultType != 0
| summarize FailureCount = count() by UserPrincipalName | where FailureCount > 10
```

C.
```kql
SigninLogs | take 24h | where ResultType == "Failed"
| group by UserPrincipalName having count(*) > 10
```

D.
```kql
SigninLogs | filter TimeGenerated > ago(24h) | filter ResultType != 0
| aggregate count() by UserPrincipalName | filter count_ > 10
```

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B**

```kql
SigninLogs 
| where TimeGenerated > ago(24h)  // GREATER than (more recent than 24h ago)
| where ResultType != 0            // Non-zero = failure
| summarize FailureCount = count() by UserPrincipalName
| where FailureCount > 10
```

- **A is incorrect**: `TimeGenerated < ago(24h)` means OLDER than 24 hours ago — this filters in the wrong direction.
- **C is incorrect**: `take 24h` is not valid KQL syntax. `ResultType == "Failed"` is wrong — ResultType is a number.
- **D is incorrect**: `filter` and `aggregate` are not valid KQL operators. Use `where` and `summarize`.

</details>

---

### Question 5

**What does the Microsoft Defender for Cloud "Secure Score" represent?**

A. A threat intelligence score based on current active attacks against your tenant  
B. A percentage indicating how well your resources comply with Microsoft's security recommendations  
C. The number of active security incidents in your environment  
D. A compliance score against the CIS Azure Benchmark  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Percentage compliance with security recommendations**

Secure Score measures your security posture:
- Each recommendation has a **max score contribution**
- Implementing recommendations increases your score
- Calculated as: `(Points achieved / Total possible points) × 100%`
- Higher score = better security posture

It is NOT:
- A threat feed (that's security alerts)
- Tied to any specific compliance framework (MCSB recommendations underpin it, but it's not a compliance score)
- Based on active incidents

</details>

---

### Question 6

**You need to automatically block an IP address in an NSG whenever Microsoft Sentinel creates a high-severity incident involving that IP.**

**What is the BEST approach?**

A. Configure an automation rule to run a playbook that modifies the NSG  
B. Configure a Scheduled Analytics Rule with a deny action  
C. Enable Microsoft Defender for Cloud's automatic remediation  
D. Create an Azure Policy with a deny effect for the IP  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: A — Automation rule triggering a playbook**

The workflow:
1. Analytics rule detects threat and creates incident
2. Automation rule triggers when High-severity incident is created
3. Playbook (Logic App) extracts the IP entity from the incident
4. Logic App calls Azure Resource Manager API to add a deny rule to the NSG

This is a classic SOAR response workflow in Sentinel.

- **B is incorrect**: Analytics rules detect threats — they don't have "deny actions."
- **C is incorrect**: Defender for Cloud's auto-remediation is for security recommendations, not incident response.
- **D is incorrect**: Azure Policy manages resource configurations, not dynamic incident-based IP blocking.

</details>

---

### Question 7

**In the MITRE ATT&CK framework, which tactic describes an attacker attempting to maintain foothold across system reboots?**

A. Initial Access  
B. Persistence  
C. Lateral Movement  
D. Defense Evasion  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — Persistence**

**Persistence**: Techniques used by attackers to maintain their foothold across interruptions (reboots, credential changes, etc.). Examples:
- Creating scheduled tasks
- Adding registry run keys
- Installing malicious services
- Creating new admin accounts

- **A**: Initial Access = first entry into the environment (phishing, exploits)
- **C**: Lateral Movement = moving between systems in the network
- **D**: Defense Evasion = avoiding detection (disable logging, obfuscate code)

</details>

---

### Question 8

**You need to investigate which Azure resources were created or deleted in the past 30 days across your entire subscription.**

**Which log source should you query in Log Analytics?**

A. `SecurityAlert`  
B. `AzureActivity`  
C. `AuditLogs`  
D. `SigninLogs`  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: B — AzureActivity**

`AzureActivity` logs all **Azure Resource Manager (ARM) operations** — create, read, update, delete operations on Azure resources across your subscription. This is exactly the subscription-level activity log (formerly "Azure Monitor Activity Log").

- **A**: `SecurityAlert` — Security alerts from Defender for Cloud
- **C**: `AuditLogs` — Microsoft Entra ID directory operations (user creation, role assignment, etc.)
- **D**: `SigninLogs` — Microsoft Entra ID authentication events

Sample query:
```kql
AzureActivity
| where TimeGenerated > ago(30d)
| where OperationNameValue endswith "write" or OperationNameValue endswith "delete"
| where ActivityStatusValue == "Success"
| project TimeGenerated, OperationNameValue, ResourceGroup, Resource, Caller
| order by TimeGenerated desc
```

</details>

---

### Question 9

**Your organization wants to monitor ALL API calls made to Azure Key Vault and alert if any secret is accessed outside of business hours.**

**Which configuration achieves this?**

A. Enable Azure Key Vault diagnostic logs and send to Log Analytics; create a Sentinel analytics rule using KQL  
B. Enable Microsoft Defender for Key Vault and configure DDoS Protection  
C. Configure Azure Key Vault access policies to deny access outside business hours  
D. Enable Azure Policy to audit Key Vault operations  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: A — Diagnostic logs to Log Analytics + Sentinel analytics rule**

The correct approach:
1. Enable **Key Vault diagnostic settings** → send `AuditEvent` category to Log Analytics
2. Create a **Sentinel Scheduled Analytics Rule** with KQL:

```kql
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet"
| where TimeGenerated > ago(1h)
| extend Hour = hourofday(TimeGenerated)
| where Hour < 8 or Hour > 18  // Outside 8am-6pm
| project TimeGenerated, Resource, CallerIPAddress, identity_claim_upn_s
```

- **B is incorrect**: Defender for Key Vault detects anomalous patterns but doesn't provide custom business-hours alerting.
- **C is incorrect**: Key Vault access policies don't support time-based conditions.
- **D is incorrect**: Azure Policy audits configurations (is the Key Vault configured correctly?) not runtime access events.

</details>

---

### Question 10

**What is the relationship between Microsoft Defender for Cloud and Microsoft Sentinel?**

A. They are the same product with different names  
B. Defender for Cloud replaces Sentinel for enterprise customers  
C. Defender for Cloud generates security alerts that can be ingested by Sentinel for advanced SIEM investigation  
D. Sentinel generates alerts and Defender for Cloud investigates them  

<details>
<summary>✅ Answer and Explanation</summary>

**Answer: C — Defender for Cloud alerts feed into Sentinel**

| | Microsoft Defender for Cloud | Microsoft Sentinel |
|---|---|---|
| **Purpose** | CSPM + CWPP (resource-level protection) | SIEM + SOAR (enterprise-wide threat detection) |
| **Scope** | Individual Azure resources | All data sources (Azure + M365 + third-party) |
| **Alerts** | Per-resource threats (VM, storage, SQL, etc.) | Correlated, cross-resource incidents |
| **Integration** | Sends alerts TO Sentinel | Receives and correlates alerts FROM multiple sources |

The integration: Connect Defender for Cloud as a data connector in Sentinel to import alerts, then correlate with other signals (identity, network, endpoint) for advanced investigations.

</details>

---

## 📊 Score Yourself

| Score | Performance |
|---|---|
| 9–10 correct | Excellent — Security Operations mastered |
| 7–8 correct | Good — Review specific areas |
| 5–6 correct | Fair — Revisit Domain 4 study guide |
| < 5 correct | Needs work — Focus especially on Sentinel and Defender for Cloud |

---

> ⬅️ [Domain 3 Questions](./domain-3-questions.md) | ⬆️ [Back to README](../README.md)
