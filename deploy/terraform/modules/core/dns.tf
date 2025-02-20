resource "routeros_ip_dns_record" "proxmox_dns_record" {
  for_each = var.proxmox_dhcp_leases
  name     = each.value.host
  address  = each.value.expected_lease
  type     = "A"
}

resource "routeros_ip_dns_record" "nas" {
  name     = "nas"
  address  = "10.70.30.10"
  type     = "A"
}
