zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*:fuzzy:*:*:*' matcher-list 'r:|?=** m:{[:lower:]}={[:upper:]}'

zstyle ':completion:*' menu select search
zstyle ':completion:*' expand prefix
zstyle ':completion:*' completer _expand _prefix _complete _mycompleter:fuzzy _list

zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/compcache"
