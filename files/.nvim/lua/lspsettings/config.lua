local lspconfig = require('lspconfig')

local diagnostic = require('lspsettings/servers/diagnostic')

local servers = {
  vimls = {},
  intelephense = {},
  clangd = { capabilities = { offsetEncoding = 'utf-8' } },
  pylsp = {},
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

function merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      merge(t1[k], t2[k])
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
function peek(targ)
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/' .. targ, params, preview_location_callback)
end

local function set_keymap(key, command)
  vim.api.nvim_set_keymap('n', key, command, { noremap=true, silent=true })
end

