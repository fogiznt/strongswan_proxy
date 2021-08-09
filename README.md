Нстройка прокси в паре со strongswan_vpn Ubuntu 18.04.5 

клиент--->впн_сервер_strongswan--->прокси--->интернет
Через 90 секунд после подключения цепочка превращается в
клиент--->впн_сервер_strongswan--->интернет

Перенаправление трафика с впн_сервера на прокси прооисходит посредством использования утилит docker - redsocks - iptables

При установке сервера вас спросят образ докера, домен прокси, диапазон портов прокси.
Эти значения всегда можно поменять в файлах /root/strong_proxy
/root/strong_proxy/image_id.txt - имя образа
/root/strong_proxy/domain_name.txt - домен или ip прокси
/root/strong_proxy/proxy_port_range.txt.txt - диапазон портов прокси

``` 
cd ~
wget https://raw.githubusercontent.com/fogiznt/strongswan_proxy/main/proxy_install.sh
chmod +x proxy_install.sh
./proxy_install.sh
```

