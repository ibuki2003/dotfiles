for _, val in ipairs({ 'alacritty', 'kitty', 'WezTerm' }) do
  if vim.env.TERM_PROGRAM == val then
    vim.opt.termguicolors = true
    break
  end
end

