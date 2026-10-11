#!/bin/sh

player="termusic"

if song="$(playerctl -p "$player" metadata --format '{{artist}} - {{title}}' 2>/dev/null)"; then
    echo "$song"
else
    echo " "
fi
