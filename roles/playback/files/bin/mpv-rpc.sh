#!/bin/env bash

declare -r socket=/tmp/mpv.socket
declare show_video=0

if [ "${1}" == "--video" ]; then 
  show_video=1
elif [ "${1}" == "--audio" ]; then 
  show_video=0
else
  echo 'first argument must be either --video or --audio'
  exit 1
fi
shift


pidof mpv || \
  (nohup mpv --no-input-terminal --idle --input-ipc-server="${socket}" </dev/null &>/dev/null & sleep .1)

echo '{ "command": ["stop"] }' | socat - "${socket}"
for item in "$@"; do
  echo '{ "command": ["loadfile", "'${item}'", "append-play", "video='${show_video}'"] }' | socat - "${socket}"
done