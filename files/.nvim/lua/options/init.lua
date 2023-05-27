local ok, msg = pcall(require, 'options.local')
if not ok and not string.match(msg, "module 'options.local' not found") then
  vim.notify(msg, vim.log.levels.ERROR)
end

require'options.opts'
require'options.keymaps'
require'options.misc'
require'options.term'
