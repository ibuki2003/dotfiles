syntax on

" setting
"文字コードをUFT-8に設定
set fenc=utf-8
set enc=utf-8
set nobackup
set noswapfile
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd

set virtualedit=block
set backspace=indent,eol,start
set ambiwidth=double
set wildmenu

set scrolloff=5

set number
set virtualedit=onemore
set smartindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest

set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>


" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk


set list
set listchars=tab:»-,trail:-,eol:¬,extends:»,precedes:«,nbsp:%
set expandtab
set tabstop=2
set shiftwidth=2

set tabline=%!MakeTabLine()
nnoremap H :<C-u>tabprevious<CR>
nnoremap L :<C-u>tabnext<CR>

noremap <C-j> <Cmd>bnext<CR>
noremap <C-k> <Cmd>bprev<CR>

set helplang=ja,en
