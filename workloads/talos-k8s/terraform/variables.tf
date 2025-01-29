variable "router_core" {
  description = "Router core settings with nested auth"
  type = object({
    auth = object({
      hosturl  = string
      username = string
      password = string
      insecure = bool
    })
  })
  sensitive = true
}

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

variable "homelab_ssh_public_key" {
  description = "SSH public key used to access to homelab admin."
  type        = string
}

