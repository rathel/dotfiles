#!/bin/env bash
set -euo pipefail

file="$(chezmoi managed --include=files --path-style=absolute --source-path | sk --preview="bat {}" --preview-window right:30%)"
file="$(chezmoi source-path "$file")"

exec nvim "$file"

if [[-z "$(chezmoi git -- status --porcelain=v1)" ]]; then
  echo "No changes made to $file"
  exit 0
else
  exec chezmoi git -- add "$file"
  exec chezmoi git -- commit -m "Edited: $file"
  exec chezmoi git -- push
fi
