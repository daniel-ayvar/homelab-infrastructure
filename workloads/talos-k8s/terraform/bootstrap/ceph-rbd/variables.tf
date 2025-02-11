variable "proxmox" {
  description = "Proxmox settings with nested auth"
  type = object({
    auth = object({
      endpoint  = string
      username  = string
      password  = string
      api_token = string
      insecure  = bool
    })
  })
  sensitive = true
}

variable "ceph" {
  description = "Proxmox settings with nested auth"
  type = object({
    auth = object({
      username  = string
      key       = string
    })
  })
  sensitive = true
}
