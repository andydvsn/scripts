#!/usr/bin/env bash

## radio.sh v1.01 (12th February 2025)
##  Streams the radio from a HDHomeRun and restarts it if there's a problem.
##  Use the accompanying radio.service file.

if [ -f /tmp/radio_restarts ]; then
	restarts=$(cat /tmp/radio_restarts)
	let restarts++
	echo $restarts > /tmp/radio_restarts
else
	echo 0 > /tmp/radio_restarts
fi

mplayer -novideo -cache 1024 -cache-min 80 http://192.168.11.103:5004/auto/v707 &

while true; do

	sleep 10
	journalctl -n 6 -u radio.service | grep -i "Cache empty" && systemctl restart radio.service

done
