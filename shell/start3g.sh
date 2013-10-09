#!/bin/bash
while true; do
    LC_ALL=C nmcli -t -f TYPE,STATE dev | grep -q "^gsm:disconnected$"
    if [ $? -eq 0 ]; then
        echo "3G Not connected"

        #nmcli -t nm wwan off
        #echo "nm wwan off"
        #sleep 1
        #nmcli -t nm wwan on
	#echo "nm wwan on"
        #sleep 1
        nmcli -t con up id "China Unicom Default"
        echo "nmcli con up"
        sleep 15
    fi
    sleep 2
done
