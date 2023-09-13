[ -f '/usr/share/fzf/key-bindings.zsh' ] && source '/usr/share/fzf/key-bindings.zsh'
[ -f '/usr/share/fzf/completion.zsh' ] && source '/usr/share/fzf/completion.zsh'

export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

if [[ -n "$TMUX" ]]; then
  FZF_TMUX=1
  FZF_TMUX_HEIGHT='25%'
fi
