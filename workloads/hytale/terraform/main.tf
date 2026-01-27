locals {
  node_names = ["minis02", "minis01", "minis03"]
  vm_id      = 220
  vm_ip      = "10.70.30.205"
}

resource "macaddress" "hytale_mac_address" {
}

resource "random_password" "hytale_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_=+?"
}

resource "routeros_ip_dhcp_server_lease" "lease" {
  mac_address = macaddress.hytale_mac_address.address
  address     = local.vm_ip
  server      = "dhcp_vl30"

  comment = "terraformconf"
}

resource "routeros_ip_dns_record" "hytale_dns_record" {
  name    = "hytale.homelab.lan"
  address = local.vm_ip
  type    = "A"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_image" {
  content_type       = "iso"
  datastore_id       = "local"
  node_name          = local.node_names[0]
  file_name          = "ubuntu-22.04-server-cloudimg-amd64.img"
  url                = "https://cloud-images.ubuntu.com/releases/22.04/release-20231211/ubuntu-22.04-server-cloudimg-amd64.img"
  verify             = false
  upload_timeout     = 5000
}

resource "proxmox_virtual_environment_vm" "hytale" {
  depends_on = [routeros_ip_dhcp_server_lease.lease]

  description = "Hytale game server"
  node_name   = local.node_names[0]
  name        = "hytale"
  vm_id       = local.vm_id

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  agent {
    enabled = false
  }

  initialization {
    datastore_id = "local_lvm"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.homelab_ssh_public_key]
      password = random_password.hytale_password.result
    }
  }

  cpu {
    cores = 12
    type  = "host"
  }

  memory {
    dedicated = 10240
  }

  tags    = ["hytale", "backup"]
  on_boot = true
  pool_id = "vm_backup_pool"

  disk {
    datastore_id = "local_lvm"
    interface    = "scsi0"
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    file_format  = "raw"
    size         = 80
    file_id      = proxmox_virtual_environment_download_file.ubuntu_image.id
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = macaddress.hytale_mac_address.address
  }

  lifecycle {
    ignore_changes = [
      initialization[0].user_account[0].username,
    ]
  }
}

resource "proxmox_virtual_environment_firewall_rules" "inbound" {
  node_name = local.node_names[0]
  vm_id     = local.vm_id
  depends_on = [proxmox_virtual_environment_vm.hytale]

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow Hytale server"
    dport   = "5520"
    proto   = "udp"
    log     = "info"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH"
    dport   = "22"
    proto   = "tcp"
    log     = "info"
  }
}

output "hytale_vm_password" {
  description = "Generated password for the Hytale VM"
  value       = random_password.hytale_password.result
  sensitive   = true
}
