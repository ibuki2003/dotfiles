$env.config = $env.config | merge deep {
  show_banner: false,
  table: {
    mode: "light",
  },
  completions: {
    case_sensitive: false # case-sensitive completions
    quick: true    # set to false to prevent auto-selecting completions
    partial: true    # set to false to prevent partial filling of the prompt
    algorithm: "fuzzy"    # prefix or fuzzy
    external: {
      max_results: 100,
    }
  },
  history: {
    max_size: 1_000_000_000,
    sync_on_enter: false,
  },
}

$env.PATH = $env.PATH | prepend [
  ~/.local/bin
  ~/.bin
  ~/.cargo/bin
  ~/.deno/bin
  ~/.local/share/bin
] | uniq


if (which bat | is-not-empty) {
  $env.MANPAGER = "sh -c 'col -bx | bat -l man -p'"
  $env.MANROFFOPT = "-c"
} else if (which batcat | is-not-empty) {
  $env.MANPAGER = "sh -c 'col -bx | batcat -l man -p'"
  alias bat = batcat
  $env.MANROFFOPT = "-c"
}

# NOTE: `--wrapped` does not enable completions :(
# https://github.com/nushell/nushell/issues/14504
export def l [...rest: glob] {
  if ($rest | is-not-empty) {
    ls -la ...$rest | select name size type user mode modified
  } else {
    ls -la | select name size type user mode modified
  }
}

alias vim = nvim
alias rm = rm -i
alias cp = cp -i
alias mv = mv -i


export def clip [file?: string] {
  if ($file != null) {
    # copying file
    open $file | wl-copy -t (file --mime --brief $file)
  } else {
    let inp = $in
    if ($inp | is-not-empty) {
      # copying stdin
      $inp | wl-copy
    } else {
      # pasting
      wl-paste
    }
  }
}

# was `open` but that shadows the built-in command
export def op [...files: glob] {
  let inp = $in | default []
  $inp ++ ($files | each {|g| glob $g} | flatten) | each {|f|
    # xdg-open $f;
    # disowning bg job is not supported: https://github.com/nushell/nushell/issues/15201
    # HACK: use sh
    let escaped = ^printf "%q" $f
    ^sh -c $"nohup xdg-open ($escaped) >/dev/null 2>&1 & disown"
    sleep 0.1sec # delay to keep order
  }
  ()
}
