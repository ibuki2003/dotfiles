return {
  {
    'hrsh7th/nvim-cmp',
    lazy = true,
    event = { 'InsertEnter' },
    config = function()
      require"settings.cmp"
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-buffer',
      'https://codeberg.org/FelipeLema/cmp-async-path',
      {
        "zbirenbaum/copilot-cmp",
        config = function ()
          require("copilot_cmp").setup()
        end
      },
      {
        'zjp-CN/nvim-cmp-lsp-rs',
        opts = {
          kind = function(k)
            return { k.Module, k.Function }
          end,
        },
      },
      'octaltree/cmp-look',
    }
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile', 'InsertEnter', 'FileType' },
    dependencies = {
      {
        'ray-x/lsp_signature.nvim',
        event = "VeryLazy",
        opts = {
          hint_enable = false,
        },
      },
    },
    config = function()
      require('settings/lsp/config')
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    'creativenull/efmls-configs-nvim',
  },
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
    'hrsh7th/vim-vsnip',
    event = { 'InsertEnter' },
    config = function()
      vim.cmd[[
      imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
      smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
     ]]
    end
  },
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
    'CopilotC-Nvim/CopilotChat.nvim',
    lazy = true,
    build = "make tiktoken",
    opts = {
      selection = function(source)
        -- return nil if no selection
        return require('CopilotChat.select').visual(source)
      end,
      chat_autocomplete = false,
    },
    keys = {
      { "<space>cc", function() require('CopilotChat').toggle() end },
      {
        "<space>ca",
        function()
          require("CopilotChat.integrations.telescope").pick(require("CopilotChat.actions").prompt_actions())
        end,
        mode = { "n", "x" },
      },
    },
    cmd = {
      -- NOTE: I won't use other available commands
      "CopilotChat",
      "CopilotChatAgents",
      "CopilotChatModels",
      "CopilotChatToggle",
      "CopilotChatReset",
      "CopilotChatDebugInfo",
      "CopilotChatSave",
      "CopilotChatLoad",
    },
  },
  {
    'aznhe21/actions-preview.nvim',
    keys = {
      { "<Leader>la", function() require('actions-preview').code_actions() end },
    },
  },
}
