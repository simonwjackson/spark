#!/bin/sh
window=$(xdotool getwindowfocus getwindowname)
app=""

case "${2}" in
  tmux)
    app=tmux 
  ;;
esac

if [[ "${app}" == "" ]] && $(echo "$window" | grep -qiE "tmux$" -); then
  case "${1}" in 
    west)
      xdotool keyup "h" key --clearmodifiers "alt+h"
    ;;
    south)
      xdotool keyup "j" key --clearmodifiers "alt+j"
    ;;
    north)
      xdotool keyup "k" key --clearmodifiers "alt+k"
    ;;
    east)
      xdotool keyup "l" key --clearmodifiers "alt+l"
    ;;
  esac
  exit 0
elif [[ "${app}" == "" ]]; then
  bspc node -f "${1}" 
  exit 0
fi

echo "W:::$window A:::$app ARG1:::$1 ARG2:::$2" >> /tmp/movlog

if [ "${app}" != "" ]; then
  case "${1}" in 
    west)
      if [ "${app}" == "tmux" ]; then
        if [ $(tmux display-message -p '#{pane_at_left}') -ne 1 ]; then
          tmux select-pane -L
        else
          bspc node -f "${1}" 
        fi
      fi
    ;;

    south)
      if [ "${app}" == "tmux" ]; then
        if [ $(tmux display-message -p '#{pane_at_bottom}') -ne 1 ]; then
          tmux select-pane -D
        else
          bspc node -f "${1}" 
        fi
      fi
    ;;
    
    north)
      if [ "${app}" == "tmux" ]; then
        if [ $(tmux display-message -p '#{pane_at_top}') -ne 1 ]; then
          tmux select-pane -U
        else
          bspc node -f "${1}" 
        fi
      fi
    ;;

    east)
      if [ "${app}" == "tmux" ]; then
        if [ $(tmux display-message -p '#{pane_at_right}') -ne 1 ]; then
          tmux select-pane -R
        else
          bspc node -f "${1}" 
        fi
      fi
    ;;
  esac
fi
exit 0