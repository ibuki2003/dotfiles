local servers = {
  {
    vim.tbl_extend("force",
      require'efmls-configs.formatters.prettier_d',
      {
        requireMarker = true,
      }
    ),
    {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "css",
      "scss",
      "json",
      "graphql",
      "markdown",
      "vue",
      "html",
    },
  },
}

local langs = {}
for _, server in ipairs(servers) do
  for _, lang in ipairs(server[2]) do
    if not langs[lang] then
      langs[lang] = {}
    end
    table.insert(langs[lang], server[1])
  end
end


return {
  filetypes = vim.tbl_keys(langs),
  -- Enable formatting provided by efm langserver
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
  settings = {
    ['log-file'] = '/tmp/efm.log',
    ['log-level'] = 1,

    rootMarkers = { '.git' },
    languages = langs,
  },
}
