vim.api.nvim_create_autocmd('BufWritePre', {
  buffer = 0,  -- Current buffer
  group = vim.api.nvim_create_augroup('rust_format', { clear = true }),
  callback = function()
    if vim.bo.filetype ~= 'rust' then
      return
    end
    print(1)
    -- Format Rust files before saving
    vim.lsp.buf.format({ async = false })
  end,
})
