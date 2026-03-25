# Web Application Firewall (WAF)

## 📌 What is WAF?

**Azure Web Application Firewall (WAF)** provides centralized protection for web applications from common exploits and vulnerabilities. It operates at **Layer 7 (HTTP/HTTPS)**.

WAF protects against:
- **OWASP Top 10** vulnerabilities (SQL injection, XSS, etc.)
- **Bot attacks**
- **DDoS application layer (L7) attacks**
- **Custom threat signatures**

---

## 🏗️ WAF Deployment Options

| Platform | Use Case |
|----------|---------|
| **Azure Application Gateway** | Regional load balancer + WAF for apps in one region |
| **Azure Front Door** | Global CDN + WAF for multi-region apps |
| **Azure CDN** | Content delivery + basic WAF (limited) |

---

## 🔑 WAF on Azure Application Gateway

### Architecture

```
Internet → WAF (Application Gateway) → Backend Pool (VMs, App Service, etc.)
```

### WAF Modes

| Mode | Behavior |
|------|----------|
| **Detection mode** | Log threats but don't block. Use for initial testing. |
| **Prevention mode** | Log AND block threats. Use for production. |

### WAF Policy

A **WAF Policy** contains:
- **Managed Rules** (OWASP/Microsoft rule sets)
- **Custom Rules** (your own rules)
- **Bot protection rules**
- **Association** (applied to Application Gateway, listener, or path)

```bash
# Create a WAF policy
az network application-gateway waf-policy create \
  --resource-group MyRG \
  --name MyWAFPolicy \
  --type OWASP \
  --version 3.2

# Set mode to prevention
az network application-gateway waf-policy update \
  --resource-group MyRG \
  --name MyWAFPolicy \
  --set policySettings.mode=Prevention \
  --set policySettings.state=Enabled
```

---

## 📋 Managed Rule Sets

### OWASP Core Rule Set (CRS)

| Version | Status |
|---------|--------|
| **CRS 3.2** | Recommended (latest) |
| CRS 3.1 | Supported |
| CRS 3.0 | Legacy |
| CRS 2.2.9 | Legacy |

### Microsoft Default Rule Set (DRS) — Front Door Only

| Version | Description |
|---------|-------------|
| **DRS 2.1** | Latest, recommended |
| DRS 2.0 | Previous version |
| DRS 1.1 | Legacy |

### Rule Groups (CRS 3.2 examples)

| Rule Group | Protects Against |
|------------|-----------------|
| **REQUEST-941-APPLICATION-ATTACK-XSS** | Cross-site scripting |
| **REQUEST-942-APPLICATION-ATTACK-SQLI** | SQL injection |
| **REQUEST-931-APPLICATION-ATTACK-RFI** | Remote file inclusion |
| **REQUEST-932-APPLICATION-ATTACK-RCE** | Remote code execution |
| **REQUEST-944-APPLICATION-ATTACK-JAVA** | Java attacks |
| **REQUEST-920-PROTOCOL-ENFORCEMENT** | Protocol violations |

---

## 🛠️ Custom Rules

Custom rules allow fine-grained control beyond managed rule sets:

### Custom Rule Components
- **Priority** — Order of evaluation (lower = first)
- **Match conditions** — What to inspect (IP, geo, headers, URI, query string, body, cookies)
- **Action** — Allow, Block, Log, Redirect

```bash
# Create a custom rule to block a specific country
az network application-gateway waf-policy custom-rule create \
  --resource-group MyRG \
  --policy-name MyWAFPolicy \
  --name BlockCountry \
  --priority 10 \
  --rule-type MatchRule \
  --action Block \
  --match-conditions "[{\"matchVariables\":[{\"variableName\":\"RemoteAddr\"}],\"operator\":\"GeoMatch\",\"matchValues\":[\"CN\",\"RU\"]}]"
```

### Custom Rule Types

| Type | Description |
|------|-------------|
| **MatchRule** | Block/allow if match condition met |
| **RateLimitRule** | Rate limiting based on conditions (Front Door WAF only) |

