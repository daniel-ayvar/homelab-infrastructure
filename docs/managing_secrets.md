# Managing Secrets

Secrets are stored in two places, in the repo's [Github Actions Secrets](https://github.com/dayvar14/homelab-infrastructure/settings/secrets/actions) and [Infisical](https://infisical.com). Currently, Whenever
a secret is created it must be updated in both. If a new secret is to be created, it should be stored
in Infisical first, then if needed in a workflow, set in Github Actions Secrets

## Retrieving secrets
Secrets can easily be retrieved by going to [Infisical's website](https://infisical.com), via the [Infisical CLI](https://infisical.com/docs/cli/overview), or by using `/scripts/util/retrieve_secrets.sh`.
You must have the correct permissions in order to retrieve them.

## Current Secrets
The following secrets can be found in use.

### Homelab SSH Key
* HOMELAB_SSH_KEY_B64 - The ssh key used to deploy to all main homelab nodes.
* HOMELAB_SSH_PUBLIC_KEY - The public key used to allow vms to be sshed into by deployments.

### Terraform Network Variables
* ROUTER_CORE_HOST_URL - The url endpoint of the RouterOS core router
* ROUTER_CORE_USERNAME - The admin username of the RouterOS core router
* ROUTER_CORE_PASSWORD - The admin passowrd of the RouterOS core router
* TERRAFORM_VARS_NETWORK_B64 - The mapping of homelab node MAC addresses to ip lease.

### Backblaze Variables
* BACKBLAZE_KEY_ID - Backblaze key id used to backup nas data.
* BACKBLAZE_APPLICATION_KEY - Backblaze application key used to backup nas data.

### PROXMOX Workload Variables
* PROXMOX_ENDPOINT - Main proxmox url endpoint of the proxmox service. Used for setup of reverse proxy. Otherwise `homelab.lan` should be used.
* PROXMOX_SSH_USERNAME - The admin username of the proxmox cluster.
* PROXMOX_USERNAME - The admin username of the proxmox cluster.
* PROXMOX_PASSWORD - The admin password of the proxmox cluster.
