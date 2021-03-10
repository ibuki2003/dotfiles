local linters = {}
local linter_filetypes = {}

local formatters = {}
local formatter_filetypes = {}

local whitelist_map = {}

function register_linter(name, filetypes, config)
  linters[name] = config
  for i = 1, #filetypes do
    linter_filetypes[filetypes[i]] = name
    whitelist_map[filetypes[i]] = true
  end
end

function register_formatter(name, filetypes, config)
  formatters[name] = config
  for i = 1, #filetypes do
    formatter_filetypes[filetypes[i]] = name
    whitelist_map[filetypes[i]] = true
  end
end

require('lsp_servers/diagnostic/eslint')
require('lsp_servers/diagnostic/phpcs')

local whitelist = {}
for key, val in pairs(whitelist_map) do
    table.insert(whitelist, key)
end
vim.fn['lsp#register_server']({
    name = 'diagnostic-languageserver',
    cmd = (function(info) return { 'diagnostic-languageserver', '--stdio' } end),
    whitelist = whitelist,
    initialization_options = {
      linters = linters,
      filetypes = linter_filetypes,
      formatters = formatters,
      formatFiletypes = formatter_filetypes,
    }
  })
