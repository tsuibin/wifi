#!/bin/bash

file_date=`date '+%Y%m%d_%H-%M'`
hostname=`hostname`
#前30分钟 named log 
named_date=`date -d '30 minute ago' '+%d-%B-%Y %H:%M'`
cat /var/log/named/named.log|grep "$nginx_date" | gzip > /mnt/tmpfs/named_${hostname}_$file_date.log.gz
#nginx log [28/May/2013:07:46:16
nginx_date=`date -d '30 minute ago' '+%d/%B/%Y:%H:%M'`
cat /data/opt/nginx/logs/proxy.log | grep $nginx_date | gzip > /mnt/tmpfs/proxy_${hostname}_$file_date.log.gz
cat /data/opt/nginx/logs/localhost.log | grep $nginx_date | gzip > /mnt/tmpfs/localhost_${hostname}_$file_date.log.gz
scp -P50022 -o ConnectTimeout=5 /mnt/tmpfs/*.gz carap@202.98.23.149:/data/coach-wifi-data/
scp -P50022 -o ConnectTimeout=5 /mnt/tmpfs/users carap@202.98.23.149:/data/coach-wifi-data/wifi_users_$file_date
scp -P50022 -o ConnectTimeout=5 /mnt/tmpfs/ads carap@202.98.23.149:/data/coach-wifi-data/for_ads_$file_date
scp -P50022 -o ConnectTimeout=5 /mnt/tmpfs/feedback carap@202.98.23.149:/data/coach-wifi-data/wifi_feedback_$file_date
#cd /mnt/tmpfs/ && rm -rf *.gz

#clear log
logs="/data/opt/php/var/log/php-fpm.log /data/opt/nginx/logs/error.log  /data/opt/nginx/logs/localhost.log  /data/opt/nginx/logs/proxy.log /var/log/named/named.log"
for log in $logs
do
	echo $log
 	size=`du $log | awk '{print $1}'`
        if [ $size -ge 1073741824 ];then
                cat /dev/null > $log
        fi
done
