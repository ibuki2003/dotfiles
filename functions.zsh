#! /bin/zsh

function gpp () {
    g++ "$1" -o "${1%.*}.exe" -std=c++1y -O2
}

alias 2to3='python "/c/Program Files/Python36/Tools/scripts/2to3.py"'
