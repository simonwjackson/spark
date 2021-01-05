#!/usr/bin/env python

import sys
from youtube_search import YoutubeSearch

for line in sys.stdin:
  results = line 

ytid = YoutubeSearch(results.strip() + ' full album', max_results=1).to_dict()[0]['id']
print('https://www.youtube.com/watch?v=' + ytid)