#!/usr/bin/env bash

## trmnl.sh v0.03 (16th February 2025) by Andrew Davison

source ~/.trmnl_key

response=$(curl -s https://usetrmnl.com/api/display \
	--header "access-token:$trmnl_key" \
	--header "battery-voltage:3.83" \
	--header "fw-version:6.9" \
	--header "rssi:-69")
image_url=$(echo "$response" | jq -r '.image_url')

[ "$1" == "debug" ] && echo "$response" | jq

wget -q -O /tmp/trmnl.bmp "$image_url"

if which display > /dev/null 2>&1; then

	#convert /tmp/trmnl.bmp -negate /tmp/trmnl.bmp
	display -window root /tmp/trmnl.bmp

elif which fbi > /dev/null 2>&1; then

	fbi -vt 1 -noverbose /tmp/trmnl.bmp > /dev/null 2>&1

else

	echo "I have no way to display the image!"
	exit 1

fi

exit 0
