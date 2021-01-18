#!/bin/sh

echo "" \
| fzf \
  --reverse \
  --sync \
  --print-query \
  --prompt "Youtube> " \
| xargs \
  -I {} \
  googler \
    --json \
    --count 20 \
    --site "youtube.com/watch" {} \
| jq \
  -c \
  -r '.[] | [.title, .abstract, .url] | @tsv' \
| fzf \
  --sync \
  --no-sort \
  --reverse \
  --with-nth 1 \
  --delimiter $'\t' \
  --preview-window="down:20%:wrap" \
  --preview='echo {} | awk -F "\t" "{print \$2}"' \
| awk \
  -F $'\t' \
  '{print $3}' \
| xargs \
  -I {} \
  mpv-video {}

# read -p 'Google: ' query

# googler \
#   --json \
#   -V "${query}" \
#   | jq -r '.[] | [.title,.url] | join("\t")' \
#   | fzf \
#     -d "\t" \
#     --with-nth 1 \
#   | cut -f 2 \
#   | xargs mpv-video
