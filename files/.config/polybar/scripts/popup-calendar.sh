#!/usr/bin/env sh
cd "$(dirname "$0")"
./popup.bash --calendar --title="calendar" > /dev/null &
