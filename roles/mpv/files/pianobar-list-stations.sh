#!/bin/sh

rm /tmp/piano
mkfifo /tmp/piano
  
$(pianobar > /tmp/piano) & 
$(sleep 1 && killall pianobar) & 

station=$(
  cat /tmp/piano \
  | gawk 'match($0, /([0-9]+)\)[^!]/, a) match($0, /[0-9]+\)[^!]....(.*)/, b) {print a[1] "---" b[1]}' \
  | grep -v -e '^-*$' \
  | fzf -d '---' --with-nth 2 \
  | awk -F '---' '{print $1}'
)

tmux new-session -d -s pianobar
tmux send-keys "pianobar-play-station $station" C-m
tmux detach -s pianobar