#!/bin/bash


function popup() {
  BORDER_SIZE=1  # border size from your wm settings
  YAD_WIDTH=${WIDTH:-222}  # 222 is minimum possible value
  YAD_HEIGHT=${HEIGHT:-193} # 193 is minimum possible value
  # DATE="$(date +"%Y-%m-%d (%a) %H:%M:%S")"

  # if [ "$(xdotool getwindowfocus getwindowname)" = "yad-calendar" ]; then
  #     exit 0
  # fi

  eval "$(xdotool getmouselocation --shell)"
  # eval "$(xdotool getdisplaygeometry --shell)"

  # X
  # : $((pos_x = X - YAD_WIDTH / 2))
  : $((pos_x = X - YAD_WIDTH))

  # Y
  : $((pos_y = Y))
  # : $((pos_x = X))

  yad --undecorated --fxed --close-on-unfocus --no-buttons \
    --width="$YAD_WIDTH" --height="$YAD_HEIGHT" --posx="$pos_x" --posy="$pos_y" \
    --borders=0 "$@"
}

#popup --list --title="yay" --column="foo" --column="bar" 1 2 3 4
