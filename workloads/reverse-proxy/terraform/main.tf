locals {
  node_names = ["minis01", "minis02", "minis03"]
  vm_id      = 200
}

resource "macaddress" "ve_mac_address" {
}

resource "random_password" "ve_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_=+?"
}


resource "routeros_ip_dhcp_server_lease" "leases" {
  mac_address = macaddress.ve_mac_address.address
  address     = "10.70.30.20"
  server      = "dhcp_vl30"

  comment = "terraformconf"
}

resource "routeros_ip_dns_record" "proxmox_dns_record_homelab" {
  name    = "homelab.lan"
  address = "10.70.30.20"
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

resource "proxmox_virtual_environment_container" "ve" {
  description = "Managed by Terraform"

  node_name = local.node_names[0]
  vm_id     = local.vm_id

  initialization {
    hostname = "rp-ve"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [var.homelab_ssh_public_key]
      password = random_password.ve_password.result
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  tags = []

  disk {
    datastore_id = "local_lvm"
    size         = 8
  }

  network_interface {
    name        = "veth0"
    mac_address = upper(macaddress.ve_mac_address.address)
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
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTP on port 80"
    dport   = "80"
    proto   = "tcp"
    log     = "info"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS on port 443"
    dport   = "443"
    proto   = "tcp"
    log     = "info"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow Minecraft on port minecraft"
    dport   = "25565"
    proto   = "tcp"
    log     = "info"
  }
}

output "rp_ve_password" {
  description = "Generated password for the rp ve"
  value       = random_password.ve_password.result
  sensitive   = true
}

data "infisical_secrets" "infra_secrets" {
  env_slug     = var.infisical.env_slug
  workspace_id = var.infisical.workspace_id
  folder_path  = "/"
}

output "wg_tunnel_credentials" {
  description = "wg tunnel public and private key"
  value       = {
    server_public_key = data.infisical_secrets.infra_secrets.secrets["WG_SERVER_PUBLIC_KEY"].value
    server_private_key = data.infisical_secrets.infra_secrets.secrets["WG_SERVER_PRIVATE_KEY"].value
    client_public_key = data.infisical_secrets.infra_secrets.secrets["WG_CLIENT_PUBLIC_KEY"].value
    client_private_key = data.infisical_secrets.infra_secrets.secrets["WG_CLIENT_PRIVATE_KEY"].value
    tunnel_vm_public_ip_address =data.infisical_secrets.infra_secrets.secrets["TUNNEL_VM_PUBLIC_IP_ADDRESS"].value
  }
  sensitive   = true
}
