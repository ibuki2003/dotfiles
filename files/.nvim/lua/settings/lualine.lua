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
    theme = 'auto',
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
        sources = {'nvim_lsp'},
        sections = { 'error', 'warn', 'info', 'hint' },
      },
    },


    lualine_x = { im_state, 'fileformat', 'encoding', 'filetype', lsp_names },
    lualine_y = { progress },
    lualine_z = { '%3l:%-2v%<' },
  },
  inactive = {
    lualine_a = { 'filename', '%M' },
    lualine_z = { 'location' },
  },
}
