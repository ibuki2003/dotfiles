-- servers

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.lsp.enable({
  'efm',

  'vimls',
  'intelephense',
  'clangd',
  'pylsp',
  -- 'pylyzer',
  'pyright',
  'eslint',
  'texlab',
  'gopls',
  'arduino_language_server',
  'lua_ls',
  'astro',
  'volar',
  'emmet_ls',
  'kotlin_language_server',
  'typst_lsp',
  'tinymist',

  'nil_ls',
  'verible',

  'ocamllsp',
})

local float_opts = {
  border = "rounded",
  focusable = false,
}

vim.diagnostic.config({
  update_in_insert = false,
  virtual_text = {
    format = function(d)
      return string.format("%s (%s: %s)", d.message, d.source, d.code)
    end,
  },
})

-- enable inlay hints by default
vim.lsp.inlay_hint.enable(true, nil)

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = true,
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

  ['<leader>ll'] = function() vim.lsp.buf.hover(float_opts) end,

  ['<leader>le'] = function() vim.diagnostic.open_float(vim.tbl_extend("force", float_opts, {
    bufnr = 0,
    scope = "line",
  })) end,
  ['<leader>lE'] = function() vim.diagnostic.open_float(vim.tbl_extend("force", float_opts, {
    bufnr = 0,
    scope = "line",
    format = format_diagnostics_hover,
  })) end,

  ['<leader>lh'] = function()
    vim.lsp.inlay_hint.enable(
      not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }),
      { bufnr = 0 }
    )
  end,

  [']e'] = function() vim.diagnostic.jump({ count = 1 ,wrap = true, float = float_opts }) end,
  ['[e'] = function() vim.diagnostic.jump({ count = -1 ,wrap = true, float = float_opts }) end,
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
