#!/usr/bin/env bash
set +e

sleep 2
echo "$border $(color green)Running updates$(color off) $border"
sleep 2

[ "$(command -v haskell-updater)" ] && haskell-updater

emerge --ask --verbose --update --deep --newuse @world || \
    emerge --resume --skipfirst

[ "$(command -v flatpak)" ] && su $LOGNAME -c "flatpak update --user"

set -e
