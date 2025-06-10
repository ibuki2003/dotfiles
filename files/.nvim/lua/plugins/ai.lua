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
      { "<Space>cc", ":CodeCompanionChat Toggle<CR>", mode = { "n" }, }, -- Just show the chat
      { "<Space>cc", ":CodeCompanionChat Add<CR>", mode = { "x" }, }, -- Add selection to chat
      { "<Space>cC", ":CodeCompanionChat<CR>", mode = { "n", "x" }, }, -- Start new chat
      { "<Space>ca", ":CodeCompanion<CR>", mode = { "n", "x" }, },
      { "<Space>cA", ":CodeCompanionActions<CR>", mode = { "n", "x" }, },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "openai",
          keymaps = {
            clear = { modes = { n = {} } }, -- undef
          },
        },
        inline = { adapter = "openai" },
      },
      display = {
        action_palette = { provider = "telescope" },
        chat = {
          auto_scroll = false,

          show_header_separator = true,
          -- show_settings = true, -- NOTE: enabling this blocks adapter/model selection ui
        },
      },
      adapters = {
        opts = {
          show_defaults = false,
          show_model_choices = true,
        },
        copilot = 'copilot',
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            schema = {
              model = {
                default = "gpt-4.1-mini",
                -- HACK: replace the table, not merge
                choices = function() return {
                  ["gpt-4.1"] = { opts = { has_vision = true } },
                  ["gpt-4.1-mini"] = { opts = { has_vision = true } },
                  ["gpt-4.1-nano"] = { opts = { has_vision = true } },
                  ["o3"] = { opts = { has_vision = true, can_reason = true } },
                  ["o4-mini"] = { opts = { has_vision = true, can_reason = true } },
                  ["o1"] = { opts = { has_vision = true, can_reason = true } },
                } end,
              },
              reasoning_effort = {
                -- fix condition
                condition = function(self)
                  local model = self.schema.model.default
                  return model:sub(1, 1) == "o"
                end,
              },
            },
            env = { api_key = "cmd:secret-tool lookup service openai" },
          })
        end,
      },
    },
    config = function(_, opts)
      require("settings.codecompanion.spinner"):init()
      require("codecompanion").setup(opts)
    end,
  },
}
