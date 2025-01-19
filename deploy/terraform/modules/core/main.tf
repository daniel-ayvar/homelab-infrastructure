# Creates a map of a hosts mac_address, assigned ip, and current ip.
data "routeros_ip_dhcp_server_leases" "current_bound_leases" {
  filter = {
    status = "bound"
  }
}

locals {
  current_vlan30_leases_by_address = {
    for lease in data.routeros_ip_dhcp_server_leases.current_bound_leases.data : lease.mac_address => lease.address
  }
}

# VLAN30 Leases
resource "routeros_ip_dhcp_server_lease" "vlan30_leases" {
  for_each = var.vlan30_dhcp_leases

  mac_address = each.key
  address     = each.value.expected_lease
  server      = "dhcp_vl30"

  comment = "terraformconf"
}

locals {
  merged_vlan30_leases = {
    for key, value in var.vlan30_dhcp_leases : key => merge(
      value,
      {
        current_lease = lookup(local.current_vlan30_leases_by_address, key, null)
      }
    )
    if lookup(local.current_vlan30_leases_by_address, key, null) != null
  }
}


output "vlan30_dhcp_leases" {
  description = "VLAN30 Mac Addresses mapped to their current and expected lease values"
  value       = local.merged_vlan30_leases
}
