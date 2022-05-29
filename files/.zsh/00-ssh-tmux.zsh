# Start tmux if only on ssh session
if [ -f /proc/$PPID/cmdline ] && [ "$(cut -d: -f1 < "/proc/$PPID/cmdline")" = "sshd" ] && [[ $- == *i* ]]; then
    ## if ssh
    if type tmux > /dev/null &&\
      type fzf > /dev/null &&\
      [[ ! -n $TMUX ]]; then
      # get the IDs
      ID="$(tmux list-sessions)"
      if [[ -z "$ID" ]]; then
        tmux new-session
        exit
      fi
      create_new_session="[Create New Session]"
      ID="$ID\n${create_new_session}:"
      ID="`echo $ID | fzf | cut -d: -f1`"
      if [[ "$ID" = "${create_new_session}" ]]; then
        tmux new-session
        exit # exit shell
      elif [[ -n "$ID" ]]; then
        tmux attach-session -t "$ID"
        exit
      else
        :  # Start terminal normally
      fi
    fi
fi
