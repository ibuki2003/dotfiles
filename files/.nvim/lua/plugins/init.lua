local packer
local function init()
  if not packer then
    -- download packer.nvim if not exists
    local fn = vim.fn
    local packerfile = fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
    local packerurl = 'https://github.com/wbthomason/packer.nvim'
    if fn.isdirectory(packerfile) == 0 then
      fn.system('git clone ' .. packerurl .. ' ' .. packerfile)
    end

    vim.cmd.packadd 'packer.nvim'
    packer = require"packer"

    packer.init {
      display = {
        open_fn = function()
          return require("packer.util").float({ border = "single" })
        end
      }
    }
  end
  packer.reset()

  packer.use {'wbthomason/packer.nvim', opt = 1} -- bootstrap
  packer.use {
    'lewis6991/impatient.nvim',
    config = function()
      require'impatient'.enable_profile()
    end
  }

  -- list of plugins
  require('plugins.general')(packer)
  require('plugins.appearance')(packer)
  require('plugins.completion')(packer)

  return packer
end

vim.api.nvim_create_user_command("PackerInstall", function(opts) init().install(unpack(opts.fargs)) end, { bang = true, nargs = '*' })
vim.api.nvim_create_user_command("PackerUpdate",  function(opts) init().update(unpack(opts.fargs)) end , { bang = true, nargs = '*' })
vim.api.nvim_create_user_command("PackerSync",    function(opts) init().sync(unpack(opts.fargs)) end   , { bang = true, nargs = '*' })
vim.api.nvim_create_user_command("PackerCompile", function(opts) init().compile(opts.args) end, { bang = true, nargs = '*' })
vim.api.nvim_create_user_command("PackerClean",   function() init().clean() end , { bang = true })
vim.api.nvim_create_user_command("PackerStatus",  function() init().status() end, { bang = true })
vim.api.nvim_create_user_command("PackerProfile", function() init().profile_output() end, { bang = true })
