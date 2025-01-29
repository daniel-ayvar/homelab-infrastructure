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

    talos = {
      source  = "siderolabs/talos"
      version = ">=0.7.0"
    }
  }

  required_version = ">= 1.10.3"
}


