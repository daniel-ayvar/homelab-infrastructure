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
: "${PROXMOX_API_TOKEN:?Environment variable PROXMOX_API_TOKEN is required}"

# Terraform
cat <<EOF > ./workloads/talos-k8s/terraform/terraform.auto.tfvars.json
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
      "username": "$PROXMOX_ADMIN_USERNAME",
      "password": "$PROXMOX_ADMIN_PASSWORD",
      "api_token": "$PROXMOX_API_TOKEN",
      "insecure": true
    }
  }
}
EOF

# Run Terraform apply
terraform -chdir=workloads/talos-k8s/terraform init
terraform -chdir=workloads/talos-k8s/terraform validate
terraform -chdir=workloads/talos-k8s/terraform plan
terraform -chdir=workloads/talos-k8s/terraform apply -auto-approve

