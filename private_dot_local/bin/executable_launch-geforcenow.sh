#!/bin/bash

echo -e "edge\nchrome\nvivaldi" | sk --prompt "Select browser to launch GeForce NOW: " --height 10 --ansi | while read -r browser; do
if [ -n "$browser" ]; then
	if [ "$browser" == edge ]; then
		notify-send "Launching GeForce NOW with Microsoft Edge..."
		setsid -f sh -c "microsoft-edge-stable --ozone-platform=wayland --app=https://play.geforcenow.com"
		exit 0
	elif [ "$browser" == chrome ]; then
		notify-send "Launching GeForce NOW with Google Chrome..."
		setsid -f sh -c "google-chrome-stable --ozone-platform=wayland --app=https://play.geforcenow.com"
		exit 0
	elif [ "$browser" == vivaldi ]; then
		notify-send "Launching GeForce NOW with Vivaldi..."
		setsid -f sh -c "vivaldi-stable --ozone-platform=wayland --app=https://play.geforcenow.com"
		exit 0

	else
		echo "Usage: $0 {edge|chrome|vivaldi}"
		exit 1
	fi

fi
done

# gamescope -f -w 1920 -h 1080 -W 1920 -H 1080 --force-grab-cursor --backend sdl -- google-chrome-stable --app=https://play.geforcenow.com
#
