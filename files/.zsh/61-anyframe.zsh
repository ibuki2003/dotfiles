zstyle ':anyframe:selector:fzf-tmux:' command "fzf-tmux -d ${FZF_TMUX_HEIGHT}"
alias fco=anyframe-widget-checkout-git-branch
alias fh=anyframe-widget-put-history
alias fk=anyframe-widget-kill

bindkey '^xF' anyframe-widget-insert-filename
bindkey '^xb' anyframe-widget-insert-git-branch
bindkey '^xh' anyframe-widget-put-history
type ghq > /dev/null && bindkey '^xg' anyframe-widget-cd-ghq-repository


function anyframe-widget-insert-filename-recursive () {
  find . \
    | anyframe-selector-auto \
    | anyframe-action-insert -q
}
zle -N anyframe-widget-insert-filename-recursive
bindkey '^xf' anyframe-widget-insert-filename-recursive
