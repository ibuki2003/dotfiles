local function get_all_diagnostics(bufnr)
  local result = {}
  local levels = {
    errors = vim.diagnostic.severity.ERROR,
    warnings = vim.diagnostic.severity.WARN,
    info = vim.diagnostic.severity.INFO,
    hints = vim.diagnostic.severity.HINT,
  }

  for k, level in pairs(levels) do
    result[k] = #vim.diagnostic.get(bufnr, {severity = level})
  end

  return result
end

local function get_str(bufnr)
  local diagnostics = get_all_diagnostics(bufnr)
  local labels = {
    errors = 'E',
    warnings = 'W',
    info = 'I',
    hints = 'H'
  }
  local parts = {}

  -- print(#diagnostics)
  for level, count in pairs(diagnostics) do
    if count > 0 then
      table.insert(parts, labels[level] .. count)
    end
  end
  return table.concat(parts, ' ')
end

return get_str
