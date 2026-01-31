
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

vim.keymap.set('n', '*', '*``')
vim.keymap.set('n', '#', '#``')

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

-- line-wise fold command

-- グローバルにして operatorfunc から参照できるようにする
function _G.FoldLinewise(type)
  local s, e
  local visual = false
  if type == 'v' or type == 'V' or type == '\022' then  -- '\022' = <C-v>
    visual = true
    s = vim.fn.getpos(".")[2]
    e = vim.fn.getpos("v")[2]
  else
    s = vim.fn.getpos("'[")[2]
    e = vim.fn.getpos("']")[2]
  end
  if s > e then s, e = e, s end
  vim.cmd(string.format('%d,%dfold', s, e))

  if visual then
    -- quit visual mode
    vim.api.nvim_feedkeys('\27', 'n', true)
  end
end
vim.keymap.set('n', 'zf', function()
  vim.o.operatorfunc = 'v:lua.FoldLinewise'
  return 'g@'
end, { expr = true, silent = true })
vim.keymap.set('x', 'zf', function()
  _G.FoldLinewise(vim.fn.mode())
end, { silent = true })


vim.keymap.set('n', 'i', function() if vim.fn.getline('.') == '' then return '"_cc' else return 'i' end end, { expr = true })
vim.keymap.set('n', 'A', function() if vim.fn.getline('.') == '' then return '"_cc' else return 'A' end end, { expr = true })


-- terminal escape
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')


-- https://zenn.dev/vim_jp/articles/20230814_ekiden_fullpath
-- <C-p> to insert path

local punct_ptn = vim.regex([[\k]])
local function expandpath()
  local pos = vim.fn.mode() == 'c' and vim.fn.getcmdpos() or vim.fn.col('.')
  local line = vim.fn.mode() == 'c' and vim.fn.getcmdline() or vim.fn.getline('.')
  local left = line:sub(pos - 1, pos - 1)

  if left == '/' then
    return vim.fn.expand('%:t')
  elseif not punct_ptn:match_str(left) then
    return vim.fn.expand('%:h') .. '/'
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

vim.keymap.set("n", "<Leader>q", "<cmd>copen<CR>")

-- https://blog.atusy.net/2024/05/29/vim-hl-enhanced/
vim.keymap.set('n', 'H', 'H<Plug>(H)')
vim.keymap.set('n', 'L', 'L<Plug>(L)')
vim.keymap.set('n', '<Plug>(H)H', '<C-u>H<Plug>(H)')
vim.keymap.set('n', '<Plug>(L)L', '<C-d>Lzb<Plug>(L)')
vim.keymap.set('n', '<Plug>(H)', '<Nop>')
vim.keymap.set('n', '<Plug>(L)', '<Nop>')


-- inspired by magic.vim

local cmdline_search_regex = vim.regex([[\%\(g\%[lobal]!?\|v\%[global]\|sort\? *[a-z]*\|s\%[ubstitute]\) *\/\zs\%\([^\\/]\|\\.\)\+\ze\%\(\/\|$\)]])
--- @param replacer fun(old: string): string?
local function search_transform(replacer)
  -- `/` `?` `:`
  local ty = vim.fn.getcmdtype()
  if ty == ':' then
    local cmdline = vim.fn.getcmdline()
    -- print(vim.inspect(cmdline))
    local s, e = cmdline_search_regex:match_str(cmdline)
    print(vim.inspect({s, e}))
    if s then
      local old = cmdline:sub(s + 1, e)
      local new = replacer(old)
      if new then
        local new_cmdline = cmdline:sub(1, s) .. new .. cmdline:sub(e + 1)
        vim.fn.setcmdline(new_cmdline)
      end
    end
  elseif ty == '/' or ty == '?' then
    local old = vim.fn.getcmdline()
    local new = replacer(old)
    if new then
      vim.fn.setcmdline(new)
    end
  end
end

--- @param prefixes string[]
local function rotate_mode_fun(prefixes)
  --- @param old string
  return function(old)
    for i, p in ipairs(prefixes) do
      local pos = old:find(p, 1, true)
      if pos then
        local next_p = (i < #prefixes) and prefixes[i + 1] or ''
        return old:sub(1, pos - 1) .. next_p .. old:sub(pos + #p)
      end
    end
    -- not found, add first
    return prefixes[1] .. old
  end
end

-- magic
vim.keymap.set('c', '<C-v>', function()
  search_transform(rotate_mode_fun({'\\v', '\\V'}))
end)

-- case
vim.keymap.set('c', '<C-c>', function()
  search_transform(rotate_mode_fun({'\\c', '\\C'}))
end)

-- whole word
vim.keymap.set('c', '<C-w>', function()
  search_transform(function (old)
    -- toggle \< \>
    -- if old contains \< or \>
    if old:find('\\<', 1, true) or old:find('\\>', 1, true) then
      local new = old:gsub('\\<', ''):gsub('\\>', '')
      return new
    else
      return '\\<' .. old .. '\\>'
    end
  end)
end)
