#!/usr/bin/env bash

## youtube.sh v0.01 (31st January 2025) by Andrew Davison

yt-dlp --hls-use-mpegts --merge-output-format mp4 -f "bv*[height<=480]+ba" "$1" -o - | mplayer -

exit 0
