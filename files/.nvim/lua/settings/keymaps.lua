
vim.g.mapleader = " "

-- wrapped move
vim.keymap.set({'n','v'}, 'j', 'gj', { noremap = true, silent = true })
vim.keymap.set({'n','v'}, 'k', 'gk', { noremap = true, silent = true })
vim.keymap.set({'n','v'}, 'gj', 'j', { noremap = true, silent = true })
vim.keymap.set({'n','v'}, 'gk', 'k', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':nohlsearch\n', { noremap = true })

-- move between split
vim.api.nvim_set_keymap('n', '<C-j>', ':bnext<CR>', { noremap = true, silent = true })
-- nnoremap <silent><C-k> :bprev<CR>
vim.api.nvim_set_keymap('n', '<C-k>', ':bprev<CR>', { noremap = true, silent = true })

-- block indent
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true })

vim.keymap.set('n', '<Space>o', function()
  for _ = 1, vim.v.count1 do
    vim.fn.append(vim.fn.line('.'), '')
  end
end, { noremap = true, silent = true})

vim.keymap.set('n', '<Space>O', function()
  for _ = 1, vim.v.count1 do
    vim.fn.append(vim.fn.line('.')-1, '')
  end
end, { noremap = true, silent = true})

-- <TAB>: completion.
vim.keymap.set('i', '<Tab>', function()
  local _, c = unpack(vim.api.nvim_win_get_cursor(0))

  if vim.fn['pum#visible']()  then
    return vim.api.nvim_replace_termcodes('<Cmd>', true, false, true) .. 'call pum#map#insert_relative(+1)\n'
  elseif c < 1 or vim.fn.getline('.'):sub(c - 1, c):match('^%s+$') ~= nil then
    return '\t'
  else
    return vim.fn['ddc#map#manual_complete']()
  end
end,
{ noremap = true, expr = true, replace_keycodes = false, })

-- <S-TAB>: completion back.
vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn['pum#visible']() then
    -- vim.fn['pum#map#insert_relative'](-1)
    return '<Cmd>call pum#map#insert_relative(-1)<CR>'
  elseif vim.fn['vsnip#jumpable'](-1) == 1 then
    return '<Plug>(vsnip-jump-prev)'
  else
    return '<C-d>'
  end
end,
{
  noremap = true,
  expr = true,
  replace_keycodes = true,
})

vim.api.nvim_set_keymap('i', '<C-e>', '', {
  noremap = true,
  expr = true,
  callback = function()
    vim.fn['pum#map#cancel']()
    return ''
  end,
})

vim.keymap.set({'n','v'}, '<Leader>y', '"+y', { noremap = true, silent = true })
vim.keymap.set({'n','v'}, '<Leader>d', '"+d', { noremap = true, silent = true })
vim.keymap.set({'n','v'}, '<Leader>p', '"+p', { noremap = true, silent = true })
vim.keymap.set({'n','v'}, '<Leader>P', '"+P', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-g>', 'ggVG', { noremap = true })

vim.api.nvim_set_keymap('n', '0', '', {
  noremap = true,
  expr = true,
  replace_keycodes = true,
  callback = function()
    local _, c = unpack(vim.api.nvim_win_get_cursor(0))
    if vim.fn.getline('.'):sub(1, c):match('^%s+$') then
      return '0'
    else
      return '^'
    end
  end,
})

vim.api.nvim_set_keymap('n', 'x', '"_x', { noremap = true })
vim.api.nvim_set_keymap('n', 'X', '"_X', { noremap = true })

-- terminal escape
vim.api.nvim_set_keymap('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true })
