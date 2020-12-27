#!/bin/sh

SOCKET=/tmp/mpv.socket

if ! pidof mpv; then
	nohup mpv --input-ipc-server="${SOCKET}" --video=1 "${@}" &
else
 	has_video=$(echo "{ \"command\": [\"get_property\", \"video\"] }" | socat - "${SOCKET}" | jq -M -r '.data')

	if [ $has_video == "false" ]; then 
		killall mpv && \
	  nohup mpv --input-ipc-server="${SOCKET}" --video=1 "${@}" &
	else 
    echo "{ \"command\": [\"set_property\", \"video\", 1] }" | socat - "${SOCKET}"
    echo "{ \"command\": [\"loadfile\", \"${@}\"] }" | socat - "${SOCKET}";
	fi
fi