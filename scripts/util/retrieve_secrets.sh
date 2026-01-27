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
export TERRAFORM_VARS_NETWORK_B64="$(infisical secrets get TERRAFORM_VARS_NETWORK_B64 --env=prod --plain)"

# RouterOS Admin Variables
export ROUTER_CORE_HOST_URL=https://router.lan
export ROUTER_CORE_ADMIN_USERNAME="$(infisical secrets get ROUTER_CORE_ADMIN_USERNAME --env=prod --plain)"
export ROUTER_CORE_ADMIN_PASSWORD="$(infisical secrets get ROUTER_CORE_ADMIN_PASSWORD --env=prod --plain)"

# RouterOS TF Variables
export ROUTER_CORE_USERNAME="$(infisical secrets get ROUTER_CORE_USERNAME --env=prod --plain)"
export ROUTER_CORE_PASSWORD="$(infisical secrets get ROUTER_CORE_PASSWORD --env=prod --plain)"

# PROXMOX Admin Variables
export PROXMOX_ENDPOINT="https://10.70.30.12:8006"
export PROXMOX_ADMIN_USERNAME="$(infisical secrets get PROXMOX_ADMIN_USERNAME --env=prod --plain)"
export PROXMOX_ADMIN_PASSWORD="$(infisical secrets get PROXMOX_ADMIN_PASSWORD --env=prod --plain)"

# Proxmox TF Variables
export PROXMOX_USERNAME="$(infisical secrets get PROXMOX_USERNAME --env=prod --plain)"
export PROXMOX_PASSWORD="$(infisical secrets get PROXMOX_PASSWORD --env=prod --plain)"
export PROXMOX_API_TOKEN="$(infisical secrets get PROXMOX_API_TOKEN --env=prod --plain)"

# Infisical Variables
export INFISICAL_HOST="https://app.infisical.com"
export INFISICAL_CLIENT_ID="$(infisical secrets get INFISICAL_CLIENT_ID --env=prod --plain)"
export INFISICAL_CLIENT_SECRET="$(infisical secrets get INFISICAL_CLIENT_SECRET --env=prod --plain)"
export INFISICAL_WORKSPACE_ID="$(infisical secrets get INFISICAL_WORKSPACE_ID --env=prod --plain)"
export INFISICAL_ENV_SLUG="prod"

# Backblaze Variables
export BACKBLAZE_KEY_ID="$(infisical secrets get BACKBLAZE_KEY_ID --env=prod --plain)"
export BACKBLAZE_APPLICATION_KEY="$(infisical secrets get BACKBLAZE_APPLICATION_KEY --env=prod --plain)"

# Hytale Discord Bot Variables
export HYTALE_DISCORD_TOKEN="$(infisical secrets get HYTALE_DISCORD_TOKEN --env=prod --plain)"
export HYTALE_DISCORD_CHANNEL_ID="$(infisical secrets get HYTALE_DISCORD_CHANNEL_ID --env=prod --plain)"
export HYTALE_DISCORD_AUTHOR_ID="$(infisical secrets get HYTALE_DISCORD_AUTHOR_ID --env=prod --plain)"
EOF
else
    echo "Secrets already retrieved in '$env_file'. To refresh, delete file and rerun."
fi
