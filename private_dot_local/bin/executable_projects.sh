#!/bin/env bash

DIRECTORIES=(
    "$HOME/src/python"
    "$HOME/src/rust"
    "$HOME/src/go"
    "$HOME/src/js"
)

project=$(fd . "${DIRECTORIES[@]}" -t d -d 1 | sk)

if [ -n "$project" ]; then
   setsid -f foot -e nvim "$project" >/dev/null 2>&1
    exit 0
else
    exit 1
fi
