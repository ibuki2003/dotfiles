let s:base_dir = expand('~/.nvim')

execute 'set runtimepath+=' . fnamemodify(s:base_dir, ':p')

runtime! secrets.vim
runtime! basic.vim
runtime! keymaps.vim
runtime! dein.vim
runtime! tabline.vim


syntax on

set helplang=ja,en

