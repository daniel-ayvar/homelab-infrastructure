variable "vlan30_dhcp_leases" {
  description = "A list of objects defining DHCP lease details."
  type = map(object({
    expected_lease = string
  }))
}
