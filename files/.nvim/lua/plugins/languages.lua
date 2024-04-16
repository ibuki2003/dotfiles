return {
  'sheerun/vim-polyglot',
  {
    'rust-lang/rust.vim',
    init = function()
      vim.g.rust_recommended_style = 1
    end
  },
  'udalov/kotlin-vim',
  'DingDean/wgsl.vim',
}
