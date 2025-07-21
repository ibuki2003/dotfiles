local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  change_detection = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = { 'matchit' },
    },
  },
})

-- NOTE: Workaround for vimdoc-ja tag file conflicting
-- https://github.com/vim-jp/vimdoc-ja/issues/279
-- ref: https://github.com/mimikun/dotfiles/blob/b724b47d8ac92cf9098effdd6cbd60447baffc5e/dot_config/nvim/lua/plugins/vimdoc-ja.lua#L3-L21
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyUpdatePre",
  group = vim.api.nvim_create_augroup("lazy-update-pre", {}),
  callback = function()
    local vimdoc_repo = vim.fn.stdpath("data") .. "/lazy/vimdoc-ja/"
    vim.system({ "git", "reset", "--hard" }, { cwd = tostring(vimdoc_repo) }, function(info)
      if info.code == 0 then
        vim.schedule(function()
          vim.notify("SUCCESS: git reset --hard", vim.log.levels.DEBUG)
        end)
      else
        vim.schedule(function()
          vim.notify("FAILED: git reset --hard", vim.log.levels.ERROR)
        end)
      end
    end):wait()
  end,
})
