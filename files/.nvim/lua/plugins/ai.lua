return {
  {
    'zbirenbaum/copilot.lua',
    event = { 'InsertEnter' },
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        [""] = false,
        markdown = false,
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    cmd = {
      "CodeCompanion",
      "CodeCompanionCmd",
      "CodeCompanionChat",
      "CodeCompanionActions",
      "CodeCompanionAutoSaveChat",
      "CodeCompanionHistory",
    },
    keys = {
      { "<Space>cc", "<Cmd>CodeCompanionAutoSaveToggle<CR>", mode = { "n" }, }, -- Just show the chat
      { "<Space>ch", "<Cmd>CodeCompanionHistory<CR>", mode = { "n" }, }, -- History
      { "<Space>cc", "<Cmd>CodeCompanionAutoSaveChat<CR>", mode = { "x" }, }, -- start new with visual selection
      { "<Space>ca", "<Cmd>CodeCompanion<CR>", mode = { "n", "x" }, },
      { "<Space>cA", "<Cmd>CodeCompanionActions<CR>", mode = { "n", "x" }, },
    },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
          keymaps = {
            clear = { modes = { n = {} } }, -- undef
          },
        },
        inline = { adapter = "copilot" },
      },
      display = {
        action_palette = { provider = "telescope" },
        chat = {
          auto_scroll = false,

          show_header_separator = true,
          -- show_settings = true, -- NOTE: enabling this blocks adapter/model selection ui
        },
      },

      history = {
        file_path = vim.fn.expand("~/Documents/codecompanion_history"),
      },
    },
    config = function(_, opts)
      require("codecompanion.fidget-spinner"):init()
      require("codecompanion").setup(opts)
      require("settings.codecompanion-save").setup()
    end,
  },
}
