return {
  {
    'Wansmer/treesj',
    keys = { '<space>m', '<space>j', '<space>s' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup{
        use_default_keymaps = true,
        max_join_length = 65536, -- almost unlimited
      }
    end,
  },
  {
    'yioneko/nvim-yati',
    lazy = true,
    event = { 'CursorMoved', 'CursorMovedI' },
    config = function() vim.cmd[[TSEnable yati]] end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
        indent = {
          enable = false,
        },
        yati = {
          -- HACK: disable at startup and enable later to speed up
          enable = false,
          default_lazy = true,
          default_fallback = "cindent",
        },
        auto_install = false,
      }
    end
  },
  {
    'andymass/vim-matchup',
    lazy = false,
    init = function()
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",
      }
      vim.g.matchup_matchparen_enabled = 1
    end,
    opts = {
      treesitter = { stopline = 500, },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'CursorMoved' },
    config = function()
      require'treesitter-context'.setup{
        enable = true,
        max_lines = 3,
        min_window_height = 15,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = 'outer',
        mode = 'topline',
        zindex = 20,
      }
    end,
  },
  {
    'whatyouhide/vim-textobj-xmlattr',
    dependencies = { 'kana/vim-textobj-user' },
  },
  {
    'sgur/vim-textobj-parameter',
    dependencies = { 'kana/vim-textobj-user' },
  },
  {
    'atusy/treemonkey.nvim',
    keys = {
      { 'm',
        function()
          require("treemonkey").select({
            ignore_injections = false,
            highlight = { backdrop = "Comment" },
          })
        end,
        mode = {'x', 'o'},
      },
      { 'M',
        function()
          require("treemonkey").select {
            action = require("treemonkey.actions").jump,
            steps = 1,
            highlight = { backdrop = "Comment" },
          }
        end,
        mode = {'n', 'x', 'o'},
      },
    },
  },
}
