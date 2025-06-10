-- remove unused keymaps defined in _defaults.lua
local maps = {
  { { "n", "v", "o" }, "gc" },
  { { "n" }, "gcc" },
  { { "n" }, "grn" },
  { { "n", "x" }, "gra" },
  { { "n" }, "grr" },
  { { "n" }, "gri" },
  { { "n" }, "gO" },
  { { "i", "s" }, "<C-S>" },
}

for _, keymap in ipairs(maps) do
  vim.keymap.del(keymap[1], keymap[2])
end

