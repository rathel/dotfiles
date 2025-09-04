#!/bin/env bash

sleep 5
pkill dunst

WALLPAPER="$HOME/Wallpapers/mobiusstripdracula.png"

swaybg -i $WALLPAPER &

wallust run  $WALLPAPER
