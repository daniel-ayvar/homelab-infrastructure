# Managing Secrets

Secrets are stored in two places: the repository's [GitHub Actions Secrets](https://github.com/dayvar14/homelab-infrastructure/settings/secrets/actions) and [Infisical](https://infisical.com). Currently, whenever a secret is created, it must be updated in both locations. If a new secret is to be created, it should be stored in **Infisical** first, then, if needed in a workflow, set in **GitHub Actions Secrets**.

## Retrieving Secrets

Secrets can be retrieved through the following methods:

1. **Infisical Website**: Access [Infisical's website](https://infisical.com) to view and manage your secrets.
2. **Infisical CLI**: Use the [Infisical CLI](https://infisical.com/docs/cli/overview) to interact with secrets programmatically.
3. **Retrieve Secrets Script**: Execute the `/scripts/util/retrieve_secrets.sh` script to export secrets into a `.env` file.

**Note**: You must have the appropriate permissions to retrieve secrets.

## Current Secrets

The following secrets are currently in use across various components of the infrastructure:

### Homelab SSH Key

- **`HOMELAB_SSH_KEY_B64`**:
  *Description*: The SSH key used to deploy to all main Homelab nodes.
  *Usage*: Required for authenticating deployment scripts with Homelab nodes.

- **`HOMELAB_SSH_PUBLIC_KEY`**:
  *Description*: The public SSH key used to allow VMs to be accessed via SSH by deployment scripts.
  *Usage*: Ensures secure access to virtual machines during deployments.

### Terraform Network Variables

- **`ROUTER_CORE_HOST_URL`**:
  *Description*: The URL endpoint of the RouterOS core router.
  *Usage*: Specifies the API endpoint for network configurations.

- **`ROUTER_CORE_USERNAME`**:
  *Description*: The admin username for the RouterOS core router.
  *Usage*: Used for authenticating API requests to the router.

- **`ROUTER_CORE_PASSWORD`**:
  *Description*: The admin password for the RouterOS core router.
  *Usage*: Used in conjunction with the username for authenticating API requests.

- **`TERRAFORM_VARS_NETWORK_B64`**:
  *Description*: Base64-encoded mapping of Homelab node MAC addresses to IP leases.
  *Usage*: Provides network configurations for Terraform deployments.

### Backblaze Variables

- **`BACKBLAZE_KEY_ID`**:
  *Description*: Backblaze key ID used to back up NAS data.
  *Usage*: Identifies the Backblaze account for backup operations.

- **`BACKBLAZE_APPLICATION_KEY`**:
  *Description*: Backblaze application key used to back up NAS data.
  *Usage*: Authenticates backup operations with Backblaze.

### Proxmox Workload Variables

- **`PROXMOX_ENDPOINT`**:
  *Description*: Main Proxmox URL endpoint of the Proxmox service. Used for setting up the reverse proxy. Otherwise, `homelab.lan` should be used.
  *Usage*: Specifies the API endpoint for Proxmox interactions.

- **`PROXMOX_ADMIN_USERNAME`**:
  *Description*: The admin username of the Proxmox cluster.
  *Usage*: Used for authenticating API requests to Proxmox.

- **`PROXMOX_ADMIN_PASSWORD`**:
  *Description*: The admin password of the Proxmox cluster.
  *Usage*: Used in conjunction with the admin username for authenticating API requests.

- **`PROXMOX_USERNAME`**:
  *Description*: Another admin username for the Proxmox cluster (if applicable).
  *Usage*: Facilitates multi-user access or alternate admin operations.

- **`PROXMOX_PASSWORD`**:
  *Description*: Another admin password for the Proxmox cluster (if applicable).
  *Usage*: Used with `PROXMOX_USERNAME` for alternate authentication.

### Infisical Variables

- **`INFISICAL_HOST`**:
  *Description*: The host URL for Infisical.
  *Usage*: Specifies the Infisical service endpoint.

- **`INFISICAL_CLIENT_ID`**:
  *Description*: The client ID for Infisical.
  *Usage*: Used for authenticating API requests to Infisical.

- **`INFISICAL_CLIENT_SECRET`**:
  *Description*: The client secret for Infisical.
  *Usage*: Used in conjunction with the client ID for secure authentication.

- **`INFISICAL_WORKSPACE_ID`**:
  *Description*: The workspace ID within Infisical.
  *Usage*: Identifies the specific workspace for secret management.

- **`INFISICAL_ENV_SLUG`**:
  *Description*: The environment slug for Infisical (e.g., `prod`).
  *Usage*: Specifies the environment context for secrets.

### Other Variables

- **`HOMELAB_SSH_KEY_PATH`**:
  *Description*: The file path to the Homelab SSH key (`./id_ed25519_homelab`).
  *Usage*: Defines where the SSH key is located for deployment scripts.

## Usage Guidelines

### Creating a New Secret

1. **Store in Infisical**:
   - Navigate to [Infisical's website](https://infisical.com) or use the Infisical CLI to add the new secret.
   - Ensure the secret is scoped to the appropriate environment (e.g., `prod`).

2. **Store in GitHub Actions Secrets (If Needed)**:
   - Go to your repository's [GitHub Actions Secrets](https://github.com/dayvar14/homelab-infrastructure/settings/secrets/actions).
   - Add the new secret with the exact same name as in Infisical.

   **Note**: Only store secrets in GitHub Actions if they are required by your workflows. Otherwise, manage them solely in Infisical for enhanced security and centralization.

### Updating an Existing Secret

1. **Update in Infisical**:
   - Modify the secret using the Infisical website or CLI.

2. **Update in GitHub Actions Secrets (If Applicable)**:
   - If the secret is used in GitHub Actions workflows, update it in the repository's [GitHub Actions Secrets](https://github.com/dayvar14/homelab-infrastructure/settings/secrets/actions).

### Deleting a Secret

1. **Delete from GitHub Actions Secrets**:
   - Remove the secret from the repository's [GitHub Actions Secrets](https://github.com/dayvar14/homelab-infrastructure/settings/secrets/actions) if it exists.

2. **Delete from Infisical**:
   - Remove the secret using the Infisical website or CLI.

