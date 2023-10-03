#!/usr/bin/env sh

sleep 30
hyprctl keyword windowrule "workspace 5 silent,^(Emacs)$"
# hyprctl keyword exec "/usr/bin/emacs --eval '(mu4e)' '(ement-connect)'"

hyprctl keyword exec "~/.config/hypr/cleanup_after_start.sh"
