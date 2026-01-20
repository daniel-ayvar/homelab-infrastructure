terraform {
  required_providers {
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }

    routeros = {
      source  = "terraform-routeros/routeros"
      version = ">=1.71.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.70.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">=2.17.0"
    }

    infisical = {
      source  = "Infisical/infisical"
      version = ">=0.15.60"
    }
  }

  required_version = ">= 1.10.3"
}

provider "proxmox" {
  endpoint = var.proxmox.auth.endpoint
  username = var.proxmox.auth.username
  password = var.proxmox.auth.password

  insecure = var.proxmox.auth.insecure
  ssh {
    agent = true
  }
}

provider "routeros" {
  hosturl  = var.router_core.auth.hosturl
  username = var.router_core.auth.username
  password = var.router_core.auth.password

  insecure = var.router_core.auth.insecure
}

provider "infisical" {
  host          = var.infisical.auth.host
  client_id     = var.infisical.auth.client_id
  client_secret = var.infisical.auth.client_secret
}

