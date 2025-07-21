# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default

# NOTE: chars except "word-chars" consist words
zstyle ':zle:*' word-chars " /=;@:{},|#'\""
zstyle ':zle:*' word-style unspecified
