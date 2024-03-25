return {
  {
    'Shougo/ddc.vim',
    dependencies = { 'vim-denops/denops.vim' },
    priority = 100,
    config = function()
      vim.fn['ddc#custom#patch_global']('ui', 'pum')

      vim.fn['ddc#custom#patch_global']('sources', {
          'copilot',
          'lsp',
          'around',
          'buffer',
          'file',
          'dictionary',
        })

      vim.fn['ddc#custom#patch_global']('sourceOptions', {
        _ = {
          matchers = { 'matcher_fuzzy' },
          converters = { 'converter_remove_overlap' },
          sorters = { 'sorter_fuzzy' },
          minAutoCompleteLength = 1,
          timeout = 500,
          dup = 'keep',
        },
      })

      vim.fn['ddc#custom#patch_global']('autoCompleteEvents',
        { 'InsertEnter', 'TextChangedI', 'TextChangedP', 'CmdlineChanged' })
      vim.fn['ddc#custom#patch_global']('cmdlineSources', { 'necovim', 'cmdline', 'file', 'around' })
      vim.fn['ddc#custom#patch_global']('sourceOptions', {
        necovim = { ignoreCase = true, },
        cmdline = { ignoreCase = true, },
      })
      vim.api.nvim_set_keymap('c', '<Tab>', '', {
        expr = true,
        noremap = true,
        callback = function()
          if vim.fn['pum#visible']() then
            vim.fn['pum#map#insert_relative'](1)
          else
            return vim.fn['ddc#map#manual_complete']()
          end
        end,
      })
      vim.api.nvim_set_keymap('c', '<S-Tab>', '', { callback = function() vim.fn['pum#map#insert_relative'](-1) end })
      vim.api.nvim_set_keymap('c', '<C-e>',   '', { callback = function() vim.fn['pum#map#cancel']() end })

      vim.api.nvim_create_autocmd('InsertEnter', {
        pattern = '*',
        callback = function()
          -- Start ddc.
          vim.fn['ddc#enable']()
        end,
      })

      vim.api.nvim_set_keymap('n', ':', '', {
        expr = true,
        noremap = true,
        callback = function()
          vim.fn['ddc#enable_cmdline_completion']()
          return ':'
        end,
      })
    end,
  },
  {
    'Shougo/ddc-ui-pum',
    dependencies = {
      {
        'Shougo/pum.vim',
        config = function()
          vim.fn['pum#set_option']({
            scrollbar_char = '█',
            highlight_matches= 'MatchParen',
          })
        end,
      },
    },
  },
  {
    'Shougo/neco-vim',
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { necovim = {
        mark = 'V',
      }})
    end,
  },
  {
    'Shougo/ddc-source-cmdline',
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { cmdline = {
        mark = 'C',
      }})
    end,
  },
  {
    'Shougo/ddc-source-around',
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { around = {
        mark = 'A',
      }})
      vim.fn['ddc#custom#patch_global']('sourceParams', { around = {
        maxSize = 1000,
      }})
    end
  },
  {
    'matsui54/ddc-buffer',
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { buffer = {
        mark = 'B',
      }})
      vim.fn['ddc#custom#patch_global']('sourceParams', { buffer = {
        requireSameFiletype = false,
        limitBytes = 5000000,
        fromAltBuf = true,
        forceCollect = true,
      }})
    end
  },
  {
    'matsui54/ddc-dictionary',
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { dictionary = {
        mark = 'D',
        maxItems = 5,
      }})
      vim.fn['ddc#custom#patch_global']('sourceParams', { dictionary = {
        dictPaths = { '/usr/share/dict/words' },
        smartCase = true,
        showMenu = false,
        isVolatile = true,
      }})
    end
  },
  {
    'Shougo/ddc-matcher_head',
  },
  {
    'tani/ddc-fuzzy',
  },
  {
    'Shougo/ddc-converter_remove_overlap',
  },
  {
    'LumaKernel/ddc-source-file',
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { file = {
        mark = 'F',
        isVolatile = true,
        forceCompletionPattern = '\\S/\\S*',
      }})
    end
  },
  {
    'Shougo/ddc-source-lsp',
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { ['lsp'] = {
        dup = 'keep',
        mark = 'lsp',
        keywordPattern = [[\k+]],
      }})
      vim.fn['ddc#custom#patch_global']('sourceParams', { ['lsp'] = {
        snippetEngine = vim.fn['denops#callback#register'](function(body) return vim.fn['vsnip#anonymous'](body) end),
        enableResolveItem = true,
        enableAdditionalTextEdit = true,
        confirmBehavior = 'replace',
      }})
    end
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre' },
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
    config = function()
      vim.fn['popup_preview#enable']()
    end
  },
  {
    'matsui54/denops-signature_help',
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
      vim.fn['ddc#custom#patch_global']('sourceOptions', { vsnip = { mark = 'v', }})

      vim.cmd[[
      imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
      smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
     ]]
    end
  },
  {
    'ibuki2003/ddc-source-copilot-lua',
    dependencies = {
      {
        'zbirenbaum/copilot.lua',
        event = { 'InsertEnter' },
        opts = {
          suggestion = { enabled = false },
          panel = { enabled = false },
          filetypes = {
            markdown = false,
          },
        },
      },
    },
    config = function()
      vim.fn['ddc#custom#patch_global']('sourceOptions', { copilot = {
        mark  = 'CP',
        matchers = {},
        minAutoCompleteLength = 0,
      }})
    end
  },
  {
    'aznhe21/actions-preview.nvim',
    init = function()
      vim.keymap.set("n", "<Leader>la", function() require('actions-preview').code_actions() end)
    end
  },
}
