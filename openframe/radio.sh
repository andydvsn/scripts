#!/bin/bash

echo 0 > /tmp/radio_restarts

mplayer -novideo -cache 1024 -cache-min 80 http://192.168.11.103:5004/auto/v707 &

while true; do

	sleep 10

	if journalctl -n 6 -u radio.service | grep -i "Cache empty"; then

		restarts=$(cat /tmp/radio_restarts)
		let restarts++
		echo $restarts > /tmp/radio_restarts

		systemctl restart radio.service

	fi

done