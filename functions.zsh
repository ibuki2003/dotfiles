#! /bin/zsh

function gpp () {
    g++ "$1" -o "${1%.*}" -std=c++1y -O2 -DLOCAL
}

alias 2to3='python "/c/Program Files/Python36/Tools/scripts/2to3.py"'
