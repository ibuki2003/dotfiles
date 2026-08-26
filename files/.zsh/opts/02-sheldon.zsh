export SHELDON_CONFIG_DIR=$ZSHHOME/sheldon
if (( $+commands[sheldon] )); then
  # eval "$(sheldon source)"
  local compiled="$SHELDON_CONFIG_DIR/.compiled.zsh"
  if [[ ! -r "$compiled" \
    || "~/.local/share/sheldon/plugins.lock" -nt "$compiled" \
    || "$SHELDON_CONFIG_DIR/plugins.toml" -nt "$compiled" \
  ]]; then
    sheldon source > "$compiled" || echo "sheldon source failed" >&2
  fi
  [[ -f "$compiled" ]] && source "$compiled"
else
  echo "sheldon not found" >&2
fi
