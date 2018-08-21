# for_widnows_update

run administrators .....


Windows Update時卻出現錯誤代碼 80004002。可試試下列方式:
 

系統管理員身分執行 CMD

於命令提示字元中，輸入指令 fsutil resource setautoreset true c:\，按下Enter

於命令提示字元中，輸入指令 sfc /scannow

於命令提示字元中，輸入指令 net stop wuauserv

於命令提示字元中，輸入指令 net stop "Cryptographic Services" 

於命令提示字元中，輸入指令 net stop bits

C:\Windows\SoftwareDistribution  將它刪除

C:\Windows\System32\Catroot2  將它刪除

shutdown -r -t 0 重新啟動電腦
