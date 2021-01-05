#!/bin/sh

read -p 'Google: ' query

googler \
  --json \
  -V "${query}" \
  | jq -r '.[] | [.title,.url] | join("\t")' \
  | fzf \
    -d "\t" \
    --with-nth 1 \
  | cut -f 2 \
  | xargs mpv-video