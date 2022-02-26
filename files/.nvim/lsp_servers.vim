function! RegisterDiagnosticLsp()
lua << EOF
local config = require('lspsettings/servers/diagnostic')
vim.fn['lsp#register_server'](config)
    vim.fn['lsp#register_server'](require('lspsettings/servers/diagnostic'))
EOF
endfunction
autocmd User lsp_setup call RegisterDiagnosticLsp()
