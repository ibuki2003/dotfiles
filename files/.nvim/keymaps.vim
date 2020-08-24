let mapleader = "\<Space>"

" wrapped move
nnoremap j gj
nnoremap k gk

" esc*2 to erase search result
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

" move between split
nnoremap <silent><C-j> :bnext<CR>
nnoremap <silent><C-k> :bprev<CR>

" tabline
nnoremap H :tabprevious<CR>
nnoremap L :tabnext<CR>


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

vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

nnoremap <C-g> ggVG

