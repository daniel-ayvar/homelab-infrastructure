terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.71.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.0"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }

  required_version = ">= 1.10.3"
}

