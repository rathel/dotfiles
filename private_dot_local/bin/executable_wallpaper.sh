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
	wallpaper="$(fd . $wallpapers -e jpg -e png | shuf -n1)"
	notify-send -i "$wallpaper" "Setting Wallpaper to:" "$(basename $wallpaper)"
	swww img "$wallpaper" >/dev/null 2>&1 &
	sleep 1h
done
