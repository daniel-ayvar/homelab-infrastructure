resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_?"
}

resource "linode_instance" "homelab_tunnel" {
  label           = "homelab_tunnel"
  image           = "linode/debian12"
  region          = "us-ord"
  type            = "g6-nanode-1"
  authorized_keys = [var.public_ssh_key]
  root_pass       = random_password.password.result

  private_ip = false
}

resource "linode_firewall" "homelab_tunnel" {
  label = "homelab_tunnel_fw"

  # Open inbound SSH
  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  # Open inbound WireGuard (UDP)
  inbound {
    label    = "allow-wg"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "2333"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  # Open inbound Minecraft (TCP)
  inbound {
    label    = "allow-minecraft"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "25565"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  # Open inbound Plex (TCP)
  inbound {
    label    = "allow-plex"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "32400"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  # Open inbound ICMP (for ping, etc.)
  inbound {
    label    = "allow-icmp"
    action   = "ACCEPT"
    protocol = "ICMP"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [linode_instance.homelab_tunnel.id]
}

output "public_ip_address" {
  description = "ip address for linode tunnel vm"
  value = linode_instance.homelab_tunnel.ip_address
}
