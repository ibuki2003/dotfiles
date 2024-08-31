typeset -U path PATH

path=(
  ~/.local/bin
  ~/.bin
  ~/.bin/scripts
  ~/.cargo/bin
  ~/.config/yarn/global/node_modules/.bin
  ~/.local/share/pnpm
  $path
)
export PATH

fpath=(~/.zsh/functions ~/.zsh/functions/*(N-/) $fpath)
