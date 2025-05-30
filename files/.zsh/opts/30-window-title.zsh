function set_title() {
  local t
  case "$TERM_PROGRAM" in
    alacritty)
      t='Alacritty'
      ;;
    kitty)
      t='Kitty'
      ;;
    *)
      # return
      ;;
  esac
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
