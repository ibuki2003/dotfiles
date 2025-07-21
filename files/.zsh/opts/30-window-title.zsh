function set_title() {
  local t
  case "$TERM_PROGRAM" in
    alacritty) t='Alacritty' ;;
    kitty) t='Kitty' ;;
    *) return ;;
  esac
  local s=${PWD/$HOME/'~'}
  [[ -n $1 ]] && s="$s : $1"
  printf "\e]0;%s\a" "$t: $s"
}

function window_title_preexec () {
  local cmd=$1
  # remove newlines
  cmd=${1//$'\n'/ }
  # truncate to 256 characters
  cmd=${cmd:0:256}

  set_title "$cmd"
}

function window_title_postexec () {
  set_title
}

add-zsh-hook preexec window_title_preexec
add-zsh-hook precmd window_title_postexec
