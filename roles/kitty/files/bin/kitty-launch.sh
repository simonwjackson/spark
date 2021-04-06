#!/bin/env sh

file="${HOME}/.config/kitty/colors/$(cat "${HOME}/.local/share/colorscheme").conf"

kitty @ \
  --to unix:/tmp/kitty.socket \
  set-colors -a ${file} &

kitty \
  --single-instance \
  --listen-on unix:/tmp/kitty.socket $@
