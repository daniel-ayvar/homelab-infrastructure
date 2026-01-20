terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = ">=1.71.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.70.0"
    }
    infisical = {
      source  = "Infisical/infisical"
      version = ">=0.15.60"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3"
    }
  }

  required_version = ">= 1.10.3"
}

provider "infisical" {
  host          = var.infisical.auth.host
  client_id     = var.infisical.auth.client_id
  client_secret = var.infisical.auth.client_secret
}

provider "routeros" {
  alias    = "routeros_core"
  hosturl  = var.router_core.auth.hosturl
  username = var.router_core.auth.admin_username
  password = var.router_core.auth.admin_password

  insecure = var.router_core.auth.insecure
}

provider "proxmox" {
  endpoint = var.proxmox.auth.endpoint
  username = var.proxmox.auth.admin_username
  password = var.proxmox.auth.admin_password

  insecure = var.proxmox.auth.insecure
}

provider "random" {
}
