local augend = require("dial.augend")
augend.constant.alias.alpha.config.cyclic = true
augend.constant.alias.Alpha.config.cyclic = true

local augends = require("dial.config").augends
augends.group.default = {
  augend.integer.alias.decimal,
  augend.integer.alias.binary,
  augend.integer.alias.hex,
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

local manip = require("dial.map").manipulate
vim.keymap.set('n',  '<C-a>', function() manip("increment", "normal") end)
vim.keymap.set('n',  '<C-x>', function() manip("decrement", "normal") end)
vim.keymap.set('x',  '<C-a>', function() manip("increment", "visual", "visual"); vim.fn.feedkeys('gv', 'n') end)
vim.keymap.set('x',  '<C-x>', function() manip("decrement", "visual", "visual"); vim.fn.feedkeys('gv', 'n') end)
vim.keymap.set('n', 'g<C-a>', function() manip("increment", "gnormal") end)
vim.keymap.set('n', 'g<C-x>', function() manip("decrement", "gnormal") end)
vim.keymap.set('x', 'g<C-a>', function() manip("increment", "gvisual", "visual") end)
vim.keymap.set('x', 'g<C-x>', function() manip("decrement", "gvisual", "visual") end)
