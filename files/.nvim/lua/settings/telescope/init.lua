require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-h>'] = 'which_key',
        ['<Esc>'] = 'close',
        ['<C-u>'] = false,
      },
    },
    path_display = {
      "filename_first",
    },
  },
}

local builtin = require('telescope.builtin')
local fd = function(opts)
  return function()
    builtin.find_files(vim.tbl_extend('force', {
      hidden = true,
      find_command = function()
        return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
      end,
    }, opts or {}))
  end
end

vim.keymap.set('n', '<leader>ff', fd{}, {})
vim.keymap.set('n', '<C-p>',      fd{}, {})
vim.keymap.set('n', '<leader>fF', fd{ no_ignore = true }, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>fm', builtin.marks, {})
vim.keymap.set('n', '<leader>fr', builtin.registers, {})
vim.keymap.set('n', '<leader>fs', builtin.git_status, {})

-- custom pickers
vim.keymap.set("n", "<leader>fl", require "settings.telescope.lsp_picker", { noremap = true, silent = true })
