#!/bin/sh
a=$(tail -n 5 /var/log/syslog | grep -o "assigning virtual IP 10.10.10")
b=$(tail -n 5 /var/log/syslog | grep -o "deleting IKE_SA ikev2-vpn")

if [ "$a" = "assigning virtual IP 10.10.10" ]; then
a=$(tail -n 5 /var/log/syslog | grep "assigning virtual IP 10.10.10")
client_ip=$(tail -n 10 /var/log/syslog | grep "established between 68.183.224.129" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
client_ip=$(echo $client_ip | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | grep -v "68.183.224.129")

user=$client_ip
ip=$(echo $a | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
local_port=$(shuf -i 0-255 -n 1)
proxy_port=$(shuf -i 0-298 -n 1)
local_len_check=${#local_port}
if [ $local_len_check = "1" ]; then
local_port=00$local_port
elif [ $local_len_check = "2" ]; then
local_port=0$local_port
fi

proxy_len_check=${#proxy_port}
if [ $proxy_len_check = "1" ]; then
proxy_port=00$proxy_port
elif [ $proxy_len_check = "2" ]; then
proxy_port=0$proxy_port
fi

docker run --name $user -d --net=host --privileged -e socks5 c6e74553c2a3 -a 0.0.0.0 -p 7$local_port -t proxy.soax.com:10$proxy_port
iptables -t nat -I PREROUTING 1 -s $ip -p tcp -j REDIRECT --to-ports 7$local_port

touch /root/killproxy_$user
cat >>/root/killproxy_$user << EOF
#!/bin/sh
sleep 90
docker kill $user
docker rm $user
iptables -t nat -D PREROUTING -s $ip -p tcp -j REDIRECT --to-ports 7$local_port
rm -f /root/killproxy_$user
EOF
chmod +x /root/killproxy_$user
/root/killproxy_$user > /log.txt 2>&1 &
cat >>/root/users.txt << EOF
$client_ip>>$ip:7$local_port>>proxy.soax.com:10$proxy_port
EOF

elif [ "$b" = "deleting IKE_SA ikev2-vpn" ]; then
client_ip=$(tail -n 5 /var/log/syslog | grep "deleting IKE_SA ikev2-vpn" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | grep -v "68.183.224.129")
user=$client_ip
sed -i '2d' /root/killproxy_$user

/root/killproxy_$user
num=$(grep -n "$user" /root/users.txt | cut -b -1)
sed -i $num'd' /root/users.txt
kill_prev=$(pidof /bin/sh /root/killproxy_$user)
kill_prev=${kill_prev%%\ *}
kill -9 $kill_prev
fi
