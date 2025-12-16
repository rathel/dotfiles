#!/bin/bash

# Look for the window ID of a Firefox window
ec="thunderbird-beta"

win_id=$(niri msg -j windows | jq -r --arg app "$ec" '.[] | select(.app_id == $app) | .id')

if [ -n "$win_id" ]; then
    # Focus that specific window
    niri msg action focus-window --id "$win_id"
else
    # Launch Thunderbird
    if [ "$ec" == "thunderbird-beta" ]; then
    	$HOME/Applications/Utilities/thunderbird-beta/thunderbird &
    fi
fi
