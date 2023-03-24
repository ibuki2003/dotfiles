local lspconfig = require('lspconfig')

local diagnostic = require('lspsettings/servers/diagnostic')

require("neodev").setup{}

local servers = {
  vimls = {},
  intelephense = {},
  clangd = { capabilities = { offsetEncoding = 'utf-8' } },
  pylsp = {
    settings = {
      pylsp = {
        plugins = { pycodestyle = { enabled = false } }
      }
    }
  },
  pyright = {},
  rust_analyzer = {},
  eslint = {},
  texlab = {},
  gopls = {},
  arduino_language_server = {},
  lua_ls = {
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
    single_file_support = false,
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

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = false,
  virtual_text = {
    format = function(d)
      return string.format("%s (%s: %s)", d.message, d.source, d.code)
    end,
  },
})

-- lspsaga
require("lspsaga").setup({
  border_style = "single",
  finder = {
    max_height = 0.5,
  },
  definition = {
    edit = "o",
  },
  symbol_in_winbar = { enable = false, },
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
  ['<leader>le'] = "<cmd>Lspsaga show_line_diagnostics<CR>",

  [']e'] = "<cmd>Lspsaga diagnostic_jump_next<CR>",
  ['[e'] = "<cmd>Lspsaga diagnostic_jump_prev<CR>",
}

for k, v in pairs(maps) do
  vim.keymap.set('n', k, v, {noremap = true, silent = true})
end
