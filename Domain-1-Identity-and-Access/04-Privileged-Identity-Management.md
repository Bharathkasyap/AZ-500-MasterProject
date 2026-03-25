# Privileged Identity Management (PIM)

## 📌 What is PIM?

**Privileged Identity Management (PIM)** is an Entra ID service that enables **just-in-time (JIT)** privileged access to Azure and Entra ID resources. It helps organizations:

- Minimize persistent privileged access
- Require justification for elevated access
- Enforce approval workflows for critical roles
- Alert when privileged roles are activated
- Conduct access reviews to clean up role assignments

> ⚠️ **Exam Note**: PIM requires **Microsoft Entra ID P2** license or **Microsoft Entra ID Governance**.

---

## 🏗️ Core PIM Concepts

### Assignment Types

| Type | Description |
|------|-------------|
| **Eligible** | User can activate the role when needed (JIT access) |
| **Active** | User has permanent, always-on access to the role |

### Assignment Duration

| Type | Description |
|------|-------------|
| **Time-bound** | Active/eligible for a specific date range |
| **Permanently eligible** | Eligible indefinitely, no expiration |
| **Permanently active** | Always-on indefinitely (avoid for high-privilege roles) |

---

## 🔄 PIM Activation Flow

```
User is "Eligible" for a role
        ↓
User requests activation in PIM portal
        ↓
   [Optional] Approval required from designated approver
        ↓
   [Optional] MFA required
        ↓
   [Optional] Justification required
        ↓
Role activated for a limited time (e.g., 1–8 hours)
        ↓
Role automatically deactivated when time expires
```

---

## ⚙️ PIM Role Settings

Configurable per role:

| Setting | Description |
|---------|-------------|
| **Maximum activation duration** | 1–24 hours |
| **Require MFA on activation** | User must complete MFA to activate |
| **Require justification** | User must enter a reason |
| **Require ticket information** | Require incident/change ticket number |
| **Require approval** | Designate approvers for the role |
| **Notification on activation** | Alert admins when role is activated |
| **Access review** | Periodic reviews of eligible/active assignments |

---

## 👁️ Access Reviews

**Access Reviews** allow periodic review of role assignments to ensure only the right people have access:

- Can be created for Entra ID roles or Azure resource roles
- Reviewers: Manager, user themselves, specific reviewers
- **Auto-apply results**: Automatically remove access if not reviewed/approved
- Frequency: Weekly, monthly, quarterly, semi-annual, annual
- Results emailed to reviewers

```bash
# Access reviews are configured in:
# Azure Portal → Entra ID → Identity Governance → Access Reviews
```

---

## 🔔 PIM Alerts

PIM generates alerts for suspicious activity:

| Alert | Trigger |
|-------|---------|
| **Roles are being assigned outside of PIM** | Role assigned directly without PIM |
| **Roles don't require MFA** | Role activation doesn't enforce MFA |
| **Too many Global Administrators** | More than 5 Global Admins |
| **Duplicate role assignment** | User has same role assigned multiple times |
| **Stale eligible role assignment** | Eligible assignment not activated in 90+ days |

---

## 🏢 PIM for Azure Resources

PIM also works for **Azure RBAC roles** (not just Entra ID roles):

- Supports Owner, Contributor, User Access Administrator, and custom roles
- Works at subscription, resource group, or resource level
- Requires the Azure resource to be "discovered" in PIM first

```
PIM → Azure Resources → Select subscription/resource group
→ Manage eligible/active assignments
```

---

## 🔐 Privileged Access Groups

**Privileged Access Groups** (PAGs) allow PIM to manage membership in security groups:

- Members and owners of the group can be made eligible (JIT)
- Useful for just-in-time access to Azure resources, applications, or other services that use group membership for access

---

## 🛡️ Least Privilege with PIM Best Practices

1. **No permanent Global Admins** — Use eligible assignments with short activation windows
2. **Require MFA + Justification** for all privileged roles
3. **Require approval** for Global Administrator activation
4. **Conduct quarterly access reviews** for all privileged roles
5. **Set short maximum activation durations** (e.g., 1–4 hours for Global Admin)
6. **Use role-specific admins** instead of Global Admin (e.g., Security Admin instead of Global Admin)
7. **Maintain at least 2 emergency access accounts** excluded from PIM policies

---

## 🔗 CLI / PowerShell Commands

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "PrivilegedEligibilitySchedule.Read.AzureADGroup"

# List eligible role assignments
Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All

# List active role assignments
Get-MgRoleManagementDirectoryRoleAssignmentScheduleInstance -All

# Activate a role (user must do via My Access or PIM portal)
# URL: https://aka.ms/pim
```

```bash
# List PIM eligible role assignments via Azure CLI
az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilitySchedules"
```

---

## 📋 PIM vs Standard Role Assignment

| Feature | Standard RBAC | PIM |
|---------|--------------|-----|
| **Persistent access** | Always active | Optional |
| **JIT access** | No | Yes |
| **MFA on elevation** | No | Yes (configurable) |
| **Justification required** | No | Yes (configurable) |
| **Approval workflow** | No | Yes (configurable) |
| **Access reviews** | No | Yes |
| **Audit logs** | Basic | Detailed activation logs |
| **License required** | None | Entra ID P2 |

---

## ❓ Practice Questions

1. You need to ensure that a user must provide a business justification and wait for manager approval before activating the Global Administrator role. Which PIM settings should you configure?
   - A) Set assignment type to Active, enable MFA
   - **B) Require justification and require approval in role settings** ✅
   - C) Set the activation duration to 1 hour
   - D) Enable access reviews

2. A PIM alert indicates "Roles are being assigned outside of PIM." What does this mean?
   - A) Users are activating roles too frequently
   - **B) Someone assigned a privileged role directly through RBAC, bypassing PIM** ✅
   - C) The maximum activation duration is too high
   - D) An access review has expired

3. You want to periodically verify that only the right people have eligible assignments for the Owner role on a subscription. What PIM feature should you use?
   - A) PIM alerts
   - B) Activation history
   - **C) Access reviews** ✅
   - D) Approval workflows

4. What license is required to use Privileged Identity Management?
   - A) Microsoft 365 E3
   - B) Entra ID P1
   - **C) Entra ID P2** ✅
   - D) Entra ID Free

5. A user is assigned as "Eligible" for the Security Administrator role in PIM. What must they do to use the role permissions?
   - **A) Activate the role through the PIM portal** ✅
   - B) Contact the help desk
   - C) Sign out and sign back in
   - D) Nothing — eligible assignments grant immediate access

---

## 📚 References

- [PIM Documentation](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/)
- [PIM for Azure Resources](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-assign-roles)
- [Access Reviews](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview)
