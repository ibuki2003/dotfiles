let s:base_dir = expand('~/.nvim')

execute 'set runtimepath+=' . fnamemodify(s:base_dir, ':p')

runtime! local.vim
runtime! secrets.vim
runtime! keymaps.vim
runtime! dein.vim
runtime! basic.vim

syntax on

set helplang=ja,en

