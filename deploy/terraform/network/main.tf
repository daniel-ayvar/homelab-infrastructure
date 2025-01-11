provider "routeros" {
  alias    = "routeros_core"
  hosturl  = var.router_core_host_url
  username = var.router_core_username
  password = var.router_core_password
  insecure = true
}

module "router_core_RB5009" {
  source = "./modules/core"

  providers = {
    routeros = routeros.routeros_core
  }

  vlan30_dhcp_leases = var.vlan30_dhcp_leases
}

output "current_vlan30_leases" {
  description = "currently_assigned_leases"
  value       = module.router_core_RB5009.vlan30_dhcp_leases
  sensitive   = true
}
