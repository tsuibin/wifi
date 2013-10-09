
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
##1.
#sudo iptables -P INPUT DROP
#sudo iptables -P FORWARD  ACCEPT  
#sudo iptables -P OUTPUT  ACCEPT 

#2. Allow ssh http
#sudo iptables -A INPUT -p tcp -m multiport --dport 80,22,3128 -j ACCEPT 


#sudo iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-port 53

#sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
# iptables -t nat -A POSTROUTING -o eth3 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth1  -m comment --comment "开始网卡转发" -j MASQUERADE
sudo iptables -t mangle -N internet

#sudo iptables -t mangle -N localhost
#sudo iptables -t mangle -A localhost -j MARK --set-mark 199
#sudo iptables -t mangle -A PREROUTING  -i eth0 -s 192.168.0.0/16 -p tcp -m tcp --dport 80 -j localhost

sudo iptables -t mangle -A PREROUTING -i eth0 -p tcp -m tcp --dport 80: -j internet
sudo iptables -t mangle -A internet -j MARK --set-mark 99
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp -m mark --mark 99 -m tcp --dport 80: -j DNAT --to-destination 192.168.10.245
#sudo iptables -t nat -A PREROUTING -i eth0 -p tcp -m mark --mark 99 -m tcp --dport 80 -j DNAT --to-destination 192.168.1.245
#sudo iptables -t nat -A PREROUTING -p tcp -m mark --mark 99 --destination-port 80 -j REDIRECT --to-ports 3128 -m comment --comment "所有ip全部走透明代理"

sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -i eth0 -d 192.168.0.0/16 -j ACCEPT
sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-ports 3128 -m comment --comment "所有ip全部走透明代理"


IPTABLES='sudo iptables'
#$IPTABLES -t filter -A FORWARD -m mark --mark 99 -j DROP
#$IPTABLES -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
#$IPTABLES -t filter -A INPUT -p udp --dport 53 -j ACCEPT
#$IPTABLES -t filter -A INPUT -m mark --mark 99 -j DROP


#允许出站DNS连接
#sudo iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT 
#sudo iptables -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT 

#sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 53 -j DNAT --to 127.0.0.1
#sudo iptables -t nat -A PREROUTING -p udp -i eth0 --dport 53 -j DNAT --to 127.0.0.1
#sudo iptables -t nat -A POSTROUTING -p tcp -o eth0 --dport 53 -j SNAT --to 127.0.0.1
#sudo iptables -t nat -A POSTROUTING -p udp -o eth0 --dport 53 -j SNAT --to 127.0.0.1

#sudo iptables -t nat -A PREROUTING -i eth0 -p tcp -m mark --mark 99 -m tcp --dport 80 -j DNAT --to-destination 192.168.10.245
#sudo iptables -t mangle -I internet 1 -m mac --mac-source USER-MAC-ADDRESS-HERE -j RETURN


