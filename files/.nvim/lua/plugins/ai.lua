return {
  {
    'zbirenbaum/copilot.lua',
    event = { 'InsertEnter' },
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        [""] = false,
        markdown = false,
      },
    },
  },
  {
    'madox2/vim-ai',
    init = function()
      vim.g.vim_ai_roles_config_file = vim.fn.expand("~/.nvim/vimai/roles.ini")
      vim.g.vim_ai_complete = { options = { selection_boundary = '```', }, }
      vim.g.vim_ai_edit = { options = { selection_boundary = '```', }, }
    end,
  },
}
