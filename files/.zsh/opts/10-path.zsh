# skip if already added
if [[ -z ${_PATH_ADDED:-} ]]; then
  path=(
    ~/.local/bin
    ~/.bin
    ~/.cargo/bin
    ~/.deno/bin
    ~/.local/share/aquaproj-aqua/bin
    ~/.config/yarn/global/node_modules/.bin
    ~/.local/share/pnpm
    ~/.nix-profile/bin
    $path
  )
  export _PATH_ADDED=1
fi

fpath=(
  ~/.zsh/functions
  ~/.zsh/functions/*(N-/)
  $fpath
)
