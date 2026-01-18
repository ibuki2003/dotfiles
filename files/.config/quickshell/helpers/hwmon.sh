#!/usr/bin/env bash
# list /sys/class/hwmon/hwmon*/name
for hwmon in /sys/class/hwmon/hwmon*; do
  if [ -f "$hwmon/name" ]; then
    name=$(cat "$hwmon/name")
    echo "$hwmon:$name"
  fi
done
