#!/usr/bin/env bash

SS="$HOME/Pictures/$(date +%Y%m%d%H%M).png"
maim "$SS"
echo "Screenshot $SS"
echo "Open in GIMP? (y/N)"
read -r ANSWER
case $ANSWER in
    y|Y)
        gimp "$SS" > /dev/null 2>&1 &
        ;;
    n|N)
        echo "Upload? (y/N)"
        read -r ANSWER
        case $ANSWER in
             y|Y)
                 curl --upload-file "$SS" 'http://paste.c-net.org/' | xclip -i
                 ;;
              *)
                 ;;
        esac
        ;;
esac
