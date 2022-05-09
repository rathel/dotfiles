#!/usr/bin/env bash
set -e

git add .
echo "Commit Message:"
read -r message
git commit -m "$message"
git push
