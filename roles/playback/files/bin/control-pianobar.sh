#!/bin/bash

# Copyright (c) 2012
# Artur de S. L. Malabarba

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN artist_name_file ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

### USAGE ####
# To use this script, place this script, pianobar-notify.sh, and
# pandora.jpg in your config folder and configure the three variables below
# according to your needs.
#
# # # Start pianobar by running 'control-pianobar.sh p'
#
# These variables should match YOUR configs
# Your config folder
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/pianobar"
# The pianobar executable
pianobar="pianobar"
# A blank icon to show when no albumart is found. I prefer to use
# the actual pandora icon for this, which you can easily find and
# download yourself. I don't include it here for copyright concerns.
blankicon="$config_dir/pandora.jpg"
  
# You probably shouldn't mess with these (or anything else)
config_file="${config_dir}/controlrc"

if [[ -f "${config_file}" ]]; then
  source "${config_file}"
fi 

notify="notify-send --hint=int:transient:1"
zenity="zenity"

log_file="${log_file:-/tmp/pianobar.log}"
control_file="${control_file:-/tmp/pianobar.control}"
artist_file="${artist_file:-/tmp/pianobar.artist}"
album_file="${album_file:-/tmp/pianobar.album}"
title_file="${title_file:-/tmp/pianobar.title}"
duration_file="${duration_file:-/tmp/pianobar.duration}"
station_file="${station_file:-/tmp/pianobar.station}"
station_list_file="${station_list_file:-/tmp/pianobar.station-list}"
ig_next_event_file="${ig_next_event_file:-/tmp/pianobar.next-event}"
state_file="${state_file:-/tmp/pianobar.state}"

mkfifo "${control_file}" 2> /dev/null
touch "${log_file}"
touch "${artist_file}"
touch "${station_list_file}"
touch "${ig_next_event_file}"

key_press () {
  if [[ -n `pidof pianobar` ]]; then
    echo -n "${1}" > "$control_file"
  fi
}

# [[ -n "$2" ]] && sleep "$2"

# : > "$log_file"

tmux has-session -t pianobar 2>/dev/null
if [ $? != 0 ]; then
  tmux new-session -d -s pianobar
fi

if [[ ! -n $(pidof pianobar) ]]; then	
  : > "$log_file" 2> /dev/null
  : > "$state_file" 2> /dev/null

  tmux send-keys -t pianobar.0 "${pianobar} | tee ${log_file}" C-m
fi 

while :; do
  case $1 in
    toggle|pause|play)
	    shift
      if [[ "$(cat ${state_file})" == "paused" ]]; then
        key_press p
        echo "playing" > "${state_file}"
      elif [[ "$(cat ${state_file})" == "playing" ]]; then
        key_press p
        echo "paused" > "${state_file}"
      fi
	    break
    ;;
        
    station)
	    shift
      station_num="${1}"

      if [[ -z "${1}" ]]; then
        station_num=$(
          cat "${station_list_file}" \
          | fzf -d '---' --with-nth 2 \
          | awk -F '---' '{print $1}'
        )
      fi

      echo "${station_num}" \
      | ( \
        [[ -s "${state_file}" ]] \
          && sed 's/^/s/' \
          || cat \
        ) \
      > "${control_file}" 

      echo "stopped" > "${state_file}"
      timeout 5s sh -c -- 'while ! grep --silent "playing" "'${state_file}'"; do sleep .25; done'
	    break
    ;;
        
    details)
      show_urls="false"

      shift
      while :; do
        case ${1} in
          --show-urls)
            shift
            show_urls="true"
            break
          ;;
          --)
            shift
            break
          ;;
          -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
          ;;
          *) 
            break
          ;;
        esac
        shift
      done

      key_press '$'

      tac "$log_file" \
      | head -n 15 \
      | grep -v '^\(stationId\|musicId\)' \
      | sed 's/\s//' \
      | sed 's/:/^^^/' \
      | sed 's/album:./\nalbum^^^/g' \
      | sort \
      | uniq \
      | tail --lines=+2 \
      | head --lines=-2 \
      | ( \
          if [[ "${show_urls}" == "true" ]]; then
            cat
          else
            grep -v '^\(detailUrl\|coverArt\|audioUrl\)'
          fi
        ) \
      | column --table -s '^^^'

      break
    ;;


    love) key_press "+" ;;
    bookmark) key_press "b"; key_press "s" ;;
    ban) key_press "-" ;;
    next) key_press "n" ;;
    tired) key_press "t" ;;

    stop|quit)
      key_press "q"
      sleep 1

      if [[ -n $(pidof pianobar) ]]; then
        echo "Oops" "Something went wrong. \n Force quitting..."
        kill -9 $(pidof pianobar)

        if [[ -n $(pidof pianobar) ]]; then
          echo "I'm Sorry" "I don't know what's happening. Could you try killing it manually?"
          exit 1
        else
          echo "Success" "Pianobar closed."
          : > "$state_file"
          exit 0
        fi
      else 
        : > "$state_file"
      fi
    ;;
        
    explain)
      key_press "e"
      sleep .25
      tac "${log_file}" \
      | grep -am1 "playing this track" \
      | sed "s/.*because it features //g" \
      | sed "s/and.*Music Genome Project.//g" \
      | awk 'BEGIN{RS=","}{$1=$1}1'
    ;;
        
    "history"|h)
      if [[ -n `pidof pianobar` ]]; then
        echo -n "h" > "$control_file"
        text="$(grep --text "[0-9]\+)" "$log_file" | sed 's/.*\t\(.*) *[^ ].*\)/\1/')""\n \n Type a number."
        snum="$($zenity --entry --title="History" --text="$text")"
        if [[ -n "$snum" ]]; then
          echo "1" > "$ig_next_event_file"
          echo "$snum" > "$control_file"
          echo -n "$($zenity --entry --title="Do what?" --text="Love[+], Ban[-], or Tired[t].")" > "$control_file"
        else
          echo "" > "$control_file"
        fi
      fi
    ;;
    --)
      shift
      break
    ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
    ;;
    ?*)
      printf 'WARN: Unknown command (ignored): %s\n' "$1" >&2
    ;;
    *)
      break
  esac
  shift
done
