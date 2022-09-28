set fenc=utf-8
set enc=utf-8

set nobackup
set noswapfile
set autoread
set hidden
set showcmd

set virtualedit=block,onemore
set backspace=indent,eol,start
set ambiwidth=double
set wildmenu

set scrolloff=5

set autoindent " not smartindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest,full

set formatoptions-=ro
au FileType * setlocal formatoptions-=ro

set completeopt-=preview " deoplete float window

set matchpairs+=「:」,『:』,（:）,【:】,《:》,〈:〉,［:］,‘:’,“:”

set cinkeys-=0#

" search
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch

" filename completion
set wildignorecase

" appearance
set list
set listchars=tab:»-,trail:-,eol:¬,extends:»,precedes:«,nbsp:%
set expandtab
set tabstop=2
set shiftwidth=2
set number
set signcolumn=yes

set noshowmode " lightline shows this

set inccommand=nosplit " incremental substitution

set ambiwidth=double

set showtabline=1
set guioptions-=e

" if has("clipboard")
"     set clipboard=unnamedplus
" endif

" 全角スペース・行末のスペース・タブの可視化
if has("syntax")
    syntax on

    " PODバグ対策
    syn sync fromstart

    function! ActivateInvisibleIndicator()
        " 下の行の"　"は全角スペース
        syntax match InvisibleJISX0208Space "　" display containedin=ALL
        highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
        "syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
        "highlight InvisibleTrailedSpace term=underline ctermbg=Red guibg=NONE gui=undercurl guisp=darkorange
        "syntax match InvisibleTab "\t" display containedin=ALL
        "highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    endfunction

    augroup invisible
        autocmd! invisible
        autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    augroup END
endif

augroup Mkdir
    autocmd!
    autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END

if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
autocmd QuickFixCmdPost *grep* cwindow

autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$")
    \ |   exe "normal! g`\""
    \ | endif
