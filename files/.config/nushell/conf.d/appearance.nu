$env.config = $env.config | merge deep {
  shell_integration: {
    osc2: false, # I will set my own window title
  },

  highlight_resolved_externals: true,
  color_config: {
    shape_internalcall: "cyan_bold",
    shape_external: "red",
    shape_external_resolved: "cyan",
  },
}

let hostname = hostname
$env.PROMPT_COMMAND = {||
  let user_host = $"(if (is-admin) { ansi red_bold } else { ansi green_bold })[($env.USER)@($hostname)](ansi reset)"

  let status = if ($env.LAST_EXIT_CODE == 0) { "" } else { $"(ansi red)\(($env.LAST_EXIT_CODE)\)(ansi reset) " }

  let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
    null => $env.PWD
    '' => '~'
    $relative_pwd => ([~ $relative_pwd] | path join)
  }

  let s = (gstat)
  let gs = if ($s.idx_added_staged < 0) {
    ""
  } else {
    let segs = [
      ($s.branch)
      (if ($s.state != "clean") { $"(ansi red).($s.state)(ansi reset)" } else { "" })

      (
        ($s.idx_added_staged + $s.idx_modified_staged + $s.idx_deleted_staged + $s.idx_renamed + $s.idx_type_changed) |
        if ($in > 0) { $"(ansi red)+($in)(ansi reset)" } else { "" }
      )
      (
        ($s.wt_modified + $s.wt_deleted + $s.wt_type_changed + $s.wt_renamed) |
        if ($in > 0) { $"(ansi light_red)*($in)(ansi reset)" } else { "" }
      )
      (if ($s.wt_untracked > 0) { $"(ansi white_dimmed)?($s.wt_untracked)(ansi reset)" } else { "" })
      (if ($s.conflicts > 0) { $"(ansi red)!($s.conflicts)(ansi reset)" } else { "" })

      (if ($s.ahead > 0) { $"(ansi blue)↑($s.ahead)(ansi reset)" } else { "" })
      (if ($s.behind > 0) { $"(ansi blue)↓($s.behind)(ansi reset)" } else { "" })
    ]
    let color = if ($segs | any { |x| $x != "" }) { ansi green_bold } else { ansi green }
    $" ($color)\(($segs | str join '')($color)\)(ansi reset)"
  }

  $"($user_host)($status) ($dir)($gs)\n"
}
$env.PROMPT_COMMAND_RIGHT = {|| "" }
$env.PROMPT_INDICATOR = "% "
$env.PROMPT_MULTILINE_INDICATOR = "> "


$env.config.keybindings ++= [
  # disable Ctrl-D
  { modifier: control, keycode: char_d, mode: emacs, event: { send: none } }
]

def set-window-title [pwd: string, cmd?: string] {
  # ex. Alacritty: ~/Documents : vim a.txt
  let term = match $env.TERM_PROGRAM {
    "alacritty" => "Alacritty"
    _ => "unknown"
  }
  let pwd_short = $pwd | str replace $nu.home-path "~"
  if ($cmd != null) {
    print -n $"(ansi title)($term): ($pwd_short) : ($cmd)(ansi st)"
  } else {
    print -n $"(ansi title)($term): ($pwd_short)(ansi st)"
  }
}

$env.config.hooks.pre_execution ++= [{
  set-window-title (pwd) (commandline)
}]
$env.config.hooks.pre_prompt ++= [{
  set-window-title (pwd)
}]
