let s:base_dir = expand('~/.nvim')

execute 'set runtimepath+=' . fnamemodify(s:base_dir, ':p')

runtime! local.vim
runtime! secrets.vim
runtime! basic.vim
runtime! keymaps.vim
lua require('dein')
runtime! tabline.vim

syntax on

set helplang=ja,en

