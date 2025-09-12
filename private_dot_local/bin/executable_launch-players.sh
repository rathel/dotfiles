#!/bin/env bash

set -euo pipefail

sites=(
	"Amazon Prime Video	https://amazon.com/gp/video/storefront"
	"Plex	https://app.plex.tv/desktop"
	"Netflix	https://netflix.com"
	"Spotify	https://spotify.com"	
)

browser=(
	"Firefox	firefox"
	"Chrome	google-chrome"
	"Microsoft Edge	microsoft-edge-stable"
	"Vivaldi	vivaldi"
)

selection=$(printf "%s\n" "${sites[@]}" | sk --with-nth=1 --delimiter=$'\t')
browser=$(printf "%s\n" "${browser[@]}" | sk --with-nth=1 --delimiter=$'\t')
cmd="${browser#*$'\t'} ${selection#*$'\t'}"

# firefox -P kiosk --kiosk "$cmd"
setsid -f "$cmd" &>/dev/null &
sleep 2
