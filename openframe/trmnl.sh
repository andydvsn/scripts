#!/usr/bin/env bash

## youtube.sh v0.01 (31st January 2025) by Andrew Davison

yt-dlp -f "bv*[height<=480]+ba" "$1" -o - | mplayer -

exit 0
