terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = ">=1.71.0"
    }

    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }

    talos = {
      source  = "siderolabs/talos"
      version = ">=0.7.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.70.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.1"
    }

    restapi = {
      source  = "Mastercard/restapi"
      version = ">=1.20.0"
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

provider "kubernetes" {
  host                   = module.talos.kube_config.kubernetes_client_configuration.host
  client_certificate     = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
}

provider "restapi" {
  uri                  = var.proxmox.auth.endpoint
  insecure             = var.router_core.auth.insecure
  write_returns_object = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "PVEAPIToken=${var.proxmox.auth.api_token}"
  }
}
