#!/bin/zsh

local -A opthash
zparseopts -D -A opthash -- -select -clip

local -a args
args=()

copy=0

if [[ -n "${opthash[(i)--select]}" ]]; then
  args+=('-s')
fi

if [[ -n "${opthash[(i)--clip]}" ]]; then
  copy=1
else
  args+=(~/Pictures/screenshots/Screenshot_$(date '+%Y%m%d_%H%M%S').png)
fi

maim "${args[@]}" |\
  ( [[ $copy -eq 1 ]] && xclip -selection clipboard -t image/png || cat )

