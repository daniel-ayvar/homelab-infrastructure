terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = ">=2.17.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.1"
    }

    infisical = {
      source = "Infisical/infisical"
      version = ">=0.12.11"
    }
  }

  required_version = ">= 1.10.3"
}

provider "kubernetes" {
  host                   = var.kubernetes.auth.host
  client_certificate     = var.kubernetes.auth.client_certificate
  client_key             = var.kubernetes.auth.client_key
  cluster_ca_certificate = var.kubernetes.auth.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes.auth.host
    client_certificate     = var.kubernetes.auth.client_certificate
    client_key             = var.kubernetes.auth.client_key
    cluster_ca_certificate = var.kubernetes.auth.cluster_ca_certificate
  }
}
