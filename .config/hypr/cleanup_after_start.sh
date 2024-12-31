#!/usr/bin/env sh
sleep 10
hyprctl keyword windowrule "workspace unset,^(firefox)$"
hyprctl keyword windowrule "workspace unset,^(firefox-bin)$"
hyprctl keyword windowrule "workspace unset,^(Emacs)$"
hyprctl keyword windowrule "workspace unset,^(Alacritty)$"
hyprctl keyword windowrule "workspace unset,^(pcmanfm)$"
hyprctl keyword windowrule "workspace unset,^(Discord)$"
hyprctl keyword windowrule "workspace unset,title:^(gtkcord4)$"
