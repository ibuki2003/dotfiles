#!/usr/bin/env sh
playerctl -F metadata --format "{{ status }}: {{ artist }} - {{ title }}" 2>/dev/null
