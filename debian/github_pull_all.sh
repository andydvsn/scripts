#!/usr/bin/env bash

# github_pull_all.sh
#  Loop through the directories of a given path and update all repos.

if [ $# -lt 1 ]; then
	echo "Usage: $0 <path>"
	echo
	exit 1
fi

dest="$1"

echo > "$dest/log.txt"

for d in $(find "$dest" -mindepth 1 -maxdepth 1 -type d); do
	echo $(date +'%Y-%m-%d-%H:%M:%S') : "$d" >> "$dest/log.txt"
	git -C "$d" stash &>>"$dest/log.txt"
	git -C "$d" pull --rebase &>>"$dest/log.txt"
	echo >> "$dest/log.txt"
done
