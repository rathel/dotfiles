#!/bin/env bash
set -euo pipefail

file="$(chezmoi managed --include=files --path-style=absolute --source-path | sk --preview="bat {}" --preview-window right:30%)"
file="$(chezmoi source-path "$file")"

nvim "$file"

if [[ -z "$(chezmoi git -- status --porcelain=v1)" ]]; then
  echo "No changes made to $file"
  exit 0
else
  chezmoi git -- add "$file"
  chezmoi git -- commit -m "Edited: $file"
  chezmoi git -- push
fi
