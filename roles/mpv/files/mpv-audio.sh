#!/bin/sh

SOCKET=/tmp/mpv.socket

if ! pidof mpv; then
	nohup mpv --input-ipc-server="${SOCKET}" "${@}" &
else
  echo "{ \"command\": [\"set_property\", \"video\", \"no\"] }" | socat - "${SOCKET}"
  echo "{ \"command\": [\"loadfile\", \"${@}\"] }" | socat - "${SOCKET}";
fi