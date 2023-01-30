local lspconfig = require('lspconfig')

local diagnostic = require('lspsettings/servers/diagnostic')

require("neodev").setup{}

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
  sumneko_lua = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        }
      }
    }
  },

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
  servers = vim.tbl_deep_extend(servers, conf)
end

for lsp, opt in pairs(servers) do
  opt = vim.tbl_deep_extend('keep', opt, overwrites)
  lspconfig[lsp].setup(opt)
end

do
  local method = "textDocument/publishDiagnostics"
  local default_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, method, result, client_id, bufnr, config)
    default_handler(err, method, result, client_id, bufnr, config)
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

local maps = {
  ['<leader>ld'] = function() peek('definition') end,
  ['<leader>lD'] = function() vim.lsp.buf.definition() end,
  ['<leader>lc'] = function() peek('declaration') end,
  ['<leader>lC'] = function() vim.lsp.buf.declaration() end,
  ['<leader>li'] = function() peek('implementation') end,
  ['<leader>lI'] = function() vim.lsp.buf.implementation() end,

  ['<leader>lr'] = function() vim.lsp.buf.rename() end,
  ['<leader>lR'] = function() vim.lsp.buf.references() end,
  ['<leader>la'] = require('actions-preview').code_actions,

  ['<leader>ll'] = function()
    if vim.diagnostic.open_float() then return end
    if vim.lsp.buf.hover() then return end
  end,
  ['<leader>lL'] = function() vim.lsp.buf.hover() end,
  ['<leader>lh'] = function() vim.lsp.buf.hover() end,
  ['<leader>lg'] = function() vim.diagnostic.open_float() end,
}

for k, v in pairs(maps) do
  vim.keymap.set('n', k, v, {noremap = true, silent = true})
end
