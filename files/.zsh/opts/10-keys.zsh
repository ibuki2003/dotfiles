# emacs mode
bindkey -e

typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Ctrl-Left]="${terminfo[kLFT5]}"
key[Ctrl-Right]="${terminfo[kRIT5]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"      end-of-line
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"   delete-char

[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"     backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"    forward-char
bindkey -- "${key[Ctrl-Left]}"  backward-word
bindkey -- "${key[Ctrl-Right]}" forward-word

[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"   history-beginning-search-backward
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}" history-beginning-search-forward
bindkey -- "^P" history-beginning-search-backward
bindkey -- "^N" history-beginning-search-forward

[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  function zle_application_mode_start { echoti smkx }
  function zle_application_mode_stop { echoti rmkx }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
