function! RegisterDiagnosticLsp()
lua << EOF
local config = require('lsp_servers/diagnostic')
vim.fn['lsp#register_server'](config)
    vim.fn['lsp#register_server'](require('lsp_servers/diagnostic'))
EOF
endfunction
autocmd User lsp_setup call RegisterDiagnosticLsp()
