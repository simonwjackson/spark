#!/bin/sh

# Copyright (c) 2021
# Simon W. Jackson

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
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -e

###########
# Config  #
###########

config_file="${XDG_CONFIG_HOME:-$HOME/.config}/muzik/config"

[[ -f "${config_file}" ]] \
  && source "${config_file}"

muzik_db="${muzik_db:-${HOME}/muzik.db}"

music_dir="${music_dir:-${XDG_MUSIC_DIR}}"
music_dir="${music_dir:-${HOME}/Music}"

file_template="${file_template:-%(playlist_index)2d - %(title)s.%(ext)s}"

############
# Helper   #
############

function download () {
    local album_cache_dir=${1}

    mkdir -p "${album_cache_dir}" \
    && echo $line \
    | awk \
        -v album_cache_dir_dir="${album_cache_dir}" \
        -v file_template="${file_template}" \
        -F ';' \
        '{print "youtube-dl --format=bestaudio --output=\"" album_cache_dir_dir "/" file_template "\" https://music.youtube.com/playlist?list=" $3}' \
    | xargs xargs \
    && mpv-audio "${album_cache_dir}" 
}

############
# Commands #
############

play () {
  local placement

  while :; do
    case $1 in
      -p|--place)
        if [ "$2" ]; then
          placement=${2^^}
          shift
        else
          die 'ERROR: "--file" requires a non-empty option argument.'
        fi
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
    esac
    shift
  done

  line=$(
    cat "${muzik_db}" \
    | tail -n +2 \
    | ([ ! -z "${placement}" ] \
      && awk -F '[[:space:]][[:space:]]+' '$4 == "'${placement}'" {print $0}' \
      || cat) \
    | column \
        --table \
        --separator $'\t' \
    | fzf \
        --exit-0 \
        --delimiter "   *" \
        --with-nth 1,2 \
        --reverse \
    | sed 's/\s\{2,\}/;/g'
  )

  [ -z "${line}" ] && exit 1

  album_cache_dir=$(
    echo $line \
    | awk -v music_dir="${music_dir}" -F ';' '{print music_dir "/" $1 " - " $2}'
  )

  # Does album_cache_dir dir exist
  if find "${album_cache_dir}" -type d -empty &> /dev/null; then
    mpv "${album_cache_dir}"
  else
    notify-send "Downloading.."
    echo "Downloading.."

    # Start downloading, spawn and disown the process 
    download "${album_cache_dir}"
  fi
}

############
# Main     #
############

while :; do
  case $1 in
    play)
	    shift
      play $@
	    break
    ;;
    tidy)
      cat "${muzik_db}" \
      | sed -e "s/\s\{2,\}/^/g" \
      | awk -F '^' -v now=$(date +%F) '{ print $1 "^" $2 "^" $3 "^" ( $4=="" ? "U":$4 ) "^" ( $5=="" ? now:$5 )}' \
      | column -s "^" -t \
      | tee "${muzik_db}" > /dev/null

      shift
      break
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
