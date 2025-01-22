data "routeros_ip_dhcp_server_leases" "current_bound_leases" {
  filter = {
    status = "bound"
  }
}

locals {
  current_proxmox_leases_by_address = {
    for lease in data.routeros_ip_dhcp_server_leases.current_bound_leases.data : lease.mac_address => lease.address
  }
}

resource "routeros_ip_dhcp_server_lease" "proxmox_leases" {
  for_each = var.proxmox_dhcp_leases

  mac_address = each.key
  address     = each.value.expected_lease
  server      = "dhcp_vl30"

  comment = "terraformconf"
}

locals {
  merged_proxmox_leases = {
    for key, value in var.proxmox_dhcp_leases : key => merge(
      value,
      {
        current_lease = lookup(local.current_proxmox_leases_by_address, key, null)
      }
    )
    if lookup(local.current_proxmox_leases_by_address, key, null) != null
  }
}


output "current_proxmox_dhcp_leases" {
  description = "Proxmox Node MAC Addresses mapped to their current and expected lease values"
  value       = local.merged_proxmox_leases
  sensitive   = true
}
