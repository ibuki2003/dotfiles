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
  vim.lsp.handlers[method] = function(err, method_, result, client_id, bufnr, config)
    default_handler(err, method_, result, client_id, bufnr, config)
    vim.diagnostic.setqflist({open=false})
  end
end

-- lspsaga
require("lspsaga").setup({
  border_style = "single",
  finder = {
    max_height = 0.5,
  },
  definition = {
    edit = "o",
  },
  symbol_in_winbar = {
    enable = true,
    separator = " / ",
  },
  lightbulb = { enable = false },
})

-- keybinds

local maps = {
  ['<leader>ld'] = "<cmd>Lspsaga lsp_finder<CR>",
  ['<leader>lD'] = "<cmd>Lspsaga peek_definition<CR>",
  ['<leader>lt'] = "<cmd>Lspsaga peek_type_definition<CR>",

  ['<leader>lr'] = function() vim.lsp.buf.rename() end,
  ['<leader>la'] = require('actions-preview').code_actions,

  ['<leader>ll'] = "<cmd>Lspsaga hover_doc<CR>",
  ['<leader>le'] = "<cmd>Lspsaga show_cursor_diagnostics<CR>",

  [']e'] = "<cmd>Lspsaga diagnostic_jump_next<CR>",
  ['[e'] = "<cmd>Lspsaga diagnostic_jump_prev<CR>",
}

for k, v in pairs(maps) do
  vim.keymap.set('n', k, v, {noremap = true, silent = true})
end
