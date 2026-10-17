#!/usr/bin/env zsh

setopt errexit nounset pipefail

zmodload zsh/zpty

typeset -gr root=${0:A:h:h}
typeset -gr tmpdir=$(mktemp -d)
typeset -gr fixture=$tmpdir/fixture
typeset -gr mockbin=$tmpdir/bin
typeset -gr completion_init=$tmpdir/completion-init.zsh
typeset -gr setup=$tmpdir/setup.zsh
typeset -gr result=$tmpdir/result
typeset -gr pty=completion-test

cleanup() {
  zpty -d $pty 2>/dev/null || true
  rm -rf -- $tmpdir
}
trap cleanup EXIT INT TERM

mkdir -p $fixture $mockbin $tmpdir/zdot
mkdir -p $tmpdir/man/man{1,5,7}
touch $tmpdir/man/man1/probe.1 $tmpdir/man/man5/probe.5 \
  $tmpdir/man/man7/man.7.gz $tmpdir/man/man1/tmux.1 \
  $tmpdir/man/man1/systemd.1 $tmpdir/man/man5/systemd.service.5
cp $root/tests/fixtures/carapace $mockbin/carapace
chmod +x $mockbin/carapace

cat >$completion_init <<'EOF'
fpath=($COMPLETION_TEST_ROOT/functions $fpath)
path=($COMPLETION_TEST_MOCKBIN $path)
ZDOTDIR=$COMPLETION_TEST_TMP/zdot
XDG_CACHE_HOME=$COMPLETION_TEST_TMP/cache
LS_COLORS='di=01;34:fi=0'
mkdir -p $ZDOTDIR $XDG_CACHE_HOME

source $COMPLETION_TEST_ROOT/functions/_mycompleter
source $COMPLETION_TEST_ROOT/opts/50-completion.zsh
export MANPATH=$COMPLETION_TEST_TMP/man
EOF

cat >$setup <<'EOF'
source $COMPLETION_TEST_INIT
zstyle ':completion:*' format '__MENU__'

setopt AUTO_LIST AUTO_MENU ALWAYS_LAST_PROMPT
COLUMNS=200
PS1='__PROMPT__ '
RPROMPT=
bindkey -e
bindkey '^I' expand-or-complete

_completion_test_dump() {
  print -r -- $BUFFER >|$COMPLETION_TEST_RESULT
  (( ++_completion_test_index ))
  BUFFER="print -r -- __CASE_DONE_${_completion_test_index}__"
  CURSOR=$#BUFFER
  zle accept-line
}
typeset -gi _completion_test_index=0
zle -N _completion_test_dump
bindkey '^]' _completion_test_dump

HOME=$COMPLETION_TEST_FIXTURE
cd $COMPLETION_TEST_FIXTURE
EOF

cat >$tmpdir/zdot/.zshrc <<EOF
source ${(q)completion_init}
EOF

export COMPLETION_TEST_ROOT=$root
export COMPLETION_TEST_TMP=$tmpdir
export COMPLETION_TEST_FIXTURE=$fixture
export COMPLETION_TEST_RESULT=$result
export COMPLETION_TEST_MOCKBIN=$mockbin
export COMPLETION_TEST_INIT=$completion_init

typeset startup_output
startup_output=$(env TERM=xterm-256color ZDOTDIR=$tmpdir/zdot zsh -i -c exit 2>&1)

zpty $pty env TERM=xterm-256color zsh -df
zpty -w $pty "source ${(q)setup}"
zpty -w $pty 'print -r -- __READY__'
typeset output
zpty -r -m $pty output '*__READY__*'

typeset -gi passed=0 failed=0 case_index=0
typeset -g interaction_buffer interaction_output

if [[ -n $startup_output ]]; then
  print -u2 -r -- 'NG - completion setup:'
  print -u2 -r -- "     interactive shell produced ${(qqq)startup_output}"
  (( ++failed ))
else
  print -r -- 'OK - completion setup'
  (( ++passed ))
fi

run_interaction() {
  local input=$1 tabs=$2
  local i done_pattern

  (( ++case_index ))
  done_pattern="*__CASE_DONE_${case_index}__*"
  : >|$result
  zpty -w -n $pty $input
  for (( i = 0; i < tabs; ++i )); do
    zpty -w -n $pty $'\t'
  done
  zpty -w -n $pty $'\x1d'
  zpty -r -m $pty interaction_output $done_pattern
  interaction_buffer=$(<$result)
}

