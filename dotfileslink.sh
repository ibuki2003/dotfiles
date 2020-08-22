#!/bin/sh
find $(realpath $(dirname $0)/files) -mindepth 1 -maxdepth 1 \
    | xargs -I {} ln -vfs {} ~/
ln -fs ~/.nvim/init.vim ~/.config/nvim/init.vim # neovim settings
echo Done.
