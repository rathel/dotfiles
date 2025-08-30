#!/bin/bash

# Look for the window ID of a Firefox window
win_id=$(niri msg windows | awk '
  $1 == "Window" && $2 == "ID" {
    id = $3;
    sub(":", "", id)
  }
  /App ID: "thunderbird"/ {
    print id
    exit
  }
')

if [ -n "$win_id" ]; then
    # Focus that specific window
    niri msg action focus-window --id "$win_id"
else
    # Launch Firefox
    thunderbird &
fi