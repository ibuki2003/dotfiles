(( $+commands[vim] )) && export EDITOR=vim
(( $+commands[nvim] )) && alias vim=nvim && export EDITOR=nvim && alias vimdiff='nvim -d'

if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
elif (( $+commands[batcat] )); then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  alias bat=batcat
  export MANROFFOPT="-c"
fi

# parallel make: use core_count + 1
export MAKEFLAGS=-j$[$(grep --max-count=1 -Po '(?<=^cpu cores\s{,10}: )\d+' /proc/cpuinfo) + 1]" $MAKEFLAGS"

if (( $+commands[gpgconf] )) || [ ! -z $GPG_AGENT_INFO ]; then
    export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket):1"
fi

if [ -z $SSH_AUTH_SOCK ]; then
    # default socket path
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi

export PNPM_HOME="/home/fuwa/.local/share/pnpm"

export COREPACK_ENABLE_AUTO_PIN=0

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
