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
      -- { "<Space>ca", ":CodeCompanion<CR>", mode = { "n", "x" }, },
      { "<Space>ch", ":CodeCompanionHistory<CR>", mode = { "n" }, },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "ravitemer/codecompanion-history.nvim",
      "franco-ruggeri/codecompanion-spinner.nvim",
    },
    init = function()
      vim.cmd[[cab cc CodeCompanion]]
    end,
    opts = function()
      local function make_openai_adapter(model, opts)
        return function()
          return require("codecompanion.adapters").extend("openai_responses", {
            schema = {
              model = {
                default = model,
                choices = { model },
              },
              ["reasoning.effort"] = {
                default = (opts and opts.effort) or "medium",
                enabled = function() return model:sub(1, 1) == "o" or model:sub(1, 5) == "gpt-5" end,
              },
            },
            env = { api_key = "cmd:secret-tool lookup service openai" },
          })
        end
      end
      return {
        interactions = {
          chat = {
            adapter = "gpt5mini",
            keymaps = {
              clear = { modes = { n = {} } }, -- undef
            },
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
          },
          inline = {
            adapter = "gpt5mini",
          },
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

            -- NOTE: must consist with alphanumeric and underscore only
            ["gpt4_1mini"] = make_openai_adapter("gpt-4.1-mini"),
            ["gpt5mini"] = make_openai_adapter("gpt-5-mini"),
            ["gpt5_1"] = make_openai_adapter("gpt-5.1"),
            ["gpt5_1_low"] = make_openai_adapter("gpt-5.1", { effort = "low" }),
            ["o3"] = make_openai_adapter("o3"),

          },
        },
        extensions = {
          history = {
            enabled = true,
            opts = {
              auto_generate_title = false,
            },
          },
          spinner = {},
        },
      }
    end,
    config = function(_, opts)
      require("codecompanion").setup(opts)
    end,
  },
}
