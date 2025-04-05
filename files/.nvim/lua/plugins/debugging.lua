return {
  {
    'mfussenegger/nvim-dap',
    cmd = {
      'DapNew',
      'DapContinue',
      'DapToggleBreakpoint',

      'DapuiOpen',
    },
    config = function()
      require 'settings.dap'
    end,

    dependencies = {
      {
        'rcarriga/nvim-dap-ui',
        dependencies = {"nvim-neotest/nvim-nio"},
        opts = {},
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },
    },
  },
}
