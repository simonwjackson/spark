
#!/usr/bin/env bash

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

declare -r youtube_playlist_prefix='https://music.youtube.com/playlist?list='


###########
# Config  #
###########

file_template="${file_template:-%(album) [%(release_year)] - %(artist)/%(playlist_index)s - %(track)s.%(ext)s}"
music_dir="${music_dir:-${XDG_MUSIC_DIR}}"
music_dir="${music_dir:-${HOME}/Music}"
cache=0
save=0


############
# Helper   #
############

while :; do
  case $1 in
    -s|--save)
      shift 
      save=1
    ;;
    -c|--cache)
      shift 
      cache=1
    ;;
    *) 
      break
    ;;
  esac
done

# | (echo -n "${youtube_playlist_prefix}" && cat) \
# jq -r '.ids.youtube' \
while read -r entry; do
  echo "${entry}" \
  | (
    ytid=$(cat)
    cached_metadata="/tmp/${ytid}"

    if [ ! -f "${cached_metadata}" ]; then
      youtube-dl \
        --dump-json \
        --continue \
        --ignore-errors \
        --no-overwrites \
        --extract-audio \
        --audio-quality 0 \
        --add-metadata \
        --output="%(album)s [%(release_year)s] - %(artist)s/%(playlist_index)s - %(track)s.%(acodec)s" \
        --yes-playlist \
        "https://music.youtube.com/playlist?list=${ytid}" \
      | tee "${cached_metadata}" 
    else
      cat "${cached_metadata}" 
    fi
  ) \
    | jq -r '[.id, (._filename | tojson)] | join(" ")' \
    | xargs -l bash -c '
        pathname=""

        if [ '${save}' -eq 1 ]; then
          pathname="/home/simonwjackson/Music/${1}"
        elif [ '${cache}' -eq 1 ]; then
          pathname="/tmp/aaa/${1}"
        fi

        [ "${pathname}" == "" ] \
          && echo "https://www.youtube.com/watch?v=${0}" \
          && exit 0

        [ ! -f "${pathname}" ] \
          && youtube-dl \
            --quiet \
            --continue \
            --ignore-errors \
            --no-overwrites \
            --extract-audio \
            --audio-quality 0 \
            --add-metadata \
            --output="${pathname}" \
            "$0"

        echo "${pathname}" \
        | sed -e "s/\(.*\)/\"\1\"/"
      ' 
done
