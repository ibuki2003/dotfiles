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
        -- event = "LspAttach",
        config = function()
          local opts = {
            hint_enable = false,
            max_height = 6,
            doc_lines = 0,
            toggle_key = "<C-h>",
            toggle_key_flip_floatwin_setting = true,
          }
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local bufnr = args.buf
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              -- NOTE: some clients do not support lsp_signature.nvim
              if
                client == nil
                or vim.tbl_contains({ 'null-ls' }, client.name) -- blacklist lsp
                or vim.tbl_contains({ 'ocaml' }, vim.bo[bufnr].filetype) -- blacklist filetypes
              then
                return
              end
              require("lsp_signature").on_attach(opts, bufnr)
            end,
          })
        end
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
    'hrsh7th/vim-vsnip',
    event = { 'InsertEnter' },
    config = function()
      vim.g.vsnip_snippet_dir = '~/.nvim/snippets'
      vim.cmd[[
      imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
      smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
     ]]
    end
  },
  {
    'aznhe21/actions-preview.nvim',
    keys = {
      { "<Leader>la", function() require('actions-preview').code_actions() end },
    },
  },
}
