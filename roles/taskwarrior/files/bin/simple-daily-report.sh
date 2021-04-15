#!/bin/sh

export TZ=America/Chicago

timew summary \
| tail -n 2 \
| head -n 1 \
| sed 's/\s//g' \
| awk -F ':' '{print "Total: "$1"h "$2"m"}'

echo ""
echo -e "Start\tEnd\tDesc"
echo -e "-----\t-----\t-------"

timew export \
| jq -r '.[] | select(.end != null and .tags != null) | select((.start | strptime("%Y%m%dT%H%M%SZ") | todateiso8601) > "'$(date +%F)'") | [(.start | strptime("%Y%m%dT%H%M%SZ") | mktime | strflocaltime("%l:%M")), (.end | strptime("%Y%m%dT%H%M%SZ") | mktime | strflocaltime("%l:%M")), (.tags | join(", "))] | join("\t")'

