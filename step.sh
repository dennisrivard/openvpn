#!/bin/bash
set -eu

case "$OSTYPE" in
  linux*)
    echo "Configuring for Ubuntu"

    echo ${ca_crt} | base64 -d > /etc/openvpn/ca.crt
    echo ${client_crt} | base64 -d > /etc/openvpn/client.crt
    echo ${client_key} | base64 -d > /etc/openvpn/client.key

    cat <<EOF > /etc/openvpn/client.conf
client
dev tun
proto udp
remote 
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
ca ca.crt
cert client.crt
key client.key
EOF

    service openvpn start client 
    sleep 5

    if ifconfig | grep tun0 > /dev/null
    then
      echo "VPN connection succeeded"
    else
      echo "VPN connection failed!"
      exit 1
    fi
    ;;
  darwin*)
    echo "Configuring for Mac OS"

    echo ${ca_crt} | base64 -D -o ca.crt 
    echo ${client_crt} | base64 -D -o client.crt
    echo ${client_key} | base64 -D -o client.key

    echo "My public IP Address:"
    curl ipinfo.io/ip
    sleep 10s
    echo " "
    
    sudo openvpn --version
#    sudo openvpn --compress --client --dev tun --proto udp --remote {$host} {$port} --resolv-retry infinite --nobind --persist-key --persist-tun --comp-lzo --verb 3 --ca ca.crt --cert client.crt --key client.key --cipher AES-256-CBC --data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC&
#    sudo openvpn --client --dev tun --proto udp --remote {$host} {$port} --resolv-retry infinite --nobind --persist-key --persist-tun --cipher AES-256-CBC --data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC --comp-lzo --verb 9 --tls-client --verify-x509-name sc5-cicd-ovpn-1.squaretrade.com name --ca ca.crt --cert client.crt --key client.key &
    sudo openvpn --client --dev tun --proto udp --remote ${host} ${port} --resolv-retry infinite --nobind --persist-key --persist-tun --cipher AES-256-CBC --data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC --comp-lzo --verb 3 --tls-client --verify-x509-name sc5-cicd-ovpn-1.squaretrade.com name --ca ca.crt --cert client.crt --key client.key &


echo "Using AES-256-CBC"

    sleep 10

#ping github server
    sudo ping -t 5 10.181.75.40

#check for vpn tunnel
    if ifconfig -l | grep utun0 
    then
      echo "VPN connection succeeded"
    else
      echo "VPN connection failed!"
      exit 1
    fi
    ;;
  *)
    echo "Unknown operative system: $OSTYPE, exiting"
    exit 1
    ;;
esac
