let s:base_dir = expand('~/.nvim')
let s:dein_dir = s:base_dir . '/plugins'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim ' . s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

let g:dein#auto_recache = 1

let s:toml_dir = s:base_dir . '/toml'

" Required:
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " load plgins file

  call dein#load_toml(s:toml_dir . '/general.toml')
  call dein#load_toml(s:toml_dir . '/appearance.toml')

  if has("nvim-0.6")
    call dein#load_toml(s:toml_dir . '/completion.toml')
  endif

  if filereadable(s:toml_dir . '/local.toml')
    call dein#load_toml(s:toml_dir . '/local.toml')
  endif

  call dein#end()
  call dein#save_state()
endif

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

" Required:
filetype plugin indent on
syntax enable

call dein#call_hook('source')
call dein#call_hook('post_source')
