#!/bin/bash
#mkdir duckdns && cd duckdns && vi duck.sh
#chmod 777 duck.sh

#get ext ip addr
ext_ip=$(curl -s ifconfig.me)
#echo $ext_ip

#get local ip addr
loc_ip=$(hostname -I | awk '{print $1}' | tr '.' ':')
#echo $loc_ip

#get time
cur_time=$(date +"%m:%d:%H:%M")
#echo $cur_time

#ipv6 is local_ip + cur_time
ext_ipv6=$loc_ip:$cur_time
#echo $ext_ipv6

#get host name
pi_name=$(hostname)
#echo $pi_name

#URL temp
url_temp="https://www.duckdns.org/update?domains=RaspNum.duckdns.org&token=c55817a8-f351-4755-8235-ac0c6c2ca3ab&ip=8.8.8.8&ipv6=1:2:3:4:5:6:7:8&verbose=true"

#exchange ip addr
#url=${url_temp//8.8.8.8/ext_ip} #can't replace duto format
url=$(echo $url_temp | sed "s/8.8.8.8/$ext_ip/" | sed "s/1:2:3:4:5:6:7:8/$ext_ipv6/" | sed "s/RaspNum/$pi_name/")

#update to duck
echo url="$url" | curl -k -o /home/pi/duckdns/duck.log -K -
#echo $url

#Per 3min update to duckdns.org free support 5 devices
#crontab -e
#*/3 * * * * sh /home/pi/duckdns/duck.sh >/dev/null 2>&1

#log result
#cat duck.log
#OK
#218.161.5.142
#192:168:51:99:06:24:20:54
