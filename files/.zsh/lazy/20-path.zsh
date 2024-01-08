typeset -U path PATH

path=(
  ~/.local/bin
  ~/.cargo/bin
  ~/.local/share/aquaproj-aqua/bin
  $path
)
export PATH
