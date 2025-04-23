return {
  -- NOTE: set root_dir to nil to enable single file support
  single_file_support = false,
  root_dir = function(bufnr, callback)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = require"settings.lsp.util".get_deno_root(fname)
    return root and callback(root)
  end,
}
