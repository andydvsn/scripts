#!/usr/bin/env bash

## trmnl.sh v0.01 (8th February 2025) by Andrew Davison

source ~/.trmnl_key

response=$(curl -s https://usetrmnl.com/api/display --header "access-token:$trmnl_key")
image_url=$(echo "$response" | jq -r '.image_url')

wget -q -O /tmp/trmnl.bmp "$image_url"
display -window root /tmp/trmnl.bmp

exit 0
