return function(packer)
  packer.use{
    {
      'Shougo/ddc.vim',
      config = function()
        vim.fn['ddc#custom#patch_global']('ui', 'pum')

        vim.fn['ddc#custom#patch_global']('sources', {
            'copilot',
            'nvim-lsp',
            'tabnine',
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

        -- Use ddc.
        vim.fn['ddc#enable']()

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

        vim.api.nvim_set_keymap('n', ':', '', {
          expr = true,
          noremap = true,
          callback = function()
            vim.fn['ddc#enable_cmdline_completion']()
            return ':'
          end,
        })
      end
    },
    {
      'Shougo/pum.vim',
      config = function()
        vim.fn['pum#set_option']({
          scrollbar_char = '█',
          use_complete= true,
          highlight_matches= 'MatchParen',
        })
      end,
    },
    {
      'Shougo/ddc-ui-pum',
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
      'nvim-treesitter/nvim-treesitter',
      config = function()
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
          },
          indent = {
            enable = false,
          },
        }
      end
    },
    {
      'Shougo/ddc-nvim-lsp',
      config = function()
        vim.fn['ddc#custom#patch_global']('sourceOptions', { ['nvim-lsp'] = {
          mark = 'lsp',
          forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
        }})
      end
    },
    {
      'neovim/nvim-lspconfig',
      config = function()
        require('lspsettings/config')
      end,
    },
    {
      'glepnir/lspsaga.nvim',
      module = 'lspsaga',
      requires = {
        "nvim-tree/nvim-web-devicons",
      }
    },
    {
      'folke/neodev.nvim',
      module = 'neodev',
    },
    {
      'jose-elias-alvarez/null-ls.nvim',
      module = 'null-ls',
      requires = { 'nvim-lua/plenary.nvim' },
    },
    {
      'j-hui/fidget.nvim',
      config = function() require"fidget".setup{} end
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
        vim.fn['signature_help#enable']()
      end,
    },
    {
      'hrsh7th/vim-vsnip',
      config = function()
        vim.fn['ddc#custom#patch_global']('sourceOptions', { vsnip = { mark = 'v', }})

        vim.cmd[[
        imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
        smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
       ]]
      end
    },
    {
      'hrsh7th/vim-vsnip-integ',
      config = function()
        vim.api.nvim_create_autocmd(
          'User',
          {
            pattern = 'PumCompleteDone',
            callback = function() vim.fn['vsnip_integ#on_complete_done'](vim.v['completed_item']) end
          }
        )
      end
    },
    {
      'github/copilot.vim',
      event = { 'InsertEnter' },
      setup = function()
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_ignore_node_version = true
      end
    },
    {
      'ibuki2003/ddc-source-copilot',
      config = function()
        vim.fn['ddc#custom#patch_global']('sourceOptions', { copilot = {
          mark  = 'CP',
          matchers = {},
          minAutoCompleteLength = 0,
        }})
      end
    },
    {
      'LumaKernel/ddc-tabnine',
      config = function()
        vim.fn['ddc#custom#patch_global']('sourceOptions', { tabnine = {
          mark  = 'TN',
          maxItems = '5',
          isVolatile = true,
        }})
        vim.fn['ddc#custom#patch_global']('sourceParams', { tabnine = {
          maxNumResults = 10,
        }})
      end
    },
    {
      'rust-lang/rust.vim',
      setup = function()
        vim.g.rust_recommended_style = 0
      end
    },
    {
      'aznhe21/actions-preview.nvim',
      requires = { 'MunifTanjim/nui.nvim' },
      setup = function()
        vim.keymap.set("n", "<Leader>la", function() require('actions-preview').code_actions() end)
      end
    },
    {
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        require'treesitter-context'.setup{
          enable = true,
          max_lines = 3,
          min_window_height = 15,
          line_numbers = true,
          multiline_threshold = 20,
          trim_scope = 'outer',
          mode = 'topline',
          zindex = 20,
        }
      end,
    },
  }
end
