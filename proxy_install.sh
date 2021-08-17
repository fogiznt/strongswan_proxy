#!/bin/sh
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
DEFAULT='\033[0m'
### Установка Docker
apt-get remove docker docker-engine docker.io
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

### Установка вспомогательных утилит
apt install apache2
apt install redsocks
apt install zip
apt install iptables-persistent
netfilter-persistent-save

### Формирование образа Docker
mkdir /root/strong_proxy
cd /root/strong_proxy
touch /root/strong_proxy/settings.txt
chmod 666 /root/strong_proxy/settings.txt
wget https://github.com/fogiznt/strongswan_proxy/archive/refs/heads/main.zip
unzip main.zip
chmod -R 777 /root/strong_proxy/strongswan_proxy-main/docker
docker build /root/strong_proxy/strongswan_proxy-main/docker/
#### Получение основыных переменных - id образа докер, адрес и порты прокси
echo -e "${BLUE}Введите IMAGE ID последнего (самого верхнего в списке) сформированного образа${DEFAULT}"
docker images
read image_id
echo "image_id=$image_id" >> /root/strong_proxy/settings.txt
echo -e "${BLUE}Введите время ожидания перед отключением прокси${DEFAULT}"
read wait_time
echo "wait_time=$wait_time" >> /root/strong_proxy/settings.txt

server_ip=$(curl check-host.net/ip)
echo "server_ip=$server_ip" >> /root/strong_proxy/settings.txt
echo -e "${BLUE}Введите домен или ip сервера${DEFAULT}"
read server_domain
echo "server_domain=$server_domain" >> /root/strong_proxy/settings.txt
echo -e "${BLUE}Введите диапазон портов сервера\nК примеру - 10000-10298${DEFAULT}"
read proxy_port_range
echo "proxy_port_range=$proxy_port_range" >> /root/strong_proxy/settings.txt
speed=30
echo "speed=$speed">> /root/strong_proxy/settings.txt
#### Загрузка управляющего скрипта
wget https://raw.githubusercontent.com/fogiznt/strongswan_proxy/main/proxy_manager.sh
chmod +x ./proxy_manager.sh
echo "    leftupdown=/root/strong_proxy/proxy_manager.sh" >> /etc/ipsec.conf
systemctl restart strongswan.service 
#### Настройка apache2
cd /var/www/html/
touch clients
rm index.html
cat >>index.html <<EOF
<!doctype html>
<html >
<head>
  <meta charset="utf-8" />
  <title></title>
</head>
<body>
 <a href="clients">Клиенты</a>
</body>
</html>
EOF
