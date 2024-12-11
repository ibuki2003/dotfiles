#!/usr/bin/env zsh

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
  filename=~/Pictures/Screenshots/Screenshot_$(date '+%Y%m%d_%H%M%S').png
  args+=($filename)
fi

maim "${args[@]}" --hidecursor |\
  ( [[ $copy -eq 1 ]] && xclip -selection clipboard -t image/png || cat )

if [[ ${pipestatus[1]} -eq 0 ]]; then
  if [[ -n "${opthash[(i)--clip]}" ]]; then
    notify-send -t 4000 "Screenshot copied to clipboard"
  else
    notify-send -t 4000 "Screenshot saved to $filename"
  fi
fi
