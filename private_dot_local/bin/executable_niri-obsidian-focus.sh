#!/bin/env bash

id="$(niri msg --json windows | jq -r '.[] | select(.app_id == "obsidian") | .id')"
uri="obsidian://open?vault=Main&file=Todo.md"
app="$HOME/Applications/Productivity/Obsidian.AppImage"

if [ -n "$id" ]; then
	focused="$(niri msg --json windows | jq --arg id "$id" '.[] | select(.id == ($id | tonumber)) | .is_focused')"
	if [ $focused = "true" ]; then
		niri msg action close-window --id "$id"
	else
		niri msg action focus-window --id "$id"
	fi
else
	$app "$uri" &
fi
