local telescope = require('telescope')
telescope.setup {
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
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {
        initial_mode = 'normal',
        layout_config = {
          width = 0.5,
          height = 0.5,
        },
      },
    },
  },
}

telescope.load_extension('ui-select')


local function is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

local builtin = require('telescope.builtin')
local fd = function(opts)
  if not opts.no_ignore and is_git_repo() then
    return function()
      builtin.git_files({ show_untracked = true, use_git_root = false })
    end
  end

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
vim.keymap.set('n', '<C-p>',      function() telescope.extensions.smart_open.smart_open() end, {})
vim.keymap.set('n', '<leader>fF', fd{ no_ignore = true }, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>fm', builtin.marks, {})
vim.keymap.set('n', '<leader>fr', builtin.registers, {})
vim.keymap.set('n', '<leader>fs', builtin.git_status, {})
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>ft', builtin.filetypes, {})

-- custom pickers
vim.keymap.set("n", "<leader>fl", require "settings.telescope.lsp_picker", { noremap = true, silent = true })
