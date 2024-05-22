return {
  {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require'cmp'

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local selectBehavior = cmp.SelectBehavior.Select

      cmp.setup ({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        confirmation = {
          default_behavior = cmp.ConfirmBehavior.Insert,
          get_commit_characters = function(c)
            return vim.list_extend({
              ";", ",", ":", ".", "(", ")", "{", "}", "[", "]", "<", ">", "/", "\\", "|", "=", "-", "+", "*", "&", "%", "#", "@", "!", "?",
              " ",
            }, c)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              -- confirm
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              -- and then insert a newline
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<CR>", true, true, true),
                "n", true)
            else
              fallback()
            end
          end, {"i", "s"}),
          ['<Esc>'] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<Esc>", true, true, true),
                "n", true)
            else
              fallback()
            end
          end, {"i", "s"}),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = selectBehavior })
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item({ behavior = selectBehavior })
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'calc' },
          { name = 'async_path' },
          {
            name = 'copilot',
            options = { fix_pairs = false, },
          },
          { name = 'vsnip' },
          { name = 'buffer' },
        }),
        comparators = {
          require'copilot_cmp.comparators'.prioritize,
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.kind,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },

        experimental = { ghost_text = true },
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end,
  },
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
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNew', 'BufNewFile', 'InsertEnter' },
    dependencies = {
      'folke/neodev.nvim',
      'uga-rosa/ddc-source-lsp-setup',
    },
    config = function()
      require('settings/lsp/config')
    end,
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
    'lvimuser/lsp-inlayhints.nvim',
    config = function()
      require("lsp-inlayhints").setup()
    end,
  },
  {
    'matsui54/denops-popup-preview.vim',
    dependencies = { 'vim-denops/denops.vim' },
    event = { 'User DenopsReady' },
    config = function()
      vim.fn['popup_preview#enable']()
    end
  },
  {
    'matsui54/denops-signature_help',
    dependencies = { 'vim-denops/denops.vim' },
    event = { 'User DenopsReady' },
    config = function()
      vim.g['signature_help_config'] = {
        viewStyle = "floating",
        multiLabel = true,
      }
      vim.fn['signature_help#enable']()
    end,
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
    'aznhe21/actions-preview.nvim',
    init = function()
      vim.keymap.set("n", "<Leader>la", function() require('actions-preview').code_actions() end)
    end
  },
}
