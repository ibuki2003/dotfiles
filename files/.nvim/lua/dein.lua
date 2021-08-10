local base_dir = vim.env.HOME .. '/.nvim'
local dein_dir = base_dir .. '/plugins'
local dein_repo_dir = dein_dir .. '/repos/github.com/Shougo/dein.vim'

-- dein.vim がなければ github から落としてくる
if not string.match(vim.o.runtimepath, '/dein.vim') then
  if vim.fn.isdirectory(dein_repo_dir) ~= 1 then
    os.execute('git clone https://github.com/Shougo/dein.vim ' .. dein_repo_dir)
  end
  vim.o.runtimepath = dein_repo_dir .. ',' .. vim.o.runtimepath
end


vim.g['dein#auto_recache'] = 1

-- Required:
if vim.call('dein#load_state', dein_dir) == 1 then
  local toml_dir = base_dir .. '/toml'
  vim.call('dein#begin', dein_dir)

  -- load plgins file

  vim.call('dein#load_toml', toml_dir .. '/general.toml')
  vim.call('dein#load_toml', toml_dir .. '/appearance.toml')
  vim.call('dein#load_toml', toml_dir .. '/completion.toml')

  vim.call('dein#end')
  vim.call('dein#save_state')
end

-- If you want to install not installed plugins on startup.
if vim.call('dein#check_install') == 1 then
  vim.call('dein#install')
end

-- Required:
vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')

