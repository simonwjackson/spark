#!/usr/bin/bash

# redirect all input and output back to the parent process
xterm -name 'floating term' -e "$* < /proc/$$/fd/0 > /proc/$$/fd/1"
