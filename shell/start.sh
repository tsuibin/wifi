#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward 
IPTABLES='/sbin/iptables'
$IPTABLES -F
$IPTABLES -X
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t mangle -F
$IPTABLES -t mangle -X
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT

$IPTABLES -A INPUT  -p tcp --dport 22  -j ACCEPT
$IPTABLES -A OUTPUT  -p tcp --sport 22 -j ACCEPT

$IPTABLES -t nat -A POSTROUTING -o eth1  -m comment --comment "" -j MASQUERADE
#$IPTABLES -t nat -A POSTROUTING -o ppp0  -m comment --comment "" -j MASQUERADE

#$IPTABLES -t nat -A POSTROUTING -o eth1  -m comment --comment "" -j MASQUERADE
$IPTABLES -t mangle -N internet

$IPTABLES -t mangle -A PREROUTING -i eth0 -p tcp -m tcp --dport 0: -j internet
$IPTABLES -t mangle -A PREROUTING -i eth0 -p udp -m udp --dport 0: -j internet

$IPTABLES -t mangle -A internet -j MARK --set-mark 99
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -m mark --mark 99 -m tcp --dport 0: -j DNAT --to-destination 192.168.0.1


#$IPTABLES -t nat -A PREROUTING -i eth0 -p udp -m mark --mark 99 -m upd --dport 80: -j DNAT --to-destination 192.168.0.1
#$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -m mark --mark 99 -m tcp --dport 80 -j DNAT --to-destination 192.168.1.245

$IPTABLES -t mangle -I internet -m mac --mac-source E0:94:67:05:BC:38 -j RETURN
#$IPTABLES -t mangle -A internet -m mac --mac-source 20:64:32:60:40:FF -j RETURN
#$IPTABLES -t mangle -A internet -m mac --mac-source 38:48:4C:4A:84:08 -j RETURN
#$IPTABLES -t mangle -A internet -m mac --mac-source 88:30:8A:3C:F1:31 -j RETURN


#iptables -A FORWARD -p tcp -i eth0 -d 192.168.0.1 --dport 81 -j ACCEPT

#$IPTABLES -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-ports 8181

#iptables -t nat -A PREROUTING -p tcp -d 192.168.0.1 -s 192.168.0.1 --dport 80 -j DNAT --to-destination 192.168.0.1:81

#iptables -t nat -A PREROUTING -p tcp --dport 80 -o eth0 -d 192.168.0.1  -j DNAT --to-destination 192.168.0.1:81
#iptables -t nat -A PREROUTING -p tcp --destination-port 80 -i eth1 -d 192.168.0.1 -j DNAT --to-destination 192.168.0.1:81
#iptables -t nat -A PREROUTING -p tcp --destination-port 80 -o eth1 -d 192.168.0.1 -j DNAT --to-destination 192.168.0.1:81
#iptables -t nat -A PREROUTING -p tcp --destination-port 80 -d 192.168.0.1 -j DNAT --to-destination 192.168.0.1:81
#$IPTABLES -t nat -A PREROUTING -p tcp --destination-port 80 -i eth0 -d 192.168.0.0/16 -j ACCEPT

$IPTABLES -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-ports 3128 -m comment --comment ""

$IPTABLES -t filter -A FORWARD -m mark --mark 99 -j DROP

#$IPTABLES -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
#$IPTABLES -t filter -A INPUT -p udp --dport 53 -j ACCEPT

#$IPTABLES -t filter -A INPUT -m mark --mark 99 -j DROP


