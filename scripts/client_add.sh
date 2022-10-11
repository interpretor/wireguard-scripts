#!/bin/bash

path=$(dirname $(readlink -f $0))
dir=${path##*/}
iface=${dir%-*}

wg_dir=${path%/*}
wg_conf="${wg_dir}/${iface}.conf"

address=$(grep 'Address' $wg_conf | awk '{print $3}')
subnet=${address#*/}

last_client_address=$(grep 'AllowedIPs' $wg_conf | tail -1 | awk '{print $3}')

client="${1%/}"

target="${path}/${client}"
privkey="${target}/${client}-private.key"
pubkey="${target}/${client}-public.key"
psk="${target}/${client}.psk"
conf="${target}/${client}.conf"

if [ -z "$client" ]; then
  echo "Please enter client name!" >&2
  exit 1
fi

if [ "$subnet" != "24" ]; then
  echo "Only /24 subnets supported by this script!" >&2
  exit 1
fi

existing_client=$(grep "# ${client}" $wg_conf)

if [ ! -z "$existing_client" ]; then
  echo "A client with the name ${client} already exists!" >&2
  exit 1
fi

if [ -z "$last_client_address" ]; then
  client_number=2
else
  last_client_ip=${last_client_address%/*}
  client_number=$((${last_client_ip##*.} + 1))

  if (( $client_number > 254 )); then
    echo "Maximum number of clients reached (253)!" >&2
    exit 1
  fi
fi

umask 077

mkdir $target

umask 177

wg genkey | tee $privkey | wg pubkey > $pubkey
wg genpsk > $psk

cp base.conf $conf

sed -i "s@PrivateKey =.*@PrivateKey = $(<$privkey)@" $conf
sed -i "s@PresharedKey =.*@PresharedKey = $(<$psk)@" $conf
sed -i "s@Address =.*@Address = ${address%.*}.${client_number}/${subnet}@" $conf

echo "# ${client}" >> $wg_conf
echo "[Peer]" >> $wg_conf
echo "PublicKey = $(<$pubkey)" >> $wg_conf
echo "PresharedKey = $(<$psk)" >> $wg_conf
echo "AllowedIPs = ${address%.*}.${client_number}/32" >> $wg_conf

echo "The client with the name ${client} has been created. Don't forget to restart the ${iface} service."

exit 0
