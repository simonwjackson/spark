#!/usr/bin/bash
# {{ ansible_managed }}

while read -t .000001 line; do
  # redirect all input and output back to the parent process
  xterm -name 'floating term' -e "$* < /proc/$$/fd/0 > /proc/$$/fd/1" && exit 0
done

# or just launch the command
xterm -name 'floating term' -e "$*"
