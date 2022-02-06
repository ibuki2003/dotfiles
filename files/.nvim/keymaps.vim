let mapleader = "\<Space>"

" wrapped move
nnoremap <silent> j gj
nnoremap <silent> k gk

vnoremap <silent> j gj
vnoremap <silent> k gk

" esc*2 to erase search result
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

" move between split
nnoremap <silent><C-j> :bnext<CR>
nnoremap <silent><C-k> :bprev<CR>

" tabline
nnoremap <silent> H :tabprevious<CR>
nnoremap <silent> L :tabnext<CR>

" block indent
vnoremap < <gv
vnoremap > >gv

"" completion
"function! InsertTabWrapper()
"    let col = col('.') - 1
"    if !col || getline('.')[col - 1] !~ '\k'
"        return "\<tab>"
"    else
"        return "\<c-p>"
"    endif
"endfunction
"inoremap <expr> <tab> InsertTabWrapper()
"inoremap <s-tab> <c-n>


nnoremap q: :q

nmap <silent> <Leader>y "+y
nmap <silent> <Leader>d "+d
vmap <silent> <Leader>y "+y
vmap <silent> <Leader>d "+d

nmap <silent> <Leader>p "+p
nmap <silent> <Leader>P "+P
vmap <silent> <Leader>p "+p
vmap <silent> <Leader>P "+P

nnoremap <C-g> ggVG

noremap <expr> 0 getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'

noremap x "_x

" terminal escape
tnoremap <Esc><Esc> <C-\><C-n>
