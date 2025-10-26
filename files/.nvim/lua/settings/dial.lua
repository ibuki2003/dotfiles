local augend = require("dial.augend")
augend.constant.alias.alpha.config.cyclic = true
augend.constant.alias.Alpha.config.cyclic = true

local augends = require("dial.config").augends
augends.group.default = {
  augend.integer.alias.decimal,
  augend.integer.alias.binary,
  augend.integer.alias.hex,
  augend.misc.alias.markdown_header,
  augend.date.alias['%Y-%m-%d'],
  augend.date.alias['%Y/%m/%d'],
  augend.hexcolor.new{ case = "lower", }, -- TODO: preserve case
  augend.constant.new{
    elements = {"true", "false"},
    word = true,
    cyclic = true,
    preserve_case = true,
  },
}
augends.group.visual = {}
vim.list_extend(augends.group.visual, augends.group.default)
vim.list_extend(augends.group.visual, {
  augend.constant.alias.alpha,
  augend.constant.alias.Alpha,
})

vim.keymap.set('n',  '<C-a>', "<Plug>(dial-increment)", { remap = true })
vim.keymap.set('n',  '<C-x>', "<Plug>(dial-decrement)", { remap = true })
vim.keymap.set('x',  '<C-a>', "<Plug>(dial-increment)", { remap = true })
vim.keymap.set('x',  '<C-x>', "<Plug>(dial-decrement)", { remap = true })
vim.keymap.set('n', 'g<C-a>', "<Plug>(dial-g-increment)", { remap = true })
vim.keymap.set('n', 'g<C-x>', "<Plug>(dial-g-decrement)", { remap = true })
vim.keymap.set('x', 'g<C-a>', "<Plug>(dial-g-increment)", { remap = true })
vim.keymap.set('x', 'g<C-x>', "<Plug>(dial-g-decrement)", { remap = true })
