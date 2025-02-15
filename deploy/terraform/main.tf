module "router_core_RB5009" {
  source = "./modules/core"

  providers = {
    routeros = routeros.routeros_core
  }

  proxmox_dhcp_leases = var.proxmox_dhcp_leases
}

resource "infisical_secret" "routeros_terraform_auth_username" {
  name         = "ROUTER_CORE_USERNAME"
  value        = module.router_core_RB5009.terraform_auth.username
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

resource "infisical_secret" "routeros_terraform_auth_password" {
  name         = "ROUTER_CORE_PASSWORD"
  value        = module.router_core_RB5009.terraform_auth.password
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

output "current_proxmox_dhcp_leases" {
  description = "current_proxmox_dhcp_leases"
  value       = module.router_core_RB5009.current_proxmox_dhcp_leases
  sensitive   = true
}

module "proxmox" {
  depends_on = [module.router_core_RB5009]

  source = "./modules/proxmox"

  providers = {
    proxmox = proxmox
  }
}

resource "infisical_secret" "proxmox_terraform_auth_username" {
  depends_on = [module.proxmox]
  name         = "PROXMOX_USERNAME"
  value        = module.proxmox.terraform_auth.username
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

resource "infisical_secret" "proxmox_terraform_auth_password" {
  depends_on = [module.proxmox]
  name         = "PROXMOX_PASSWORD"
  value        = module.proxmox.terraform_auth.password
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

resource "infisical_secret" "proxmox_terraform_auth_api_token" {
  depends_on = [module.proxmox]
  name         = "PROXMOX_API_TOKEN"
  value        = module.proxmox.terraform_auth.api_token
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

data "infisical_secrets" "infra_secrets" {
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

# Used for tunnel
module "linode" {
  source = "./modules/linode"

  providers = {
    infisical = infisical
  }

  linode_token = data.infisical_secrets.infra_secrets.secrets["LINODE_TOKEN"].value
  public_ssh_key = data.infisical_secrets.infra_secrets.secrets["HOMELAB_SSH_PUBLIC_KEY"].value
}

resource "infisical_secret" "linode_tunnel_vm_public_ip_address" {
  name         = "TUNNEL_VM_PUBLIC_IP_ADDRESS"
  value        = module.linode.public_ip_address
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

output "wg_tunnel_credentials" {
  depends_on = [module.linode]
  description = "wg tunnel public and private key"
  value       = {
    server_public_key = data.infisical_secrets.infra_secrets.secrets["WG_SERVER_PUBLIC_KEY"].value
    server_private_key = data.infisical_secrets.infra_secrets.secrets["WG_SERVER_PRIVATE_KEY"].value
    client_public_key = data.infisical_secrets.infra_secrets.secrets["WG_CLIENT_PUBLIC_KEY"].value
    client_private_key = data.infisical_secrets.infra_secrets.secrets["WG_CLIENT_PRIVATE_KEY"].value
    tunnel_vm_public_ip_address = module.linode.public_ip_address
  }
  sensitive   = true
}
