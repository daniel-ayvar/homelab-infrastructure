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
  }
}
EOF

# Run Terraform apply
terraform -chdir=workloads/reverse-proxy/terraform init
terraform -chdir=workloads/reverse-proxy/terraform validate
terraform -chdir=workloads/reverse-proxy/terraform plan
terraform -chdir=workloads/reverse-proxy/terraform apply -auto-approve


# Run Ansible playbook
ansible-lint workloads/reverse-proxy/ansible/playbook.yaml

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i workloads/reverse-proxy/ansible/inventory workloads/reverse-proxy/ansible/playbook.yaml \
  --key-file "${HOMELAB_SSH_KEY_PATH}"

