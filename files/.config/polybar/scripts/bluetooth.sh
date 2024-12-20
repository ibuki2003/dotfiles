#!/usr/bin/env sh
type bluetoothctl > /dev/null 2>&1 || exit

if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
  echo "%{F#66ffffff}󰂲"
else
  if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]; then
    echo "󰂯"
  fi
  echo "%{F#2193ff}󰂱"
fi

