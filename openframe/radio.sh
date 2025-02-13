#!/usr/bin/env bash

## radio.sh v1.01 (12th February 2025)
##  Streams the radio from a HDHomeRun and restarts it if there's a problem.
##  Use the accompanying radio.service file.

hdhrip="192.168.11.103"
channel="707"

# Handle play, pause and channel selection.
if [ "$1" == "pause" ]; then
	[ -f /tmp/radio_channel ] && cp /tmp/radio_channel /tmp/radio_paused
	echo 0 > /tmp/radio_channel
	chmod 666 /tmp/radio_channel
	exit 0
elif [ "$1" == "play" ]; then
	if [ -f /tmp/radio_paused ]; then
		cp /tmp/radio_paused /tmp/radio_channel
		chmod 666 /tmp/radio_channel
	else
		echo $channel > /tmp/radio_channel
		chmod 666 /tmp/radio_channel
	fi
	exit 0
elif [[ "$1" =~ ^[+-]?[0-9]+$ ]]; then
	echo $1 > /tmp/radio_channel
	chmod 666 /tmp/radio_channel
	exit 0
elif [[ "$1" != "" ]]; then
	exit 1
fi

# Keep an eye on our restart count.
if [ -f /tmp/radio_restarts ]; then
	restarts=$(cat /tmp/radio_restarts)
	let restarts++
	echo $restarts > /tmp/radio_restarts
	chmod 666 /tmp/radio_restarts
else
	echo 0 > /tmp/radio_restarts
	chmod 666 /tmp/radio_restarts
fi

# Set the channel from the file if present.
if [ -f /tmp/radio_channel ]; then
	channel=$(cat /tmp/radio_channel)
else
	echo $channel > /tmp/radio_channel
	chmod 666 /tmp/radio_channel
fi

# Watch the channel file for changes.
while inotifywait -e close_write /tmp/radio_channel; do

	systemctl restart radio.service

done &

mplayer -novideo -cache 1024 -cache-min 80 http://$hdhrip:5004/auto/v$channel &

while true; do

	sleep 10
	journalctl -n 6 -u radio.service | grep -i "Cache empty" && systemctl restart radio.service

done
