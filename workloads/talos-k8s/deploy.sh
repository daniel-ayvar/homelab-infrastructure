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



# Run Ansible playbook. Outputs the ceph key to supply to terraform
ansible-lint workloads/talos-k8s/ansible/playbook.yaml

export ANSIBLE_HOST_KEY_CHECKING=False
export CEPH_USERNAME=admin
export CEPH_KEY_OUTPUT_FILE="ceph.client.${CEPH_USERNAME}.key"
export CEPH_KEY_ANSIBLE_OUTPUT_FILE_PATH="../${CEPH_KEY_OUTPUT_FILE}"

ansible-playbook -i workloads/talos-k8s/ansible/inventory workloads/talos-k8s/ansible/playbook.yaml \
  --key-file "${HOMELAB_SSH_KEY_PATH}"

export CEPH_KEY=$(cat "workloads/talos-k8s/${CEPH_KEY_OUTPUT_FILE}")

# Create terraform vars
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
  },
  "ceph": {
     "auth": {
      "username": "$CEPH_USERNAME",
      "key": "$CEPH_KEY"
    },
    "cluster_ips": ["10.70.30.12", "10.70.30.14", "10.70.30.16"]
  }
}
EOF


# Run Terraform apply
terraform -chdir=workloads/talos-k8s/terraform init
terraform -chdir=workloads/talos-k8s/terraform validate
terraform -chdir=workloads/talos-k8s/terraform plan
terraform -chdir=workloads/talos-k8s/terraform apply -auto-approve

# Kubernetes Apps
kubectl apply -k workloads/talos-k8s/kubernetes/apps/minecraft
