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
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter'.setup {}

      -- https://blog.atusy.net/2025/08/10/nvim-treesitter-main-branch/
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
        callback = function(_)
          -- 必要に応じて`ctx.match`に入っているファイルタイプの値に応じて挙動を制御
          -- `pcall`でエラーを無視することでパーサーやクエリがあるか気にしなくてすむ
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end
  },
  {
    'andymass/vim-matchup',
    enabled = true,
    lazy = false,
    init = function()
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",
      }
      vim.g.matchup_matchparen_enabled = 1

      -- Disable in markdown files due to performance issues
      -- And... markdown files usually don't need such feature
      -- https://github.com/andymass/vim-matchup/issues/416
      vim.g.matchup_treesitter_disabled = { "markdown" }

      -- vim.g.matchup_treesitter_enable_quotes = true
      -- vim.g.matchup_treesitter_disable_virtual_text = true
      -- vim.g.matchup_treesitter_include_match_words = true
    end,
    --@type matchup.Config
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
