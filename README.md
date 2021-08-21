Настройка прокси в паре со strongswan_vpn Ubuntu 18.04.5  
Этот скрипт используется после настройки сервера strongswan_vpn  

Цепочка такая  
клиент--->впн_сервер_strongswan--->прокси--->интернет  
Через определённое количество секунд (см.ниже) после подключения цепочка превращается в  
клиент--->впн_сервер_strongswan--->интернет  

Перенаправление трафика с впн_сервера на прокси происходит посредством использования утилит docker - redsocks - iptables  

При установке сервера вас спросят образ докера, время ожидания после подключения, домен прокси, диапазон портов прокси.  
Эти значения всегда можно поменять в файлах /root/strong_proxy  
/root/strong_proxy/settigs.txt  
image_id - название образа docker  
wait_time.txt - время до отключения прокси   
domain_name.txt - домен или ip прокси  
proxy_port_range.txt - диапазон портов прокси  
speed - ограничение скорости для клиентов в мегабитах  

Команды установки  
``` 
cd ~
wget https://raw.githubusercontent.com/fogiznt/strongswan_proxy/main/proxy_install.sh
chmod +x proxy_install.sh
./proxy_install.sh
```

