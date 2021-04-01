#!/bin/sh
xrandr --output eDP-1-1 --off --output DP-1-1 --primary --mode 3840x2160 --pos 0x0 --rotate normal --output DP-2 --off --output DP-3 --off
echo "Xft.dpi: 163" | xrdb -merge
feh --bg-scale ~/Pictures/Wallpapers/mountains.jpg
~/.config/polybar/4kboi.sh
