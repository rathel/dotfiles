#!/bin/env bash

set -euo pipefail

sites=(
	"Amazon Prime Video	https://amazon.com/gp/video/storefront"
	"Plex	https://app.plex.tv/desktop"
	"Netflix	https://netflix.com"
	"Spotify	https://spotify.com"	
)

selection=$(printf "%s\n" "${sites[@]}" | sk --with-nth=1 --delimiter=$'\t')
cmd="${selection#*$'\t'}"

# firefox -P kiosk --kiosk "$cmd"
setsid -f microsoft-edge-stable --app="$cmd" >/dev/null 2>&1 &
sleep 2
