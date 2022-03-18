#!/bin/bash

vboxnames=$(vboxmanage list vms | awk '{print $1}' | sed 's/"//g')
choice=$(printf '%s\n' $vboxnames | dmenu -i -l 20 -p "VirtualBoxes:")

if [[ "$choice" ]]; then
    vboxmanage startvm $choice
fi