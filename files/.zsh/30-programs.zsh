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

if type gpgconf > /dev/null || [ ! -z $GPG_AGENT_INFO ]; then
    export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket):1"
fi

if [ -z $SSH_AUTH_SOCK ] || \
    ! ( [ -p "$SSH_AUTH_SOCK" ] && ss -l | grep "$SSH_AUTH_SOCK" > /dev/null ); then

    # default socket path
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi
