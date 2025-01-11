/delay delay-time=15s

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
add comment=scriptconf interface=ether3 list=LAN
add comment=scriptconf interface=ether4 list=LAN
add comment=scriptconf interface=ether5 list=LAN
add comment=scriptconf interface=ether6 list=LAN
add comment=scriptconf interface=ether7 list=LAN
add comment=scriptconf interface=ether8 list=LAN
add comment=scriptconf interface=upstream list=WAN
add comment=scriptconf interface=sfp-sfpplus2 list=LAN

/interface bridge port
add bridge=bridge comment=scriptconf interface=ether1
add bridge=bridge comment=scriptconf interface=ether2
add bridge=bridge comment=scriptconf interface=ether3
add bridge=bridge comment=scriptconf interface=ether4
add bridge=bridge comment=scriptconf interface=ether5
add bridge=bridge comment=scriptconf interface=ether6
add bridge=bridge comment=scriptconf interface=ether7
add bridge=bridge comment=scriptconf interface=ether8
add bridge=bridge comment=scriptconf interface=upstream
add bridge=bridge comment=scriptconf interface=sfp-sfpplus2

/ip dhcp-client
add interface=bridge

/system clock
set time-zone-name=America/Chicago

/system identity
set name="Homelab Router: CR311-8G+2S+in"

/tool mac-server
set allowed-interface-list=LAN

/tool mac-server mac-winbox
set allowed-interface-list=LAN

/log info "Sub Router setup complete as a bridge."
