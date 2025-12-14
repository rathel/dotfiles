#!/bin/bash

# Look for the window ID of a Firefox window
win_id=$(niri msg -j windows | jq -r --arg app "thunderbird" '.[] | select(.app_id == $app) | .id')

if [ -n "$win_id" ]; then
    # Focus that specific window
    niri msg action focus-window --id "$win_id"
else
    # Launch Thunderbird
    $HOME/Applications/Utilities/thunderbird-beta/thunderbird &
fi
