#!/bin/bash

set -ex

: "${HOMELAB_SSH_KEY_PATH:?Environment variable HOMELAB_SSH_KEY_PATH is required}"
: "${HOMELAB_SSH_PUBLIC_KEY:?Environment variable HOMELAB_SSH_PUBLIC_KEY is required}"

: "${ROUTER_CORE_USERNAME:?Environment variable ROUTER_CORE_USERNAME is required}"
: "${ROUTER_CORE_PASSWORD:?Environment variable ROUTER_CORE_PASSWORD is required}"
: "${ROUTER_CORE_HOST_URL:?Environment variable ROUTER_CORE_HOST_URL is required}"

: "${PROXMOX_ENDPOINT:?Environment variable PROXMOX_ENDPOINT is required}"
: "${PROXMOX_USERNAME:?Environment variable PROXMOX_USERNAME is required}"
: "${PROXMOX_PASSWORD:?Environment variable PROXMOX_PASSWORD is required}"

export TF_VAR_homelab_ssh_public_key="$HOMELAB_SSH_PUBLIC_KEY"

export TF_VAR_router_core_username="$ROUTER_CORE_USERNAME"
export TF_VAR_router_core_password="$ROUTER_CORE_PASSWORD"
export TF_VAR_router_core_host_url="$ROUTER_CORE_HOST_URL"

export TF_VAR_proxmox_endpoint="$PROXMOX_ENDPOINT"
export TF_VAR_proxmox_username="$PROXMOX_USERNAME"
export TF_VAR_proxmox_password="$PROXMOX_PASSWORD"

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

