local lspconfig = require('lspconfig')

local diagnostic = require('lspsettings/servers/diagnostic')

local servers = {
  vimls = {},
  intelephense = {},
  clangd = { capabilities = { offsetEncoding = 'utf-8' } },
  pylsp = {},
  rls = {},
  rust_analyzer = {},
  eslint = {},
  texlab = {},
  gopls = {},
  arduino_language_server = {},

  tsserver = {
    root_dir = function(fname, buf)
      return lspconfig.util.root_pattern("package.json", "node_modules")(fname, buf)
    end,
  },
  denols = {
    root_dir = function(fname, buf)
      if lspconfig.util.root_pattern("package.json", "node_modules")(fname, buf) ~= nil then
        return nil
      end
      local r = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "tsconfig.json", ".git")(fname, buf)
      if r ~= nil then
        return r
      end
      -- single file support
      return lspconfig.util.path.dirname(fname)
    end,
    single_file_support = false,
  },
  diagnosticls = {
    filetypes = diagnostic.whitelist,
    init_options = diagnostic.initialization_options,
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local overwrites = {
  capabilities = capabilities,
}

local function merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      merge(t1[k], t2[k])
    elseif (type(v) == "function" and type(t1[k] or false) == "function") then
      t1[k] = function(...)
        t1[k](...)
        return v(...)
      end
    else
      t1[k] = v
    end
  end
  return t1
end

for lsp, opt in pairs(servers) do
  opt = merge(opt, overwrites)
  lspconfig[lsp].setup(opt)
end

do
  local method = "textDocument/publishDiagnostics"
  local default_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, method, result, client_id, bufnr, config)
    default_handler(err, method, result, client_id, bufnr, config)
    vim.diagnostic.setloclist({open=false})
    vim.diagnostic.setqflist({open=false})
  end
end

-- keybinds

local function preview_location_callback(_, method, result)
  if result == nil or vim.tbl_isempty(result) then
    vim.lsp.log.info(method, 'No location found')
    return nil
  end
  if vim.tbl_islist(result) then
    vim.lsp.util.preview_location(result[1])
  else
    vim.lsp.util.preview_location(result)
  end
end
local function peek(targ)
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/' .. targ, params, preview_location_callback)
end

vim.keymap.set('n', '<leader>ld', function() peek('definition') end)
vim.keymap.set('n', '<leader>lD', function() vim.lsp.buf.definition() end)
vim.keymap.set('n', '<leader>lc', function() peek('declaration') end)
vim.keymap.set('n', '<leader>lC', function() vim.lsp.buf.declaration() end)
vim.keymap.set('n', '<leader>li', function() peek('implementation') end)
vim.keymap.set('n', '<leader>lI', function() vim.lsp.buf.implementation() end)

vim.keymap.set('n', '<leader>lr', function() vim.lsp.buf.rename() end)
vim.keymap.set('n', '<leader>lR', function() vim.lsp.buf.references() end)
vim.keymap.set('n', '<leader>la', function() vim.lsp.buf.code_action() end)

vim.keymap.set('n', '<leader>ll', function()
  if vim.diagnostic.open_float() then return end
  if vim.lsp.buf.hover() then return end
end)
vim.keymap.set('n', '<leader>lh', function() vim.lsp.buf.hover() end)
vim.keymap.set('n', '<leader>lg', function() vim.diagnostic.open_float() end)
