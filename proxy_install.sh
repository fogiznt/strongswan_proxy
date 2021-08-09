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
wget https://github.com/fogiznt/strongswan_proxy/archive/refs/heads/main.zip
uzip main.zip
docker build /root/strong_proxy/strongswan_proxy-main/docker/
image_id=$(docker images | tail -n -1)
image_id=$(echo ${image_id##*>} | cut -b -12)
echo "$image_id" > ./image_id.txt
server_ip=$(curl check-host.net/ip)
echo "$server_ip" > ./server_ip.txt
echo -e "${BLUE}Введите домен или ip сервера${DEFAULT}"
read server_domain
echo "$server_domain" > ./domain_name.txt
echo -e "${BLUE}Введите диапазон портов сервера\nК примеру - 10000-10298${DEFAULT}"
read proxy_port_range
echo "$proxy_port_range" > ./proxy_port_range.txt
wget https://raw.githubusercontent.com/fogiznt/strongswan_proxy/main/proxy_manager.sh
echo "    leftupdown=/root/strong_proxy/proxy_manager.sh" >> /etc/ipsec.conf

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
