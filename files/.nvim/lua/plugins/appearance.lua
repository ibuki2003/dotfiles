return function(packer)
  packer.use{
    {
      'tomasr/molokai',
      opt = true,
      config = function()
        vim.api.nvim_create_autocmd('ColorScheme', {
            pattern = 'molokai',
            callback = function()
              vim.cmd[[
              hi Comment ctermfg=102 guifg=#878787
              hi Visual ctermbg=240 guibg=#585858
              hi MatchParen cterm=bold ctermfg=208 ctermbg=233 gui=bold guifg=#FD971F guibg=#000000
              hi Pmenu ctermbg=237 ctermfg=4 guibg=#3a3a3a guifg=#00ffff
              ]]
            end
          })
      end
    },
    {
      'dracula/vim',
      as = 'dracula',
      opt=false,
      config = function()
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
        vim.cmd'colorscheme dracula'
      end,
    },
    {
      'ishan9299/nvim-solarized-lua',
      opt = true,
    },
    {
      'cocopon/iceberg.vim',
      setup = function()
        vim.api.nvim_create_autocmd('ColorScheme', {
          pattern ='iceberg',
          callback = function()
            vim.cmd[[
            hi Visual ctermbg=237
            hi NonText ctermfg=240
            ]]
          end
        })
      end
    },
    'navarasu/onedark.nvim',
    {
      'nvim-lualine/lualine.nvim',
      -- after = {'dracula'},
      config = function() require'settings.lualine' end
    },
    {
      'nathanaelkane/vim-indent-guides',
      setup = function()
        vim.g.indent_guides_enable_on_vim_startup = 1
        vim.g.indent_guides_auto_colors = 0
        vim.g.indent_guides_default_mapping = 0
        vim.api.nvim_create_autocmd('ColorScheme', {
          pattern = '*',
          callback = function()
            vim.cmd[[
            hi IndentGuidesOdd guibg=NONE
            hi link IndentGuidesEven WinSeparator
            ]]
          end,
        })
      end
    },
    'bronson/vim-trailing-whitespace',
  }
end
