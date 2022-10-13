#!/bin/bash

path="$(dirname "$(readlink -f $0)")"

client="${1%/}"

target="${path}/${client}"
conf="${target}/${client}.conf"

if [ -z "$client" ]; then
  echo "Please enter client name!" >&2
  exit 1
fi

if [ ! -f "$conf" ]; then
  echo "No client with the name ${client} found!" >&2
  exit 1
fi

qrencode --read-from="$conf" --type=UTF8

exit 0
