#!/bin/sh

SOCKET=/tmp/mpv.socket

if ! pidof mpv; then
  nohup mpv --input-ipc-server="${SOCKET}" "${@}" &
  sleep 1
else
  echo "{ \"command\": [\"loadfile\", \"${@}\"] }" | socat - "${SOCKET}";
fi

echo "{ \"command\": [\"set_property\", \"video\", \"no\"] }" | socat - "${SOCKET}"