#!/bin/sh

youtube-dl \
  -j \
  --flat-playlist "https://www.youtube.com/playlist?list=PLRcY50fIZFfKm9AX14bzA57t8UtrNY5hE" \
  | jq -r '(.title + ";" + .id)' \
  | fzf --with-nth=1 -d ";" \
  | awk -F ";" '{print "https://www.youtube.com/watch?v=" $2}' \
  | xargs mpv-audio