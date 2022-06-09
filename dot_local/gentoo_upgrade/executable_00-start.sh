#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "needs root"
    exit 1
fi

[ ! "$(command -v color)" ] && emerge --ask app-misc/color

border="$(color yellow)#####$(color off)"

if [[ "$(date +%d -r /var/db/repos/gentoo)" != "$(date +%d)" ]]; then
    echo "$border $(color green)Syncing portage$(color off) $border"
    sleep 2
    emaint --auto sync
    sleep 2
else
    echo "$border $(color red)Skipping Sync$(color off) $border"
    sleep 2
fi

. 01-updates.sh
[ ! "$(grep -q N280 /proc/cpuinfo)" ] && . 02-kernel.sh
. 03-cleanup.sh
