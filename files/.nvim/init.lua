vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/packer/opt/impatient.nvim')
local ok, impatient = pcall(require, 'impatient')
if ok then
  impatient.enable_profile()
else
  vim.notify(impatient, vim.log.levels.ERROR)
end

local _, _ = pcall(require, 'settings.local')

-- require'settings.local'
require'settings.opts'
require'settings.keymaps'
require'settings.term'
require'plugins'

-- vim.cmd[[colorscheme dracula]]
