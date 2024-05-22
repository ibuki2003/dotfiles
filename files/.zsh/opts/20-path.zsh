typeset -U path PATH

path=(
  ~/.local/bin
  ~/.cargo/bin
  ~/.local/share/aquaproj-aqua/bin
  ~/.config/yarn/global/node_modules/.bin
  ~/.local/share/pnpm
  $path
)
export PATH

fpath=(~/.zsh/functions ~/.zsh/functions/*(N-/) $fpath)
