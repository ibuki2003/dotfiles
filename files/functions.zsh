#! /bin/zsh

function gpp () {
    g++ "$1" -o "${1%.*}" -std=c++1y -O2 -DLOCAL
}

