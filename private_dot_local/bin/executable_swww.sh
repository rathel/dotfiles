#!/bin/bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix
#
sleep 5

DIRECTORY="/home/rathel/Wallpapers"

#if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
#	echo "Usage:
#	$0 <dir containing images>"
#	exit 1
#fi

if ! pgrep swww-daemon; then
	swww-daemon &
fi

# Edit below to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=2
export SWWW_TRANSITION="random"

# This controls (in seconds) when to switch to the next image
INTERVAL=1h

while true; do
	find "$DIRECTORY" \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
			swww img "$img"
			wallust run "$img"
			notify-send "Wallpaper: $(basename $img)"
			pkill dunst
			sleep $INTERVAL
		done
done
