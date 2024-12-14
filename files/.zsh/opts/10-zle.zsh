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

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default

# NOTE: chars except "word-chars" consist words
zstyle ':zle:*' word-chars " /=;@:{},|#'\""
zstyle ':zle:*' word-style unspecified
