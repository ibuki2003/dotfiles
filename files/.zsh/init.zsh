ZSHHOME="${ZDOTDIR}/.zsh"

HISTFILE=${ZDOTDIR}/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

autoload -Uz colors && colors

typeset -U path PATH

# update pre-built joined option file
(( $+commands[make] )) && make -C$ZSHHOME --silent

source $ZSHHOME/opts.cat.zsh

autoload -Uz compinit && compinit -C

if (( $+functions[zsh-defer] )); then
  zsh-defer source $ZSHHOME/lazy.cat.zsh
else
  source $ZSHHOME/lazy.cat.zsh
fi
