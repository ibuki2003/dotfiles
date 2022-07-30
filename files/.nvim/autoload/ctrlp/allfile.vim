" Load guard
if ( exists('g:loaded_ctrlp_allfile') && g:loaded_ctrlp_allfile )
	\ || v:version < 700 || &cp
	finish
endif
let g:loaded_ctrlp_allfile = 1

call add(g:ctrlp_ext_vars, {
\ 'init': 'ctrlp#allfile#init()',
\ 'accept': 'ctrlp#acceptfile',
\ 'lname': 'All files',
\ 'sname': 'all',
\ 'type': 'path',
\ 'specinput': 1,
\})

function! ctrlp#allfile#init()
	let cmd = executable('fd')
				\ ? 'fd . %s -t f -HIL'
				\ : 'find %s -type f -follow'
	let cmd = printf(cmd, getcwd())
	return ctrlp#rmbasedir(systemlist(cmd))
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#allfile#id()
	return s:id
endfunction

" vim:nofen:fdl=0:ts=2:sw=2:sts=2
