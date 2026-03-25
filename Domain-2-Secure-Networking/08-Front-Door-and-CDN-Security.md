# Azure Front Door and CDN Security

## 📌 What is Azure Front Door?

**Azure Front Door** is Microsoft's global, scalable entry-point that uses the Microsoft global edge network to create fast, secure, and highly scalable web applications. It provides:

- **Global HTTP/HTTPS load balancing**
- **SSL/TLS offloading**
- **Web Application Firewall (WAF)**
- **DDoS protection**
- **URL-based routing**
- **Content caching (CDN)**
- **Health monitoring and failover**

---

## 🏢 Azure Front Door SKUs

| Feature | Classic | Standard | Premium |
|---------|---------|----------|---------|
| **Global load balancing** | ✅ | ✅ | ✅ |
| **Static content caching** | ✅ | ✅ | ✅ |
| **Dynamic site acceleration** | ✅ | ✅ | ✅ |
| **WAF** | Separate resource | ✅ Included | ✅ Included |
| **Bot protection (managed)** | ❌ | ❌ | ✅ |
| **Private Link origins** | ❌ | ❌ | ✅ |
| **Microsoft threat intelligence** | ❌ | ❌ | ✅ |
| **DDoS protection** | Basic | Standard | Enhanced |
| **Custom WAF rules** | Separate | ✅ | ✅ |
| **Recommendation** | Legacy | Most workloads | Security-sensitive |

> 💡 **Exam Note**: **Premium SKU** is required for Private Link origins, bot protection, and Microsoft Threat Intelligence integration.

---

## 🔒 Security Features

### 1. WAF (Web Application Firewall)

See [03-Web-Application-Firewall.md](03-Web-Application-Firewall.md) for full WAF details.

Front Door WAF specifics:
- Uses **Microsoft Default Rule Set (DRS)** instead of OWASP CRS (though OWASP CRS also available)
- **Rate limiting rules** — Limit requests per IP per time window
- **Geo-filtering** — Block/allow by country
- Bot protection rules (Premium)

```bash
# Create WAF policy for Front Door
az network front-door waf-policy create \
  --resource-group MyRG \
  --name FrontDoorWAFPolicy \
  --sku Premium_AzureFrontDoor \
  --mode Prevention

# Assign WAF policy to Front Door security policy
az afd security-policy create \
  --resource-group MyRG \
  --profile-name MyFrontDoor \
  --security-policy-name MySecurityPolicy \
  --domains /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Cdn/profiles/MyFrontDoor/afdEndpoints/MyEndpoint \
  --waf-policy /subscriptions/{sub}/resourceGroups/MyRG/providers/Microsoft.Network/frontDoorWebApplicationFirewallPolicies/FrontDoorWAFPolicy
```

### 2. DDoS Protection

Front Door includes built-in DDoS protection at the edge:
- Standard SKU: Standard DDoS protection
- Premium SKU: Enhanced DDoS protection
- Absorbs volumetric DDoS attacks at the Microsoft network edge
- Complements Azure DDoS Network Protection for origin VNet

### 3. SSL/TLS Security

| Feature | Description |
|---------|-------------|
| **Managed certificates** | Auto-provisioned and renewed Let's Encrypt/DigiCert certificates |
| **Custom certificates** | Bring your own certificate (from Azure Key Vault) |
| **Minimum TLS version** | Configure TLS 1.2 minimum |
| **HTTPS redirect** | Automatically redirect HTTP to HTTPS |
| **End-to-end TLS** | Re-encrypt traffic from Front Door to origin |

```bash
# Configure HTTPS with managed certificate
az afd custom-domain enable-https \
  --resource-group MyRG \
  --profile-name MyFrontDoor \
  --custom-domain-name MyDomain \
  --certificate-type ManagedCertificate \
  --minimum-tls-version TLS12
```

### 4. Private Link Origins (Premium)

Connect Front Door to origin servers via **Private Link** — no public IP needed on origin:

```
Internet → Front Door Edge (Public) → Private Link → Origin (no public IP)
```

Benefits:
- Origins not exposed to internet
- Traffic from Front Door to origin stays on Microsoft network
- No need for origin-side firewall rules

