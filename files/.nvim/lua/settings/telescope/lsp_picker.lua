local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local lsp_clients_picker = function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "LSP clients",
    finder = finders.new_dynamic {
      fn = function() return vim.lsp.get_clients() end,
      entry_maker = function(entry)
        local attached = (entry.attached_buffers[bufnr]) or false
        return {
          value = {id = entry.id, attached = attached},
          display = string.format("%s %s", attached and "+" or " ", entry.name),
          ordinal = entry.id,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection == nil then return end

        if selection.value.attached then
          vim.lsp.buf_detach_client(bufnr, selection.value.id)
        else
          vim.lsp.buf_attach_client(bufnr, selection.value.id)
        end
        action_state.get_current_picker(prompt_bufnr):refresh()
      end)
      return true
    end,
  }):find()
end

return lsp_clients_picker
