return {
  single_file_support = false,
  root_dir = function(bufnr, callback)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = require"settings.lsp.util".get_node_root(fname)
    return root and callback(root)
  end,

  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    },
  },
}
