#!/bin/sh

cat "${HOME}/.config/nvim/init.vim" \
| sed -n 's/^let \(.*\).path = \(.*\)/\1 \2/p' \
| fzf --with-nth 1 \
| cut -d ' ' -f 2  \
| xargs -I '___' nvim -c "cd ___ | VimwikiIndex"
