#!/bin/bash
set -eo pipefail

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/niri_last_browser"

BROWSERS=("zen" "zen-twilight" "firefox" "edge" "vivaldi-stable")

declare -A BROWSER_CMDS=(
  ["zen"]="$HOME/Applications/Utilities/zen/zen"
  ["zen-twilight"]="$HOME/Applications/Utilities/zen-twilight/zen"
  ["firefox"]="firefox"
  ["edge"]="microsoft-edge-stable"
  ["vivaldi-stable"]="vivaldi"
)

last_browser=""
if [[ -f "$STATE_FILE" ]]; then
  last_browser=$(cat "$STATE_FILE")
fi

menu_items=""
if [[ -n "$last_browser" ]] && [[ " ${BROWSERS[*]} " =~ " ${last_browser} " ]]; then
  menu_items="$last_browser\n"
fi

for b in "${BROWSERS[@]}"; do
  if [[ "$b" != "$last_browser" ]]; then
    menu_items="$menu_items$b\n"
  fi
done

# Since this script is already launched inside a terminal, we can pipe directly to sk
selected=$(echo -e -n "$menu_items" | sk)

if [[ -z "$selected" ]]; then
  exit 0
fi

echo "$selected" > "$STATE_FILE"

win_id=$(niri msg -j windows | jq -r --arg app "$selected" '.[] | select(.app_id == $app) | .id' | head -n 1)

if [[ -n "$win_id" ]]; then
  niri msg action focus-window --id "$win_id"
else
  exec ${BROWSER_CMDS[$selected]}
fi
