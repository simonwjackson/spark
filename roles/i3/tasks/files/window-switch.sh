#!/bin/bash

WINDOWS=$(
    wmctrl -l \
    | grep -v " Mozilla Firefox" \
    | awk -F '  -?[0-9] [a-zA-Z0-9]+ ' '{print "WIN\t" $1 "\t" $2}'
)
TABS=$(
  bt list \
  | awk -F "\t" '{print "TAB\t" $1 "\t" $2}'
)

CHOICE=$(
  echo "${WINDOWS}${TABS}" \
  | fzf --delimiter "\t" --with-nth 3
)

ID=$(
  echo $CHOICE \
  | awk '{print $2}'
)

if [[ $CHOICE = WIN* ]]; then
  wmctrl -ia $ID
else [[ $CHOICE = TAB* ]]
  bt activate --focused $ID
fi