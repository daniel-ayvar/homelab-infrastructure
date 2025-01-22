variable "proxmox_dhcp_leases" {
  description = "A list of objects defining DHCP lease details for proxmox nodes."
  type = map(object({
    expected_lease = string
    host           = string
  }))
}
