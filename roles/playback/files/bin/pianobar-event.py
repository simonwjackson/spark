#!/usr/bin/env python

# Write name of the currently-playing song and artist to a file.
# The output file is meant to be used in status bars and such.

import os
import sys
from os.path import join

fn = join('/tmp/pianobar.nowplaying')

info = sys.stdin.readlines()
cmd = sys.argv[1]
fields = dict([line.strip().split("=" , 1) for line in info])

title = fields["title"]
artist = fields["artist"]
album = fields["album"]
coverArt = fields["coverArt"]
stationName = fields["stationName"]
stationCount = fields["stationCount"]
detailUrl = fields["detailUrl"]
rating = fields["rating"]
songPlayed = fields["songPlayed"]
songDuration = fields["songDuration"]
songStationName = fields["songStationName"] 

if cmd == 'songstart':
    with open(fn, 'w') as f:
        f.write("{} - {}\n".format(artist,title))
elif cmd == 'songfinish':
    with open(fn, 'w') as f:
        f.write("")
