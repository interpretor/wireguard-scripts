#!/bin/bash

path="$(dirname "$(readlink -f "$0")")"

client="${1%/}"

target="${path}/${client}"
conf="${target}/${client}.conf"
qr_png="${target}/${client}-qr.png"

if [ -z "$client" ]; then
  echo "Please enter client name!" >&2
  exit 1
fi

if [ ! -f "$conf" ]; then
  echo "No client with the name ${client} found!" >&2
  exit 1
fi

umask 177

qrencode --read-from="$conf" --type=UTF8
qrencode --read-from="$conf" --output="$qr_png" --type=PNG

exit 0
