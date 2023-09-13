ZSHHOME="${ZDOTDIR}/.zsh"

HISTFILE=${ZDOTDIR}/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

autoload -Uz colors && colors

setopt print_eight_bit
setopt no_beep
setopt no_flow_control
setopt ignore_eof
setopt interactive_comments
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt extended_glob
setopt correct
setopt appendhistory
setopt globdots

bindkey -e

typeset -U path PATH

path=(
  ~/.local/bin
  ~/.cargo/bin
  $path
)
export PATH

alias dsource='zsh-defer source'

export SHELDON_CONFIG_DIR=$ZSHHOME/sheldon
if type sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
else
  echo "sheldon not found" >&2
  alias dsource=source
fi

# load files
for i in $ZSHHOME/opts/*.zsh(.r); do
  source $i
done

for i in $ZSHHOME/lazy/*.zsh(.r); do
  source $i
done

autoload -Uz compinit && zsh-defer compinit -C
