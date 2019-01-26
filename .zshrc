########################################
# 環境変数
export LANG=ja_JP.UTF-8


# 操作 {{{

# emacs 風キーバインドにする
bindkey -e

# 先頭マッチのヒストリサーチ
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward



# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# }}}



# 表示 {{{
# 色を使用出来るようにする
autoload -Uz colors
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
colors

# プロンプト
PROMPT="%F{green}[%n@%m]%(?..%F{009}!)%f %~
%# "


# }}}


# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000


# 補完 {{{
# 補完機能を有効にする
autoload -Uz compinit
compinit

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# }}}
# Git(vcs) {{{
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


# }}}

# オプション {{{

# 日本語ファイル名を表示可能にする
setopt print_eight_bit
# beep を無効にする
setopt no_beep
# フローコントロールを無効にする
setopt no_flow_control
# Ctrl+Dでzshを終了しない
setopt ignore_eof
# '#' 以降をコメントとして扱う
setopt interactive_comments
# ディレクトリ名だけでcdする
setopt auto_cd
# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups
# 同時に起動したzshの間でヒストリを共有する
setopt share_history
# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space
# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks
# 高機能なワイルドカード展開を使用する
setopt extended_glob

# ミスを自動修正
setopt correct

# }}}

# エイリアス {{{

alias ls='ls -F --color=auto'

alias la='ls -la'
alias ll='ls -l'
alias l='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias grep='grep --color'

alias mkdir='mkdir -p'


# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス

alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."

if [ -e ~/aliases ]; then
    source ~/aliases
fi


# }}}
# OS 別の設定 {{{
case ${OSTYPE} in
    linux*)
        #Linux用の設定
        bindkey "^[OH" beginning-of-line
        bindkey "^[OF" end-of-line
        bindkey "^[[3~" delete-char

        ;;
    *)
        # Other:Windows
        bindkey "^[[H" beginning-of-line
        bindkey "^[[F" end-of-line
        bindkey "^[[3~" delete-char
        alias e='explorer'
        # Fake drives
        drives=$(mount | sed -rn 's#^[A-Z]: on /([a-z]).*#\1#p' | tr '\n' ' ')
        zstyle ':completion:*' fake-files /: "/:$drives"
        unset drives
        ;;
esac
# }}}

# vim:set ft=zsh:

source ~/functions.zsh

# zplug settings {{{
export ZPLUG_HOME=~/.zplug

if [ ! -e ~/.zplug ]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi
source ~/.zplug/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "zsh-users/zsh-completions"

zplug "zsh-users/zsh-autosuggestions"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose

#}}}

# zsh-syntax-highlighting {{{
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

#clear
