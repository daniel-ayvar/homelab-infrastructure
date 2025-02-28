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

variable "ceph" {
  description = "Ceph settings with nested auth"
  type = object({
    auth = object({
      username = string
      key      = string
    })
    cluster_ips = list(string)
  })
  sensitive = true
}

variable "kubernetes" {
  description = "Kubernetes settings with nested auth"
  type = object({
    auth = object({
      host                       = string
      client_certificate_b64     = string
      cluster_ca_certificate_b64 = string
      client_key_b64             = string
    })
  })
  sensitive = true
}
