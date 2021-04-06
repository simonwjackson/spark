#!/bin/bash

LOCAL="/home/simonwjackson/cbe-ui/"
REMOTE="simonwjackson@10.10.15.18:/Users/simonwjackson/storage/code/bottomline/CB/cbe-ui/"

rsync \
  --archive \
  --verbose \
  --recursive \
  --exclude={'.git/config','node_modules/*','build/*','coverage/*'} \
  $REMOTE \
  $LOCAL
