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


declare -A usage
declare -r script_path="$(realpath $0)"
declare -r itunes_results_path="/tmp/itunes.results"
declare -r tmp_db=$(mktemp)

set -e

usage["main"]="Usage:
  $(basename $0) COMMAND [ARGS...]
  $(basename $0) help COMMAND

Commands:
  search    Search for metadata
  library   Interactive selection of your library
  help      Give detailed help on a specific sub-command"

usage["search"]="Usage: $(basename $0) search [options]

Options:
  -a, --add Add the result to your library"


###########
# Config  #
###########

config_file="${XDG_CONFIG_HOME:-$HOME/.config}/muzik/config"

[[ -f "${config_file}" ]] \
  && source "${config_file}"

muzik_db="${muzik_db:-${HOME}/muzik.db}"

touch ${muzik_db}

############
# Helper   #
############

function scrape_google_search () {
  local html
  local id
  local clean_artist
  local clean_album

  while read -r query; do
    # html=$(cat ~/google-res.html)
    # "https://www.google.com/search?q=\"${artist}\"+\"${album}\"" \

    query=${query// /+}

    html=$(
      w3m \
        -o user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:84.0) Gecko/20100101 Firefox/84.0' \
        -dump_source \
        "https://www.google.com/search?q=${query}+album" \
      | gunzip -f
    )

    # echo "${html}" > "${HOME}/google-res.html"
    
    id=$(
      echo "${html}" \
      | grep 'https://music.youtube.com/playlist' \
      | sed -e 's/.*\(music.youtube.com\/playlist\?\)/\1/g' \
      | cut -d '&' -f 1 \
      | cut -d '=' -f 2
    )

    clean_artist=$(
      echo "${html}" \
      | grep 'data-attrid="subtitle">' \
      | perl -lane 'print m/data-attrid="subtitle">.*?album by (.+?)<\/.+?>/gi'
    )

    clean_album=$(
      echo "${html}" \
      | grep 'data-attrid="title' \
      | perl -lane 'print m/data-attrid="title">.+?>(.+?)<\/.+?>/g'
    )

    jq \
      --compact-output \
      --null-input \
      '{ artist: $artist, album: $album, ids: { youtube: $youtube }}' \
      --arg 'artist'  "${clean_artist}"  \
      --arg 'album'   "${clean_album}" \
      --arg 'youtube' "${id}"
  done
}

function to_db () {
  while read -r entry; do
    echo "${entry}" \
    | jq -r '[.artist, .album, .ids.youtube] | @tsv' \
    | sed -e "s/\t/^/g" \
    | sed -e "s/^/\n/g" \
    | cat "${muzik_db}" - \
    | sed -e "s/\s\{2,\}/^/g" \
    | awk \
      -F '^' \
      -v now=$(date +%F) \
      '{ print $1 "^" $2 "^" $3 "^" ( $4=="" ? "U":$4 ) "^" ( $5=="" ? now:$5 )}' \
    | awk 'NR == 1; NR > 1 {print $0 | "sort -u -t ^ -k 1,2 -k 3 "}' \
    | column \
      --separator ^ \
      --table \
    | tee "${muzik_db}" > /dev/null
  done
}


############
# Commands #
############

list () {
  local placement

  cat "${muzik_db}" \
  | ([ ! -z "${placement}" ] \
    && awk \
        -F '[[:space:]][[:space:]]+' \
        '$4 == "'${placement}'" {print $0}' \
    || cat) \
  | column \
      --table \
      --separator $'\t'
}


