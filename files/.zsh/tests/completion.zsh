#!/usr/bin/env zsh

setopt errexit nounset pipefail

zmodload zsh/zpty

typeset -gr root=${0:A:h:h}
typeset -gr tmpdir=$(mktemp -d)
typeset -gr fixture=$tmpdir/fixture
typeset -gr setup=$tmpdir/setup.zsh
typeset -gr result=$tmpdir/result
typeset -gr pty=completion-test

cleanup() {
  zpty -d $pty 2>/dev/null || true
  rm -rf -- $tmpdir
}
trap cleanup EXIT INT TERM

mkdir -p $fixture

cat >$setup <<'EOF'
fpath=($COMPLETION_TEST_ROOT/functions $fpath)
ZDOTDIR=$COMPLETION_TEST_TMP/zdot
XDG_CACHE_HOME=$COMPLETION_TEST_TMP/cache
LS_COLORS='di=01;34:fi=0'
mkdir -p $ZDOTDIR $XDG_CACHE_HOME

source $COMPLETION_TEST_ROOT/functions/_mycompleter
source $COMPLETION_TEST_ROOT/opts/50-completion.zsh
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

cd $COMPLETION_TEST_FIXTURE
EOF

export COMPLETION_TEST_ROOT=$root
export COMPLETION_TEST_TMP=$tmpdir
export COMPLETION_TEST_FIXTURE=$fixture
export COMPLETION_TEST_RESULT=$result

zpty $pty env TERM=xterm-256color zsh -df
zpty -w $pty "source ${(q)setup}"
zpty -w $pty 'print -r -- __READY__'
typeset output
zpty -r -m $pty output '*__READY__*'

typeset -gi passed=0 failed=0 case_index=0
typeset -g interaction_buffer interaction_output

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
  for (( i = 1; i <= $#buffers; ++i )); do
    run_interaction $input $i
    (( i == 1 )) && first_output=$interaction_output
    if [[ $interaction_buffer != $buffers[i] ]]; then
      print -u2 -r -- "NG - $name item $i:"
      print -u2 -r -- "     expected ${(qqq)buffers[i]}, got ${(qqq)interaction_buffer}"
      case_failed=1
    fi
  done

  run_interaction $input $(( $#buffers + 1 ))
  if [[ $interaction_buffer != $buffers[1] ]]; then
    print -u2 -r -- "NG - $name wrap:"
    print -u2 -r -- "     expected ${(qqq)buffers[1]}, got ${(qqq)interaction_buffer}"
    case_failed=1
  fi

  normalized=$(normalize_output $first_output)
  if [[ $normalized != *__MENU__* ]]; then
    print -u2 -r -- "NG - $name:"
    print -u2 -r -- "     menu was not displayed"
    case_failed=1
  else
    menu_text=${normalized#*__MENU__}
    tail=${${(f)menu_text}[1]}
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

# === Testcase definition ===

# fixture files and directories
mkdir -p \
  $fixture/test1/foo \
  $fixture/test123 \
  $fixture/boo/bar \
  $fixture/foo/bar \
  $fixture/at
touch \
  $fixture/test1/bar \
  $fixture/test123/bar \
  $fixture/test123/foobarbaz \
  $fixture/foo/bar/baz

# Press tab after the input, then check that the menu is displayed with the expected items (display string, buffer string)

menu_case 'normal path' 'ls t/f' \
  'test1/'   'ls test1/f' \
  'test123/' 'ls test123/f'

menu_case 'fuzzy path' 'ls t/r' \
  'test1/'   'ls test1/r' \
  'test123/' 'ls test123/r'

menu_case 'missing leaf keeps prefix matches' 'ls t/q' \
  'test1/'   'ls test1/q' \
  'test123/' 'ls test123/q'

menu_case 'missing leaf does not filter directories' 'ls t/z' \
  'test1/'   'ls test1/z' \
  'test123/' 'ls test123/z'

menu_case 'fuzzy parent' 'ls o/b' \
  'boo/' 'ls boo/b' \
  'foo/' 'ls foo/b'

# The match is expected to be unique, so no menu should be displayed, and the buffer should be updated to the expected value

unique_case 'single fuzzy directory expands' \
  'ls 3/b' 'ls test123/b'
unique_case 'fuzzy leaf completes in exact directory' \
  'ls test1/br' 'ls test1/bar '
unique_case 'multi-component path completes' \
  'ls f/b/b' 'ls foo/bar/baz '

print -r -- "$passed passed, $failed failed"
(( failed == 0 ))
