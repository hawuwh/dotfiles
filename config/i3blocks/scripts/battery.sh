#!/bin/bash

CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity)
STATUS=$(cat /sys/class/power_supply/BAT1/status)

if [ $STATUS = "Charging" ]; then
    DISPLAY_STATUS='+'
elif [ $STATUS = "Discharging" ]; then
    DISPLAY_STATUS='-'
else 
    DISPLAY_STATUS='FULL'
fi

echo "BAT $CAPACITY% [$DISPLAY_STATUS]"
