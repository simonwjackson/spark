#!/bin/bash

TABS=$(
  bt list \
  | awk -F "\t" '{print "TAB\t" $1 "\t" $2}'
)

CHOICE=$(
  echo "${TABS}" \
  | fzf --delimiter "\t" --with-nth 3
)
ID=$(
  echo $CHOICE \
  | awk '{print $2}'
)

if [[ $CHOICE = TAB* ]]; then
  bt activate --focused $ID
fi