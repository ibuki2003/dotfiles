vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/packer/opt/impatient.nvim')
local ok, impatient = pcall(require, 'impatient')
if ok then
  impatient.enable_profile()
else
  vim.notify(impatient, vim.log.levels.ERROR)
end

require'options'
require'plugins'

-- vim.cmd[[colorscheme dracula]]
