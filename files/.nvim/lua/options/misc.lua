vim.api.nvim_create_augroup("fuwa", {})

-- highlight ideographic space
vim.api.nvim_create_autocmd({"BufNew", "BufRead"}, {
  pattern = "*",
  group = "fuwa",
  callback = function()
    vim.cmd[[
      syntax match InvisibleJISX0208Space "　" display containedin=ALL
      highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
    ]]
  end,
})

vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = "*",
  group = "fuwa",
  callback = function()
    vim.fn.mkdir(vim.fn.expand("<afile>:p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd({"QuickFixCmdPost"}, {
  pattern = "*grep*",
  group = "fuwa",
  callback = function()
    vim.cmd("cwindow")
  end,
})

vim.api.nvim_create_autocmd({"BufReadPost"}, {
  pattern = "*",
  group = "fuwa",
  callback = function()
    if vim.bo.filetype == "gitcommit" then return end

    if vim.fn.line("'\"") >= 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd("normal! g`\"")
    end
  end,
})

vim.api.nvim_create_user_command("Rename", function (opts)
  local args = opts.fargs
  local nargs = #args
  local newfilename
  local curfilename = vim.fn.expand("%")
  if nargs == 1 then
    -- move to
    newfilename = vim.fs.normalize(args[1])
    if vim.fn.isdirectory(newfilename) == 1 or args[1]:match("/$") then
      newfilename = vim.fs.joinpath(newfilename, vim.fs.basename(curfilename))
      print(newfilename)
    elseif vim.fn.filereadable(newfilename) == 1 then
      if not opts.bang then
        vim.cmd("echo 'Rename: destination exists'")
        return
      end
    end
  elseif nargs == 2 then
    -- replace string
    local from = args[1]
    local to = args[2]

    local p = vim.split(curfilename, '/', { plain=true, trimempty=false })
    local fnr = ""
    local found = false

    for i = #p, 1, -1 do
      fnr = (fnr == "") and p[i] or p[i] .. '/' .. fnr

      if not found then
        local pos0, pos1 = fnr:find(from, 1, true)
        if pos0 ~= nil then
          found = true
          fnr = fnr:sub(1, pos0 - 1) .. to .. fnr:sub(pos1 + 1)
        end
      end
    end

    if not found then
      vim.cmd("echo 'Rename: pattern not found'")
      return
    end
    newfilename = fnr

    -- replace mode does not allow directory as destination
    if vim.fn.isdirectory(newfilename) == 1 or vim.fn.filereadable(newfilename) == 1 then
      if not opts.bang then
        vim.cmd("echo 'Rename: destination exists'")
        return
      end
    end
  else
    vim.cmd("echo 'Rename: Invalid number of arguments'")
    return
  end

  local par = vim.fs.dirname(newfilename)
  if vim.fn.isdirectory(par) ~= 1 then
    if vim.fn.filereadable(par) == 1 then
      vim.cmd("echo 'Rename: destination exists'")
      return
    end
    vim.fn.mkdir(par, "p")
  end


  if vim.fn.filereadable(curfilename) ~= 1 then
    -- only rename buffer
    vim.cmd("file " .. newfilename)
    return
  end

  -- NOTE: rename() overwrites existing file with no warning
  if vim.fn.rename(curfilename, newfilename) == 0 then
    -- rename buffer
    vim.cmd("file " .. newfilename)
  else
    vim.cmd("echo 'Rename: Failed'")
  end
end, {
  nargs = "*",
  complete = "file",
  bang = true,
})
