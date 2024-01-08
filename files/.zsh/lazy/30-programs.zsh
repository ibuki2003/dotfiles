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
export MAKEFLAGS=-j$[$(grep cpu.cores /proc/cpuinfo | sort -u | sed 's/[^0-9]//g') + 1]" $MAKEFLAGS"

if (( $+commands[gpgconf] )) || [ ! -z $GPG_AGENT_INFO ]; then
    export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket):1"
fi

if [ -z $SSH_AUTH_SOCK ] || \
    ! ( [ -p "$SSH_AUTH_SOCK" ] && ss -l | grep "$SSH_AUTH_SOCK" > /dev/null ); then

    # default socket path
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi

export SNCLIRC=~/.config/sncli/config.ini

export AQUA_GLOBAL_CONFIG=${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml
export AQUA_POLICY_CONFIG=~/.config/aquaproj-aqua/aqua-policy.yaml
