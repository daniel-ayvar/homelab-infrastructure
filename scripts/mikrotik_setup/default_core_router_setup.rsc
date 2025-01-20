/delay delay-time=15s

# =======================
# NETWORK CONFIGURATION
# =======================
/interface bridge
add admin-mac=78:9A:18:D5:FB:D7 auto-mac=no name=bridge comment=scriptconf vlan-filtering=yes

/interface ethernet
set [ find default-name=ether1 ] comment=scriptconf name=wan

# Original interface lists
/interface list
add comment=scriptconf name=WAN
add comment=scriptconf name=LAN

# =======================
# VLAN CONFIGURATION
# =======================
# VLAN10
/interface vlan
add interface=bridge name=vlan10 vlan-id=10 comment=scriptconf

/interface bridge vlan
add bridge=bridge vlan-ids=10 tagged=bridge untagged=ether3 comment=scriptconf

# VLAN30
/interface vlan
add interface=bridge name=vlan30 vlan-id=30 comment=scriptconf

/interface bridge vlan
add bridge=bridge vlan-ids=30 tagged=bridge untagged=sfp-sfpplus1 comment=scriptconf

# VLAN30
/interface vlan
add interface=bridge name=vlan40 vlan-id=40 comment=scriptconf

/interface bridge vlan
add bridge=bridge vlan-ids=40 tagged=bridge untagged=ether4 comment=scriptconf

# ===========================
# ASSIGN INTERFACES TO LISTS
# ===========================
/interface list member
add interface=wan list=WAN comment=scriptconf
add interface=bridge list=LAN comment=scriptconf
add interface=vlan10 list=LAN comment=scriptconf
add interface=vlan30 list=LAN comment=scriptconf
add interface=vlan40 list=LAN comment=scriptconf

# ===========================
# DHCP (MAIN LAN) SETUP
# ===========================
/ip pool
add name=dhcp_0 ranges=10.70.0.2-10.70.0.254

/ip dhcp-server
add address-pool=dhcp_0 interface=bridge name=dhcp_0

# ================================
# BRIDGE PORTS
# ================================
/interface bridge port
add bridge=bridge comment=scriptconf interface=ether2
add bridge=bridge comment=scriptconf interface=ether3 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=bridge comment=scriptconf interface=ether4 pvid=40 frame-types=admit-only-untagged-and-priority-tagged
add bridge=bridge comment=scriptconf interface=ether5
add bridge=bridge comment=scriptconf interface=ether6
add bridge=bridge comment=scriptconf interface=ether7
add bridge=bridge comment=scriptconf interface=ether8
add bridge=bridge comment=scriptconf interface=sfp-sfpplus1 pvid=30 frame-types=admit-only-untagged-and-priority-tagged

# ================================
# IP ADDRESSING
# ================================
# Main LAN
/ip address
add address=10.70.0.1/24 interface=bridge network=10.70.0.0 comment=scriptconf

# WAN
add address=99.175.86.109/29 interface=wan network=99.175.86.104

# VLAN 10 Gateway
add address=10.70.10.1/24 interface=vlan10 network=10.70.10.0 comment=scriptconf

# VLAN 30 Gateway
add address=10.70.30.1/24 interface=vlan30 network=10.70.30.0 comment=scriptconf

# VLAN 40 Gateway
add address=10.70.40.1/30 interface=vlan40 network=10.70.40.0 comment=scriptconf

# =========================
# WAN DHCP CLIENT
# =========================
/ip dhcp-client
add comment=scriptconf interface=wan

# ======================================
# DHCP NETWORKS
# ======================================
# Main LAN
/ip dhcp-server network
add address=10.70.0.0/24 comment=scriptconf dns-server=10.70.0.1 gateway=10.70.0.1 netmask=24

# VLAN 10
/ip pool
add name=dhcp_vlan10 ranges=10.70.10.2-10.70.10.254 comment=scriptconf

/ip dhcp-server
add address-pool=dhcp_vlan10 interface=vlan10 name=dhcp_vl10 comment=scriptconf

/ip dhcp-server network
add address=10.70.10.0/24 gateway=10.70.10.1 dns-server=10.70.10.1 comment=scriptconf

# VLAN 30
/ip pool
add name=dhcp_vlan30 ranges=10.70.30.2-10.70.30.254 comment=scriptconf

