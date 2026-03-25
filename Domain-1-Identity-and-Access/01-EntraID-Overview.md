# Microsoft Entra ID Overview

## 📌 What is Microsoft Entra ID?

**Microsoft Entra ID** (formerly Azure Active Directory / Azure AD) is Microsoft's cloud-based Identity and Access Management (IAM) service. It provides:

- Authentication and authorization for Azure resources and applications
- Single Sign-On (SSO) to thousands of SaaS applications
- Multi-Factor Authentication (MFA)
- Conditional Access policies
- Identity governance and lifecycle management

> 💡 **Exam Note**: Microsoft rebranded Azure Active Directory to **Microsoft Entra ID** in 2023. Both names may appear on the AZ-500 exam.

---

## 🏗️ Core Concepts

### Tenant
- A **tenant** is a dedicated and trusted instance of Entra ID automatically created when an organization signs up for Microsoft cloud services.
- Each tenant has a unique **tenant ID** (GUID) and a primary domain (e.g., `contoso.onmicrosoft.com`).
- Organizations can add custom domains (e.g., `contoso.com`).

### Directory
- The Entra ID directory contains **users**, **groups**, **applications**, **devices**, and **service principals**.
- A single Azure subscription is always associated with exactly one Entra ID tenant.
- One tenant can have multiple Azure subscriptions.

### Users

| User Type | Description |
|-----------|-------------|
| **Member** | Internal user in the organization's tenant |
| **Guest** | External user invited via B2B collaboration |
| **Service Account** | User account used for applications/services (not recommended; use managed identities instead) |

### Groups

| Group Type | Description |
|------------|-------------|
| **Security Group** | Used to manage access to resources |
| **Microsoft 365 Group** | Used for collaboration (Teams, SharePoint, Outlook) |
| **Dynamic Group** | Membership automatically managed by rules |
| **Assigned Group** | Members manually added/removed |

---

## 🔑 Authentication Methods

| Method | Description |
|--------|-------------|
| **Password Hash Synchronization (PHS)** | Password hashes synced from on-prem AD to Entra ID |
| **Pass-Through Authentication (PTA)** | Authentication validated against on-prem AD in real-time |
| **Federated Authentication** | Uses on-prem AD FS or third-party federation |
| **Cloud-Only** | Identity exists only in Entra ID (no on-prem AD) |

---

## 🔄 Hybrid Identity

**Microsoft Entra Connect** (formerly Azure AD Connect) synchronizes on-premises Active Directory with Entra ID.

Key features:
- **Directory synchronization** — Sync users, groups, and devices
- **Password Hash Sync (PHS)** — Sync password hashes for cloud authentication
- **Pass-through Authentication (PTA)** — Validate passwords on-prem
- **Single Sign-On** — Seamless SSO for domain-joined devices

**Entra Connect Health** — Monitors sync health and provides alerts.

---

## 📱 Device Management

| Feature | Description |
|---------|-------------|
| **Entra ID Registered** | Personal devices (BYOD), user signs in with work account |
| **Entra ID Joined** | Organization-owned, cloud-only devices |
| **Hybrid Entra ID Joined** | On-prem domain joined AND Entra ID joined |

---

## 🏢 Licenses and SKUs

| SKU | Key Features |
|-----|-------------|
| **Free** | SSO (limited), user/group management, basic MFA |
| **P1** | Conditional Access, self-service group management, hybrid identity |
| **P2** | All P1 features + Identity Protection + Privileged Identity Management (PIM) |

> ⚠️ **Exam Note**: PIM and Identity Protection require **Entra ID P2** (or Microsoft Entra ID Governance).

---

## 🔒 Security Features Summary

| Feature | License Required |
|---------|-----------------|
| MFA (basic) | Free |
| Conditional Access | P1 |
| Named Locations | P1 |
| Identity Protection | P2 |
| Privileged Identity Management (PIM) | P2 |
| Access Reviews | P2 |
| Entitlement Management | P2 |

---

## 🌐 Application Registration vs Enterprise Application

| Concept | Description |
|---------|-------------|
| **App Registration** | Defines the application identity in Entra ID (the "template") |
| **Enterprise Application** | The service principal — the instance of the app in your tenant |
| **Service Principal** | The identity of an application/service within a specific tenant |

---

## 📋 Entra ID Roles (Directory Roles)

Key roles for AZ-500:

| Role | Permissions |
|------|------------|
| **Global Administrator** | Full control over the tenant |
| **Security Administrator** | Configure security policies and features |
| **Security Reader** | Read-only access to security features |
| **User Administrator** | Manage users and groups |
| **Privileged Role Administrator** | Manage role assignments in PIM |
| **Conditional Access Administrator** | Manage Conditional Access policies |
| **Authentication Administrator** | Manage authentication methods for non-admin users |

> 💡 **Least Privilege Principle**: Always assign the minimum role required for the task.

---

## 🔗 Useful CLI Commands

```bash
# Create a user
az ad user create --display-name "John Doe" --password "P@ssword123" \
  --user-principal-name john@contoso.onmicrosoft.com

# List all users
az ad user list --output table

# Get a user by UPN
az ad user show --id john@contoso.onmicrosoft.com

# Create a security group
az ad group create --display-name "Security-Team" --mail-nickname "security-team"

# Add member to group
az ad group member add --group "Security-Team" --member-id <user-object-id>
```

---

## ❓ Practice Questions

1. Your organization requires that all password hashes be synchronized with on-premises Active Directory for backup authentication. Which Entra Connect feature should you configure?
   - A) Pass-Through Authentication
   - B) Federation
   - **C) Password Hash Synchronization** ✅
   - D) Seamless SSO

2. Which Entra ID license is required to configure Privileged Identity Management (PIM)?
   - A) Entra ID Free
   - B) Entra ID P1
   - **C) Entra ID P2** ✅
   - D) Microsoft 365 E3

3. A user from a partner organization needs read-only access to a SharePoint site. What user type is created?
   - A) Member user
   - B) Service principal
   - **C) Guest user** ✅
   - D) Managed identity

4. What is the maximum number of Entra ID tenants an Azure subscription can be associated with at one time?
   - **A) 1** ✅
   - B) 5
   - C) 10
   - D) Unlimited

---

## 📚 References

- [Microsoft Entra ID Documentation](https://learn.microsoft.com/en-us/entra/identity/)
- [Microsoft Entra ID Licensing](https://www.microsoft.com/en-us/security/business/microsoft-entra-pricing)
- [Hybrid Identity Documentation](https://learn.microsoft.com/en-us/entra/identity/hybrid/)
