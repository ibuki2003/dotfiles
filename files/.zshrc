ZDOTDIR=${ZDOTDIR:-$HOME}

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


########################################
# 環境変数

# 操作 ====================================
# emacs 風キーバインドにする
bindkey -e

typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" history-beginning-search-forward



# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi


# 先頭マッチのヒストリサーチ
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|-"
zstyle ':zle:*' word-style unspecified




# 表示 ====================================
# 色を使用出来るようにする
autoload -Uz colors
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
colors

# プロンプト
PROMPT="%F{green}[%n@%m]%(?..%F{009}!)%f %~
%# "




# ヒストリの設定
HISTFILE=${ZDOTDIR}/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000


# Completion ====================================
autoload -Uz compinit
if [[ -n $(find ~/.zcompdump 2> /dev/null) ]]; then
	compinit -C
else
	#compinit
fi;

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin


# Git(vcs) ====================================
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{red}+"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}*"
zstyle ':vcs_info:*' formats "%F{green}[%b%c%u]%f"
zstyle ':vcs_info:*' actionformats '%F{red}[%b|%a]%f'
precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'

function _update_vcs_info_msg() {
    LANG=en_US.UTF-8 vcs_info
    RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg


# opt ====================================
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
setopt incappendhistory
setopt globdots


# alias ====================================

alias ls='ls -F --color=auto'

alias la='ls -la'
alias ll='ls -l'
alias l='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias rename='rename -i'

alias grep='grep --color'
alias diff='diff --color=auto'

alias mkdir='mkdir -p'

alias :q=exit

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス

alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."


# function ====================================
function gpp () {
    g++ -std=c++1y -o "${1%.*}" -O2 -g -DLOCAL -D_GLIBCXX_DEBUG -Wall -Wextra -Wpedantic $@
}
compdef gpp=g++

# programs ==============================
if type vim > /dev/null; then
  export EDITOR=vim
fi


if type bat > /dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif type batcat > /dev/null; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  alias bat=batcat
fi

# local zshrc can be used to load local plugin
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# zinit settings ====================================

if [ ! -e ${ZDOTDIR}/.zinit/bin/zinit.zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
fi
source ${ZDOTDIR}/.zinit/bin/zinit.zsh
autoload -Uz _zinit


zinit light zsh-users/zsh-autosuggestions

zinit light zsh-users/zsh-syntax-highlighting

zinit snippet 'OMZL::clipboard.zsh'
zinit snippet '/usr/share/fzf/key-bindings.zsh'
zinit light 'mollifier/anyframe'

#'
zinit ice blockf
zinit light zsh-users/zsh-completions
(( ${+_comps} )) && _comps[zinit]=_zinit

# external settings ====================================
# zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,underline'

ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'

ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=magenta'

ZSH_HIGHLIGHT_STYLES[comment]='fg=gray'


ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red,bold'

ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=cyan,bold'

ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'

# fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

if [[ -n "$TMUX" ]]; then
  FZF_TMUX=1
  FZF_TMUX_HEIGHT='25%'
fi

# anyframe
zstyle ':anyframe:selector:fzf-tmux:' command "fzf-tmux -d ${FZF_TMUX_HEIGHT}"
alias fco=anyframe-widget-checkout-git-branch
alias fh=anyframe-widget-put-history
alias fk=anyframe-widget-kill

bindkey '^xf' anyframe-widget-insert-filename
bindkey '^xb' anyframe-widget-insert-git-branch
bindkey '^xh' anyframe-widget-put-history
type ghq > /dev/null && bindkey '^xg' anyframe-widget-cd-ghq-repository

