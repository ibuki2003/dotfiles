
local extensions = {
  astro = "astro",
}


for ext, ft in pairs(extensions) do
  vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
      pattern = "*." .. ext,
      callback = function()
        vim.api.nvim_buf_set_option(0, "filetype", ft)
      end,
  })
end


