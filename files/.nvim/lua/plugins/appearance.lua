return {
  {
    'dracula/vim',
    name = 'dracula',
    lazy = true,
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
    priority = 10000,
    init = function() vim.cmd[[colorscheme palenight]] end,
    opts = {
      italic = true,
    },
  },
  {
    'navarasu/onedark.nvim',
    lazy = true,
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function() require'settings.lualine' end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    -- event = { "UIEnter" },
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
}
