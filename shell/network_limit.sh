#!/bin/bash

for((i=2;i<255;i++));do
#下载速度
iptables -A FORWARD -s 192.168.0.$i -m limit --limit 50/s -j ACCEPT
iptables -A FORWARD -s 192.168.0.$i -j DROP
#上传速度
iptables -A FORWARD -d 192.168.0.$i -m limit --limit 20/s --limit-burst 100 -j ACCEPT 
iptables -A FORWARD -d 192.168.0.$i -j DROP
done
exit;
# 定义进出设备(eth0 内网，eth1外网)
#  定义进出设备(如果不是ADSL拨号用户可以把ppp0改为eth1)
IDEV="eth0"
ODEV="eth1"
#  定义总的上下带宽
UP="60kbps"
DOWN="400kbps"

#  定义每个受限制的IP上下带宽
UPLOAD="10kbps"
DOWNLOAD="100kbps"

# 定义限制的IP范围以外的共享速度outdown为下行outup为上行
outdown="2kbps"
outup="2kbps"

# 清除 ppp0 eth0 所有队列规则
tc qdisc del dev $ODEV root 2>/dev/null
tc qdisc del dev $IDEV root 2>/dev/null

# 定义最顶层(根)队列规则，并指定 default 类别编号
tc qdisc add dev $ODEV root handle 10: htb default 2254
tc qdisc add dev $IDEV root handle 10: htb default 2254
# 定义第一层的 10:1 类别 (上行/下行 总频宽)
tc class add dev $ODEV parent 10: classid 10:1 htb rate $UP ceil $UP
tc class add dev $IDEV parent 10: classid 10:1 htb rate $DOWN ceil $DOWN
#定义请求内网资源不限制带宽使用

tc class add dev $ODEV parent 10:1 classid 10:20 htb rate $UPLOAD ceil $UPLOAD prio 1
tc qdisc add dev $ODEV parent 10:20 handle 1000: sfq perturb 10
tc filter add dev $ODEV parent 10: protocol ip prio 100 handle 20 fw classid 10:20
iptables -t mangle -A POSTROUTING -s 192.168.0.1 -j MARK --set-mark 20


#定义default 类别编的上行 （上面没定义带宽的IP上行速度）
tc class add dev $ODEV parent 10:1 classid 10:2254 htb rate $outup ceil $outup prio 1
#tc qdisc add dev $ODEV parent 10:2254 handle 100254: pfifo
tc qdisc add dev $ODEV parent 10:2254 handle 100254: sfq perturb 10
tc filter add dev $ODEV parent 10: protocol ip prio 100 handle 2254 fw classid 10:2254

#定义default 类别编的下行 （上面没定义带宽的IP下行速度）
tc class add dev $IDEV parent 10:1 classid 10:2254 htb rate $outdown ceil $outdown prio 1
#tc qdisc add dev $IDEV parent 10:2254 handle 100254: pfifo
tc qdisc add dev $IDEV parent 10:2254 handle 100254: sfq perturb 10
tc filter add dev $IDEV parent 10: protocol ip prio 100 handle 2254 fw classid 10:2254

exit;
#删除原来的tc规则队列
tc qdisc del dev $IDEV root
#添加tc规则队列
tc qdisc add dev $IDEV root handle 10: htb default 256
#生成根类
tc class add dev $IDEV parent 10: classid 10:1 htb rate 100mbit ceil 100mbit
#支类列表用于限制速度
#这里的rate指的是保证带宽,ceil是最大带宽。
tc class add dev $IDEV parent 10:1 classid 10:10 htb rate 40kbps ceil 4kbps prio 1
#添加支类规则队列
#采用sfq伪随机队列，并且10秒重置一次散列函数。
tc qdisc add dev $IDEV parent 10:10 handle 101: sfq perturb 10

#建立网络包过滤器，设置fw。
#tc filter add dev $IDEV parent 10: protocol ip prio 1 u32 match ip dst 192.168.0.0/24 flowid 10:10
#tc filter add dev eth0 parent 10: protocol ip prio 10 handle 10 fw classid 10:10
#在iptables里面设定mark值，与上面的handle值对应。
#iptables -t mangle -A POSTROUTING -s 192.168.0.1 -j MARK --set-mark 10

#tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match ip dst 172.17.0.0/16 flowid 1:3
