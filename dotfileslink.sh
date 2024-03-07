#!/bin/zsh

root=$(realpath $(dirname "$0"))

function ln_files() {
    if [ ! -e ~/"$1" ]; then
        mkdir -p ~/"$1"
    fi

    for filename in $(find "$root/files/$1" -mindepth 1 -maxdepth 1 | xargs -n1 basename); do
        fn="$1/$filename"
        case $filename in
            .config)
                ln_files $filename
                ;;
            *)
                ln -vfTns "$root/files/$fn" ~/"$fn"
                ;;
        esac
    done
}

ln_files .

mkdir -p ~/.local/share/albert/python
ln -vfTns $root/etc/albert_plugins ~/.local/share/albert/python/plugins
