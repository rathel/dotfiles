#!/bin/bash
set -euo pipefail

browsers=(
	"brave" 
	"firefox" 
	"google-chrome-stable"
	"microsoft-edge-stable" 
)

read -p "Search DuckDuckGo for: " query

browser="$(printf "%s\n" "${browsers[@]}" | sk)"

case ${browser} in
	"firefox")
		firefox "https://duckduckgo.com/?q=$query" &>/dev/null &
		;;
	"microsoft-edge-stable")
		microsoft-edge-stable "https://duckduckgo.com/?q=$query" &>/dev/null &
		;;
	"brave")
		brave "https://duckduckgo.com/?q=$query" &>/dev/null &
		;;
	"google-chrome-stable")
		google-chrome "https://duckduckgo.com/?q=$query" &>/dev/null &
		;;
	*)
		echo "No browser selected."
		exit 1
		;;
esac

sleep 1
