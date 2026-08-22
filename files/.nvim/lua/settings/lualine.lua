local function im_state()
  if vim.fn.exists('*IMStatus') then
    return vim.fn.IMStatus("JP")
  end
  return ""
end

local function progress() -- builtin source shows 'Top'/'Bot', that is annoying
  local cur = vim.fn.line('.')
  local total = vim.fn.line('$')
  return string.format('%2d%%%%', math.floor(cur / total * 100))
end

-- idea from https://mikoto2000.blogspot.com/2026/05/vim.html
local function char_code_label()
  local char = vim.fn.matchstr(vim.fn.getline('.'), '\\%' .. vim.fn.col('.') .. 'c.')
  if char == '' then
    return '------'
  end
  return string.format('U+%04X', vim.fn.char2nr(char))
end

local function lsp_names()
  local clients = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if client.name ~= 'null-ls' then
      table.insert(clients, client.name)
    end
  end
  return table.concat(clients, ', ')
end

require('lualine').setup {
  options = {
    icons_enabled = false,
    -- HACK: speedup
    theme = require('lualine.themes.palenight'),
    section_separators = { left = '', right = '' },
    component_separators = { left = '|', right = '|' },
  },

  sections = {
    lualine_a = { 'mode', '&paste' },
    lualine_b = {
      'branch',
      {
        'filename',
        path = 1, -- relative path
        shorting_target = 40,
        symbols = {
          modified = '+',
          readonly = '-',
          unnamed = '[No Name]'
        },
      },
    },
    lualine_c = {
      {
        'diagnostics',
        sources = {'nvim_diagnostic'},
        sections = { 'error', 'warn', 'info', 'hint' },
      },
    },


    lualine_x = { im_state, char_code_label, 'fileformat', 'encoding', 'filetype', lsp_names },
    lualine_y = { progress },
    lualine_z = { '%3l:%-2v%<' },
  },
  inactive = {
    lualine_a = { 'filename', '%M' },
    lualine_z = { 'location' },
  },
}
