-- https://gist.github.com/MunifTanjim/7a34aa247cbabdec50f4de45fffdf53e
local mod = {}

---@param server_name string
---@param settings_patcher fun(settings: table): table
function mod.patch_lsp_settings(server_name, settings_patcher)
  local function patch_settings(client)
    client.config.settings = settings_patcher(client.config.settings)
    client.notify("workspace/didChangeConfiguration", {
      settings = client.config.settings,
    })
  end

  -- local clients = vim.lsp.get_active_clients({ name = server_name })
  local clients = vim.lsp.get_clients({ name = server_name })
  if #clients > 0 then
    patch_settings(clients[1])
    return
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client ~= nil and client.name == server_name then
        patch_settings(client)
        return true
      end
    end,
  })
end

return mod
