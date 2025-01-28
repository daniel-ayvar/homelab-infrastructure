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
  name         = "PROXMOX_USERNAME"
  value        = module.proxmox.terraform_auth.username
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

resource "infisical_secret" "proxmox_terraform_auth_password" {
  name         = "PROXMOX_PASSWORD"
  value        = module.proxmox.terraform_auth.password
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

resource "infisical_secret" "proxmox_terraform_auth_api_token" {
  name         = "PROXMOX_API_TOKEN"
  value        = module.proxmox.terraform_auth.api_token
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}
