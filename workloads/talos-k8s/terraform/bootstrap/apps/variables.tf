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
