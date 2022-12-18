let s:base_dir = expand('~/.nvim')

execute 'set runtimepath+=' . fnamemodify(s:base_dir, ':p')

runtime! local.vim
runtime! secrets.vim
runtime! keymaps.vim
runtime! basic.vim
lua require'plugins'

syntax on

set helplang=ja,en

