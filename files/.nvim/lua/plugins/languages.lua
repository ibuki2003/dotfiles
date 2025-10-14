return {
  {
    'chrisbra/csv.vim',
  },
  {
    'https://git.sr.ht/~sotirisp/vim-tsv',
  },

  {
    'rust-lang/rust.vim',
    ft = { 'rust' },
    init = function()
      vim.g.rust_recommended_style = 1
      -- seems not to work?
      -- vim.g.rustfmt_autosave = 1
    end
  },
  {
    'mrcjkb/rustaceanvim',
    init = function()
      vim.g.rustaceanvim = {
      }
    end
  },
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {
      lsp = {
        enabled = true,
        on_attach = function(client, bufnr)
          -- add keybinds
          vim.keymap.set('n', '<leader>lf', function()
            require'crates'.show_features_popup()
          end, { noremap = true, silent = true, buffer = bufnr })

        end,
        actions = true,
        completion = true,
        hover = true,
      }
    },
  },
  {
    'udalov/kotlin-vim',
    ft = { 'kotlin' },
  },
  {
    'DingDean/wgsl.vim',
    event = { 'BufReadPre *.wgsl', 'BufNewFile *.wgsl' },
    ft = { 'wgsl' },
  },
  {
    'tikhomirov/vim-glsl',
    ft = { 'glsl' },
  },
  {
    'jxnblk/vim-mdx-js',
    event = { 'BufRead *.mdx', 'BufNewFile *.mdx' },
    ft = { 'mdx' },
  },
  {
    'ixru/nvim-markdown',
    lazy = false,
    init = function()
      vim.g.vim_markdown_no_default_key_mappings = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_math = 1
    end,
    keys = {
      { ft='markdown', ']]', '<Plug>Markdown_MoveToNextHeader', mode={'n','v'} },
      { ft='markdown', '[[', '<Plug>Markdown_MoveToPreviousHeader', mode={'n','v'} },
      { ft='markdown', '][', '<Plug>Markdown_MoveToNextSiblingHeader', mode={'n','v'} },
      { ft='markdown', '[]', '<Plug>Markdown_MoveToPreviousSiblingHeader', mode={'n','v'} },
      { ft='markdown', ']u', '<Plug>Markdown_MoveToParentHeader', mode={'n','v'} },
      { ft='markdown', ']c', '<Plug>Markdown_MoveToCurHeader', mode={'n','v'} },
      { ft='markdown', '<C-c>', '<Plug>Markdown_Checkbox', mode='n' },
      { ft='markdown', '<TAB>', '<Plug>Markdown_Fold', mode='n' },
      { ft='markdown', 'o', '<Plug>Markdown_NewLineBelow', mode='n' },
      { ft='markdown', 'O', '<Plug>Markdown_NewLineAbove', mode='n' },
      { ft='markdown', '<CR>', '<Plug>Markdown_NewLineBelow', mode='i' },
    },
  },
  {
    'chomosuke/typst-preview.nvim',
    ft = { 'typst' },
    version = '1.*',
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
  {
    'pest-parser/pest.vim',
    -- opts = {}, -- nvim-lspconfig supports pest-ls
  },
}
