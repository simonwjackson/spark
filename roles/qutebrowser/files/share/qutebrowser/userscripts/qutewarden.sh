#!/bin/env bash

function type_entry () {
  local col=${1}

  echo "${QUTE_URL}" \
  | sed -e 's|^[^/]*//||' -e 's|/.*$||' \
  | xargs \
    -I % \
    term-float bitwarden-choose --immediate % \
  | awk '{print $'${col}'}' \
  | (echo 'mode-enter insert' >> "${QUTE_FIFO}" && sleep .1 && cat -) \
  | xargs xdotool type \
  && echo 'mode-enter normal' >> "${QUTE_FIFO}"
}

while :; do
  case $1 in
    --help)
      shift
      echo "${usage[main]}"
      break
    ;; 
    user)
      shift
      type_entry 1
      break
    ;;
    pass)
      shift
      type_entry 2
      break
    ;; 
    both)
      shift
        line="$(
          echo "${QUTE_URL}" \
          | sed -e 's|^[^/]*//||' -e 's|/.*$||' \
          | xargs \
            -I % \
            term-float bitwarden-choose --immediate "%"
        )"
        echo 'mode-enter insert' >> "${QUTE_FIFO}"
        sleep .1
        echo "${line}" | awk '{print $1}' | xargs xdotool type
        sleep .1
        xdotool key Tab
        sleep .1
        echo "${line}" | awk '{print $2}' | xargs xdotool type
        sleep .1
        xdotool key Return
        sleep .1
        echo 'mode-enter normal' >> "${QUTE_FIFO}"
      break
    ;; 
  esac
  shift
done


# This method is prefered but i am getting inconsistant results from various pages. For example, reddit does not allow me to use jseval to find/fill their login form
# echo 'jseval document.querySelector("#loginUsername,#login_field,input[name=identifier]").value = "'${user}'".trim()' >> "${QUTE_FIFO}" 
# echo 'jseval document.querySelector("#password").value = "'${pass}'".trim()' >> "${QUTE_FIFO}"

