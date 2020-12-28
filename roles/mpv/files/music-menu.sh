#!/bin/sh

cat ${HOME}/music.txt \
  | fzf \
  | find-full-album-youtube \
  | xargs mpv-audio --ytdl-format=bestaudio