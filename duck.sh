#!/bin/bash

#get ext ip addr
ext_ip=$(curl -s ifconfig.me)
#echo $ext_ip

#get local ip addr
loc_ip=$(hostname -I | awk '{print $1}' | tr '.' ':')
#echo $loc_ip

#get time, #%Y max=9999, 
cur_time1=$(date +"%m:%d:%H:%M")
cur_time2=$(date +"%H%M") #$(date +"%Y:%m%d:%H%M") or $(date +"%m%d:%H%M")
#echo $cur_time1
#echo $cur_time2

#get disk free space number(MB), max=9999MB (ffff), or '-BM' -> '-BG' for GB size
cur_size=$(df -BM / | grep '/' | awk '{print $4}' | sed 's/M//') #or df -BM / | awk 'NR==2 {print $4}' | sed 's/M//'
# Extract the thousands and the rest
cur_size_th=$(echo "$cur_size" | awk '{print int($1 / 1000)}')
cur_size_rm=$(echo "$cur_size" | awk '{print $1 % 1000}')
#echo $cur_size, $cur_size_th, $cur_size_rm

#get cpu temperature
cpu_temp=$(vcgencmd measure_temp | grep -o '[0-9]*\.[0-9]*' | cut -d '.' -f 1)
#echo $cpu_temp

#ipv6 is local_ip + HHMM:disk_space(GB):disk_space(%MB):CPU_Temp or old:local_ip + mm:dd:HH:MM 
ext_ipv6=$loc_ip:$cur_time2:$cur_size_th:$cur_size_rm:$cpu_temp #old: $loc_ip:$cur_time1
#echo $ext_ipv6

#get host name, ex:rasp4b-001
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

#log result, old version, g_ipv4, l_ipv4+mm:dd:hh:min
#cat duck.log
#OK
#218.161.5.142
#192:168:51:99:06:24:20:54

#new version, ipv4 + hhmm + free disk size(GB) + free disk size(%MB) + cpu_temp(C)
#cat duck.log
#OK
#218.161.5.142
#192:168:51:99:2054:40:814:70
