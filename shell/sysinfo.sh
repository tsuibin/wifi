#!/bin/sh
#
filename=`hostname`
Time2=`date +%Y%m%d`
## 定义变量Time1 显示状态 为YYYYMMDD
#
Time1=${filename}_`date '+%Y%m%d_%H-%M'`
## 定义变量Time2 显示状态为 x年x月x日 星期x x时x分x秒
#
cd /mnt/tmpfs/
## 日志文件的路径
#
echo "=================================================================" >>sysinfo_$Time1.log
#
echo "-------------------">>sysinfo_$Time1.log
echo "[ sysinfo ]">>sysinfo_$Time1.log
echo "-------------------">>sysinfo_$Time1.log
#
date +%c>>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
echo "Cpu状态">>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
sar -P ALL 1 5 -u >>sysinfo_$Time1.log
#3G 网卡流量

echo "" >>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
echo "3G网卡状态">>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
time=`date +%m"-"%d" "%k":"%M`
day=`date +%m"-"%d`
rx_before=`ifconfig ppp0|sed -n "7"p|awk '{print $2}'|cut -c7-`
tx_before=`ifconfig ppp0|sed -n "7"p|awk '{print $6}'|cut -c7-`
sleep 2
rx_after=`ifconfig ppp0|sed -n "7"p|awk '{print $2}'|cut -c7-`
tx_after=`ifconfig ppp0|sed -n "7"p|awk '{print $6}'|cut -c7-`
rx_result=$((($rx_after-$rx_before)/256))
tx_result=$((($tx_after-$tx_before)/256))
echo "ppp0 $time Now_In_Speed: "$rx_result"kbps Now_OUt_Speed: "$tx_result"kbps rx_before:"$rx_before "tx_before:" $tx_before >> sysinfo_$Time1.log



## 当前时间收集5次CPU占用状况，系统取得平均值
#
echo "" >>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
echo "网卡状态">>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
sar 1 3 -n DEV>>sysinfo_$Time1.log
## 当前时间收集3次网络流量状况，系统取得平均值
#
echo "" >>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
echo "内存状态(M单位)">>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
free -m >>sysinfo_$Time1.log
## 以M为单位显示当前内存状态
#
echo "" >>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
echo "磁盘占用状况(M单位)">>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
df -m>>sysinfo_$Time1.log
## 以M为单位显示当前磁盘占用状态
#
#获取cpu温度
echo "" >>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
echo "cpu 温度">>sysinfo_$Time1.log
echo "--------------------" >>sysinfo_$Time1.log
/usr/bin/sensors >>sysinfo_$Time1.log
echo "" >>sysinfo_$Time1.log
scp -P50022 -o ConnectTimeout=5 /mnt/tmpfs/sysinfo_$Time1.log carap@202.98.23.149:/data/coach-wifi-data/
#
################################
