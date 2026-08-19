#!/bin/bash
set -euo pipefail

set +u
source "$HOME/.myenv"
set -u

# Get JSON from niri
json=$(niri msg -j windows)

mapfile -t window_ids < <(jq -r '.[].id' <<<"$json")

# Use fuzzel to pick a window by title. Select by index so the window ID stays hidden.
if ! selected_index=$(
  jq -r '.[] | [(.app_id // ""), (.title // "")] | @tsv' <<<"$json" |
    while IFS=$'\t' read -r app_id title; do
      icon="${app_id:-application-x-executable}"
      lower_icon="$(tr '[:upper:]' '[:lower:]' <<<"$icon")"
      printf '%s - %s\0icon\x1f%s\n' \
        "${app_id:-Unknown}" "${title:-Untitled}" "$lower_icon"
    done |
    fuzzel --dmenu \
      --index \
      --no-run-if-empty \
      --no-sort \
      --prompt "Switch window: " \
      --lines=15
); then
  exit 0
fi

# Exit if nothing was selected or the index is invalid.
[[ "$selected_index" =~ ^[0-9]+$ ]] || exit 1
(( selected_index < ${#window_ids[@]} )) || exit 1

niri msg action focus-window --id "${window_ids[selected_index]}"
