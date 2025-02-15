#!/bin/bash

# Ensure script stops on error
set -ex

# Check for required environment variables
: "${HOMELAB_SSH_KEY_PATH:?Environment variable HOMELAB_SSH_KEY_PATH is required}"

: "${ROUTER_CORE_HOST_URL:?Environment variable ROUTER_CORE_HOST_URL is required}"
: "${ROUTER_CORE_ADMIN_USERNAME:?Environment variable ROUTER_CORE_ADMIN_USERNAME is required}"
: "${ROUTER_CORE_ADMIN_PASSWORD:?Environment variable ROUTER_CORE_ADMIN_PASSWORD is required}"

: "${TERRAFORM_VARS_NETWORK_B64:?Environment variable TERRAFORM_VARS_NETWORK_B64 is required}"

: "${PROXMOX_ENDPOINT:?Environment variable PROXMOX_ENDPOINT is required}"
: "${PROXMOX_ADMIN_USERNAME:?Environment variable PROXMOX_ADMIN_USERNAME is required}"
: "${PROXMOX_ADMIN_PASSWORD:?Environment variable PROXMOX_ADMIN_PASSWORD is required}"

: "${INFISICAL_HOST:?Environment variable INFISICAL_HOST is required}"
: "${INFISICAL_CLIENT_ID:?Environment variable INFISICAL_CLIENT_ID is required}"
: "${INFISICAL_CLIENT_SECRET:?Environment variable INFISICAL_CLIENT_SECRET is required}"
: "${INFISICAL_ENV_SLUG:?Environment variable INFISICAL_ENV_SLUG is required}"
: "${INFISICAL_WORKSPACE_ID:?Environment variable INFISICAL_WORKSPACE_ID is required}"

: "${BACKBLAZE_APPLICATION_KEY:?Environment variable BACKBLAZE_APPLICATION_KEY is required}"
: "${BACKBLAZE_KEY_ID:?Environment variable BACKBLAZE_KEY_ID is required}"

# Terraform
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

echo "$TERRAFORM_VARS_NETWORK_B64" | base64 --decode > ./deploy/terraform/proxmox_dhcp_leases.auto.tfvars.json

terraform -chdir=./deploy/terraform/ init
terraform -chdir=./deploy/terraform/ validate
terraform -chdir=./deploy/terraform/ plan -out=tfplan.tmp
terraform -chdir=./deploy/terraform/ apply -auto-approve tfplan.tmp
terraform -chdir=./deploy/terraform/ output -json current_proxmox_dhcp_leases > ./current_proxmox_dhcp_leases.json

echo "Terraform output generated successfully."

# Refresh DHCP Leases
JSON_FILE="./current_proxmox_dhcp_leases.json"

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

python3 ./scripts/ci/refresh-node-dhcp-lease.py ./current_proxmox_dhcp_leases.json

# Put Wireguard credentials into env variable
terraform -chdir=./deploy/terraform/ output -json wg_tunnel_credentials > ./wg_tunnel_credentials.json
export WG_SERVER_PUBLIC_KEY=$(jq -r '.server_public_key' < wg_tunnel_credentials.json)
export WG_SERVER_PRIVATE_KEY=$(jq -r '.server_private_key' < wg_tunnel_credentials.json)
export WG_CLIENT_PUBLIC_KEY=$(jq -r '.client_public_key' < wg_tunnel_credentials.json)
export WG_CLIENT_PRIVATE_KEY=$(jq -r '.client_private_key' < wg_tunnel_credentials.json)
export VM_TUNNEL_IP_ADDRESS=$(jq -r '.tunnel_vm_public_ip_address' < wg_tunnel_credentials.json)

# Ansible
# ansible-lint deploy/ansible/homelab.yaml
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-lint workloads/talos-k8s/ansible/playbook.yaml
ansible-playbook -i deploy/ansible/inventory ./deploy/ansible/homelab.yaml --key-file $HOMELAB_SSH_KEY_PATH
