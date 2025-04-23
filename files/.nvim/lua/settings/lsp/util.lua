local lspconfig = require('lspconfig')

local M = {}

M.get_node_root = lspconfig.util.root_pattern({
  "package.json",
  "node_modules",
})
M.get_deno_root = function(fname)
  if M.get_node_root(fname) ~= nil then return end
  local root = lspconfig.util.root_pattern({
    "deno.json",
    "deno.jsonc",
    "tsconfig.json",
    ".git",
  })(fname)

  if root ~= nil then
    return root
  end
  -- single file support
  return vim.fs.dirname(fname)
end

return M
