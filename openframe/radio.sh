#!/usr/bin/env bash

## radio.sh v1.04 (29th March 2025)
##  Streams the radio from a HDHomeRun and restarts it if there's a problem.
##  Use the accompanying radio.service file.

hdhrip="192.168.11.103"
channel="707"
tmploc="/tmp/radio"

# Set up our temporary location with access for any audio group member.
if [ ! -d $tmploc ]; then
	mkdir -p $tmploc
	chown :audio $tmploc
	chmod 777 $tmploc
	chmod g+s $tmploc
	umask 002 $tmploc
fi

# Handle play, pause and channel selection.
if [ "$1" == "pause" ]; then
	[ -f $tmploc/channel ] && cp $tmploc/channel $tmploc/paused
	echo 0 > $tmploc/channel
	exit 0
elif [ "$1" == "play" ]; then
	if [ -f $tmploc/paused ]; then
		cp $tmploc/paused $tmploc/channel
		rm $tmploc/paused
	else
		echo $channel > $tmploc/channel
	fi
	exit 0
elif [[ "$1" =~ ^[+-]?[0-9]+$ ]]; then
	echo $1 > $tmploc/channel
	exit 0
elif [[ "$1" != "" ]]; then
	exit 1
fi

# Keep an eye on our restart count.
if [ -f $tmploc/restarts ]; then
	restarts=$(cat $tmploc/restarts)
	let restarts++
	echo $restarts > $tmploc/restarts
else
	echo 0 > $tmploc/restarts
fi

# Set the channel from the file if present.
if [ -f $tmploc/channel ]; then
	channel=$(cat $tmploc/channel)
else
	echo $channel > $tmploc/channel
fi

# Watch the channel file for changes.
while inotifywait -e close_write $tmploc/channel; do

	systemctl restart radio.service

done &

mplayer -novideo -cache 512 -cache-min 80 -softvol -volume 50 http://$hdhrip:5004/auto/v$channel &

while true; do

	sleep 10
	log=$(journalctl -n 6 -u radio.service)
	
	if [[ "$log" =~ "Cache empty" ]] || [[ "$log" =~ "Network is unreachable" ]] || [[ "$log" =~ "No route" ]] || [[ "$log" =~ "Trying to reset soundcard" ]] || [[ "$log" =~ "Failed" ]]; then
		systemctl restart radio.service
	fi

done
