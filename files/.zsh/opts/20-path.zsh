typeset -U path PATH

# skip if already added
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
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
fi

fpath=(~/.zsh/functions ~/.zsh/functions/*(N-/) $fpath)
