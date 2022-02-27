#!/usr/bin/env bash

git add .
echo "Commit Message:"
read -r message
git commit -m "$message"
git push
