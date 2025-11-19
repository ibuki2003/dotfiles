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
        typst = false,
      },
    },
  },
  {
    'Xuyuanp/nes.nvim',
    keys = {
        {
            '<A-i>',
            function()
                require('nes').get_suggestion()
            end,
            mode = 'i',
            desc = '[Nes] get suggestion',
        },
        {
            '<A-n>',
            function()
                require('nes').apply_suggestion(0, { jump = true, trigger = true })
            end,
            mode = 'i',
            desc = '[Nes] apply suggestion',
        },
    },
    opts = {},
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
          -- language= "user's", -- NOTE: Hacky way to set the language to user's
          system_prompt = function()
            local p = [[
              You are a helpful AI assistant.
              You can answer questions, provide explanations, and assist with coding tasks.
              Answer in language the user is using.
            ]]
            -- trim indentation
            p = p:gsub("\n%s+", "\n"):gsub("^%s+", ""):gsub("%s+$", "")
            return p
          end,
        },
        strategies = {
          chat = {
            adapter = "gpt-5-mini",
            keymaps = {
              clear = { modes = { n = {} } }, -- undef
            },
          },
          inline = { adapter = "gpt-5-mini" },
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
          http = {
            opts = {
              show_defaults = false,
              show_model_choices = true,
            },
            copilot = 'copilot',
            -- openai = {},

            ["gpt-4.1"] = make_openai_adapter("gpt-4.1"),
            ["gpt-4.1-mini"] = make_openai_adapter("gpt-4.1-mini"),
            ["gpt-4.1-nano"] = make_openai_adapter("gpt-4.1-nano"),
            ["gpt-5"] = make_openai_adapter("gpt-5"),
            ["gpt-5-mini"] = make_openai_adapter("gpt-5-mini"),
            ["gpt-5-nano"] = make_openai_adapter("gpt-5-nano"),
            ["o3"] = make_openai_adapter("o3"),
            ["o4-mini"] = make_openai_adapter("o4-mini"),
          },
        },
      }
    end,
    config = function(_, opts)
      require("settings.codecompanion.spinner"):init()
      require("codecompanion").setup(opts)
    end,
  },
}
