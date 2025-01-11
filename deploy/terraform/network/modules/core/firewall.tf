resource "routeros_ip_firewall_nat" "old_plex_rule_dst_nat" {
  action       = "dst-nat"
  chain        = "dstnat"
  in_interface = "wan"
  protocol     = "tcp"
  to_addresses = "10.70.30.13"
  dst_port     = "32400"
  to_ports     = "32400"

  comment = "terraformconf"
}

resource "routeros_ip_firewall_nat" "old_plex_rule_accept" {
  action       = "accept"
  chain        = "forward"
  in_interface = "wan"
  protocol     = "tcp"
  dst_address  = "10.70.30.13"
  dst_port     = "32400"

  comment = "terraformconf"
}

data "routeros_ip_firewall" "fw" {
  rules {
    filter = {
      chain   = "forward"
      comment = "scriptconf: Block VLAN10 to VLAN30"
    }
  }

  rules {
    filter = {
      chain   = "forward"
      comment = "scriptconf: Block VLAN30 to VLAN10"
    }
  }
}

resource "routeros_ip_firewall_filter" "allow_vlan10_to_plex" {
  chain       = "forward"
  action      = "accept"
  src_address = "10.70.10.0/24"
  dst_address = "10.70.30.13/32"
  protocol    = "tcp"
  dst_port    = "32400"
  comment     = "terraformconf: Allow VLAN10 -> 10.70.30.13:32400"

  place_before = data.routeros_ip_firewall.fw.rules[0].id
}

resource "routeros_ip_firewall_filter" "allow_return_traffic_from_plex" {
  chain            = "forward"
  action           = "accept"
  src_address      = "10.70.30.13/32" # Only from that Plex host
  dst_address      = "10.70.10.0/24"  # Going to VLAN10
  connection_state = "established, related"
  comment          = "terraformconf: Allow return traffic from 10.70.30.13 to VLAN10 if established"

  place_before = data.routeros_ip_firewall.fw.rules[1].id
}
