if [ -z $SSH_AUTH_SOCK ] || \
    ! ( [ -p "$SSH_AUTH_SOCK" ] && ss -l | grep "$SSH_AUTH_SOCK" > /dev/null ); then

    # default socket path
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi
