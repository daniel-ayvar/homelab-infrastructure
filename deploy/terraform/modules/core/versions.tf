terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3"
    }
  }

}
