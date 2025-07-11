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
    },
    config = function()
      require"settings.telescope"
    end,
  },

}
