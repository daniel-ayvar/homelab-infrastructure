#!/bin/bash

set -ex

: "${HOMELAB_SSH_KEY_PATH:?Environment variable HOMELAB_SSH_KEY_PATH is required}"

: "${ROUTER_CORE_HOST_URL:?Environment variable ROUTER_CORE_HOST_URL is required}"
: "${ROUTER_CORE_ADMIN_USERNAME:?Environment variable ROUTER_CORE_ADMIN_USERNAME is required}"
: "${ROUTER_CORE_ADMIN_PASSWORD:?Environment variable ROUTER_CORE_ADMIN_PASSWORD is required}"

: "${PROXMOX_ENDPOINT:?Environment variable PROXMOX_ENDPOINT is required}"
: "${PROXMOX_ADMIN_USERNAME:?Environment variable PROXMOX_ADMIN_USERNAME is required}"
: "${PROXMOX_ADMIN_PASSWORD:?Environment variable PROXMOX_ADMIN_PASSWORD is required}"

: "${INFISICAL_HOST:?Environment variable INFISICAL_HOST is required}"
: "${INFISICAL_CLIENT_ID:?Environment variable INFISICAL_CLIENT_ID is required}"
: "${INFISICAL_CLIENT_SECRET:?Environment variable INFISICAL_CLIENT_SECRET is required}"
: "${INFISICAL_ENV_SLUG:?Environment variable INFISICAL_ENV_SLUG is required}"
: "${INFISICAL_WORKSPACE_ID:?Environment variable INFISICAL_WORKSPACE_ID is required}"

# Terraform vars for tunnel infra.
cat <<EOF > ./deploy/terraform/terraform.auto.tfvars.json
{
  "router_core": {
    "auth": {
      "hosturl": "$ROUTER_CORE_HOST_URL",
      "admin_username": "$ROUTER_CORE_ADMIN_USERNAME",
      "admin_password": "$ROUTER_CORE_ADMIN_PASSWORD",
      "insecure": true
    }
  },
  "proxmox": {
    "auth": {
      "endpoint": "$PROXMOX_ENDPOINT",
      "admin_username": "$PROXMOX_ADMIN_USERNAME",
      "admin_password": "$PROXMOX_ADMIN_PASSWORD",
      "insecure": true
    }
  },
  "infisical": {
    "auth": {
      "host": "$INFISICAL_HOST",
      "client_id": "$INFISICAL_CLIENT_ID",
      "client_secret": "$INFISICAL_CLIENT_SECRET"
    },
    "env_slug": "$INFISICAL_ENV_SLUG",
    "workspace_id": "$INFISICAL_WORKSPACE_ID"
  }
}
EOF

terraform -chdir=./deploy/terraform/ init
terraform -chdir=./deploy/terraform/ validate
terraform -chdir=./deploy/terraform/ plan -out=tfplan.tunnel.tmp
terraform -chdir=./deploy/terraform/ apply -auto-approve tfplan.tunnel.tmp

terraform -chdir=./deploy/terraform/ output -json wg_tunnel_credentials > ./wg_tunnel_credentials.json
export WG_SERVER_PUBLIC_KEY=$(jq -r '.server_public_key' < wg_tunnel_credentials.json)
export WG_SERVER_PRIVATE_KEY=$(jq -r '.server_private_key' < wg_tunnel_credentials.json)
export WG_CLIENT_PUBLIC_KEY=$(jq -r '.client_public_key' < wg_tunnel_credentials.json)
export WG_CLIENT_PRIVATE_KEY=$(jq -r '.client_private_key' < wg_tunnel_credentials.json)
export VM_TUNNEL_IP_ADDRESS=$(jq -r '.tunnel_vm_public_ip_address' < wg_tunnel_credentials.json)

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i deploy/ansible/inventory deploy/ansible/tunnel.yaml --key-file "$HOMELAB_SSH_KEY_PATH"
