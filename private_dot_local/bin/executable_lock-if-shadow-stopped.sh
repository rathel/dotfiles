#!/usr/bin/env bash

# ShadowPC provides its own activity, so do not lock the host session while it is running.
if pgrep -f '[S]hadowPC\.AppImage' >/dev/null; then
  exit 0
fi

exec swaylock -f -c 000000
