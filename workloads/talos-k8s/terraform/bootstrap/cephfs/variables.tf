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
  description = "Ceph settings with nested auth"
  type = object({
    auth = object({
      username  = string
      key       = string
    })
  })
  sensitive = true
}

variable "kubernetes" {
  description = "Proxmox settings with nested auth"
  type = object({
    auth = object({
      host                   = string
      client_certificate     = string
      client_key             = string
      cluster_ca_certificate = string
    })
  })
  sensitive = true
}
