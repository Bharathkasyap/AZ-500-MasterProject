# Scripts Reference

This directory contains Azure CLI scripts for each AZ-500 exam domain. Each script creates a self-contained lab environment in its own resource group for easy cleanup.

---

## Prerequisites

1. **Azure CLI** installed — [Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Logged in** — run `az login`
3. **Subscription selected** — run `az account set --subscription "<name or ID>"`
4. **Permissions** — Owner or Contributor + User Access Administrator on the subscription

```bash
# Verify your setup
az account show
az --version
```

---

## Scripts

| Script | Domain | What It Creates |
|---|---|---|
| [`identity/setup-identity.sh`](identity/setup-identity.sh) | Domain 1 | Azure AD user/group, RBAC assignment, Key Vault, managed identity |
| [`networking/setup-networking.sh`](networking/setup-networking.sh) | Domain 2 | Hub-and-spoke VNets, Azure Firewall, NSGs, UDR, firewall rules |
| [`compute-storage/setup-compute-storage.sh`](compute-storage/setup-compute-storage.sh) | Domain 3 | VM with managed identity, secure storage, SQL with private endpoint |
| [`security-operations/setup-security-operations.sh`](security-operations/setup-security-operations.sh) | Domain 4 | Log Analytics, Sentinel, Key Vault with audit logs, Defender plans |

---

## Cost Awareness

> ⚠️ **Always delete lab resources when finished to avoid unexpected charges!**

The most expensive resources in these labs:
- **Azure Firewall** — ~$1.25/hour
- **Azure Bastion** — ~$0.19/hour
- **Defender for Servers Plan 2** — ~$15/server/month
- **SQL Database (S1)** — ~$30/month

Each script prints a cleanup command at the end. **Run the cleanup command** when you finish the lab.

### Quick cleanup

```bash
# Identity lab
az group delete --name rg-az500-identity-lab --yes --no-wait
az ad user delete --id "az500lab-user@<yourdomain>.onmicrosoft.com"

# Networking lab (includes Azure Firewall — most important to delete!)
az group delete --name rg-az500-network-lab --yes --no-wait

# Compute/Storage lab
az group delete --name rg-az500-compute-lab --yes --no-wait

# Security Operations lab
az group delete --name rg-az500-secops-lab --yes --no-wait

# Disable Defender plans
for plan in VirtualMachines StorageAccounts KeyVaults SqlServers AppServices; do
  az security pricing create --name "$plan" --tier "Free"
done
```

---

## Making Scripts Executable

```bash
chmod +x scripts/identity/setup-identity.sh
chmod +x scripts/networking/setup-networking.sh
chmod +x scripts/compute-storage/setup-compute-storage.sh
chmod +x scripts/security-operations/setup-security-operations.sh
```
