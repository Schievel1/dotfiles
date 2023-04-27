#!/bin/bash
playerctl pause &
amixer set Master mute &
# betterlockscreen -l
xscreensaver-command -lock
