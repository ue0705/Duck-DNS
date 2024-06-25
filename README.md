# Duck-DNS
duckdns update information

Raspberry Pi 有什麼方式可以線上知道他是否活著? 我看過 MTK 的 Austin 的 Rolf 弄過一套系統, 現在有專門的遠端監控工具或服務，這些工具能夠定期檢查設備的狀態並發送警報或通知。一些常見的監控工具包括Zabbix、Nagios、Prometheus等，它們可以配置來監控Raspberry Pi的運行狀態。

其實我們也可以利用 Duck DNS, 他可以一行 shell 就更新本機狀態, 所以我們嘗試把 ipv4 寫成對外網址, ipv6 需要八個數字, 前四個是本地網址, 後四個是月日時分, 接著再利用 crontab -e 每隔三分鐘來執行這個 shell, 這樣我們就可以透過 Duck DNS 的網頁來看 Raspberry 是否有上線.

![image](https://github.com/ue0705/Duck-DNS/assets/117436583/3c2d4b32-592b-48ad-aeb9-6fb649db05c4)
