#!/usr/bin/env bash

sleep 2

wallpapers="$HOME/Wallpapers"

if command -v swww &> /dev/null; then
	if ! pgrep -x "swww-daemon" > /dev/null; then
		nohup swww-daemon >/dev/null 2>&1 &
	fi
else
	echo "swww command not found. Please install swww to set the wallpaper."
	exit 1
fi

while :; do
	wallpaper1="$(fd . $wallpapers -e jpg -e png | shuf -n1)"
	wallpaper2="$(fd . $wallpapers -e jpg -e png | shuf -n1)"
	swww img -o DP-1 "$wallpaper1"
	sleep 1
	swww img -o DP-2 "$wallpaper2"
	sleep 1h
done
