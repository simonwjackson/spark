#!/bin/sh

music_dir="${HOME}/music"
file_template="%(playlist_index)2d - %(title)s.%(ext)s"

line=$(
  cat ${HOME}/music.txt \
  | tr --squeeze-repeats '\t' '\t' \
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