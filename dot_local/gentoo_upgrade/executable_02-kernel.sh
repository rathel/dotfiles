#!/usr/bin/env bash

kernelc=$(uname -r | cut -d '-' -f1)
kernell=$(ls /usr/src | sort | tail -1 | cut -d '-' -f2)

upgradekernel(){
    eselect kernel list
    read -r num
    eselect kernel set "$num"
    fs_tests
    grub-mkconfig -o /boot/grub/grub.cfg
}

fs_tests(){
    lvm="$(lsblk | grep -q lvm)"
    crypt="$(lsblk | grep -q crypt)"
    [ -n $lvm ] && genkernel all --lvm
    [ -n $crypt ] && genkernel all --luks
    [[ -z $lvm && -z $crypt ]] && genkernel all

}

if [ "$kernelc" != "$kernell" ]; then
    echo "$border $(color green)Upgrading Kernel$(color off) $border"
    sleep 2
    upgradekernel
fi
