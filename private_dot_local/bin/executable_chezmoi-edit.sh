#!/bin/env bash

selection=$(chezmoi managed -p absolute | sk)

setsid -f chezmoi edit "$selection" > /dev/null 2>&1 &

sleep 0.5
