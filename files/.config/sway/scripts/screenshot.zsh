#!/bin/zsh

local -A opthash
zparseopts -D -A opthash -- -select -clip

local -a args
args=()

copy=0

if [[ -n "${opthash[(i)--select]}" ]]; then
  args+=('-g' "$(slurp)")
fi

if [[ -n "${opthash[(i)--clip]}" ]]; then
  args+=('-')
  copy=1
else
  args+=(~/Pictures/screenshots/Screenshot_$(date '+%Y%m%d_%H%M%S').png)
fi

grim "${args[@]}" |\
  ( [[ $copy -eq 1 ]] && wl-copy || cat )

