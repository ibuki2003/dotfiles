let s:base_dir = expand('~/.nvim')
let s:dein_dir = s:base_dir . '/plugins'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

runtime! dein_github_token.vim

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

let s:toml_dir = s:base_dir . '/toml'

" Required:
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " load plgins file

  call dein#load_toml(s:toml_dir . '/general.toml',      {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/general_lazy.toml', {'lazy': 1})
  call dein#load_toml(s:toml_dir . '/nerdtree.toml',     {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/appearance.toml',   {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/completion.toml',   {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/search.toml',          {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/git.toml',          {'lazy': 0})

  if !has('nvim')
      call dein#add('roxma/nvim/yarp')
      call dein#add('roxma/vim-hug-neovim-rpc')
  endif
  call dein#end()
  call dein#save_state()
endif

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif
call dein#recache_runtimepath()

" Required:
filetype plugin indent on
syntax enable

