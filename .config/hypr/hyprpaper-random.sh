#!/usr/bin/env bash

wallpaper=$(find /home/pascal/Pictures/wallpapers -type f | shuf -n 1)
monitor="$1"

hyprctl hyprpaper preload "$wallpaper"
hyprctl hyprpaper wallpaper "$monitor, $wallpaper"
