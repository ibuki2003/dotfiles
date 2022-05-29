if type gpg-agent > /dev/null; then
    export SSH_AGENT_PID=
    export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket):1"
fi
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
