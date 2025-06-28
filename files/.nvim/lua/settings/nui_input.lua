-- vim.ui wrapper
-- R.I.P. dressing.nvim

-- https://github.com/MunifTanjim/nui.nvim/wiki/vim.ui

local _UIInput = nil

local function UIInput()
  if _UIInput ~= nil then
    return _UIInput
  end

  local Input = require("nui.input")
  local event = require("nui.utils.autocmd").event

  _UIInput = Input:extend("UIInput")

  local function get_prompt_text(prompt, default_prompt)
    local prompt_text = prompt or default_prompt
    if prompt_text:sub(-1) == ":" then
      prompt_text = "[" .. prompt_text:sub(1, -2) .. "]"
    end
    return prompt_text
  end

  function _UIInput:init(opts, on_done)
    local border_top_text = get_prompt_text(opts.prompt, "[Input]")
    local default_value = tostring(opts.default or "")

    _UIInput.super.init(self, {
      relative = "cursor",
      position = {
        row = 1,
        col = 0,
      },
      size = {
        -- clamp the width to a reasonable size
        width = math.min(
          math.max(
            vim.api.nvim_strwidth(default_value) + 5,
            50
          ),
          vim.o.columns - 5
        ),
      },
      border = {
        style = "rounded",
        text = {
          top = border_top_text,
          top_align = "left",
        },
      },
      win_options = {
        winhighlight = "NormalFloat:Normal,FloatBorder:Normal",
      },
    }, {
      default_value = default_value,
      on_close = function()
        on_done(nil)
      end,
      on_submit = function(value)
        on_done(value)
      end,
    })

    -- cancel operation if cursor leaves input
    self:on(event.BufLeave, function()
      on_done(nil)
    end, { once = true })

    -- cancel operation if <Esc> is pressed
    self:map("n", "<Esc>", function()
      on_done(nil)
    end, { noremap = true, nowait = true })
    self:map("i", "<Esc>", function()
      on_done(nil)
    end, { noremap = true, nowait = true })
  end
  return _UIInput
end

local input_ui

vim.ui.input = function(opts, on_confirm)
  assert(type(on_confirm) == "function", "missing on_confirm function")

  if input_ui then
    -- ensure single ui.input operation
    -- vim.api.nvim_err_writeln("busy: another input is pending!")
    print("busy: another input is pending!")
    return
  end

  input_ui = UIInput()(opts, function(value)
    if input_ui then
      -- if it's still mounted, unmount it
      input_ui:unmount()
    end
    -- pass the input value
    on_confirm(value)
    -- indicate the operation is done
    input_ui = nil
  end)

  input_ui:mount()
end

