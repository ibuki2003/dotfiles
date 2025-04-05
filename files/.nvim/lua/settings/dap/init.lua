local dap = require "dap"
local dapui = require "dapui"

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
-- dap.listeners.before.event_terminated.dapui_config = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited.dapui_config = function()
--   dapui.close()
-- end

vim.api.nvim_create_user_command("DapuiOpen", function()
  dapui.open()
end, { desc = "Open DAP UI" })
vim.api.nvim_create_user_command("DapuiClose", function()
  dapui.close()
end, { desc = "Close DAP UI" })

require 'settings.dap.probe-rs'
require 'settings.dap.gdb'
