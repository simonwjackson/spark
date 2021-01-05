#!/bin/sh

curl \
  -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" \
  -s ${@} \
  | grep \
    --perl-regexp \
    --only-matching \
    '\\x22audioPlaylistId\\x22:\\x22(.{41})\\x22' \
  | awk -F '\\\\x22' '{print $4}'