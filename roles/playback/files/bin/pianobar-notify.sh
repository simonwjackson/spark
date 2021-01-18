#!/bin/bash

# Copyright (c) 2011
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

###### USAGE: ######
#
# This is artist_name_file event script. Place it somewhere convenient for you and
# add the line 'event_command = /PATH/TO/pianobar-notify.sh' to your
# pianobar config file.
#
# Also check if this matches you config folder
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/pianobar"

# You should also place the control-pianobar.sh script in the
# config folder (or modify the following variable accordingly).
control_pianobar="control-pianobar"

# Also place the pandora.jpg file in the same folder, or modify de
# following variable.
blankicon="$fold/pandora.jpg"

notify="notify-send --hint=int:transient:1"
zenity="zenity"

log_file="${log_file:-/tmp/pianobar.log}"
control_file="${control_file:-/tmp/pianobar.control}"
artist_file="${artist_file:-/tmp/pianobar.artist}"
album_file="${album_file:-/tmp/pianobar.album}"
title_file="${title_file:-/tmp/pianobar.title}"
duration_file="${duration_file:-/tmp/pianobar.duration}"
station_file="${station_file:-/tmp/pianobar.station}"
explain_file="${explain_file:-/tmp/pianobar.explain}"
station_list_file="${station_list_file:-/tmp/pianobar.station-list}"
ig_next_event_file="${ig_next_event_file:-/tmp/pianobar.next-event}"
state_file="${state_file:-/tmp/pianobar.state}"

mkfifo "${control_file}" 2> /dev/null
touch "${state_file}"
touch "${log_file}"
touch "${artist_file}"
touch "${duration_file}"
touch "${explain_file}"
touch "${station_list_file}"
touch "${station_file}"
touch "${ig_next_event_file}"

while read L; do
    k="`echo "$L" | cut -d '=' -f 1`"
    v="`echo "$L" | cut -d '=' -f 2`"
    export "$k=$v"
done < <(grep -e '^\(audioUrl\|title\|artist\|album\|stationName\|songStationName\|pRet\|pRetStr\|wRet\|wRetStr\|songDuration\|songPlayed\|rating\|coverArt\|stationCount\|station[0-9]\+\)=' /dev/stdin) # don't overwrite $1...

case "$1" in
  songstart)
    echo "playing" > "${state_file}"
    if [[ $songDuration -gt 10 ]]; then
      [[ ! -z $songDuration ]] \
        && echo "${songDuration}" \
        > "${duration_file}"

      [[ -z $stationName ]] \
        && echo "${songStationName}" > "${station_file}" \
        || echo "${stationName}" > "${station_file}"

      [[ ! -z $album ]] \
        && echo "${album}" \
        > "${album_file}"

      [[ ! -z $artist ]] \
        && echo "${artist}" \
        > "${artist_file}"

      [[ ! -z $title ]] \
        && echo "${title}" \
        > "${title_file}"
    fi
  ;;

  songexplain)
    sleep .25
    list=$(
      tac "$log_file" \
      | grep -am1 "playing this track" \
      | sed "s/.*because it features //g" \
      | sed "s/and.*Music Genome Project.//g" \
      | awk 'BEGIN{RS=","}{$1=$1}1'
    )

    echo "$list" > "${explain_file}"
  ;;

  songbookmark)
    sleep .25
    url=$(${control_pianobar} details --show-urls | grep audioUrl | awk '{print $2}')
    date_with_week_num=$(date +"%Y-%m.w%W")
		music_dir="${HOME}/new-music"
		date_dir="${music_dir}/${date_with_week_num}"
		mkdir -p "${date_dir}"
    name_template="$(cat ${title_file}) - $(cat ${artist_file})"
		echo "${name_template}" >> "${date_dir}/${date_with_week_num}.txt"
		awk '!seen[$0]++' "${date_dir}/${date_with_week_num}.txt" # Uniqe lines
    notify-send "Downloading: ${name_template}"
    filename="${date_dir}/$(cat ${title_file}) - $(cat ${album_file}) - $(cat ${artist_file}).mp4"
    wget \
      --output-document="${filename}" \
      "${url}" \
    && id3tag --artist="$(cat ${artist_file})" "${filename}" \
    && id3tag --album="$(cat ${album_file})" "${filename}" \
    && id3tag --song="$(cat ${title_file})" "${filename}"
  ;;

  songlove)
    :
  ;;

  songban)
    :
  ;;

  songshelf)
    :
  ;;

  stationfetchplaylist)
    :
  ;;

  usergetstations)
    if [[ $stationCount -gt 0 ]]; then
      : > "${station_list_file}"
      for stnum in $(seq 0 $(($stationCount-1))); do
        echo "$stnum---"$(eval "echo \$station$stnum") >> "$station_list_file"
      done
    fi
  ;;

  userlogin)
      if [ "$pRet" -ne 1 ]; then
          :
          # error
      elif [ "$wRet" -ne 1 ]; then
          :
          # error
      else
          :
          # success
      fi;;

  songfinish)
    echo "stopped" > "${state_file}"
    exit
  ;;

  *)
    :
  ;;
esac
