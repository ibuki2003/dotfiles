require("lspsettings/servers")
require("lspsettings/nls")

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = false,
  virtual_text = {
    format = function(d)
      return string.format("%s (%s: %s)", d.message, d.source, d.code)
    end,
  },
})

vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_inlayhints",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("lsp-inlayhints").on_attach(client, bufnr)
  end,
})

-- lspsaga
require("lspsaga").setup({
  ui = { icons = false },
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

vim.api.nvim_create_user_command("LspFormat", function(arg)
  vim.pretty_print(arg)
  local range = nil
  if arg.range > 0 then
    range = {
      ['start'] = {arg.line1, 0},
      ['end'] = {arg.line2 + 1, 0},
    }
  end
  vim.lsp.buf.format({ name = arg.fargs[1], range = range })
end, { nargs = '?', range = '%' })
