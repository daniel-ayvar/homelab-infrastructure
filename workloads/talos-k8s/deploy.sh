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

# Create terraform vars for infra
cat <<EOF > ./workloads/talos-k8s/terraform/infra/terraform.auto.tfvars.json
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
  "infisical": {
    "auth": {
      "host": "$INFISICAL_HOST",
      "client_id": "$INFISICAL_CLIENT_ID",
      "client_secret": "$INFISICAL_CLIENT_SECRET"
    },
    "env_slug": "$INFISICAL_ENV_SLUG",
    "workspace_id": "$INFISICAL_WORKSPACE_ID"
  },
  "ceph": {
    "cluster_ips": ["10.70.30.12", "10.70.30.14", "10.70.30.16"]
  }
}
EOF


# Run Terraform apply for infra
terraform -chdir=workloads/talos-k8s/terraform/infra init
terraform -chdir=workloads/talos-k8s/terraform/infra validate
terraform -chdir=workloads/talos-k8s/terraform/infra plan
terraform -chdir=workloads/talos-k8s/terraform/infra apply -auto-approve

terraform -chdir=workloads/talos-k8s/terraform/infra output -json kubernetes > ./k8s_credentials.json
export K8S_HOST=$(jq -r '.auth.host' < ./k8s_credentials.json)
export K8S_CLIENT_KEY_B64=$(jq -r '.auth.client_key_b64' < ./k8s_credentials.json)
export K8S_CLIENT_CERTIFICATE_B64=$(jq -r '.auth.client_certificate_b64' < ./k8s_credentials.json)
export K8S_CLUSTER_CA_CERTIFICATE_B64=$(jq -r '.auth.cluster_ca_certificate_b64' < ./k8s_credentials.json)

# Create terraform vars
cat <<EOF > ./workloads/talos-k8s/terraform/bootstrap/terraform.auto.tfvars.json
{
  "proxmox": {
    "auth": {
      "endpoint": "$PROXMOX_ENDPOINT",
      "username": "$PROXMOX_ADMIN_USERNAME",
      "password": "$PROXMOX_ADMIN_PASSWORD",
      "api_token": "$PROXMOX_API_TOKEN",
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
  },
  "ceph": {
     "auth": {
      "username": "$CEPH_USERNAME",
      "key": "$CEPH_KEY"
    },
    "cluster_ips": ["10.70.30.12", "10.70.30.14", "10.70.30.16"]
  },
  "kubernetes": {
    "auth": {
      "host": "$K8S_HOST",
      "client_key_b64": "$K8S_CLIENT_KEY_B64",
      "client_certificate_b64": "$K8S_CLIENT_CERTIFICATE_B64",
      "cluster_ca_certificate_b64": "$K8S_CLUSTER_CA_CERTIFICATE_B64"
    }
  }
}
EOF

# Run Terraform apply
terraform -chdir=workloads/talos-k8s/terraform/bootstrap init
terraform -chdir=workloads/talos-k8s/terraform/bootstrap validate
terraform -chdir=workloads/talos-k8s/terraform/bootstrap plan
terraform -chdir=workloads/talos-k8s/terraform/bootstrap apply -auto-approve
