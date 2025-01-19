terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.71.0"
    }
  }

  required_version = ">= 1.10.3"
}
