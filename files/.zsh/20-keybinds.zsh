# emacs 風キーバインドにする
bindkey -e


# 先頭マッチのヒストリサーチ
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
