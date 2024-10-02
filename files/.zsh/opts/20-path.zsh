typeset -U path PATH

path=(
  ~/.local/bin
  ~/.bin
  ~/.bin/scripts
  ~/.cargo/bin
  ~/.local/share/aquaproj-aqua/bin
  ~/.config/yarn/global/node_modules/.bin
  ~/.local/share/pnpm
  ~/.nix-profile/bin
  $path
)
export PATH

fpath=(~/.zsh/functions ~/.zsh/functions/*(N-/) $fpath)
