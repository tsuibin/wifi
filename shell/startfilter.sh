#!/bin/bash
IPTABLES=/sbin/iptables

$IPTABLES -N internet -t mangle

$IPTABLES -t mangle -A PREROUTING -j internet
$IPTABLES -t mangle -A internet -j LOG --log-prefix "--iptables--:"

for mac in $(cat /var/auth/mac_address);do
    $IPTABLES -t mangle -A internet -m mac --mac-source $mac -j ACCEPT
done

$IPTABLES -t mangle -A internet -j MARK --set-mark 99
$IPTABLES -t mangle -A internet -j LOG --log-prefix "--iptables--:"

$IPTABLES -t nat -A PREROUTING -m mark --mark 99 -p tcp --dport 80 -j DNAT --to-destination 192.168.16.1

$IPTABLES -t filter -A FORWARD -m mark --mark 99 -j DROP

$IPTABLES -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
$IPTABLES -t filter -A INPUT -p udp --dport 53 -j ACCEPT
$IPTABLES -t filter -A INPUT -m mark --mark 99 -j DROP

echo "1" > /proc/sys/net/ipv4/ip_forward
$IPTABLES -A FORWARD -i eth3 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A FORWARD -i eth0 -o eth3 -j ACCEPT
$IPTABLES -t nat -A POSTROUTING -o eth3 -j MASQUERADE
