#!/bin/env sh

colorscheme=${1}
colorscheme_file="${HOME}/.local/share/colorscheme"

echo "${colorscheme}" > "${colorscheme_file}"

ls /tmp/nvim**/0 \
| xargs \
  -n 1 \
  -P 8 \
  -I % \
  nvr -s --nostart --servername % -c ":colorscheme ${colorscheme}" &

kitty @ --to unix:/tmp/kitty.socket set-colors -a "${HOME}/.config/kitty/colors/${colorscheme}.conf" &
