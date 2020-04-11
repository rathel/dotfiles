#!/bin/bash

get_charging(){
	if [ "$(acpi -b | awk '{print $5}')" = charging ]; then
	echo ""
	else
	echo " < $(acpi -b | awk '{print $5}')"
	fi
}

get_battery(){
	echo "BAT: $(acpi -b | awk '{gsub(/,/, ""); print $3}') < $(acpi -b | awk '{gsub(/,/, ""); print $4}')$(get_charging)"
}

get_date(){
	date +%H:%M
}

get_volume(){
	mute="$(pactl list sinks | grep Mute | awk '{print $2}')"
	if [ $mute = yes ]; then
		echo "Muted"
	else
		echo "$(pactl list sinks | grep '^[[:space:]]Volume:' | \
		head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')%"
	fi
}

test_headphone(){
	headphone_test="$(pactl list sinks | grep Active | awk '{print $3}')"
	if [ $headphone_test = analog-output-headphones ]; then
		echo "Volume_H:"
	else
		echo "Volume_S:"
	fi
}

madam_nazar_location(){
	file_json="$HOME/.cache/madamnazar.json"
	file_date="$(date -r $file_json) | awk '{print $2}'"
	current_date="$(date +%d)"

	if [[ $file_date != $current_date ]]; then
	curl --location --request GET 'https://madam-nazar-location-api.herokuapp.com/location/current' > $file_json
	fi

	jq '.data | .location | .region' $file_json | tr -d '\n' | sed -e 's/"//g;s/{//;s/}//;s/name://;s/precise://'
	
}

while true; do
	xsetroot -name "$(madam_nazar_location) | $(test_headphone)$(get_volume) | $(get_battery) | $(get_date)"
	sleep 2
done
