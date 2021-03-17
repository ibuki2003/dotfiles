
local lspconfig = require('lspconfig')

local on_attach = function (client, bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local servers = {
  -- "vimls",
  "tsserver",
  "intelephense",
  "clangd",
  "pyls",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup { on_attach = on_attach }
end

local diagnosticls_configs = require('lsp_servers/diagnostic')
lspconfig.diagnosticls.setup{
  filetypes = diagnosticls_configs.whitelist,
  init_options = diagnosticls_configs.init_options,
  on_attach = on_attach,
}
