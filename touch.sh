#!/bin/bash
# This disables my touchscreen
#search for "Touchscreen" or something like that in /proc/bus/input/devices to make sure you're disabling what you want to disable.

path_for_temp_files="$HOME/temp"
regex='event([0-9]+)'
DEVICE="Touchscreen"

if [ -r "${path_for_temp_files}touchscreen-evtest0.pid" ]; then
    kill_these_files=("${path_for_temp_files}"touchscreen-evtest*)

    for i in "${kill_these_files[@]}"; do
        echo "kill" $(cat "${i}")
        sudo kill $(cat "${i}")
        sudo rm "${i}"
    done  

fi

filename='/proc/bus/input/devices'
inside=0
events=()
while read line; do
    if [[ $line =~ $DEVICE ]]; then 
        inside=1
    fi

    if [[ $line =~ $regex ]]; then
        if [[ "$inside" -eq 1 ]]; then
            events+=("${BASH_REMATCH[1]}")
        fi
        inside=0
    fi
done < $filename

numevents=${#events[@]}

for (( i=0; i<${numevents}; i++ )); do
    sudo evtest --grab "/dev/input/event${events[$i]}" > /dev/null &
    pid=$!
    echo $pid > "${path_for_temp_files}touchscreen-evtest${i}.pid"
    echo "/dev/input/event${events[$i]} running on pid ${pid}"
done
