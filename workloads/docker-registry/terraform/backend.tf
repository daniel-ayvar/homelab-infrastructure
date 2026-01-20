terraform {
  cloud {
    organization = "daniel-ayvar-homelab-infrastructure"

    workspaces {
      name = "homelab-registry-ve-workspace"
    }
  }
}
