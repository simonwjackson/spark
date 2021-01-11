#!/bin/sh

socket=/tmp/mpv.socket

if ! pidof mpv; then
  nohup mpv --input-ipc-server="${socket}" "${@}" &
  sleep 1
else
  echo "{ \"command\": [\"loadfile\", \"${@}\"] }" | socat - "${socket}";
fi

echo "{ \"command\": [\"set_property\", \"video\", \"no\"] }" | socat - "${socket}"