normalize_output() {
  emulate -L zsh
  setopt extendedglob

  local value=$1
  value=${value//$'\e'\[[0-9;:?]#[@-~]/}
  value=${value//$'\r'/}
  print -r -- $value
}

menu_case() {
  local name=$1 input=$2
  shift 2

  if (( $# == 0 || $# % 2 != 0 )); then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     menu items must be display/buffer pairs"
    (( ++failed ))
    return
  fi

  local -a displays buffers
  while (( $# )); do
    displays+=($1)
    buffers+=($2)
    shift 2
  done

  local i first_output normalized menu_text tail
  local case_failed=0

  run_interaction $input 1
  first_output=$interaction_output
  if [[ $interaction_buffer != $input ]]; then
    print -u2 -r -- "NG - $name initial:"
    print -u2 -r -- "     expected ${(qqq)input}, got ${(qqq)interaction_buffer}"
    case_failed=1
  fi

  for (( i = 1; i <= $#buffers; ++i )); do
    run_interaction $input $(( i + 1 ))
    if [[ $interaction_buffer != $buffers[i] ]]; then
      print -u2 -r -- "NG - $name item $i:"
      print -u2 -r -- "     expected ${(qqq)buffers[i]}, got ${(qqq)interaction_buffer}"
      case_failed=1
    fi
  done

  run_interaction $input $(( $#buffers + 2 ))
  if [[ $interaction_buffer != $buffers[1] ]]; then
    print -u2 -r -- "NG - $name wrap:"
    print -u2 -r -- "     expected ${(qqq)buffers[1]}, got ${(qqq)interaction_buffer}"
    case_failed=1
  fi

  normalized=$(normalize_output $first_output)
  if [[ $input == man* && $normalized == *__MENU__*__MENU__* ]]; then
    print -u2 -r -- "NG - $name: manual candidates were split into groups"
    case_failed=1
  fi
  if [[ $normalized != *__MENU__* ]]; then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     menu was not displayed"
    case_failed=1
  else
    menu_text=${normalized#*__MENU__}
    tail=$menu_text
    for (( i = 1; i <= $#displays; ++i )); do
      if [[ $tail != *$displays[i]* ]]; then
        print -u2 -r -- "NG - $name menu item $i:"
        print -u2 -r -- "     ${(qqq)displays[i]} was not displayed in order"
        case_failed=1
        break
      fi

      tail=${tail#*$displays[i]}
    done
  fi

  if (( case_failed )); then
    (( ++failed ))
  else
    print -r -- "OK - $name"
    (( ++passed ))
  fi
}

unique_case() {
  local name=$1 input=$2 expected=$3
  local case_failed=0

  run_interaction $input 1

  if [[ $interaction_buffer != $expected ]]; then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     expected ${(qqq)expected}, got ${(qqq)interaction_buffer}"
    case_failed=1
  fi

  if [[ $interaction_output == *__MENU__* ]]; then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     a menu was displayed for a unique match"
    case_failed=1
  fi

  if (( case_failed )); then
    (( ++failed ))
  else
    print -r -- "OK - $name"
    (( ++passed ))
  fi
}

insertion_case() {
  local name=$1 input=$2 expected=$3

  run_interaction $input 1
  if [[ $interaction_buffer != $expected ]]; then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     expected ${(qqq)expected}, got ${(qqq)interaction_buffer}"
    (( ++failed ))
  else
    print -r -- "OK - $name"
    (( ++passed ))
  fi
}

prefix_then_menu_case() {
  local name=$1 input=$2 prefix=$3 selected=$4
  local case_failed=0 actual_prefix actual_selected

  run_interaction $input 1
  actual_prefix=$interaction_buffer
  [[ $actual_prefix == $prefix ]] || case_failed=1
  run_interaction $input 2
  actual_selected=$interaction_buffer
  [[ $actual_selected == $selected ]] || case_failed=1

  if (( case_failed )); then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     expected prefix ${(qqq)prefix} then ${(qqq)selected}"
    print -u2 -r -- "     got ${(qqq)actual_prefix} then ${(qqq)actual_selected}"
    (( ++failed ))
  else
    print -r -- "OK - $name"
    (( ++passed ))
  fi
}

prefix_candidates_case() {
  local name=$1 input=$2 prefix=$3
  local candidate
  local -A before after
  local -i i case_failed=0

  run_interaction $input 1
  [[ $interaction_buffer == $prefix ]] || case_failed=1
  for (( i = 2; i <= 4; ++i )); do
    run_interaction $input $i
    before[$interaction_buffer]=1
    run_interaction $prefix $i
    after[$interaction_buffer]=1
  done
  for candidate in 'ls CaseMix.one ' 'ls CaseMix.two ' 'ls caseMix.three '; do
    [[ -n ${before[$candidate]-} && -n ${after[$candidate]-} ]] || case_failed=1
  done
  (( $#before == 3 && $#after == 3 )) || case_failed=1
  if (( case_failed )); then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     prefix: ${(qqq)interaction_buffer}; before: ${(k)before}; after: ${(k)after}"
    (( ++failed ))
  else
    print -r -- "OK - $name"
    (( ++passed ))
  fi
}

# === Testcase definition ===

# fixture files and directories
mkdir -p \
  $fixture/test1/foo \
  $fixture/test123 \
  $fixture/boo/bar \
  $fixture/foo/bar \
  $fixture/run/amulet/watch \
  $fixture/run/media/fuwa \
  $fixture/run/motd.d \
  $fixture/at
touch \
  $fixture/Cargo.toml \
  $fixture/CaseMix.one \
  $fixture/CaseMix.two \
  $fixture/caseMix.three \
  $fixture/toolchain.toml \
  $fixture/flake.lock \
  $fixture/flake.nix \
  $fixture/test1/bar \
  $fixture/test123/bar \
  $fixture/test123/foobarbaz \
  $fixture/foo/bar/baz \
  $fixture/foo/bar.rs \
  $fixture/run/motd.d/86-fwupd

touch \
  "$fixture/space name" \
  "$fixture/quote'file" \
  "$fixture/dollar\$file" \
  "$fixture/bracket(file"

# --- Basic matching and candidate selection ---
# Verify exact/prefix/fuzzy priority within each component and leaf completion.

unique_case 'fuzzy path without a slash' \
  'ls Ctoml' 'ls Cargo.toml '
unique_case 'space in filename' \
  'ls space' 'ls space\ name '
unique_case 'single quote in filename' \
  'ls quote' "ls quote\\'file "
unique_case 'dollar sign in filename' \
  'ls dollar' 'ls dollar\$file '
unique_case 'parenthesis in filename' \
  'ls bracket' 'ls bracket\(file '
unique_case 'home-relative space in filename' \
  'ls ~/space' 'ls ~/space\ name '
unique_case 'home-relative quote in filename' \
  'ls ~/quote' "ls ~/quote\\'file "
unique_case 'home-relative dollar sign in filename' \
  'ls ~/dollar' 'ls ~/dollar\$file '
unique_case 'home-relative parenthesis in filename' \
  'ls ~/bracket' 'ls ~/bracket\(file '
prefix_then_menu_case 'common prefix precedes menu selection' \
  'ls fl' 'ls flake.' 'ls flake.lock '
prefix_then_menu_case 'mixed case prefix retains matches' \
  'ls cas' 'ls casemix.' 'ls CaseMix.one '
insertion_case 'mixed case names extend a short prefix' \
  'ls c' 'ls ca'
prefix_then_menu_case 'upper-case prefix remains case-sensitive' \
  'ls CaseM' 'ls CaseMix.' 'ls CaseMix.one '
prefix_candidates_case 'mixed case candidate set' 'ls cas' 'ls casemix.'
unique_case 'completion continues after common prefix' \
  'ls flake.n' 'ls flake.nix '
insertion_case 'fuzzy matches do not insert a common prefix' \
  'ls ctoml' 'ls ctoml'

menu_case 'exact and prefix leaf matches are both kept' 'ls f/bar' \
  'bar/'   'ls foo/bar/' \
  'bar.rs' 'ls foo/bar.rs '

menu_case 'normal path' 'ls t/f' \
  'foo/'       'ls test1/foo/' \
  'foobarbaz'  'ls test123/foobarbaz ' \
  'test1/'     'ls test1/f' \
  'test123/'   'ls test123/f'

menu_case 'fuzzy path' 'ls t/r' \
  'bar' 'ls test1/bar ' \
  'bar' 'ls test123/bar ' \
  'foobarbaz' 'ls test123/foobarbaz ' \
  'test1/' 'ls test1/r' \
  'test123/' 'ls test123/r'

menu_case 'missing leaf keeps prefix matches' 'ls t/q' \
  'test1/'   'ls test1/q' \
  'test123/' 'ls test123/q'

menu_case 'fuzzy leaf filters deep paths' 'ls t/z' \
  'foobarbaz' 'ls test123/foobarbaz ' \
  'test1/' 'ls test1/z' \
  'test123/' 'ls test123/z'

menu_case 'fuzzy parent' 'ls o/b' \
  'bar/' 'ls boo/bar/' \
  'bar/' 'ls foo/bar/' \
  'bar.rs' 'ls foo/bar.rs ' \
  'boo/' 'ls boo/b' \
  'foo/' 'ls foo/b'

menu_case 'multiple fuzzy leaves defer insertion' 'ls test123/a' \
  'bar'       'ls test123/bar ' \
  'foobarbaz' 'ls test123/foobarbaz '

unique_case 'glob suffix remains unquoted' \
  'ls f/*' 'ls foo/*'
unique_case 'fuzzy leaf completes in exact directory' \
  'ls test1/br' 'ls test1/bar '
unique_case 'parent-relative path completes' \
  'ls ../fixture/test1/br' 'ls ../fixture/test1/bar '

# --- Candidate-source integration ---
# Ensure carapace and native Zsh candidates share the same menu without duplication.

menu_case 'carapace and zsh candidates are not duplicated' 'mockcmd ' \
  'boo/' 'mockcmd boo/' \
  'foo/' 'mockcmd foo/'

menu_case 'carapace flag layout' 'mockcmd --' \
  '--alpha  -a  first flag' 'mockcmd --alpha ' \
  '--beta   -b  second flag' 'mockcmd --beta '

# --- Manual pages without a man-db index ---
unique_case 'manual names take priority over matching local paths' 'man t' 'man tmux'
unique_case 'explicit manual section takes priority over local paths' \
  'man 1 t' 'man 1 tmux '
unique_case 'manual names hide sections before a dot' 'man pro' 'man probe'
menu_case 'manual sections appear after a dot' 'man probe.' \
  'probe.1' 'man probe.1 ' \
  'probe.5' 'man probe.5 '
unique_case 'manual macro name hides its section before a dot' 'man ma' 'man man'
unique_case 'section-qualified manual name completes after a dot' \
  'man man.' 'man man.7 '
menu_case 'dotted page names and qualified names share one group' 'man systemd.' \
  'systemd.1' 'man systemd.1 ' \
  'systemd.service' 'man systemd.service'
unique_case 'dot within a page name does not expose its sections' \
  'man systemd.s' 'man systemd.service'
unique_case 'manual name completion continues directly into its section' \
  $'man tmu\t.' 'man tmux.1 '
unique_case 'dotted page name supports a section after another dot' \
  'man systemd.service.' 'man systemd.service.5 '
unique_case 'partial section narrows qualified names' \
  'man probe.5' 'man probe.5 '
unique_case 'manual names in an explicit section' 'man 5 pro' 'man 5 probe '
unique_case 'manual names do not leak from other sections' 'man 7 ma' 'man 7 man '
unique_case 'manual section option still works' 'man -s 5 pro' 'man -s 5 probe '
unique_case 'manual options still work' 'man --sec' 'man --sections='
menu_case 'manual sections have descriptions' 'man ' \
  '1  -- general commands' 'man 1 ' \
  '5  -- file formats and conventions' 'man 5 ' \
  '7  -- miscellanea' 'man 7 '

# --- Multi-component traversal and candidate order ---
# Prefer deeply resolved paths, then retain the former one-component expansion.

menu_case 'single fuzzy directory expands' 'ls 3/b' \
  'bar' 'ls test123/bar ' \
  'test123/' 'ls test123/b'
menu_case 'multi-component path completes' 'ls f/b/b' \
  'baz' 'ls foo/bar/baz ' \
  'foo/' 'ls foo/b/b'
menu_case 'prefix leaf excludes fuzzy matches in sibling branches' 'ls r/m/f' \
  'fuwa/' 'ls run/media/fuwa/' \
  'run/' 'ls run/m/f'
menu_case 'fuzzy leaf does not restore a discarded fuzzy parent' 'ls r/m/wa' \
  'fuwa/' 'ls run/media/fuwa/' \
  'run/' 'ls run/m/wa'
menu_case 'deep absolute path expands at once' "ls $fixture/r/m/f" \
  'fuwa' "ls $fixture/run/media/fuwa" \
  'run/' "ls $fixture/run/m/f"
menu_case 'deep fuzzy path expands at once' 'ls rn/ei/fw' \
  'fuwa/' 'ls run/media/fuwa/' \
  'run/' 'ls run/ei/fw'

# paths start with tilde
unique_case 'home-relative fuzzy directory' \
  'ls ~/rn' 'ls ~/run/'
menu_case 'home-relative fuzzy path' 'ls ~/rn/ei/fw' \
  'fuwa/' 'ls ~/run/media/fuwa/' \
  'run/' 'ls ~/run/ei/fw'

# --- Unmatched-suffix preservation ---
# Keep unresolved components on the surviving branches without restoring discarded fuzzy branches.

menu_case 'unmatched suffix is kept on prefix branches' 'ls r/m/x' \
  'media/'  'ls run/media/x' \
  'motd.d/' 'ls run/motd.d/x' \
  'run/' 'ls run/m/x'
unique_case 'unmatched multi-component suffix is kept' \
  'ls r/x/y' 'ls run/x/y'

print -r -- "$passed passed, $failed failed"
(( failed == 0 ))
