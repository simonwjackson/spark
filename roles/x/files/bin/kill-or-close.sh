#!/bin/sh

if [[ $(xdotool getwindowfocus getwindowname) =~ " — Mozilla Firefox" ]]; then
  sleep .1 && xdotool key ctrl+w
else
  bspc node -c
fi