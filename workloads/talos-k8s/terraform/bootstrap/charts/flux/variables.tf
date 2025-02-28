variable "gh_ssh_credentials" {
  description = "GitHub SSH credentials"

  type = object({
    identity     = string
    identity_pub = string
    known_hosts  = string
  })
}

