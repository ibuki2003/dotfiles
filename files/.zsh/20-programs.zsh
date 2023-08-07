type vim > /dev/null 2>&1 && export EDITOR=vim
type nvim > /dev/null 2>&1 && alias vim=nvim && export EDITOR=nvim && alias vimdiff='nvim -d'

if type bat > /dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
elif type batcat > /dev/null; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  alias bat=batcat
  export MANROFFOPT="-c"
fi

# parallel make: use core_count + 1
export MAKEFLAGS=-j$[$(grep cpu.cores /proc/cpuinfo | sort -u | sed 's/[^0-9]//g') + 1]" $MAKEFLAGS"
