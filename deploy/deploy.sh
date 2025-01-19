#!/bin/bash

# Ensure script stops on error
set -ex

# Check for required environment variables
: "${HOMELAB_SSH_KEY_PATH:?Environment variable HOMELAB_SSH_KEY_PATH is required}"

: "${ROUTER_CORE_USERNAME:?Environment variable ROUTER_CORE_USERNAME is required}"
: "${ROUTER_CORE_PASSWORD:?Environment variable ROUTER_CORE_PASSWORD is required}"
: "${ROUTER_CORE_HOST_URL:?Environment variable ROUTER_CORE_HOST_URL is required}"
: "${TERRAFORM_VARS_NETWORK_B64:?Environment variable TERRAFORM_VARS_NETWORK_B64 is required}"

: "${PROXMOX_PASSWORD:?Environment variable PROXMOX_PASSWORD is required}"
: "${BACKBLAZE_APPLICATION_KEY:?Environment variable BACKBLAZE_APPLICATION_KEY is required}"
: "${BACKBLAZE_KEY_ID:?Environment variable BACKBLAZE_KEY_ID is required}"

export TF_VAR_router_core_username="$ROUTER_CORE_USERNAME"
export TF_VAR_router_core_password="$ROUTER_CORE_PASSWORD"
export TF_VAR_router_core_host_url="$ROUTER_CORE_HOST_URL"

# Terraform
echo "$TERRAFORM_VARS_NETWORK_B64" | base64 --decode > ./deploy/terraform/network_terraform.tfvars.json

terraform -chdir=./deploy/terraform/ init
terraform -chdir=./deploy/terraform/ validate
terraform -chdir=./deploy/terraform/ plan -var-file=network_terraform.tfvars.json -out=tfplan.tmp
terraform -chdir=./deploy/terraform/ apply -var-file=network_terraform.tfvars.json -auto-approve tfplan.tmp
terraform -chdir=./deploy/terraform/ output -json current_vlan30_leases > ./dhcp_leases_by_node.json

echo "Terraform output generated successfully."

# Refresh DHCP Leases
JSON_FILE="./dhcp_leases_by_node.json"

if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt-get update && sudo apt-get install -y jq
fi

CURRENT_LEASE_IPS=$(jq -r '.[].current_lease' "$JSON_FILE" | sort -u)
echo "Adding the following IPs to known_hosts:"
echo "$CURRENT_LEASE_IPS"

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts

for IP in $CURRENT_LEASE_IPS; do
  echo "Scanning SSH keys for ${IP}..."
  ssh-keyscan -H "$IP" >> ~/.ssh/known_hosts 2>/dev/null || echo "Failed to scan ${IP}"
done

sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts

python3 ./scripts/util/refresh-node-dhcp-lease.py ./dhcp_leases_by_node.json

# Ansible
ansible-lint deploy/ansible/homelab.yaml
ansible-playbook -i ./deploy/ansible/inventory ./deploy/ansible/homelab.yaml --key-file $HOMELAB_SSH_KEY_PATH \
  -e "proxmox_password=$PROXMOX_PASSWORD backblaze_application_key=$BACKBLAZE_APPLICATION_KEY backblaze_key_id=$BACKBLAZE_KEY_ID"
