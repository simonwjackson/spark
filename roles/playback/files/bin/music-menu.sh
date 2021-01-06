#!/bin/sh

set -e

music_dir="${HOME}/music"
file_template="%(playlist_index)2d - %(title)s.%(ext)s"

# cleanup
# sed -e "s/\s\{2,\}/^/g" | awk -F '^' -v now=asd '{ print $1 "^" $2 "^" $3 "^" ( $4=="" ? "U":$4 ) "^" ( $5=="" ? now:$5 )}' | column -s "^" -t

# Filter by Placement
# awk -F '^' '$4 == "N" {print $0}'

line=$(
  cat ${HOME}/music.txt \
  | column \
      --table \
      --separator $'\t' \
  | fzf \
      --delimiter "   *" \
      --with-nth 1,2 \
      --header-lines 1 \
      --reverse \
  | sed 's/\s\{2,\}/;/g'
)

echo $line
exit 1


cache=$(
  echo $line \
  | awk -v music_dir="${music_dir}" -F ';' '{print music_dir "/" $1 " - " $2}'
)

function download () {
    mkdir -p "${cache}" \
    && echo $line \
    | awk \
        -v cache_dir="${cache}" \
        -v file_template="${file_template}" \
        -F ';' \
        '{print "youtube-dl --format=bestaudio --output=\"" cache_dir "/" file_template "\" https://music.youtube.com/playlist?list=" $3}' \
    | xargs xargs \
    && mpv-audio "${cache}" 
}

# Does cache dir exist
if find "${cache}" -type d -empty &> /dev/null; then
  mpv-audio "${cache}"
else
  notify-send "Downloading.."
  echo "Downloading.."

  # Start downloading, spawn and disown the process 
  download
fi
