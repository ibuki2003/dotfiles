#!/usr/bin/env bash

list=(
  ##  Lock  ##
  "Lock Screen"  "gnome-screensaver-command -l"
  "Logout"       "i3-msg exit"
  ##  Power ##
  "Reboot"       "systemctl reboot"
  "Suspend"      "systemctl suspend"
  "Shutdown"     "systemctl poweroff"
)

if selected="$(for (( i=0; i<=$((${#list[@]}/2-1)); i++ )) { echo "${list[($i+1)*2-2]}"; } | rofi -dmenu -i -format i)"; then
  [[ "$selected" -ge 0 ]] && eval "${list[($selected+1)*2-1]}"
fi
