#!/bin/bash

path=$(dirname $(readlink -f $0))
scripts="${path}/scripts"

echo "Enter the Wireguard interface name (e.g. wg0)"
read iface

echo "Enter the Wireguard address. Only /24 subnets supported by this script. (e.g. 10.20.30.0/24)"
read address

echo "Enter the listening port of the Wireguard interface (e.g. 51820)"
read port

echo "Enter the DNS server (optional) (e.g. 9.9.9.9)"
read dns

echo "Enter the endpoint domain or IP (e.g. wg.domain.tld)"
read endpoint

echo "Enter allowed IPs including submask, separate with comma if multiple (e.g. 0.0.0.0/0, 192.168.0.0/24)"
read allowed_ips

privkey="${path}/${iface}-private.key"
pubkey="${path}/${iface}-public.key"
conf="${path}/${iface}.conf"
clients_path="${path}/${iface}-clients"
clients_conf="${clients_path}/base.conf"

umask 077

mkdir $clients_path

umask 177

wg genkey | tee $privkey | wg pubkey > $pubkey

echo "[Interface]" >> $conf
echo "PrivateKey = $(<$privkey)" >> $conf
echo "Address = ${address%.*}.1/24" >> $conf
echo "ListenPort = ${port}" >> $conf
echo "" >> $conf

echo "[Interface]" >> $clients_conf
echo "PrivateKey =" >> $clients_conf
echo "Address =" >> $clients_conf
if [ ! -z "$dns" ]; then
  echo "DNS = ${dns}" >> $clients_conf
fi
echo "" >> $clients_conf

echo "[Peer]" >> $clients_conf
echo "PublicKey = $(<$pubkey)" >> $clients_conf
echo "PresharedKey =" >> $clients_conf
echo "Endpoint = ${endpoint}:${port}" >> $clients_conf
echo "AllowedIPs = ${allowed_ips}" >> $clients_conf

umask 077

cp $scripts/* $clients_path

exit 0
