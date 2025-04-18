-- original from https://github.com/olimorris/codecompanion.nvim/discussions/652
--[[
CodeCompanion Chat History Management
This module provides persistence and retrieval functionality for CodeCompanion chats.
--]]

local M = {}
local path = require("plenary.path")
local context_utils = require("codecompanion.utils.context")
local client = require("codecompanion.http")
local config = require("codecompanion.config")
local default_file_path = vim.fn.stdpath("data") .. "/codecompanion_chats"
local chats_history_file_path = path:new(config.history and config.history.file_path or default_file_path)
local api = vim.api

-- A way to tell this chat is auto-saved
local default_buf_title = "[CodeCompanionAutoSaveChat]"

---@class CodeCompanion.HistoryEntry
---@field messages List
-- ---@field settings table
-- ---@field adapter table

---------------------------------------------------------------------------------------------------
-- Local Helpers
---------------------------------------------------------------------------------------------------
---@param chatid number
local function chat_file_path(chatid)
    if not chats_history_file_path:exists() then
        chats_history_file_path:mkdir({
          parents = true,
          mode = 493, -- 0755
        })
    end
    if chats_history_file_path:is_file() then
      vim.notify("Chat history path is a file, not a directory", vim.log.levels.ERROR)
      return nil
    end
    return chats_history_file_path:joinpath(tostring(chatid) .. ".json")
end

---@param chatid number
---@return CodeCompanion.HistoryEntry | nil
local function load_chat(chatid)
  local filepath = chat_file_path(chatid)
  if not filepath then
    return nil
  end
  local content = filepath:read()
  if not content then
    return nil
  end
  return vim.json.decode(content)
end

---returns list of chat ids
---@return number[]
local function list_chat_history()
  if not chats_history_file_path:exists() then
    return {}
  end

  local files = vim.fn.readdir(tostring(chats_history_file_path), function(file)
    return vim.endswith(file, ".json") and 1 or 0
  end)
  local entries = {}
  for _, file in ipairs(files) do
    -- remove the file extension
    local stem = string.gsub(file, "%.json$", "")
    local num = tonumber(stem)
    if num == nil then
      print("Invalid file name: " .. file)
    else
      table.insert(entries, num)
    end
  end
  return entries
end

-- Persist chat to file, filtering out system messages
local function save_chat(chat)
    local filepath = chat_file_path(chat.id)
    if not filepath then
      return
    end

    -- Filter out system messages before saving
    local messages = vim.tbl_filter(function(msg)
        return msg.role ~= "system"
    end, chat.messages)

    local content = {
        -- settings = chat.settings,
        -- adapter = chat.adapter,
        messages = messages,
    }

    filepath:write(vim.json.encode(content), "w", 420) -- 0644
end

-- Format chat data for display in telescope picker
local function format_chat_items(chat_ids)
    -- Sort by timestamp (latest first)
    table.sort(chat_ids, function(a, b)
        return a > b
    end)

    return chat_ids
end


-- Adapted from codecompanion ui.lua render function
-- Focuses only on message rendering without settings/visual context handling
local function render_messages(bufnr, messages, last_role, roles)
    local lines = {}

    local last_set_role
    local function spacer()
        table.insert(lines, "")
    end

    local function set_header(tbl, role)
        local header = "## " .. role
        table.insert(tbl, header)
        table.insert(tbl, "")
    end

    for i, msg in ipairs(messages) do
        -- Skip system messages or hidden messages
        if msg.role ~= config.constants.SYSTEM_ROLE or (msg.opts and msg.opts.visible ~= false) then
            if i > 1 and last_role ~= msg.role then
                spacer()
            end

            if msg.role == config.constants.USER_ROLE and last_set_role ~= config.constants.USER_ROLE then
                set_header(lines, roles.user)
            end
            if msg.role == config.constants.LLM_ROLE and last_set_role ~= config.constants.LLM_ROLE then
                set_header(lines, roles.llm)
            end

            for _, text in ipairs(vim.split(msg.content, "\n", { plain = true, trimempty = true })) do
                table.insert(lines, text)
            end

            last_set_role = msg.role
            last_role = msg.role
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    return last_role
end

-- Create custom previewer to show messages in markdown
local function create_previewer()
    local previewers = require("telescope.previewers")
    return previewers.new_buffer_previewer({
        title = "Chat Preview",
        define_preview = function(self, entry, status)
            local messages = load_chat(entry.value).messages
            render_messages(self.state.bufnr, messages, nil, {
                user = "User",
                llm = "LLM",
            })
            vim.bo[self.state.bufnr].filetype = "markdown"
        end
    })
end

