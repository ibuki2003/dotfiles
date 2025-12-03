return {
  single_file_support = true,
  settings = {
    exportPdf = "onType",
    outputPath = "/tmp/$name",
    preview = {
      background = { enabled = true },
    },
    ["preview.background.enabled"] = true,
  },
  capabilities = { offsetEncoding = { 'utf-16' } },
}
