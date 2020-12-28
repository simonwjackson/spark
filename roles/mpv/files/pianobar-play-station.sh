#!/usr/bin/expect -f

set station [lindex $argv 0];
set timeout -1
spawn pianobar
match_max 100000
expect -exact "\[2K\[?\] Select station: "
send -- "$station\r"
expect eof