function library () {
  local placement

  "${script_path}" _list > "${tmp_db}"

  bindings_array=(
    'ctrl-a:execute("'${script_path}'" _list > "'${tmp_db}'")+reload(cat "'${tmp_db}'")+change-prompt(All> )'
    'ctrl-s:execute("'${script_path}'" _list -p s > "'${tmp_db}'")+reload(cat "'${tmp_db}'")+change-prompt(Shelf> )'
    'ctrl-u:execute("'${script_path}'" _list -p u > "'${tmp_db}'")+reload(cat "'${tmp_db}'")+change-prompt(Unknown> )'
    'ctrl-r:execute("'${script_path}'" _list -p r > "'${tmp_db}'")+reload(cat "'${tmp_db}'")+change-prompt(Retired> )'
    'ctrl-o:execute("'${script_path}'" _list -p h > "'${tmp_db}'")+reload(cat "'${tmp_db}'")+change-prompt(Hot> )'
    'ctrl-n:execute("'${script_path}'" _list -p n > "'${tmp_db}'")+reload(cat "'${tmp_db}'")+change-prompt(New> )'
    # 'ctrl-alt-u:reload("'${script_path}'" move -p u)'
    # 'ctrl-alt-r:reload("'${script_path}'" move -p r)'
    # 'ctrl-alt-h:reload("'${script_path}'" move -p h)'
    # 'ctrl-alt-n:reload("'${script_path}'" move -p n)'
  )
  bindings=$(IFS=, ; echo "${bindings_array[*]}")

  cat "${tmp_db}" \
  | fzf \
    --bind "${bindings}" \
    --header "(n)ew, h(o)t, (s)helf, (r)etired, (u)nknown, (a)ll. [C: Filter, C-A: Move]" \
    --header-lines 1 \
    --inline-info \
    --exit-0 \
    --delimiter "   *" \
    --with-nth 1,2 \
    --reverse \
  | sed 's/\s\{2,\}/^^^/g' \
  | jq \
    --compact-output \
    --raw-input \
    'split("^^^") | ({
       "artist": .[0],
       "album": .[1],
       "ids": {
         "youtube": .[2]
       },
       "placement": .[3],
       "date_added": .[4],
    })'
}


function itunes_search () {
  echo -n '' \
  | fzf \
    --preview="[[ {q} != '' ]] && sleep .5 && cat /tmp/itunes.results | jq -r '.results[] | select(.collectionId == {1}) | {Artist: .artistName, Album: .collectionName, Tracks: .trackCount, Label: (.copyright[7:]), Country: .country, Year: (.releaseDate[:4]), Genre: .primaryGenreName} | to_entries[] | [.key, .value] | join(\"^^\")' | column --table --separator '^^'" \
    --preview-window="up:7:rounded:wrap" \
    --reverse \
    --info hidden \
    --bind "change:reload:${script_path} _query '{q}' || true" \
    --with-nth '2,3,4' \
    --delimiter "   *" \
    --ansi \
    --prompt 'Search> ' \
    --header 'Album Search' \
    --tabstop 3 \
    --phony \
  | awk \
    -F '   *' \
    '{print "\"" $3 "\" " "\"" $4 "\""}'
}

while :; do
  case $1 in
    --help)
      shift
      echo "${usage[main]}"
      break
    ;; 
    help)
      shift
      echo "${usage[${1}]}"
      break
    ;; 
    add)
      shift
      to_db "${1}" "${2}"
      break
    ;;
    library)
      shift
      library $@
      break
    ;;
    search)
      shift
      add=0

      while :; do
        case $1 in
          -a|--add)
            shift
            add=1
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
        esac
        shift
      done

      ([ $# -eq 0 ] \
          && itunes_search \
          || echo "$@" | scrape_google_search) \
      | (
        if [ $add -eq 1 ]; then
          to_db
        else
          cat 
        fi 
      )
      break
    ;;

    move)
      shift
      echo $@ >> "/tmp/mylog"
      break
    ;;

    ###################
    # Exposed for FZF #
    ###################

    _list)
      shift
      list $@
      break
    ;;
    _query)
      shift
      query="${@}"

      curl \
        -s \
        "https://itunes.apple.com/search?entity=album&term=${query// /%20}" \
      | tee "${itunes_results_path}" \
      | jq \
        -r '.results | sort_by(.releaseDate) | reverse[] | [.collectionId, (.releaseDate | .[:4]), .artistName, .collectionName] | join("^^")' \
      | column \
        --table \
        --separator '^^'
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
      echo "$usage" >&2
      break
  esac
  shift
done

