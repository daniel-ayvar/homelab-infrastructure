#!/bin/bash
 
if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root."
  exit 1
fi

IPT="/sbin/iptables"

IN_FACE="{{ network_interface }}"
WG_FACE="{{ wg_interface }}"
SUB_NET="{{ wg_server_address }}/24"
WG_PORT="{{ wg_listen_port }}"

# Rules for wireguard to work
$IPT -t nat -I POSTROUTING 1 -s $SUB_NET -o $IN_FACE -j MASQUERADE
$IPT -I INPUT 1 -i $WG_FACE -j ACCEPT
$IPT -I FORWARD 1 -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT -I FORWARD 1 -i $WG_FACE -o $IN_FACE -j ACCEPT
$IPT -I INPUT 1 -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT

# Rules to forward ports 25565 (Minecraft), 32400 (Plex), and 5520 (Hytale)
rules=("25565:tcp" "32400:tcp" "5520:udp")
for rule in "${rules[@]}"
do
    IFS=':' read -r port protocol <<< "$rule"

    $IPT -t nat -A PREROUTING -i $IN_FACE -p $protocol --dport $port -j DNAT --to-destination {{ wg_client_address }}:$port
    $IPT -t nat -A POSTROUTING -o $WG_FACE -p $protocol --dport $port -d {{ wg_client_address }} -j SNAT --to-source {{ wg_server_address }}
done
