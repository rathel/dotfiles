#!/usr/bin/env bash
#
sleep 2
echo "$border $(color green)Running Cleanup$(color off) $border"
sleep 2

emerge --ask --verbose --depclean
eclean-kernel -A
dispatch-conf

read -p "$(color green)Would you like to $(color red)reboot$(color green) now? \
    $(color off)($(color red)yes$(color off)/$(color green)No$(color off)) " -r reboot

case $reboot in
    Y|y|Yes|yes)
        echo "$(color green)Rebooting in $(color red)30$(color green) seconds$(color off)"
        sleep 30
        shutdown -r now
        ;;
    *)
        echo "$(color green)Doing nothing$(color off)"
        ;;
esac
