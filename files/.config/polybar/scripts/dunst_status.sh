#!/usr/bin/env bash
sleep_pid=0

toggle() {
    dunstctl set-paused toggle
    if [ "$sleep_pid" -ne 0 ]; then
        kill $sleep_pid >/dev/null 2>&1
    fi
}

trap "toggle" USR1

while true; do
    if $(dunstctl is-paused); then
        # muted icon
        echo '󰂛'
    else
        # bell icon
        echo '󰂞'
    fi
    sleep 5 &
    sleep_pid=$!
    sleep 0.1
    wait
done