---

## 🤖 Bot Protection

WAF Bot Manager rules categorize bots:

| Category | Action |
|----------|--------|
| **Good bots** (search engines, Azure services) | Allow |
| **Bad bots** (malicious scanners, scrapers) | Block |
| **Unknown bots** | Configurable |

```bash
# Enable bot protection on WAF policy
az network application-gateway waf-policy update \
  --resource-group MyRG \
  --name MyWAFPolicy \
  --set policySettings.requestBodyCheck=true \
  --set policySettings.maxRequestBodySizeInKb=128
```

---

## ⚙️ WAF Exclusions

Sometimes legitimate traffic triggers WAF rules (false positives). Use **exclusions** to suppress specific rule triggers:

| Exclusion Scope | Description |
|-----------------|-------------|
| **Global exclusion** | Applies to all requests |
| **Per-rule exclusion** | Only suppresses specific rule |

Exclusion targets:
- Request headers
- Request cookies
- Request URI
- Query string arguments
- Request body post args

> ⚠️ **Best Practice**: Use per-rule exclusions — global exclusions reduce protection.

---

## 📊 WAF Diagnostics and Logging

### Log Types

| Log | Description |
|-----|-------------|
| **ApplicationGatewayAccessLog** | All HTTP requests processed |
| **ApplicationGatewayFirewallLog** | All WAF detections and blocks |
| **ApplicationGatewayPerformanceLog** | Performance metrics |

### KQL Query (WAF blocked requests)

```kql
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayFirewallLog"
| where action_s == "Blocked"
| project TimeGenerated, clientIp_s, requestUri_s, ruleId_s, ruleGroup_s, action_s
| order by TimeGenerated desc
```

---

## 🌐 WAF on Azure Front Door

### Differences from Application Gateway WAF

| Feature | Application Gateway WAF | Front Door WAF |
|---------|------------------------|----------------|
| **Scope** | Regional | Global |
| **DDoS** | Azure DDoS Protection | Built-in DDoS |
| **Rule sets** | OWASP CRS | Microsoft DRS + OWASP CRS |
| **Rate limiting** | Limited | Full rate limiting rules |
| **Geo-filtering** | Via custom rules | Via custom rules or managed |
| **Bot protection** | Bot manager rules | Bot manager rules |

```bash
# Create WAF policy for Front Door
az network front-door waf-policy create \
  --resource-group MyRG \
  --name MyFrontDoorWAF \
  --sku Premium_AzureFrontDoor \
  --mode Prevention
```

---

## ❓ Practice Questions

1. A web application protected by Azure Application Gateway WAF is experiencing false positives on a specific request header. How should you address this without disabling the WAF?
   - A) Switch WAF to Detection mode
   - B) Disable the entire rule group
   - **C) Create a WAF exclusion for the specific request header for that rule** ✅
   - D) Create a custom Allow rule with higher priority

2. You need to protect a globally distributed web application deployed across multiple Azure regions against web exploits. Which WAF deployment option should you use?
   - A) Application Gateway WAF in each region
   - **B) Azure Front Door with WAF** ✅
   - C) Azure Firewall application rules
   - D) NSG with port 443 allowed

3. In WAF detection mode, what happens when a rule matches a request?
   - A) The request is blocked and the client receives a 403 error
   - **B) The request is allowed but the match is logged** ✅
   - C) The request is redirected to a honeypot
   - D) An alert is sent to the security team and the request is blocked

4. Which OWASP rule group protects against SQL injection attacks?
   - A) REQUEST-941-APPLICATION-ATTACK-XSS
   - **B) REQUEST-942-APPLICATION-ATTACK-SQLI** ✅
   - C) REQUEST-932-APPLICATION-ATTACK-RCE
   - D) REQUEST-920-PROTOCOL-ENFORCEMENT

---

## 📚 References

- [WAF Documentation](https://learn.microsoft.com/en-us/azure/web-application-firewall/overview)
- [WAF on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview)
- [WAF on Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
