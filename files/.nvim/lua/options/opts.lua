vim.opt.helplang = { "ja", "en" }

vim.opt.fileencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencodings = {"ucs-bom", "utf-8", "shift-jis", "euc-jp", "latin1"}
vim.opt.fileformats = {"unix", "dos", "mac"}

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = true
vim.opt.updatetime = 60000 -- ms
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.showcmd = true

vim.opt.background = "dark"

vim.opt.virtualedit = {"block", "onemore"}
vim.opt.backspace = {"indent", "eol", "start"}
vim.opt.ambiwidth = "double"
vim.opt.wildmenu = true

vim.opt.cinoptions:append("l1")

vim.opt.scrolloff = 5

vim.opt.visualbell = true
vim.opt.showmatch = true
vim.opt.laststatus = 2

vim.opt.formatoptions:remove("ro")
vim.cmd [[ au Filetype * if &ft != 'markdown' | setlocal formatoptions-=ro | endif ]]

vim.opt.completeopt:remove("preview")

vim.opt.matchpairs = vim.list_extend(vim.opt.matchpairs, {
  "「:」",
  "『:』",
  "（:）",
  "【:】",
  "《:》",
  "〈:〉",
  "［:］",
  "‘:’",
  "“:”",
})

vim.opt.cinkeys:remove("0#")
vim.opt.mouse = {}

-- " search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.hlsearch = true

-- " filename completion
vim.opt.wildignorecase = true

-- " appearance
vim.opt.list = true
vim.opt.listchars = {
  tab = "»-",
  trail = "-",
  eol = "¬",
  extends = "»",
  precedes = "«",
  nbsp = "%",
}
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.foldcolumn = "1"

vim.opt.showmode = false -- lightline

vim.opt.inccommand = "nosplit" -- incremental substitution

vim.opt.showtabline = 1
if vim.fn.has("gui_running") == 1 then
  vim.opt.guioptions:remove("e")
end

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end
