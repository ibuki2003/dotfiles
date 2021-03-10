function! RegisterDiagnosticLsp()
lua << EOF
    require('lsp_servers/diagnostic')
EOF
endfunction
autocmd User lsp_setup call RegisterDiagnosticLsp()
