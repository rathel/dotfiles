#!/bin/bash

# Get JSON from niri
json=$(niri msg -j windows)

# Use skim to pick a window by title (prefix with ID to ensure uniqueness)
selected=$(echo "$json" | jq -r '.[] | "\(.id): \(.app_id) - \(.title)"' | sk)

# Exit if nothing selected
[ -z "$selected" ] && exit 1

# Extract ID from the selection (everything before the colon)
id=${selected%%:*}

niri msg action focus-window --id "$id"