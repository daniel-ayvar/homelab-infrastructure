variable "router_core_host_url" {
  description = "The public url of the core router host"
  type        = string
}

variable "router_core_username" {
  description = "The username of the core router host"
  type        = string
}

variable "router_core_password" {
  description = "The password of the core router host"
  type        = string
  sensitive   = true
}

variable "vlan30_dhcp_leases" {
  description = "A list of objects defining DHCP lease details."
  type = map(object({
    expected_lease = string
  }))
}
