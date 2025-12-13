#!/bin/bash

browser="zen"
win_id=$(niri msg -j windows | jq -r --arg app "$browser" '.[] | select(.app_id == $app) | .id')

if [ -n "$win_id" ]; then
    # Focus that specific window
    niri msg action focus-window --id "$win_id"
else
    case "$browser" in
        "zen")
        $HOME/Applications/Utilities/zen-x86_64.AppImage
        ;;
        "zen-twilight")
        $HOME/Applications/Utilities/zen-twilight/zen
        ;;
        "firefox")
        firefox
        ;;
        "edge")
        microsoft-edge-stable
        ;;
        "vivaldi-stable")
        vivaldi
        ;;

        *)
            echo "Unknown browser: $browser"
            exit 1
            ;;
    esac
fi
