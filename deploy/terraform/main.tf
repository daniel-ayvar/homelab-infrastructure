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

module "linode" {
  source = "./modules/linode"

  providers = {
    infisical = infisical
  }

  linode_token = data.infisical_secrets.infra_secrets.secrets["LINODE_TOKEN"].value
  public_ssh_key = data.infisical_secrets.infra_secrets.secrets["HOMELAB_SSH_PUBLIC_KEY"].value
}
