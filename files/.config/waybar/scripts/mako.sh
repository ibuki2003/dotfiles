#!/usr/bin/env bash

# argument: toggle
if [[ "$1" == "toggle" ]]; then
    if makoctl mode | grep -q 'do-not-disturb'; then
        makoctl mode -r do-not-disturb > /dev/null
    else
        makoctl mode -a do-not-disturb > /dev/null
    fi
    exit
fi

sleep 0.1 # deal with exec-on-event problem (executes script before toggle done)
if makoctl mode | grep -q 'do-not-disturb'; then
    # muted icon
    echo '󰂛'
else
    # bell icon
    echo '󰂞'
fi
