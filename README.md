# Duck-DNS
duckdns update information

Raspberry Pi 有什麼方式可以線上知道他是否活著? 我看過 Austin 的 Rolf 弄過一套系統, 在電腦跑一個 python 他會列出來目前有上線的 pi list, 現在有專門的遠端監控工具或服務，這些工具能夠定期檢查設備的狀態並發送警報或通知。一些常見的監控工具包括Zabbix、Nagios、Prometheus等，它們可以配置來監控Raspberry Pi的運行狀態。

其實我們也可以利用 DDNS, 讓 pi 固定跟他回報目前的 ip address, 例如 Duck DNS 他可以一行 shell 就更新本機狀態, 所以我們嘗試把 ipv4 寫成對外網址, ipv6 需要八個數字, 前四個是本地網址, 後四個是月日時分, 接著再利用 crontab -e 每隔三分鐘來執行這個 shell, 這樣我們就可以透過 Duck DNS 的網頁來看 Raspberry 是否有上線且是否還活著.

所以下圖就可以看到 ipv4 是實際的對外網址, 然後 ipv6 的前半段就是內部網址, 後半段就是幾乎是三分鐘內的月:日:時:分, 理論上機器會每三分鐘回報一次, 如果超過這個時間, 你就可以知道大約離線多久了.
![image](https://github.com/ue0705/Duck-DNS/assets/117436583/3c2d4b32-592b-48ad-aeb9-6fb649db05c4)
