local dap = require("dap")
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}
require("dap.ext.vscode").type_to_filetypes["gdb"] = { "c", "cpp", "rust" }

vim.fn.sign_define('DapBreakpoint', { text = 'B', texthl = 'DiagnosticError', linehl = '', numhl = '' })

