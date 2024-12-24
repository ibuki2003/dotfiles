local source = {}

function source:is_available()
  return vim.bo.filetype == 'copilot-chat'
end

function source:get_position_encoding_kind()
  return 'utf-8'
end

function source:get_keyword_pattern()
  return [[\%(@\|/\|#\|\$\)\S*]]
end

function source:get_trigger_characters()
  return { '@', '/', '#', '$' }
end

local cc = require("CopilotChat")
local types = require('cmp.types')

function source:complete(_, callback)
  cc.complete_items(function(items)
    items = vim.tbl_map(function(item)
      return {
        label = item.word,
        detail = item.menu,
        documentation = item.info,
        kind = types.lsp.CompletionItemKind.Keyword,
      }
    end, items)
    callback(items)
  end)
end

return source
