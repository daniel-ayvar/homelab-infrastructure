#!/bin/bash

set -ex

: "${HOMELAB_SSH_KEY_PATH:?Environment variable HOMELAB_SSH_KEY_PATH is required}"
: "${HOMELAB_SSH_PUBLIC_KEY:?Environment variable HOMELAB_SSH_PUBLIC_KEY is required}"

: "${ROUTER_CORE_HOST_URL:?Environment variable ROUTER_CORE_HOST_URL is required}"
: "${ROUTER_CORE_USERNAME:?Environment variable ROUTER_CORE_USERNAME is required}"
: "${ROUTER_CORE_PASSWORD:?Environment variable ROUTER_CORE_PASSWORD is required}"

: "${PROXMOX_ENDPOINT:?Environment variable PROXMOX_ENDPOINT is required}"
: "${PROXMOX_USERNAME:?Environment variable PROXMOX_USERNAME is required}"
: "${PROXMOX_PASSWORD:?Environment variable PROXMOX_PASSWORD is required}"

: "${HYTALE_DISCORD_TOKEN:?Environment variable HYTALE_DISCORD_TOKEN is required}"
: "${HYTALE_DISCORD_CHANNEL_ID:?Environment variable HYTALE_DISCORD_CHANNEL_ID is required}"
: "${HYTALE_DISCORD_AUTHOR_ID:?Environment variable HYTALE_DISCORD_AUTHOR_ID is required}"

# Ensure SSH agent has the homelab key loaded for Proxmox SSH operations.
if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
  eval "$(ssh-agent -s)"
fi
ssh-add "${HOMELAB_SSH_KEY_PATH}"

# Terraform
cat <<EOF_TFVARS > ./workloads/hytale/terraform/terraform.auto.tfvars.json
{
  "homelab_ssh_public_key": "$HOMELAB_SSH_PUBLIC_KEY",
  "router_core": {
    "auth": {
      "hosturl": "$ROUTER_CORE_HOST_URL",
      "username": "$ROUTER_CORE_USERNAME",
      "password": "$ROUTER_CORE_PASSWORD",
      "insecure": true
    }
  },
  "proxmox": {
    "auth": {
      "endpoint": "$PROXMOX_ENDPOINT",
      "username": "$PROXMOX_USERNAME",
      "password": "$PROXMOX_PASSWORD",
      "insecure": true
    }
  }
}
EOF_TFVARS

terraform -chdir=workloads/hytale/terraform init
terraform -chdir=workloads/hytale/terraform validate
terraform -chdir=workloads/hytale/terraform plan
terraform -chdir=workloads/hytale/terraform apply -auto-approve

# Run Ansible playbook
ansible-lint workloads/hytale/ansible/playbook.yaml

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i workloads/hytale/ansible/inventory workloads/hytale/ansible/playbook.yaml --key-file "${HOMELAB_SSH_KEY_PATH}"
