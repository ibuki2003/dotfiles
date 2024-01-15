zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' matcher-list \
  'm:{[:lower:]}={[:upper:]}' \
  'r:|?=** m:{[:lower:]}={[:upper:]}'

zstyle ':completion:*' menu select search
zstyle ':completion:*' completer _prefix _mycompleter

zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
