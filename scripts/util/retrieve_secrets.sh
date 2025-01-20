#!/bin/bash
set -e

env_file="./.env"

if [ ! -f "$env_file" ]; then
    echo "Retrieving secrets and exporting into '$env_file'."
    cat <<EOF > $env_file
# Homelab SSH Key
export HOMELAB_SSH_KEY_PATH="./id_ed25519_homelab"
export HOMELAB_SSH_KEY_B64="$(infisical secrets get HOMELAB_SSH_KEY_B64 --env=prod --plain)"
export HOMELAB_SSH_PUBLIC_KEY="$(infisical secrets get HOMELAB_SSH_PUBLIC_KEY --env=prod --plain)"

# Terraform Network Variables
export ROUTER_CORE_HOST_URL=https://10.70.30.1
export ROUTER_CORE_USERNAME="$(infisical secrets get ROUTER_CORE_USERNAME --env=prod --plain)"
export ROUTER_CORE_PASSWORD="$(infisical secrets get ROUTER_CORE_PASSWORD --env=prod --plain)"
export TERRAFORM_VARS_NETWORK_B64="$(infisical secrets get TERRAFORM_VARS_NETWORK_B64 --env=prod --plain)"

# Backblaze Variables
export BACKBLAZE_KEY_ID="$(infisical secrets get BACKBLAZE_KEY_ID --env=prod --plain)"
export BACKBLAZE_APPLICATION_KEY="$(infisical secrets get BACKBLAZE_APPLICATION_KEY --env=prod --plain)"

# PROXMOX Workload Variables
export PROXMOX_SSH_USERNAME="$(infisical secrets get PROXMOX_SSH_USERNAME --env=prod --plain)"
export PROXMOX_USERNAME="$(infisical secrets get PROXMOX_SSH_USERNAME --env=prod --plain)"
export PROXMOX_ENDPOINT="$(infisical secrets get PROXMOX_ENDPOINT --env=prod --plain)"
export PROXMOX_PASSWORD="$(infisical secrets get PROXMOX_PASSWORD --env=prod --plain)"
EOF
else
    echo "Secrets already retrieved in '$env_file'. To refresh, delete file and rerun."
fi
