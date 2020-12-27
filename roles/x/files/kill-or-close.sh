#!/bin/sh

if [[ $(xdotool getwindowfocus getwindowname) =~ " — Mozilla Firefox" ]]; then
  sleep .1 && xdotool key ctrl+w
else
  i3-msg kill
fi