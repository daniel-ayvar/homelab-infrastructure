terraform {
  cloud {
    organization = "daniel-ayvar-homelab-infrastructure"

    workspaces {
      name = "homelab-network-workspace"
    }
  }
}
