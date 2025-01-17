
/delay delay-time=15s

/interface bonding
add name=bond1 mode=802.3ad lacp-rate=1 slaves=ether3,ether4 comment="scriptconf: LACP Bond for first dual-nic node"
add name=bond2 mode=802.3ad lacp-rate=1 slaves=ether5,ether6 comment="scriptconf: LACP Bond for second dual-nic node"
add name=bond3 mode=802.3ad lacp-rate=1 slaves=ether7,ether8 comment="scriptconf: LACP Bond for third dual-nic node"

/interface bridge
add admin-mac=D4:01:C3:64:E2:D1 auto-mac=no comment=scriptconf name=bridge

/interface ethernet
set [ find default-name=sfp-sfpplus1 ] comment=scriptconf name=upstream

/interface list
add comment=scriptconf name=WAN
add comment=scriptconf name=LAN

/interface list member
add comment=scriptconf interface=bridge list=LAN
add comment=scriptconf interface=ether1 list=LAN
add comment=scriptconf interface=ether2 list=LAN
add comment=scriptconf interface=bond1 list=LAN
add comment=scriptconf interface=bond2 list=LAN
add comment=scriptconf interface=bond3 list=LAN
add comment=scriptconf interface=upstream list=WAN

/interface bridge port
add bridge=bridge comment=scriptconf interface=ether1
add bridge=bridge comment=scriptconf interface=ether2
add bridge=bridge comment=scriptconf interface=bond1
add bridge=bridge comment=scriptconf interface=bond2
add bridge=bridge comment=scriptconf interface=bond3
add bridge=bridge comment=scriptconf interface=upstream

/ip dhcp-client
add interface=bridge comment="scriptconf: DHCP Client for bridge"

/system clock
set time-zone-name=America/Chicago

/system identity
set name="Homelab Router: CR311-8G+2S+in"

/tool mac-server
set allowed-interface-list=LAN

/tool mac-server mac-winbox
set allowed-interface-list=LAN

/log info "Sub Router setup complete as a bridge."
