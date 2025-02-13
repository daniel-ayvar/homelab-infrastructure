terraform {
  required_providers {
    infisical = {
      source  = "Infisical/infisical"
      version = ">=0.12.11"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3"
    }
    linode = {
      source  = "linode/linode"
      version = ">=2.34.1"
    }
  }

  required_version = ">= 1.10.3"
}


provider "linode" {
  token = var.linode_token
}
