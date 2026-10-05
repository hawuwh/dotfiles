#!/bin/bash

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5; exit}')

echo "VOL $VOL"
