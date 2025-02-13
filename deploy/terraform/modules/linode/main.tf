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

  private_ip = true
}

resource "linode_firewall" "homelab_tunnel" {
  label = "homelab_tunnel_fw"

#  inbound {
#    label    = "allow-http"
#    action   = "ACCEPT"
#    protocol = "TCP"
#    ports    = "80"
#    ipv4     = ["0.0.0.0/0"]
#    ipv6     = ["::/0"]
#  }
#
#  inbound {
#    label    = "allow-https"
#    action   = "ACCEPT"
#    protocol = "TCP"
#    ports    = "443"
#    ipv4     = ["0.0.0.0/0"]
#    ipv6     = ["::/0"]
#  }

  inbound_policy = "DROP"

#  outbound {
#    label    = "reject-http"
#    action   = "DROP"
#    protocol = "TCP"
#    ports    = "80"
#    ipv4     = ["0.0.0.0/0"]
#    ipv6     = ["::/0"]
#  }
#
#  outbound {
#    label    = "reject-https"
#    action   = "DROP"
#    protocol = "TCP"
#    ports    = "443"
#    ipv4     = ["0.0.0.0/0"]
#    ipv6     = ["::/0"]
#  }

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.homelab_tunnel.id]
}
