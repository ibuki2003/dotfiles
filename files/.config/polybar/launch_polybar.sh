#!/bin/bash

# kill once
polybar-msg cmd quit

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

if type "xrandr" > /dev/null; then
  for m in $(polybar -m | cut -d: -f1); do
    MONITOR=$m nohup polybar --reload main > /dev/null &
    sleep 0.1
  done
else
  polybar --reload main > /dev/null 2>/dev/null &
fi
