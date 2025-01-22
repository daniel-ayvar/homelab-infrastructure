resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_?"
}

resource "proxmox_virtual_environment_group" "ci_cd" {
  comment  = "Managed by Terraform"
  group_id = "ci-cd"
}

resource "proxmox_virtual_environment_role" "ci_cd_operations" {
  role_id = "operations-storage-vm"

  privileges = [
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.AllocateTemplate",
    "Datastore.Audit",
    "SDN.Use",
    "Sys.Audit",
    "Sys.Modify", # Refactor to lessen perimissions. As of 01-22-25, this is the only way.
    "VM.Allocate",
    "VM.Audit",
    "VM.Config.CPU",
    "VM.Config.Cloudinit",
    "VM.Config.Disk",
    "VM.Config.HWType",
    "VM.Config.Memory",
    "VM.Config.Network",
    "VM.Config.Options",
    "VM.PowerMgmt"
  ]
}

resource "proxmox_virtual_environment_user" "operations_automation" {
  comment  = "Managed by Terraform"
  password = random_password.password.result
  user_id  = "terraform@pve"

  groups = [proxmox_virtual_environment_group.ci_cd.group_id]

  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.ci_cd_operations.role_id
  }

  enabled = true
}

output "terraform_auth" {
  description = "Router os auth for terraform deployments"
  value = {
    username = proxmox_virtual_environment_user.operations_automation.user_id
    password = proxmox_virtual_environment_user.operations_automation.password
  }
  sensitive = true
}

