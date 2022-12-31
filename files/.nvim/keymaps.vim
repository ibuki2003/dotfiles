let mapleader = "\<Space>"

" wrapped move
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> gj j
nnoremap <silent> gk k

vnoremap <silent> j gj
vnoremap <silent> k gk
vnoremap <silent> gj j
vnoremap <silent> gk k

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

" <TAB>: completion.
inoremap <silent><expr> <Tab>
      \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
      \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ? '<TAB>' :
      \ ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>
      \ pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' :
      \ vsnip#jumpable(-1) ? '\<Plug>(vsnip-jump-prev)' :
      \ "\<C-d>"


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
