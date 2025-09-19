#!/bin/env bash

browsers=(
	"Chrome"
	"Edge"
	"Firefox"
	"Vivaldi"
)

common_options="--ozone-platform=wayland --app=https://pc.shadow.tech"

printf "%s\n" "${browsers[@]}" | sk --prompt "Select browser to launch ShadowTech: " --height 10 --ansi | while read -r browser; do
if [ -n "$browser" ]; then
	if [ "$browser" == Edge ]; then
		notify-send "Launching ShadowTech with Microsoft Edge..."
		setsid -w sh -c "microsoft-edge-stable $common_options" >/dev/null 2>&1 &
		sleep 0.5
		exit 0
	elif [ "$browser" == Chrome ]; then
		notify-send "Launching ShadowTech with Google Chrome..."
		# setsid -f sh -c "google-chrome-stable --ozone-platform=wayland --app=https://pc.shadow.tech" &
		setsid -w sh -c "google-chrome-stable $common_options" >/dev/null 2>&1 &
		sleep 0.5
		exit 0
	elif [ "$browser" == Vivaldi ]; then
		notify-send "Launching ShadowTech with Vivaldi..."
		setsid -w sh -c "vivaldi-stable $common_options" >/dev/null 2>&1 &
		sleep 0.5
		exit 0
	elif [ "$browser" == Firefox ]; then
		notify-send "Launching ShadowTech with Firefox..."
		setsid -w sh -c "firefox --new-window https://pc.shadow.tech" >/dev/null 2>&1 &
		sleep 0.5
		exit 0

	else
		echo "Usage: $0 {chrome|edge|vivaldi}"
		exit 1
	fi

fi
done

# gamescope -f -w 1920 -h 1080 -W 1920 -H 1080 --force-grab-cursor --backend sdl -- google-chrome-stable --app=https://pc.shadow.tech
#
