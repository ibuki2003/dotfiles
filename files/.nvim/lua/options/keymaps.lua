
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


-- https://zenn.dev/vim_jp/articles/20230814_ekiden_fullpath
-- <C-p> to insert full-path cwd

local punct_ptn = vim.regex([[\k]])
local function expandpath()
  local pos = vim.fn.mode() == 'c' and vim.fn.getcmdpos() or vim.fn.col('.')
  local line = vim.fn.mode() == 'c' and vim.fn.getcmdline() or vim.fn.getline('.')
  local left = line:sub(pos - 1, pos - 1)

  if left == '/' then
    return vim.fn.expand('%:p:t')
  elseif not punct_ptn:match_str(left) then
    return vim.fn.expand('%:p:h') .. '/'
  end
end
vim.keymap.set({'c','i'}, '<C-p>', expandpath, { noremap = true, expr = true })
