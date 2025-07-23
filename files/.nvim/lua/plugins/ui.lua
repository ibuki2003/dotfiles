return {
  {
    'j-hui/fidget.nvim',
    opts = {
      progress = {
        ignore = {
          'efm',
          'null-ls',
        },
      }
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    keys = { '<C-p>', '<leader>f' },
    cmd = { 'Telescope' },
    module = 'telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      {
        "danielfalk/smart-open.nvim",
        branch = "0.2.x",
        config = function()
          require("telescope").load_extension("smart_open")
        end,
        dependencies = {
          {
            "kkharji/sqlite.lua",
            init = function()
              local sqlite_path_nix = vim.fn.expand("~/.nix-profile/lib/libsqlite3.so")
              if vim.uv.fs_stat(sqlite_path_nix) then
                vim.g.sqlite_clib_path = sqlite_path_nix
              end
            end,
          },
          -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
          { "nvim-telescope/telescope-fzy-native.nvim" },
        },
      },
    },
    config = function()
      require"settings.telescope"
    end,
  },

}
