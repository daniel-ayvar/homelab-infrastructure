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

    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }

  required_version = ">= 1.10.3"
}
