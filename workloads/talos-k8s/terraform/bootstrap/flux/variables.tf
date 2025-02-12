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

variable "gh_ssh_credentials" {
  description = "GitHub SSH credentials"

  type = object({
    identity     = string
    identity_pub = string
    known_hosts  = string
  })
}

