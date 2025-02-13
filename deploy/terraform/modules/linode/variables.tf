variable "linode_token" {
  description = "A token for linode access."
  type = string
  sensitive = true
}

variable "public_ssh_key" {
  description = "A ssh key for linode access."
  type = string
  sensitive = true
}
