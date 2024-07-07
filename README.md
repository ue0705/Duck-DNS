# Duck-DNS
Short description:
Using DuckDNS's update function, configure the Raspberry Pi to update the global IP in the IPv4 field every three minutes, and fill the local IP in the first four digits of the IPv6 field. The remaining four digits should include the time, disk free space, and CPU temperature. Save the records to a CSV file to provide external processing by another service, which will generate visual charts to clearly display system temperature and other information.

簡短說明:
利用 DuckDNS 更新的功能, 將 Raspberry Pi 固定每三分鐘更新廣域 ip 填到 ipv4 欄位, 將本地 ip 填到 ipv6 前四碼, 剩下的後四碼填上 時間:磁碟剩餘空間:CPU溫度, 並且將記錄存到 CSV 檔案, 提供外部 ducker 做其他整理, 畫出視覺畫圖表, 讓系統的溫度等訊息更清楚.
=================================================================================================

Raspberry Pi 有什麼方式可以線上知道他是否活著? 我看過 Austin 的 Rolf 弄過一套系統, 在電腦跑一個 python 他會列出來目前有上線的 pi list, 現在有專門的遠端監控工具或服務，這些工具能夠定期檢查設備的狀態並發送警報或通知。一些常見的監控工具包括Zabbix、Nagios、Prometheus等，它們可以配置來監控Raspberry Pi的運行狀態。

其實我們也可以利用 DDNS, 讓 pi 固定跟他回報目前的 ip address, 例如 Duck DNS 他可以一行 shell 就更新本機狀態, 所以我們嘗試把 ipv4 寫成對外網址, ipv6 需要八個數字, 前四個是本地網址, 後四個是月日時分, 接著再利用 crontab -e 每隔三分鐘來執行這個 shell, 這樣我們就可以透過 Duck DNS 的網頁來看 Raspberry 是否有上線且是否還活著.

所以下圖就可以看到 ipv4 是實際的對外網址, 然後 ipv6 的前半段就是內部網址, 後半段就是幾乎是三分鐘內的月:日:時:分, 理論上機器會每三分鐘回報一次, 如果超過這個時間, 你就可以知道大約離線多久了.
![image](https://github.com/ue0705/Duck-DNS/assets/117436583/3c2d4b32-592b-48ad-aeb9-6fb649db05c4)

2024/7/3 更新
我突然想到 Raspberry 有記憶卡, 有時候我們不知道他的剩餘空間, 於是我稍微修改了一下 ipv6 的格式, 我把原本的 local_ipv4:mm:dd:HH:MM 共八個數字, 改成 local_ipv4:YY:mmdd:HHMM:free_disk(dec MB), 結果最後一個如果超過 9999MB 也就是 10GB 會無法塞進去, 他的格式就是八個 ffff, 我轉成 16進制就會變成非常難讀, 所以我把年給拆掉, 然後MB改成千位也就是GB, 外加餘數MB來顯示, 所以最大可以顯示 9999GB, 也就是約 10TB, 應該 raspberry pi 暫時沒有這種等級的記憶卡才是. 然後 mmdd 的日期更新我也拿掉, 實際上 HH:MM 的時間也可以拿掉, 因為他右邊還是有最後更新時間, 最後的位址我擠出來放 CPU 溫度, 所以最後的格式就會變成 local_ipv4:HHMM:free_disk(dec GB):free_disk(dec 餘數MB):CPU_Temperature(C), 可以看到 Pi Zero 2W 岌岌可危只剩下 1401MB 了, Pi 4B 溫度始終高居 69C, 要去弄散熱模組.
![image](https://github.com/ue0705/Duck-DNS/assets/117436583/ea6e0c3b-37c1-49ef-8a46-6d82d3190681)

2024/7/7 更新
把每三分鐘的 duck.log 更新結果, 加上本地訊息, 每次新增到 result 目錄中, 檔名每週更換一次, 例如 2024_0701_0707_week27_duck.csv, 方便日後調取日誌, 並劃出剩餘磁碟空間或者 CPU 溫度曲線等功能.

=================================================================================================

How can I check online if a Raspberry Pi is alive? I saw Austin's Rolf create a system that runs a Python script on a computer to list the currently online Pi devices. Nowadays, there are dedicated remote monitoring tools or services that can regularly check the status of devices and send alerts or notifications. Some common monitoring tools include Zabbix, Nagios, Prometheus, etc. These can be configured to monitor the running status of a Raspberry Pi.

We can also use DDNS to let the Pi report its current IP address regularly. For instance, Duck DNS can update the local status with a single shell command. Therefore, we can try to write the IPv4 address as an external URL. IPv6 needs eight numbers, where the first four are the local URL and the last four represent the month, day, hour, and minute. Then, using `crontab -e`, we execute this shell command every three minutes. This way, we can check the Duck DNS webpage to see if the Raspberry Pi is online and alive.

The diagram below shows the IPv4 as the actual external URL, the first half of the IPv6 as the internal URL, and the second half as the timestamp (MM:DD:HH:MM) within three minutes. Theoretically, the machine will report every three minutes, so if it exceeds this time, you can estimate how long it has been offline.
![image](https://github.com/ue0705/Duck-DNS/assets/117436583/3c2d4b32-592b-48ad-aeb9-6fb649db05c4)

Update on 2024/7/3:
I suddenly thought of the Raspberry Pi's memory card. Sometimes we don't know its remaining space, so I slightly modified the IPv6 format. I changed the original `local_ipv4:mm:dd:HH:MM` (total eight digits) to `local_ipv4:YY:mmdd:HHMM:free_disk(dec MB)`. If the last one exceeds 9999MB, i.e., 10GB, it can't fit. The format is eight `ffff`, and converting it to hexadecimal makes it very difficult to read. So, I removed the year and changed MB to thousand units, i.e., GB, plus the remaining MB. This way, it can display up to 9999GB, approximately 10TB, which the Raspberry Pi is unlikely to have such a high-capacity memory card. Also, I removed the `mmdd` date update, and the `HH:MM` time can be removed too since the last update time is still on the right. The final address now includes CPU temperature. The final format is `local_ipv4:HHMM:free_disk(dec GB):free_disk(dec remaining MB):CPU_Temperature(C)`. You can see the Pi Zero 2W is critically low with only 1401MB left, and the Pi 4B's temperature remains high at 69°C, so a cooling module is needed.
![image](https://github.com/ue0705/Duck-DNS/assets/117436583/ea6e0c3b-37c1-49ef-8a46-6d82d3190681)

Update on 2024/7/7:
I added the local information to the duck.log update results every three minutes. Each time, the new data is appended to the end of duck.csv for future log retrieval, enabling plotting of remaining disk space or CPU temperature curves and other functions.

