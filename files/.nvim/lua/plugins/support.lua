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
        matchup = {
          enable = true,
        },
        auto_install = false,
      }
    end
  },
  {
    'andymass/vim-matchup',
    event = { 'CursorMoved', 'CursorMovedI' },
    init = function()
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",
      }
      -- TODO: use appropriate event
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          -- workaround: disable if not supported
          if not vim.b.match_words then
            vim.b.matchup_matchparen_enabled = 0
          else
            vim.b.matchup_matchparen_enabled = 1
          end
        end,
      })
    end,
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
    'mattn/emmet-vim',
    keys = { { '<C-z>', mode = 'i' } },
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
