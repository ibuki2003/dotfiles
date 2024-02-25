require("settings/lsp/servers")
require("settings/lsp/nls")

local float_opts = {
  border = "rounded",
  focusable = false,
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = false,
  virtual_text = {
    format = function(d)
      return string.format("%s (%s: %s)", d.message, d.source, d.code)
    end,
  },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, float_opts)

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

-- keybinds

local function format_diagnostics_hover(diag)
  if diag.user_data.lsp and diag.user_data.lsp.data and diag.user_data.lsp.data.rendered then
    return diag.user_data.lsp.data.rendered
  end
  return diag.message
end

local maps = {
  ['<leader>ld'] = function() vim.lsp.buf.definition() end,
  ['<leader>lt'] = function() vim.lsp.buf.type_definition() end,
  ['<leader>lc'] = function() vim.lsp.buf.declaration() end,
  ['<leader>li'] = function() vim.lsp.buf.implementation() end,
  ['<leader>lr'] = function() vim.lsp.buf.rename() end,
  ['<leader>lR'] = function() vim.lsp.buf.references() end,
  ['<leader>la'] = require('actions-preview').code_actions,

  ['<leader>ll'] = vim.lsp.buf.hover,

  ['<leader>le'] = function() vim.diagnostic.open_float(0, vim.tbl_extend("force", float_opts, { scope = "line", })) end,
  ['<leader>lE'] = function() vim.diagnostic.open_float(0, vim.tbl_extend("force", float_opts, {
    scope = "line",
    format = format_diagnostics_hover,
  })) end,

  [']e'] = function() vim.diagnostic.goto_next({ wrap = true, float = float_opts }) end,
  ['[e'] = function() vim.diagnostic.goto_prev({ wrap = true, float = float_opts }) end,
}

for k, v in pairs(maps) do
  vim.keymap.set('n', k, v, { noremap = true, silent = true })
end

vim.api.nvim_create_user_command("LspFormat", function(arg)
  local range = nil
  if arg.range > 0 then
    range = {
      ['start'] = { arg.line1, 0 },
      ['end'] = { arg.line2 + 1, 0 },
    }
  end
  vim.lsp.buf.format({ name = arg.fargs[1], range = range })
end, { nargs = '?', range = '%' })