/ip dhcp-server
add address-pool=dhcp_vlan30 interface=vlan30 name=dhcp_vl30 lease-time=1m comment=scriptconf

/ip dhcp-server network
add address=10.70.30.0/24 gateway=10.70.30.1 dns-server=10.70.30.1,9.9.9.9 comment=scriptconf

# VLAN 40
/ip pool
add name=dhcp_vlan40 ranges=10.70.40.2 comment=scriptconf

/ip dhcp-server
add address-pool=dhcp_vlan40 interface=vlan40 name=dhcp_vl40 comment=scriptconf

/ip dhcp-server network
add address=10.70.40.0/30 gateway=10.70.40.1 dns-server=10.70.40.1,9.9.9.9 comment=scriptconf

# ====================
# DNS CONFIGURATION
# ====================
/ip dns
set allow-remote-requests=yes servers=1.1.1.3,1.0.0.3 cache-max-ttl=1h

/ip dns static add name=router.lan address=10.70.30.1
# ================================
# FIREWALL AND NAT CONFIGURATION
# ================================

/ip firewall filter

# Allow established, related, untracked traffic to the router
add action=accept chain=input comment="scriptconf: Accept established, related, untracked" connection-state=established,related,untracked

# Allow ICMP (Ping) traffic to the router
add action=accept chain=input comment="scriptconf: Allow ICMP" protocol=icmp

# Fasttrack established and related connections for performance
add action=fasttrack-connection chain=forward comment="scriptconf: Fasttrack established, related" connection-state=established,related hw-offload=yes

# Allow DNS traffic to external DNS servers
add action=accept chain=forward protocol=udp dst-port=53 comment="scriptconf: Allow DNS UDP to WAN"
add action=accept chain=forward protocol=tcp dst-port=53 comment="scriptconf: Allow DNS TCP to WAN"

# Accept established, related, untracked traffic between devices
add action=accept chain=forward comment="scriptconf: Accept established, related, untracked" connection-state=established,related,untracked

# Drop traffic from WAN not DSTNATed
add action=drop chain=forward comment="scriptconf: Drop traffic from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN

# Allow devices in 10.70.0.0/24 to communicate with all devices
add action=accept chain=forward comment="scriptconf: Allow 10.70.0.0/24 to communicate with all" src-address=10.70.0.0/24

# Allow access to the router for devices in 10.70.0.0/24
add action=accept chain=input comment="scriptconf: Allow access from 10.70.0.0/24" src-address=10.70.0.0/24

# Allow access to the router for devices in VLAN40
add action=accept chain=input comment="scriptconf: Allow access from 10.70.40.0/30" src-address=10.70.40.0/30

# Block all traffic from VLAN10 (10.70.10.0/24) to VLAN30 (10.70.30.0/24)
add action=drop chain=forward comment="scriptconf: Block VLAN10 to VLAN30" src-address=10.70.10.0/24 dst-address=10.70.30.0/24

# Block all traffic from VLAN30 (10.70.30.0/24) to VLAN10 (10.70.10.0/24)
add action=drop chain=forward comment="scriptconf: Block VLAN30 to VLAN10" src-address=10.70.30.0/24 dst-address=10.70.10.0/24

# Allow traffic from VLAN40 (10.70.40.0/30) to Main LAN (10.70.0.0/24)
add action=accept chain=forward comment="scriptconf: Allow VLAN40 to Main LAN" src-address=10.70.40.0/30 dst-address=10.70.0.0/24

# Allow traffic from VLAN40 (10.70.40.0/30) to VLAN30 (10.70.30.0/24)
add action=accept chain=forward comment="scriptconf: Allow VLAN40 to VLAN30" src-address=10.70.40.0/30 dst-address=10.70.30.0/24

# Block traffic from VLAN40 (10.70.40.0/30) to VLAN10 (10.70.10.0/24)
add action=drop chain=forward comment="scriptconf: Block VLAN40 to VLAN10" src-address=10.70.40.0/30 dst-address=10.70.10.0/24

# Allow DNS queries (UDP) from Main LAN
add chain=input action=accept protocol=udp dst-port=53 src-address=10.70.0.0/24 comment="scriptconf: Allow DNS UDP from Main LAN"

