variable "router_core" {
  description = "Router core settings with nested auth"
  type = object({
    auth = object({
      hosturl        = string
      admin_username = string
      admin_password = string
      insecure       = bool
    })
  })
  sensitive = true
}

variable "proxmox" {
  description = "Proxmox settings with nested auth"
  type = object({
    auth = object({
      endpoint       = string
      admin_username = string
      admin_password = string
      insecure       = bool
    })
  })
  sensitive = true
}

variable "infisical" {
  description = "Infisical settings with nested auth"
  type = object({
    auth = object({
      host          = string
      client_id     = string
      client_secret = string
    })
    env_slug     = string
    workspace_id = string
  })
  sensitive = true
}


variable "proxmox_dhcp_leases" {
  description = "A list of objects defining DHCP lease details for proxmox nodes."
  type = map(object({
    expected_lease = string
    host           = string
  }))
}
