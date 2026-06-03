#!/bin/bash
set -euo pipefail

set +u
source "$HOME/.myenv"
set -u

# Get JSON from niri
json=$(niri msg -j windows)

# Use fuzzel to pick a window by title, with the window ID hidden from view.
id=$(
  jq -r '.[] | [.id, (.app_id // ""), (.title // "")] | @tsv' <<<"$json" |
    while IFS=$'\t' read -r win_id app_id title; do
      icon="${app_id:-application-x-executable}"
      lower_icon="$(tr '[:upper:]' '[:lower:]' <<<"$icon")"
      label="${app_id:-Unknown} - ${title:-Untitled}"

      printf '%s\t%s\0icon\x1f%s,%s,application-x-executable\n' \
        "$win_id" "$label" "$icon" "$lower_icon"
    done |
    fuzzel --dmenu \
      --prompt "Switch window: " \
      --with-nth=2 \
      --accept-nth=1 \
      --match-nth=2 \
      --nth-delimiter=$'\t' \
      --minimal-lines \
      --lines=15
)

# Exit if nothing selected
[ -z "$id" ] && exit 1

niri msg action focus-window --id "$id"
