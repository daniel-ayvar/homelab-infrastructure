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

resource "proxmox_virtual_environment_download_file" "debian_12_standard_12_7_1_amd64" {
  content_type       = "vztmpl"
  datastore_id       = "nfs_data"
  node_name          = local.node_names[0]
  url                = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
  checksum           = "39f6d06e082d6a418438483da4f76092ebd0370a91bad30b82ab6d0f442234d63fe27a15569895e34d6d1e5ca50319f62637f7fb96b98dbde4f6103cf05bff6d"
  checksum_algorithm = "sha512"
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
    cores = 1
  }

  memory {
    dedicated = 1024
  }

  tags = []

  disk {
    datastore_id = "local_lvm"
    size         = 4
  }

  network_interface {
    name        = "veth0"
    mac_address = upper(macaddress.ve_mac_address.address)
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_12_standard_12_7_1_amd64.id
    type             = "debian"
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
}

output "rp_ve_password" {
  description = "Generated password for the rp ve"
  value       = random_password.ve_password.result
  sensitive   = true
}
