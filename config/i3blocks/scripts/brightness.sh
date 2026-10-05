#!/bin/bash

CURRENT_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/brightness)
MAX_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/max_brightness)

brightness=$((CURRENT_BRIGHTNESS*100/MAX_BRIGHTNESS))


echo "B $brightness%"
