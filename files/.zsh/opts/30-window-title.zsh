function set_title() {
  if [[ "$TERM" == "rxvt-unicode" || "$TERM" == "rxvt-unicode-256color" ]]; then
    local t='urxvt'
  elif [[ "$TERM_PROGRAM" == "alacritty" ]]; then
    local t='Alacritty'
  elif [[ "$TERM_PROGRAM" == "kitty" ]]; then
    local t='Kitty'
  fi
  echo -ne "\e]0;$t: $@\a"
}

function urxvt_window_preexec () {
  local WD="$(pwd | sed "s/^\/home\/$USER/~/")"
  COMMAND="$(echo $1 | tr -d '\n' | head -c 256)"
  set_title "$WD : $COMMAND"
}

function urxvt_window_postexec () {
  set_title "$(pwd | sed "s/^\/home\/$USER/~/")"
}

add-zsh-hook preexec urxvt_window_preexec
add-zsh-hook precmd urxvt_window_postexec
