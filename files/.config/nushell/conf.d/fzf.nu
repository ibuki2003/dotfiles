$env.config.keybindings ++= [{
  name: ghq_fzf
  modifier: control
  keycode: char_x
  mode: [emacs]
  event: {
    send: executehostcommand
    cmd: "ghq-fzf"
  }
}]

$env.FZF_DEFAULT_OPTS = "--height 40% --reverse --border"

export def fuzzy-find [
  column?: cell-path
  --multi
  --index
] {
  let inp = $in
  let items = if ($column | is-not-empty) {
    $inp | get $column
  } else {
    $inp
  }
  let m = if $multi { [--multi] } else { [] }
  let idx = ($items |
    enumerate |
    each {$"($in.index)\t($in.item)"} |
    str join (char -i 0) |
    fzf --read0 --print0 -d '\t' --accept-nth=1 --with-nth=2.. ...$m |
    split row (char -i 0) | compact --empty | into int
  )
  let ret = if ($index) {
    $idx
  } else {
    $idx | each {|i| $inp | get $i }
  }
  if ($ret | is-not-empty) {
    if $multi { $ret } else { $ret | get 0 }
  }
}

export def --env ghq-fzf [] {
  let sel = ghq list | lines | fuzzy-find
  if ($sel | is-not-empty) {
    cd (ghq root | path join $sel)
  }
}
