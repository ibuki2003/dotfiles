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
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'yioneko/nvim-yati',
    },
    config = function()
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
        indent = {
          enable = false,
        },
        yati = {
          enable = true,
          default_lazy = true,
          default_fallback = "cindent",
        },
        matchup = {
          enable = true,
        },
      }
    end
  },
  {
    'andymass/vim-matchup',
    event = { 'CursorMoved', 'CursorMovedI' },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
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
    'mattn/emmet-vim',
    keys = { '<C-z>' },
    init = function()
      vim.g.user_emmet_leader_key = '<C-z>'
    end,
  },
  {
    'whatyouhide/vim-textobj-xmlattr',
    keys = {
      { 'ix', mode = 'o' },
      { 'ax', mode = 'o' },
    },
    dependencies = { 'kana/vim-textobj-user' },
  },
}
