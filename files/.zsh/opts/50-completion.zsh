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

# Route every candidate source through one interaction policy. The candidate
# router tries normal completion once, then falls back to fuzzy path matching.
autoload -Uz _my_completion_candidates _fuzzy_path_prefix
zstyle ':completion:*' completer _mycompleter

# _my_completion_candidates: candidate generation and fallback order
# _mycompleter: insert a unique match; for multiple matches, show the menu on
#               the first tab and start selection on the following tab

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

# Do not append `_path_files` because current carapace already supplies filesystem candidates.
carapace_patched=$(
  print -r -- "$carapace_init" |
    awk '
      # Initialize an explicit match flag before carapace processes candidate blocks.
      $0 == "  local block tag displays values displaysArr valuesArr" {
        print
        print "  local carapace_matches=0"
        declarations++
        next
      }

      # Mark successful descriptions because the generated while status is ambiguous.
      index($0, "&& _describe -t") && index($0, "displaysArr valuesArr") {
        print $0 " && carapace_matches=1"
        descriptions++
        next
      }

      # Return success only when carapace added candidates.
      $0 == "  done <<<\"${data}\"" {
        print
        print ""
        print "  (( carapace_matches ))"
        returns++
        next
      }

      { print }

      END {
        # Fail closed when the generated code no longer has every expected insertion point.
        if (declarations != 1 || descriptions != 1 || returns != 1)
          exit 42
      }
    '
)

if (( $? == 0 )); then
  source /dev/stdin <<< "$carapace_patched"
else
  print -u2 -- \
    'warning: output of carapace init script was not patched, falling back to original output'
  source /dev/stdin <<< "$carapace_init"
fi

unset carapace_init carapace_patched
