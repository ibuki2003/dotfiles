PROMPT="%F{green}[%n@%m]%(?..%F{009}!)%f %~
%# "

autoload -Uz vcs_info
autoload -Uz add-zsh-hook

setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{red}+"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}*"
zstyle ':vcs_info:*' formats "%F{green}[%b%c%u%F{green}]%f"
zstyle ':vcs_info:*' actionformats '%F{red}[%b|%a]%f'

RPROMPT=$RPROMPT'${vcs_info_msg_0_}'

function _update_vcs_info_msg() {
    zsh-defer -a +p vcs_info
}
add-zsh-hook precmd _update_vcs_info_msg
