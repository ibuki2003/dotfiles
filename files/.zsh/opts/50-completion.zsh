zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# just case-insensitive
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
# fuzzy matching with case-insensitive
zstyle ':completion:*:fuzzy:*:*:*' matcher-list 'r:|?=** m:{[:lower:]}={[:upper:]}'
# zstyle ':completion:*:fuzzy:*:*:*' matcher-list 'r:?||?=* m:{[:lower:]}={[:upper:]}'

zstyle ':completion:*' menu yes select search
# insert prefix even if there are multiple matches
# zstyle ':completion:*' expand prefix

zstyle ':completion:*:fuzzy:*:*:paths' expand prefix suffix
zstyle ':completion:*:fuzzy:*:*:paths' list-suffixes true
zstyle ':completion:*:paths' accept-exact-dirs true

# try these completers in order, stop at the first one that produces matches
autoload -Uz _fuzzy_path_prefix
zstyle ':completion:*' completer _expand _prefix _complete _fuzzy_path_prefix _mycompleter:fuzzy

# expand: emit candidates by expanding the current word (e.g. brace expansion)
# prefix: emit candidates with the leftside of the cursor
# complete: normal completion
# fuzzy: special completer for path-like words (matching with suffix-removed string)
# mycompleter: insert the only candidate, or show a menu and then insert on following tab keypresses

zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/compcache"

zstyle ':completion:*' format $'\e[2;37m[%d]\e[m'

autoload -Uz compinit && compinit -C # `-C`: skip the check for new functions

local carapace_init carapace_patched

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
export CARAPACE_HIDDEN=2
export CARAPACE_UNFILTERED=1

carapace_init=$(carapace _carapace)

carapace_patched=$(
  print -r -- "$carapace_init" |
    awk '
      $0 == "  done <<<\"${data}\"" {
        print
        print ""
        print "  _path_files"
        patched++
        next
      }

      { print }

      END {
        if (patched != 1)
          exit 42
      }
    '
)

if (( $? == 0 )); then
  source /dev/stdin <<< "$carapace_patched"
else
  print -u2 -- \
    'warning: output of carapace init script was not patched, falling back to original output' \
  source /dev/stdin <<< "$carapace_init"
fi

unset carapace_init carapace_patched
