#!/bin/bash

get_battery(){
	echo "BAT: $(acpi -b | awk '{gsub(/,/, ""); print $3}') < $(acpi -b | awk '{gsub(/,/, ""); print $4}') < $(acpi -b | awk '{print $5}')"
}

get_date(){
	date +%H:%M
}

get_volume(){
	echo "Volume: $(pactl list sinks | grep '^[[:space:]]Volume:' | \
		head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')%"
	    }

while true; do
	xsetroot -name "$(get_volume) | $(get_battery) | $(get_date)"
	sleep 2
done
