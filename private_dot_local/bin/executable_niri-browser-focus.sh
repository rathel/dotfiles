#!/bin/bash

browser="zen"
win_id=$(niri msg -j windows | jq -r --arg app "$browser" '.[] | select(.app_id == $app) | .id')

if [ -n "$win_id" ]; then
    # Focus that specific window
    niri msg action focus-window --id "$win_id"
else
	case "$browser" in
		"zen")
			/home/rathel/Applications/zen-x86_64.AppImage
			;;
		"firefox")
			firefox
			;;
		"edge")
			microsoft-edge-stable
			;;
		*)
			echo "Unknown browser: $browser"
			exit 1
			;;
	esac
fi
