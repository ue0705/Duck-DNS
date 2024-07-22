#Gen by fue0416@gmail.com 20240707 ver 1.6
#!/bin/bash

#Per 3min update to duckdns.org free support 5 devices
#crontab -e
#*/3 * * * * sh /home/$USER_NAME/duckdns/duck.sh >/dev/null 2>&1

#set run path, pls replace "pi" to your user name
USER_NAME="pi"
BASE_DIR="/home/$USER_NAME/duckdns"

#URL temp
url_temp="https://www.duckdns.org/update?domains=RaspNum.duckdns.org&token=YOUR_DUCK_TOKEN&ip=8.8.8.8&ipv6=1:2:3:4:5:6:7:8&verbose=true"

# Line Notify Token (replace you real Token)
LINE_NOTIFY_TOKEN="YOUR_LINE_TOKEN"

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

#exchange ip addr
#url=${url_temp//8.8.8.8/ext_ip} #can't replace duto format
url=$(echo $url_temp | sed "s/8.8.8.8/$ext_ip/" | sed "s/1:2:3:4:5:6:7:8/$ext_ipv6/" | sed "s/RaspNum/$pi_name/")

#get current folder and update to duck
echo url="$url" | curl -k -o "$BASE_DIR/duck.log" -K -
#echo $url

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

#fail example1
#cat duck.log
#KO

#fail example2
#cat duck.log
#<html>
#,<head><title>502 Bad Gateway</title></head>
#,<body>

#------------- save duck.log to duck.csv ------------
#!/bin/bash

# set source duck.log and output(sunday is week first day) ex:2024_0721_0727_week30_duck.csv file path
LOG_FILE="$BASE_DIR/duck.log"
CSV_FILE="$BASE_DIR/result/$(date +'%Y')_$(date -d"last sunday" +'%m%d')_$(date -d"last sunday + 6 days" +'%m%d')_week$(date +'%V')_duck.csv"
CSV_DIRECT="$BASE_DIR/result"

# if not direct then create direct
if [ ! -d "$CSV_DIRECT" ]; then
  mkdir -p "$CSV_DIRECT"
fi

# if not file then init duck.csv，write header
if [ ! -f "$CSV_FILE" ]; then
  echo "timestamp,hostname,duck_result,duck_ipv4,duck_ipv6,free_space(MB),cpu_temp(C)" > "$CSV_FILE"
fi

# Read duck.log 3 line, pls reference duck.log format
if [ -f "$LOG_FILE" ]; then
    duck_result=$(sed -n '1p' "$LOG_FILE")
    if [ "$duck_result" = "OK" ]; then
        duck_ipv4=$(sed -n '2p' "$LOG_FILE")
        duck_ipv6=$(sed -n '3p' "$LOG_FILE")
    elif [ "$duck_result" = "KO" ]; then
        duck_ipv4="N/A"
        duck_ipv6="N/A"
    else
        duck_result="FAIL"
        duck_ipv4="502 bad Gateway"
        duck_ipv6="html"
    fi
else
    echo "duck.log file not exist or can't read"
    continue
fi

# gen now timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# out all information to duck.csv
echo "$TIMESTAMP,$pi_name,$duck_result,$duck_ipv4,$duck_ipv6,$cur_size,$cpu_temp" >> "$CSV_FILE"

#------------- send line message perday when 12:00AM ------------
#!/bin/bash

# check 12:00AM
if [ "$(date +"%H:%M")" = "12:00" ]; then
	msg="message="+"$TIMESTAMP,$pi_name,$duck_result,$duck_ipv4,$duck_ipv6,$cur_size,$cpu_temp"
	curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -H "Authorization: Bearer ""$LINE_NOTIFY_TOKEN" --data "$msg" https://notify-api.line.me/api/notify
fi
