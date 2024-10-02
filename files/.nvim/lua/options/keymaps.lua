
vim.g.mapleader = " "

-- wrapped move
vim.keymap.set({'n','v'}, 'j', 'gj', { silent = true })
vim.keymap.set({'n','v'}, 'k', 'gk', { silent = true })
vim.keymap.set({'n','v'}, 'gj', 'j', { silent = true })
vim.keymap.set({'n','v'}, 'gk', 'k', { silent = true })

vim.keymap.set('n', '<Esc><Esc>', '<Cmd>nohlsearch<CR>')

vim.keymap.set('n', '<C-j>', '<Cmd>bnext<CR>', { silent = true })
vim.keymap.set('n', '<C-k>', '<Cmd>bprev<CR>', { silent = true })

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

vim.keymap.set('n', '<Space>o', function() for _ = 1, vim.v.count1 do vim.fn.append(vim.fn.line('.'), '') end end, { silent = true })
vim.keymap.set('n', '<Space>O', function() for _ = 1, vim.v.count1 do vim.fn.append(vim.fn.line('.')-1, '') end end, { silent = true })

vim.keymap.set({'n','v'}, '<Leader>y', '"+y', { silent = true })
vim.keymap.set({'n','v'}, '<Leader>d', '"+d', { silent = true })
vim.keymap.set({'n','v'}, '<Leader>p', '"+p', { silent = true })
vim.keymap.set({'n','v'}, '<Leader>P', '"+P', { silent = true })

vim.keymap.set('n', '<C-g>', 'ggVG')

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

vim.keymap.set('n', 'x', '"_x')
vim.keymap.set('n', 'X', '"_X')

vim.keymap.set({'o', 'x'}, 'i<space>', 'iW')
vim.keymap.set('n', 'M', '%')

-- https://blog.atusy.net/2024/09/06/linewise-zf/
vim.keymap.set('n', 'zf', 'zfV')
vim.keymap.set('v', 'zf', function() return vim.fn.mode() == 'V' and 'zf' or 'Vzf' end, { expr = true })

vim.keymap.set('n', 'i', function() if vim.fn.getline('.') == '' then return '"_cc' else return 'i' end end, { expr = true })
vim.keymap.set('n', 'A', function() if vim.fn.getline('.') == '' then return '"_cc' else return 'A' end end, { expr = true })

vim.keymap.set('n', '/', '/\\v')
vim.keymap.set('n', '?', '/\\V')

-- terminal escape
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')


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

vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    vim.ui.open(cfile)
  else
    vim.cmd("normal! gF")
  end
end)

-- https://blog.atusy.net/2024/05/29/vim-hl-enhanced/
vim.keymap.set('n', 'H', 'H<Plug>(H)')
vim.keymap.set('n', 'L', 'L<Plug>(L)')
vim.keymap.set('n', '<Plug>(H)H', '<C-u>H<Plug>(H)')
vim.keymap.set('n', '<Plug>(L)L', '<C-d>Lzb<Plug>(L)')
vim.keymap.set('n', '<Plug>(H)', '<Nop>')
vim.keymap.set('n', '<Plug>(L)', '<Nop>')
