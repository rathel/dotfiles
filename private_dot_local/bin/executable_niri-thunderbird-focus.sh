#!/bin/bash

# Look for the window ID of a Firefox window
win_id=$(niri msg -j windows | jq -r --arg app "thunderbird" '.[] | select(.app_id == $app) | .id')

if [ -n "$win_id" ]; then
    # Focus that specific window
    niri msg action focus-window --id "$win_id"
else
<<<<<<< Updated upstream
    # Launch Thunderbird
    $HOME/Applications/thunderbird-beta/thunderbird &
fi
=======
    # Launch Firefox
    ~/Applications/thunderbird/thunderbird &
fi
>>>>>>> Stashed changes
