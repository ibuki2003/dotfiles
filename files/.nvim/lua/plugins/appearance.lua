return {
  {
    'dracula/vim',
    name = 'dracula',
    lazy = true,
    priority = 10000, -- load before others
    init = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = 'dracula',
        callback = function()
          vim.cmd[[
          hi! LineNr ctermbg=238 guibg=#424450
          hi CursorLineNr ctermbg=238 guibg=#424450 gui=NONE
          hi clear CursorLine
          ]]
        end
      })
    end,
  },
  {
    'alexmozaidze/palenight.nvim',
    lazy = false, -- use default
    priority = 10000,
    config = function()
      require('palenight').setup({ italic = true })
      vim.cmd[[colorscheme palenight]]
    end,
  },
  {
    'navarasu/onedark.nvim',
    priority = 10000, -- load before others
    lazy = true,
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function() require'settings.lualine' end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require"ibl".setup {
        indent = {
          -- highlight = {'WinSeparator'},
          char = "",
        },
        whitespace = {
          highlight = {
            'Whitespace',
            'CursorLine',
          },
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      }
    end,
  },
  'bronson/vim-trailing-whitespace',
  {
    'machakann/vim-highlightedyank',
    init = function()
      vim.g.highlightedyank_highlight_duration = 300
    end
  },
  {
    'luukvbaal/statuscol.nvim',
    opts = function()
      local builtin = require('statuscol.builtin')
      return {
        segments = {
          { sign = { namespace = { 'gitsigns.*' }, maxwidth = 1, colwidth = 1, wrap = true } },
          { sign = { namespace = { '.*' }, name = { '.*' }, maxwidth = 1, colwidth = 1 } }, -- fallback
          { text = {
            '%C', -- fold
            builtin.lnumfunc,
            ' ',
          } },
        },
        setopt = true,
      }
    end,
  },
}