---@param entry_ids number[]
local function open_picker(entry_ids)
    -- Initialize telescope picker
    local pickers = require("telescope.pickers")
    local conf = require("telescope.config").values
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    -- Create and open picker
    pickers.new({}, {
        prompt_title = "Saved Chats",
        finder = finders.new_table({
            results = entry_ids,
            entry_maker = function(entry_id)
                local current_chat = require("codecompanion").last_chat()
                local is_current = current_chat and current_chat.id == entry_id
                -- local relative_time = format_relative_time(entry_id)
                local datetime = os.date("%Y-%m-%d %H:%M:%S", entry_id)
                local display_title = string.format("%s %s (%s.json)",
                    --some dev icon
                    is_current and "*" or " ",
                    datetime,
                    entry_id
                )

                return {
                    value = entry_id,
                    display = display_title,
                    ordinal = datetime,
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        previewer = create_previewer(),
        attach_mappings = function(prompt_bufnr, map)
            -- local delete_item = function()
            --     local selection = action_state.get_selected_entry()
            --     if selection then
            --         delete_chat(selection.id)
            --         actions.close(prompt_bufnr)
            --         -- Reopen picker to refresh
            --         M.open_saved_chats()
            --     end
            -- end
            -- -- Add delete mapping
            -- map("i", "x", delete_item)
            -- map("n", "x", delete_item)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    M.create_auto_save_chat(selection.value)
                end
            end)
            return true
        end,
    }):find()
end

local function set_buf_title(bufnr, title, attempt)
    attempt = attempt or 0
    vim.schedule(function()
        --  throws error if already buffer with same name is present, so try again with different name
        local success, err = pcall(function()
            local _title = title .. " " .. (attempt > 0 and "(" .. tostring(attempt) .. ")" or "")
            vim.api.nvim_buf_set_name(bufnr, _title)
        end)
        if not success then
            if attempt > 5 then
                vim.notify("Failed to set buffer title: " .. err, vim.log.levels.ERROR)
                return
            end
            set_buf_title(bufnr, title, attempt + 1)
        end
    end)
end


---------------------------------------------------------------------------------------------------
-- Public Interface
---------------------------------------------------------------------------------------------------

-- Open the chat history picker using Telescope
M.open_saved_chats = function()
    local chats = list_chat_history()
    if vim.tbl_isempty(chats) then
        vim.notify("No chat history found", vim.log.levels.INFO)
        return
    end
    local items = format_chat_items(chats)
    open_picker(items)
end

-- Create a new chat with auto-saving functionality
---@param chatid number|nil
M.create_auto_save_chat = function(chatid)
    local chat_data = chatid and load_chat(chatid) or {}

    local messages = chat_data.messages or {}
    -- local settings = chat_data.settings or nil
    -- local adapter = chat_data.adapter or nil

    --HACK: Ensure last message is from user to show header
    if #messages > 0 and messages[#messages].role ~= "user" then
        table.insert(messages, {
            role = "user",
            content = "\n\n",
            opts = { visible = true }
        })
    end

    local context = context_utils.get(api.nvim_get_current_buf())
    local chat = require("codecompanion.strategies.chat").new({
        context = context,
        messages = messages,
        -- settings = settings,
        -- adapter = adapter,
    })
    if chat == nil then
      vim.notify("Failed to create chat", vim.log.levels.ERROR)
      return
    end

    local id = chatid or os.time()
    chat.id = id
    set_buf_title(chat.bufnr, default_buf_title .. " " .. chat.id)

    chat:set_range(-1)

    -- Add subscription to save chat on every response from llm
    chat.subscribers:subscribe({
        id = "save_messages",
        data = {},
        callback = function(chat_instance)
            save_chat(chat_instance)
        end
    })

    return chat
end

-- Setup user commands for chat history management
function M.setup()
    vim.api.nvim_create_user_command("CodeCompanionHistory", function() M.open_saved_chats() end, { desc = "Open saved chats", })
    vim.api.nvim_create_user_command("CodeCompanionAutoSaveChat", function() M.create_auto_save_chat() end, { desc = "Create a new chat with auto-saving", })
    vim.api.nvim_create_user_command("CodeCompanionAutoSaveToggle", function()
      local cc = require("codecompanion")
      local chat = cc.last_chat()
      if chat ~= nil then
        if chat.ui:is_visible() then
          return chat.ui:hide()
        else
          chat.context = context_utils.get(api.nvim_get_current_buf())
          cc.close_last_chat()
          chat.ui:open()
        end
      else
        -- create a new chat with auto-saving
        M.create_auto_save_chat()
      end
    end, { desc = "Toggle a chat, or create a new chat with auto-saving if empty", })
end

return M
