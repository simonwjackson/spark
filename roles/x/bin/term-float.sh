#!/usr/bin/bash

# launch floating term (output is ignored)
xterm -name 'floating term' -e "$* > /proc/$$/fd/1"
