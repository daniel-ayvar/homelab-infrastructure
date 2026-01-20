locals {
  node_names = ["minis01", "minis02", "minis03"]
  vm_id      = 210
}

resource "macaddress" "registry_mac_address" {
}

resource "random_password" "registry_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_=+?"
}

resource "routeros_ip_dhcp_server_lease" "lease" {
  mac_address = macaddress.registry_mac_address.address
  address     = "10.70.30.21"
  server      = "dhcp_vl30"

  comment = "terraformconf"
}

resource "routeros_ip_dns_record" "registry_dns_record" {
  name    = "registry.homelab.lan"
  address = "10.70.30.21"
  type    = "A"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_image" {
  content_type       = "vztmpl"
  datastore_id       = "nfs_data"
  node_name          = local.node_names[0]
  url                = "https://cloud-images.ubuntu.com/releases/22.04/release-20231211/ubuntu-22.04-server-cloudimg-amd64-root.tar.xz"
  checksum           = "c9997dcfea5d826fd04871f960c513665f2e87dd7450bba99f68a97e60e4586e"
  checksum_algorithm = "sha256"
  verify             = false
  upload_timeout     = 5000
}

resource "proxmox_virtual_environment_container" "registry" {
  description = "Managed by Terraform"

  node_name = local.node_names[0]
  vm_id     = local.vm_id

  initialization {
    hostname = "registry"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [var.homelab_ssh_public_key]
      password = random_password.registry_password.result
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  tags = ["registry"]

  disk {
    datastore_id = "local_lvm"
    size         = 20
  }

  network_interface {
    name        = "veth0"
    mac_address = upper(macaddress.registry_mac_address.address)
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.ubuntu_image.id
    type             = "ubuntu"
  }

  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "inbound" {
  node_name = local.node_names[0]
  vm_id     = local.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow Docker registry on port 5000"
    dport   = "5000"
    proto   = "tcp"
    log     = "info"
  }
}

output "registry_ve_password" {
  description = "Generated password for the registry ve"
  value       = random_password.registry_password.result
  sensitive   = true
}
