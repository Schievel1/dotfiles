#!/bin/bash
set -e;

if ! pgrep firefox >/dev/null; then echo "Launching firefox (bin)..." && swaymsg 'exec /usr/bin/firefox-bin'; fi
# echo "Launching emacs..." && swaymsg 'exec emacsclient -a emacs -c'
if ! pgrep alacritty >/dev/null; then echo "Launching alacritty..." && swaymsg 'exec alacritty'; fi
if ! pgrep pcmanfm >/dev/null; then echo "Launching pcmanfm..." && swaymsg 'exec pcmanfm'; fi
