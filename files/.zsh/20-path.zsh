typeset -U path PATH

path=(
  ~/.local/bin
  ~/.cargo/bin
  $path
)
export PATH
