#!/bin/zsh

local -A opthash
zparseopts -D -A opthash -- -select -clip

local -a args
args=()

copy=0

if [[ -n "${opthash[(i)--select]}" ]]; then
  args+=('-g' "$(slurp)")
  if [[ $? -ne 0 ]]; then
    # cancelled
    exit 1
  fi
fi

if [[ -n "${opthash[(i)--clip]}" ]]; then
  args+=('-')
  copy=1
else
  filename=~/Pictures/Screenshots/Screenshot_$(date '+%Y%m%d_%H%M%S').png
  args+=($filename)
fi

grim "${args[@]}" |\
  ( [[ $copy -eq 1 ]] && wl-copy || cat )

if [[ -n "${opthash[(i)--clip]}" ]]; then
  notify-send -t 3000 "Screenshot copied to clipboard"
else
  notify-send -t 3000 "Screenshot saved to $filename"
fi
