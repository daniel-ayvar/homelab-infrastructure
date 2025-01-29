terraform {
  cloud {
    organization = "daniel-ayvar-homelab-infrastructure"

    workspaces {
      name = "homelab-talos-ve-workspace"
    }
  }
}


