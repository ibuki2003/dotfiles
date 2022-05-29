type vim > /dev/null 2>&1 && export EDITOR=vim
type nvim > /dev/null 2>&1 && alias vim=nvim && export EDITOR=nvim

if type bat > /dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif type batcat > /dev/null; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  alias bat=batcat
fi
