variable "kubernetes" {
  description = "Kubernetes settings with nested auth"
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

variable "infisical" {
  description = "Infisical settings"
  type = object({
    env_slug     = string
    workspace_id = string
  })
}
