#!/bin/env bash

selection=$(chezmoi managed -p absolute | sk)

notify-send "Editing $selection."

setsid -f chezmoi edit "$selection" > /dev/null 2>&1 &

sleep 0.5
