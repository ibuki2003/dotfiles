return {
  {
    'chrisbra/csv.vim',
    ft = { 'csv' },
  },
  {
    'rust-lang/rust.vim',
    ft = { 'rust' },
    init = function()
      vim.g.rust_recommended_style = 1
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
    'jxnblk/vim-mdx-js',
    event = { 'BufRead *.mdx', 'BufNewFile *.mdx' },
    ft = { 'mdx' },
  },
}
