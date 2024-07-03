# Duck-DNS
duckdns update information

Raspberry Pi 有什麼方式可以線上知道他是否活著? 我看過 Austin 的 Rolf 弄過一套系統, 在電腦跑一個 python 他會列出來目前有上線的 pi list, 現在有專門的遠端監控工具或服務，這些工具能夠定期檢查設備的狀態並發送警報或通知。一些常見的監控工具包括Zabbix、Nagios、Prometheus等，它們可以配置來監控Raspberry Pi的運行狀態。

其實我們也可以利用 DDNS, 讓 pi 固定跟他回報目前的 ip address, 例如 Duck DNS 他可以一行 shell 就更新本機狀態, 所以我們嘗試把 ipv4 寫成對外網址, ipv6 需要八個數字, 前四個是本地網址, 後四個是月日時分, 接著再利用 crontab -e 每隔三分鐘來執行這個 shell, 這樣我們就可以透過 Duck DNS 的網頁來看 Raspberry 是否有上線且是否還活著.

所以下圖就可以看到 ipv4 是實際的對外網址, 然後 ipv6 的前半段就是內部網址, 後半段就是幾乎是三分鐘內的月:日:時:分, 理論上機器會每三分鐘回報一次, 如果超過這個時間, 你就可以知道大約離線多久了.
![image](https://github.com/ue0705/Duck-DNS/assets/117436583/3c2d4b32-592b-48ad-aeb9-6fb649db05c4)

2024/7/3 更新
我突然想到 Raspberry 有記憶卡, 有時候我們不知道他的剩餘空間, 於是我稍微修改了一下 ipv6 的格式, 我把原本的 local_ipv4:mm:dd:HH:MM 共八個數字, 改成 local_ipv4:YY:mmdd:HHMM:free_disk(dec MB), 結果最後一個如果超過 9999MB 也就是 10GB 會無法塞進去, 他的格式就是八個 ffff, 我轉成 16進制就會變成非常難讀, 所以我把年給拆掉, 然後MB改成千位也就是GB, 外加餘數MB來顯示, 所以最大可以顯示 9999GB, 也就是約 10TB, 應該 raspberry pi 暫時沒有這種等級的記憶卡才是. 所以最後的格式就會變成 local_ipv4:mmdd:HHMM:free_disk(dec GB):free_disk(dec 餘數MB).
![Uploading image.png…]()
