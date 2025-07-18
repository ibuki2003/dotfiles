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
    init = function()
      vim.cmd[[cab cc CodeCompanion]]
    end,
    opts = function()
      local function make_openai_adapter(model)
        return function()
          return require("codecompanion.adapters").extend("openai", {
            schema = {
              model = {
                default = model,
                choices = { model },
              },
              reasoning_effort = {
                condition = function(self)
                  return self.schema.model.default:sub(1, 1) == "o"
                end,
              },
            },
            env = { api_key = "cmd:secret-tool lookup service openai" },
          })
        end
      end
      return {
        opts = {
          language= "user's", -- NOTE: Hacky way to set the language to user's
        },
        strategies = {
          chat = {
            adapter = "gpt-4.1-mini",
            keymaps = {
              clear = { modes = { n = {} } }, -- undef
            },
          },
          inline = { adapter = "gpt-4.1-mini" },
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
          -- openai = {},

          ["gpt-4.1"] = make_openai_adapter("gpt-4.1"),
          ["gpt-4.1-mini"] = make_openai_adapter("gpt-4.1-mini"),
          ["gpt-4.1-nano"] = make_openai_adapter("gpt-4.1-nano"),
          ["o3"] = make_openai_adapter("o3"),
          ["o4-mini"] = make_openai_adapter("o4-mini"),
        },
      }
    end,
    config = function(_, opts)
      require("settings.codecompanion.spinner"):init()
      require("codecompanion").setup(opts)
    end,
  },
}
