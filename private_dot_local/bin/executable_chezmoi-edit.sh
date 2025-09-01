#!/bin/env bash

selection=$(chezmoi managed -p absolute | sk)

[ -z "$selection" ] && exit 1

notify-send "Editing $selection."

setsid -f chezmoi edit "$selection" > /dev/null 2>&1 &

sleep 0.5
