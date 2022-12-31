return function(packer)
  packer.use{
    {
      'Shougo/ddc.vim',
      config = function()
        vim.fn['ddc#custom#patch_global']('ui', 'pum')

        vim.fn['ddc#custom#patch_global']('sources', {
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
      end
    },
    {
      'Shougo/pum.vim',
      config = function()
        vim.fn['pum#set_option']('scrollbar_char', '█')
        vim.fn['pum#set_option']('use_complete', true)
      end,
    },
    {
      'Shougo/ddc-ui-pum',
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
            enable = true,
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
      end
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
    },
    {
      'github/copilot.vim',
      setup = function()
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_ignore_node_version = true
        vim.cmd[[
        imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
        ]]
      end
    },
    {
      'LumaKernel/ddc-tabnine',
      config = function()
        vim.fn['ddc#custom#patch_global']('sourceOptions', { tabnine = {
          mark  = 'TN',
          maxCandidates = '5',
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
    }
  }
end
