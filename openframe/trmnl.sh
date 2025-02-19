#!/usr/bin/env bash

## trmnl.sh v0.04 (19th February 2025) by Andrew Davison

source ~/.trmnl_key

while true; do

	response=$(curl -s https://usetrmnl.com/api/display \
		--header "access-token:$trmnl_key" \
		--header "battery-voltage:3.83" \
		--header "fw-version:6.9" \
		--header "rssi:-69")
	image_url=$(echo "$response" | jq -r '.image_url')
	refresh_rate=$(echo "$response" | jq -r '.refresh_rate')

	[ "$1" == "debug" ] && echo "$response" | jq

	if [ "$image_url" != "null" ]; then

		wget -q -O /tmp/trmnl.bmp "$image_url"

		if which display > /dev/null 2>&1; then

			#convert /tmp/trmnl.bmp -negate /tmp/trmnl.bmp
			display -window root /tmp/trmnl.bmp

		elif which fbi > /dev/null 2>&1; then

			pid=$(pgrep fbi)
			fbi -vt 1 -noverbose /tmp/trmnl.bmp > /dev/null 2>&1
			[ "$pid" != "" ] && sleep 1 && kill $pid

		else

			echo "No means to display the image. Please install fbi or imagemagick."
			exit 1

		fi

	else

			[ "$1" != "debug" ] && echo "$response" | jq
			echo "Failed to fetch image."
			exit 1

	fi

	[ "$1" == "debug" ] && break || sleep $refresh_rate

done

exit 0
