resource "routeros_ip_dns_record" "proxmox_dns_record" {
  for_each = var.proxmox_dhcp_leases
  name     = each.value.host
  address  = each.value.expected_lease
  type     = "A"
}
