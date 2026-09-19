#!/bin/bash
set -euo pipefail

browsers=(
	"brave" 
	"firefox" 
	"google-chrome-stable"
	"microsoft-edge-stable" 
)

read -p "Search DuckDuckGo for: " query

if command -v sk >/dev/null 2>&1; then
	picker=sk
elif command -v fzf >/dev/null 2>&1; then
	picker=fzf
else
	printf 'ddg: install skim (sk) or fzf for browser selection.\n' >&2
	exit 1
fi

browser="$(printf "%s\n" "${browsers[@]}" | "$picker")"

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
