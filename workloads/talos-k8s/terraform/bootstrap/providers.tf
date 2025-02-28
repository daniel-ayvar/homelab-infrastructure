terraform {
  required_providers {
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.70.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">=2.17.0"
    }

    infisical = {
      source  = "Infisical/infisical"
      version = ">=0.12.11"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.19.0"
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

provider "kubernetes" {
  host                   = var.kubernetes.auth.host
  client_certificate     = base64decode(var.kubernetes.auth.client_certificate_b64)
  client_key             = base64decode(var.kubernetes.auth.client_key_b64)
  cluster_ca_certificate = base64decode(var.kubernetes.auth.cluster_ca_certificate_b64)
}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes.auth.host
    client_certificate     = base64decode(var.kubernetes.auth.client_certificate_b64)
    client_key             = base64decode(var.kubernetes.auth.client_key_b64)
    cluster_ca_certificate = base64decode(var.kubernetes.auth.cluster_ca_certificate_b64)
  }
}

provider "kubectl" {
  host                   = var.kubernetes.auth.host
  client_certificate     = base64decode(var.kubernetes.auth.client_certificate_b64)
  client_key             = base64decode(var.kubernetes.auth.client_key_b64)
  cluster_ca_certificate = base64decode(var.kubernetes.auth.cluster_ca_certificate_b64)
  load_config_file       = false
}

provider "infisical" {
  host          = var.infisical.auth.host
  client_id     = var.infisical.auth.client_id
  client_secret = var.infisical.auth.client_secret
}
