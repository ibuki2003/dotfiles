-- highlight ideographic space
vim.api.nvim_create_augroup("invisible", {})
vim.api.nvim_create_autocmd({"BufNew", "BufRead"}, {
  pattern = "*",
  group = "invisible",
  callback = function()
    vim.cmd[[
      syntax match InvisibleJISX0208Space "　" display containedin=ALL
      highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
    ]]
  end,
})

vim.api.nvim_create_augroup("Mkdir", {})
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = "*",
  group = "Mkdir",
  callback = function()
    vim.fn.mkdir(vim.fn.expand("<afile>:p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd({"QuickFixCmdPost"}, {
  pattern = "*grep*",
  callback = function()
    vim.cmd("cwindow")
  end,
})

vim.api.nvim_create_autocmd({"BufReadPost"}, {
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"") >= 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd("normal! g`\"")
    end
  end,
})
