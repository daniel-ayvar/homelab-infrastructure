provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password

  insecure = true
}

provider "routeros" {
  hosturl  = var.router_core_host_url
  username = var.router_core_username
  password = var.router_core_password

  insecure = true
}

