let s:base_dir = expand('~/.nvim')

execute 'set runtimepath+=' . fnamemodify(s:base_dir, ':p')

runtime! local.vim
runtime! secrets.vim
runtime! dein.vim
runtime! basic.vim
runtime! keymaps.vim

syntax on

set helplang=ja,en

