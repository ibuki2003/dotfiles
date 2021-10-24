#!/bin/zsh

root=$(realpath $(dirname "$0"))/files

function ln_files() {
    if [ ! -e ~/"$1" ]; then
        mkdir -p ~/"$1"
    fi

    for filename in $(find "$root/$1" -mindepth 1 -maxdepth 1 | xargs -n1 basename); do
        fn="$1/$filename"
        case $filename in
            .config)
                ln_files $filename
                ;;
            *)
                ln -vfTns "$root/$fn" ~/"$fn"
                ;;
        esac
    done
}

ln_files .
