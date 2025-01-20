terraform {
  cloud {
    organization = "daniel-ayvar-homelab-infrastructure"

    workspaces {
      name = "homelab-rp-ve-workspace"
    }
  }
}


