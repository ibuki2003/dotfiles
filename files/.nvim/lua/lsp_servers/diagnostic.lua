local linters = {}
local linter_filetypes = {}

local formatters = {}
local formatter_filetypes = {}

local whitelist_map = {}

local function append_key(tbl, key, val)
  if tbl[key]  == nil or tbl[key] ~= "table" then
    tbl[key] = {val}
  else
    table.insert(tbl[key], val)
  end
end

local function register_linter(name, filetypes, config)
  linters[name] = config
  for i = 1, #filetypes do
    append_key(linter_filetypes, filetypes[i], name)
    -- linter_filetypes[filetypes[i]] = name
    whitelist_map[filetypes[i]] = true
  end
end

local function register_formatter(name, filetypes, config)
  formatters[name] = config
  for i = 1, #filetypes do
    append_key(formatter_filetypes, filetypes[i], name)
    -- formatter_filetypes[filetypes[i]] = name
    whitelist_map[filetypes[i]] = true
  end
end

require('lsp_servers/diagnostic/eslint')(register_linter, register_formatter)
require('lsp_servers/diagnostic/phpcs')(register_linter, register_formatter)

local whitelist = {}
for key, val in pairs(whitelist_map) do
    table.insert(whitelist, key)
end

return {
  name = 'diagnostic-languageserver',
  cmd = { 'diagnostic-languageserver', '--stdio' },
  whitelist = whitelist,
  initialization_options = {
    linters = linters,
    filetypes = linter_filetypes,
    formatters = formatters,
    formatFiletypes = formatter_filetypes,
  }
}