# Allow DNS queries (TCP) from Main LAN
add chain=input action=accept protocol=tcp dst-port=53 src-address=10.70.0.0/24 comment="scriptconf: Allow DNS TCP from Main LAN"

# Allow DNS queries (UDP) from VLAN10
add chain=input action=accept protocol=udp dst-port=53 src-address=10.70.10.0/24 comment="scriptconf: Allow DNS UDP from VLAN10"

# Allow DNS queries (TCP) from VLAN10
add chain=input action=accept protocol=tcp dst-port=53 src-address=10.70.10.0/24 comment="scriptconf: Allow DNS TCP from VLAN10"

# Allow DNS queries (UDP) from VLAN30
add chain=input action=accept protocol=udp dst-port=53 src-address=10.70.30.0/24 comment="scriptconf: Allow DNS UDP from VLAN30"

# Allow DNS queries (TCP) from VLAN30
add chain=input action=accept protocol=tcp dst-port=53 src-address=10.70.30.0/24 comment="scriptconf: Allow DNS TCP from VLAN30"

# Allow DNS queries (UDP) from VLAN40
add chain=input action=accept protocol=udp dst-port=53 src-address=10.70.40.0/30 comment="scriptconf: Allow DNS UDP from VLAN40"

# Allow DNS queries (TCP) from VLAN40
add chain=input action=accept protocol=tcp dst-port=53 src-address=10.70.40.0/30 comment="scriptconf: Allow DNS TCP from VLAN40"

# Drop invalid traffic
add action=drop chain=forward comment="scriptconf: Drop invalid traffic" connection-state=invalid

# Drop all other traffic to the router
add action=drop chain=input comment="scriptconf: Drop all other access to the router"

# ====================
# NAT CONFIGURATION
# ====================

/ip firewall nat
add action=masquerade chain=srcnat comment="scriptconf: Masquerade for WAN" ipsec-policy=out,none out-interface-list=WAN

# =========================
# IPv6 FIREWALL CONFIG
# =========================
/ipv6 firewall address-list
add address=::/128 comment="scriptconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="scriptconf: lo" list=bad_ipv6
add address=fec0::/10 comment="scriptconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="scriptconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="scriptconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="scriptconf: discard only" list=bad_ipv6
add address=2001:db8::/32 comment="scriptconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="scriptconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="scriptconf: 6bone" list=bad_ipv6

/ipv6 firewall filter
add action=accept chain=input comment="scriptconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="scriptconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="scriptconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=input comment="scriptconf: accept UDP traceroute" port=33434-33534 protocol=udp
add action=accept chain=input comment="scriptconf: accept DHCPv6-Client prefix delegation" dst-port=546 protocol=udp src-address=fe80::/10
add action=accept chain=input comment="scriptconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=input comment="scriptconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=input comment="scriptconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=input comment="scriptconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment="scriptconf: drop everything else not coming from LAN" in-interface-list=!LAN

add action=accept chain=forward comment="scriptconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="scriptconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="scriptconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment="scriptconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="scriptconf: rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="scriptconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=forward comment="scriptconf: accept HIP" protocol=139
add action=accept chain=forward comment="scriptconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=forward comment="scriptconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=forward comment="scriptconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=forward comment="scriptconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment="scriptconf: drop everything else not coming from LAN" in-interface-list=!LAN

# ================================
# SYSTEM SETTINGS
# ================================
/system clock
set time-zone-name=America/Chicago

/system identity
set name="Core Router: RB5009UPr+S+"

# Enable MAC-Server and Winbox access only on LAN interfaces
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN

# ================================
# HTTPS SSL CERTIFICATE CONFIGURATION
# ================================
/certificate
add name=ssl-web-management common-name=ssl-web-management key-usage=digital-signature,key-encipherment,tls-server,key-cert-sign
sign ssl-web-management

/delay delay-time=15s

/ip service set www-ssl certificate=ssl-web-management disabled=no
/ip firewall filter add chain=input protocol=tcp dst-port=443 action=accept
/ip service set www address=10.70.40.0/30
/ip firewall filter add chain=input protocol=tcp dst-port=80 src-address=10.70.40.0/30 action=accept
/ip firewall filter add chain=input protocol=tcp dst-port=80 action=drop

# =======================
# FINAL LOG MESSAGE
# =======================
/log info "Core Router setup complete."

