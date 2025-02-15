#!/bin/bash

set -ex

: "${HOMELAB_SSH_KEY_PATH:?Environment variable HOMELAB_SSH_KEY_PATH is required}"
: "${HOMELAB_SSH_PUBLIC_KEY:?Environment variable HOMELAB_SSH_PUBLIC_KEY is required}"

: "${ROUTER_CORE_HOST_URL:?Environment variable ROUTER_CORE_HOST_URL is required}"
: "${ROUTER_CORE_USERNAME:?Environment variable ROUTER_CORE_USERNAME is required}"
: "${ROUTER_CORE_PASSWORD:?Environment variable ROUTER_CORE_PASSWORD is required}"

: "${INFISICAL_HOST:?Environment variable INFISICAL_HOST is required}"
: "${INFISICAL_CLIENT_ID:?Environment variable INFISICAL_CLIENT_ID is required}"
: "${INFISICAL_CLIENT_SECRET:?Environment variable INFISICAL_CLIENT_SECRET is required}"
: "${INFISICAL_ENV_SLUG:?Environment variable INFISICAL_ENV_SLUG is required}"
: "${INFISICAL_WORKSPACE_ID:?Environment variable INFISICAL_WORKSPACE_ID is required}"

: "${PROXMOX_ENDPOINT:?Environment variable PROXMOX_ENDPOINT is required}"
: "${PROXMOX_USERNAME:?Environment variable PROXMOX_USERNAME is required}"
: "${PROXMOX_PASSWORD:?Environment variable PROXMOX_PASSWORD is required}"

# Terraform
cat <<EOF > ./workloads/reverse-proxy/terraform/terraform.auto.tfvars.json

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

# Run Terraform apply
terraform -chdir=workloads/reverse-proxy/terraform init
terraform -chdir=workloads/reverse-proxy/terraform validate
terraform -chdir=workloads/reverse-proxy/terraform plan
terraform -chdir=workloads/reverse-proxy/terraform apply -auto-approve

# Put Wireguard credentials into env variable
terraform -chdir=workloads/reverse-proxy/terraform output -json wg_tunnel_credentials > ./wg_tunnel_credentials.json
export WG_SERVER_PUBLIC_KEY=$(jq -r '.server_public_key' < wg_tunnel_credentials.json)
export WG_SERVER_PRIVATE_KEY=$(jq -r '.server_private_key' < wg_tunnel_credentials.json)
export WG_CLIENT_PUBLIC_KEY=$(jq -r '.client_public_key' < wg_tunnel_credentials.json)
export WG_CLIENT_PRIVATE_KEY=$(jq -r '.client_private_key' < wg_tunnel_credentials.json)
export VM_TUNNEL_IP_ADDRESS=$(jq -r '.tunnel_vm_public_ip_address' < wg_tunnel_credentials.json)

# Run Ansible playbook
ansible-lint workloads/reverse-proxy/ansible/playbook.yaml

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i workloads/reverse-proxy/ansible/inventory workloads/reverse-proxy/ansible/playbook.yaml --key-file "${HOMELAB_SSH_KEY_PATH}"


