-- enable conceal only if the buffer is not for editing; i.e. it's a preview
if not vim.bo.modifiable then
  vim.wo.conceallevel = 2
end
