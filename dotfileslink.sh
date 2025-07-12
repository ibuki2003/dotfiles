#!/usr/bin/env zsh

root=$(realpath $(dirname "$0"))

function ln_checked() {
  # check if already linked
  if [[ -L "$2" ]]; then
    if [[ $(readlink "$2") = "$1" ]]; then
      echo "Already linked: ~/$fn"
      return
    else
      echo "Skipping $2, already linked to $(readlink $2)"
      return
    fi
  fi
  ln -vfTns "$1" "$2"
}

function ln_files() {
    if [ ! -e ~/"$1" ]; then
        mkdir -p ~/"$1"
    fi

    for filename in $(find "$root/files/$1" -mindepth 1 -maxdepth 1 | xargs -n1 basename); do
        fn="$1/$filename"
        if [[ $filename = .config ]]; then
            ln_files $filename
        else
            ln_checked "$root/files/$fn" ~/"$fn"
        fi
    done
}

ln_files .

mkdir -p ~/.local/share/albert/python
ln_checked $root/etc/albert_plugins ~/.local/share/albert/python/plugins
