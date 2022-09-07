if type gpgconf > /dev/null || [ ! -z $GPG_AGENT_INFO ]; then
    export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket):1"
fi
