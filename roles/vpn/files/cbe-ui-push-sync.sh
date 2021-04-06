#!/bin/bash

LOCAL="/home/simonwjackson/cbe-ui/"
REMOTE="simonwjackson@10.10.15.18:/Users/simonwjackson/storage/code/bottomline/CB/cbe-ui/"

while true; do \
    sleep .1s ; \
    find $LOCAL \
    | entr -d \
      rsync \
        --archive \
        --verbose \
        --recursive \
        --exclude={'.git','node_modules','build','coverage'} \
        $LOCAL \
        $REMOTE \
    ; \
done
