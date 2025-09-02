#!/bin/env bash
set -euo pipefail

selection=$(chezmoi managed -p absolute -x dirs | sk)

[ -z "$selection" ] && exit 1

notify-send "Editing $selection."

setsid -f chezmoi edit "$selection" > /dev/null 2>&1 &

sleep 0.5
