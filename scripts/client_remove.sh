#!/bin/bash

path="$(dirname "$(readlink -f $0)")"
dir="${path##*/}"
iface="${dir%-*}"

wg_dir="${path%/*}"
wg_conf="${wg_dir}/${iface}.conf"

client="${1%/}"

target="${path}/${client}"

if [ -z "$client" ]
then
  echo "Please enter client name!" >&2
  exit 1
fi

if [ ! -d "$target" ]; then
  echo "No client with the name ${client} found!" >&2
  exit 1
fi

rm -r "$client"

sed -i "/\# ${client}\>/,+4d" "$wg_conf"

echo "The client with the name ${client} has been removed. Don't forget to restart the ${iface} service."

exit 0
