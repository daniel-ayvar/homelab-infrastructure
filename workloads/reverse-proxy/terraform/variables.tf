variable "proxmox_endpoint" {
  description = "The endpoint URL of the Proxmox nodes"
  type        = string
}

variable "proxmox_username" {
  description = "The admin username for the Proxmox nodes"
  type        = string
}

variable "proxmox_password" {
  description = "The admin password for the Proxmox nodes"
  type        = string
  sensitive   = true
}

variable "router_core_host_url" {
  description = "The public url of the core router host"
  type        = string
}

variable "router_core_username" {
  description = "The username of the core router host"
  type        = string
}

variable "router_core_password" {
  description = "The password of the core router host"
  type        = string
  sensitive   = true
}

variable "homelab_ssh_public_key" {
  description = "SSH public key used to access to homelab admin."
  type        = string
}
