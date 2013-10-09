#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward 
IPTABLES='/sbin/iptables'
LAN_FACE=eth2
INET_FACE=eth3
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

$IPTABLES -t nat -A POSTROUTING -s 192.168.0.0/24 -o $INET_FACE -j MASQUERADE
#$IPTABLES -t nat -A POSTROUTING -s 192.168.0.0/24 -o ppp0 -m comment --comment "" -j MASQUERADE

$IPTABLES -t mangle -N internet

$IPTABLES -t mangle -A PREROUTING -i $LAN_FACE -p tcp -m tcp --dport 0: -j internet
$IPTABLES -t mangle -A PREROUTING -i $LAN_FACE -p udp -m udp --dport 0: -j internet

$IPTABLES -t mangle -A internet -j MARK --set-mark 0x01
$IPTABLES -t nat -A PREROUTING -i $LAN_FACE -p tcp -m mark --mark 0x01 -m tcp --dport 0: -j DNAT --to-destination 192.168.0.1


#$IPTABLES -t nat -A PREROUTING -i $LAN_FACE -p udp -m mark --mark 0x01 -m upd --dport 80: -j DNAT --to-destination 192.168.0.1
#$IPTABLES -t nat -A PREROUTING -i $LAN_FACE -p tcp -m mark --mark 0x01 -m tcp --dport 80 -j DNAT --to-destination 192.168.1.245

$IPTABLES -t mangle -I internet -m mac --mac-source E0:94:67:05:BC:38 -j RETURN
$IPTABLES  -t mangle -I internet -m mac --mac-source  b8:8d:12:28:d8:a2 -j RETURN

$IPTABLES  -t mangle -I internet -m mac --mac-source  00:26:c6:8b:71:f0 -j RETURN
$IPTABLES  -t mangle -I internet -m mac --mac-source  00:1e:65:db:f3:3a -j RETURN

#$IPTABLES -t mangle -A internet -m mac --mac-source 20:64:32:60:40:FF -j RETURN
#$IPTABLES -t mangle -A internet -m mac --mac-source 38:48:4C:4A:84:08 -j RETURN
#$IPTABLES -t mangle -A internet -m mac --mac-source 88:30:8A:3C:F1:31 -j RETURN

$IPTABLES -t nat -A PREROUTING -p tcp --dport 80  -d 192.168.0.1  -j DNAT --to-destination 192.168.0.1:81

#$IPTABLES -t nat -A PREROUTING -p tcp --destination-port 80 -i $LAN_FACE -d 192.168.0.0/16 -j ACCEPT
$IPTABLES -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-ports 3128 -m comment --comment ""


$IPTABLES -t filter -A FORWARD -m mark --mark 0x01 -j DROP
#同时可以限制IP碎片，每秒钟只允许100个碎片，用来防止DoS攻击
$IPTABLES -A INPUT -f -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
for((i=2;i<255;i++));do
#下载速度
	$IPTABLES -A FORWARD -s 192.168.0.$i -m limit --limit 50/s -j ACCEPT
	$IPTABLES -A FORWARD -s 192.168.0.$i -j DROP
#上传速度
	$IPTABLES -A FORWARD -d 192.168.0.$i -m limit --limit 20/s --limit-burst 100 -j ACCEPT 
	$IPTABLES -A FORWARD -d 192.168.0.$i -j DROP
done

#$IPTABLES -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
#$IPTABLES -t filter -A INPUT -p udp --dport 53 -j ACCEPT

#$IPTABLES -t filter -A INPUT -m mark --mark 99 -j DROP


