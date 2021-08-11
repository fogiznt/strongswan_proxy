#!/bin/sh
a=$(tail -n 10 /var/log/syslog | grep -o "assigning virtual IP 10.10.10")
b=$(tail -n 10 /var/log/syslog | grep -o "deleting IKE_SA ikev2-vpn")


if [ "$a" = "assigning virtual IP 10.10.10" ]; then
a=$(tail -n 10 /var/log/syslog | grep "assigning virtual IP 10.10.10")
server_ip=$(sed -n 3p /root/strong_proxy/settings.txt)
server_ip=${server_ip##*=}
client_ip=$(tail -n 15 /var/log/syslog | grep "established between $server_ip" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | grep -v "$server_ip")
server_domain=$(sed -n 4p /root/strong_proxy/settings.txt)
server_domain=${server_domain##*=}
image_id=$(sed -n 1p /root/strong_proxy/settings.txt)
image_id=${image_id##*=}
user=$client_ip
wait_time=$(sed -n 2p /root/strong_proxy/settings.txt)
wait_time=${wait_time##*=}
ip=$(echo $a | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
local_port=$(shuf -i 7000-7255 -n 1)
proxy_port=$(sed -n 5p /root/strong_proxy/settings.txt)
proxy_port=${proxy_port##*=}
proxy_port=$(shuf -i $proxy_port -n 1)

docker run --name $user -d --net=host --privileged -e socks5 $image_id -a 0.0.0.0 -p $local_port -t $server_domain:$proxy_port
iptables -t nat -I PREROUTING 1 -s $ip -p tcp -j REDIRECT --to-ports $local_port

touch /root/strong_proxy/killproxy_$user
cat >>/root/strong_proxy/killproxy_$user << EOF
#!/bin/sh
sleep $wait_time
docker kill $user
docker rm $user
iptables -t nat -D PREROUTING -s $ip -p tcp -j REDIRECT --to-ports $local_port
rm -f /root/strong_proxy/killproxy_$user
EOF
chmod +x /root/strong_proxy/killproxy_$user
/root/strong_proxy/killproxy_$user > /log.txt 2>&1 &
cat >>/var/www/html/clients << EOF
$client_ip>>$ip:$local_port>>$server_domain:$proxy_port
EOF

elif [ "$b" = "deleting IKE_SA ikev2-vpn" ]; then
server_ip=$(cat /root/strong_proxy/server_ip.txt)
client_ip=$(tail -n 10 /var/log/syslog | grep "deleting IKE_SA ikev2-vpn" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | grep -v "$server_ip")
user=$client_ip
sed -i '2d' /root/strong_proxy/killproxy_$user

/root/strong_proxy/killproxy_$user
num=$(grep -n "$user" /var/www/html/clients | cut -b -1)
sed -i $num'd' /var/www/html/clients
kill_prev=$(pidof $(ps -uax | grep "/bin/sh /root/killproxy_$user"))
kill -9 $kill_prev &
fi
