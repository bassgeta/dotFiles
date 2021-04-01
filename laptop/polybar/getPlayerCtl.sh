#!/bin/sh

player_status=$(playerctl --player=spotify status 2> /dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    echo " $(playerctl --player=spotify -f '{{artist}} - {{title}}' metadata)"
else
    echo ""
fi