### 5. Header Security

Best practices for security headers via Front Door rules:

```
Add response headers:
- Strict-Transport-Security: max-age=31536000; includeSubDomains
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- Content-Security-Policy: default-src 'self'
- Referrer-Policy: strict-origin-when-cross-origin
```

---

## 🌐 Azure CDN (Content Delivery Network)

> 📌 **Note**: Azure CDN is being consolidated into Azure Front Door. For new deployments, prefer Azure Front Door Standard/Premium.

### Azure CDN Products (Legacy)

| Product | Provider | Notes |
|---------|---------|-------|
| **Azure CDN Standard from Microsoft** | Microsoft | Integrated with Azure |
| **Azure CDN Standard from Akamai** | Akamai | Being retired |
| **Azure CDN Standard from Verizon** | Verizon | Being retired |
| **Azure CDN Premium from Verizon** | Verizon | Being retired |

### CDN Security Features

| Feature | Description |
|---------|-------------|
| **HTTPS** | Free managed certificate or custom cert |
| **Custom domain HTTPS** | TLS for custom domain names |
| **Token authentication** | Protect content with tokens |
| **Geo-filtering** | Block/allow by country |
| **HTTP to HTTPS redirect** | Force HTTPS |
| **WAF** | Web Application Firewall (via Front Door WAF) |

### CDN Rules Engine

Front Door/CDN rules allow custom logic:

```
Rule: Redirect HTTP to HTTPS
IF: Request.Protocol == HTTP
THEN: Redirect to HTTPS (308 Permanent)

Rule: Add Security Headers
IF: Request.Protocol == HTTPS
THEN: Append response header Strict-Transport-Security: max-age=31536000
```

---

## 🔄 Front Door Routing and Failover

### Origin Groups
- Group multiple origins for load balancing and failover
- Health probes monitor origin availability
- Weighted routing, round-robin, latency-based

### Routing Rules
- Match based on path, host, query string
- Actions: forward, redirect, cache, add/modify headers

```bash
# Create origin group with failover
az afd origin-group create \
  --resource-group MyRG \
  --profile-name MyFrontDoor \
  --origin-group-name MyOriginGroup \
  --probe-request-type GET \
  --probe-protocol Https \
  --probe-interval-in-seconds 30 \
  --probe-path "/health" \
  --sample-size 4 \
  --successful-samples-required 3 \
  --additional-latency-in-milliseconds 50
```

---

## ❓ Practice Questions

1. You need to protect a globally distributed web application using Front Door with bot protection and the ability to use Private Link origins. Which SKU should you choose?
   - A) Classic
   - B) Standard
   - **C) Premium** ✅
   - D) Any SKU supports these features

2. A Front Door WAF policy has a rate limiting rule set to 100 requests per minute per IP. A bot sends 500 requests per minute. What happens to the excess requests?
   - **A) They are blocked by the rate limiting rule** ✅
   - B) They are queued and processed later
   - C) They are redirected to a CAPTCHA page
   - D) Rate limiting only logs, it doesn't block

3. You want all HTTP traffic to your Azure Front Door endpoint to be redirected to HTTPS. How should you configure this?
   - **A) Create a routing rule that redirects HTTP to HTTPS** ✅
   - B) Enable the HTTPS-only option in the origin settings
   - C) Configure an NSG rule blocking port 80
   - D) Set minimum TLS version to 1.2

4. What is the benefit of using Azure Front Door Premium with Private Link origins over Standard?
   - A) Better performance for static content
   - B) Support for more origin types
   - **C) Origins don't need public IP addresses — traffic stays on Microsoft's network** ✅
   - D) Standard doesn't support private origins at all

---

## 📚 References

- [Azure Front Door Documentation](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview)
- [Front Door Security](https://learn.microsoft.com/en-us/azure/frontdoor/security)
- [Front Door WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)
- [Front Door Private Link](https://learn.microsoft.com/en-us/azure/frontdoor/private-link)
- [Azure CDN Documentation](https://learn.microsoft.com/en-us/azure/cdn/cdn-overview)
