vim.g.sandwich_no_default_key_mappings = 1
vim.g['sandwich#input_fallback'] = 0
vim.fn['operator#sandwich#set']('delete', 'all', 'hi_duration', 50)

local recipes = {
  {
    buns = {"(\\s*", "\\s*)"},
    nesting = 1,
    regex = 1,
    match_syntax = 1,
    kind = {"delete", "replace", "textobj"},
    action = {"delete"},
    input = {"("},
  },
}

for _, k in ipairs({ {'{','}'}, {'[',']'} }) do
  local opr = vim.fn.escape(k[1], '[')

  table.insert(recipes, {
      buns = { k[1] .. " ", " " .. k[2] },
      nesting = 1,
      match_syntax = 1,
      motionwise = { 'char', 'block' }, -- only not line
      action = { "add", "replace" },
      input = { k[1] }
    })

  table.insert(recipes, {
      buns = { opr .. "\\s*", "\\s*" .. k[2] },
      nesting = 1,
      regex = 1,
      match_syntax = 1,
      action = { "delete" },
      input = { k[1] }
    })
end
vim.list_extend(recipes, {
  -- Type param Type<>
  { buns = { 'input("typename: ") . "<"', '">"' }, action = { 'add', 'replace' }, expr = 1, input = { 'g' }},
  { buns = {
    [[\%([^A-Za-z0-9:]\|^\)\@<=[A-Za-z0-9:]\+<]],
    [[>]],
  }, regex = 1, nesting = 1, action = { "delete" }, input = { 'g' }, },

  -- math
  { buns = { '$', '$' }, action = { "add", "replace", "delete" }, input = { 'm', '$' } },
})

vim.g['sandwich#recipes'] = vim.list_extend(vim.g['sandwich#default_recipes'], recipes)
