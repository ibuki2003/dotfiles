---@diagnostic disable: missing-fields

local cmp = require'cmp'

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local selectBehavior = cmp.SelectBehavior.Select

---@type cmp.ConfigSchema
local opts = {}

opts.snippet = {
  expand = function(args)
    vim.fn["vsnip#anonymous"](args.body)
  end,
}
opts.confirmation = {
  default_behavior = cmp.ConfirmBehavior.Insert,
  get_commit_characters = function(c)
    return vim.list_extend(
      vim.split([[ !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~]], ""),
      c
    )
  end,
}
opts.completion = { autocomplete = { 'InsertEnter', 'TextChanged' }, }
opts.preselect = cmp.PreselectMode.None

opts.mapping = {
  ['<CR>'] = cmp.mapping(function(fallback)
    if cmp.visible() and cmp.get_selected_entry() then
      -- confirm
      cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
      -- and then insert a newline
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<CR>", true, true, true),
        "n", true)
    else
      fallback()
    end
  end, {"i", "s"}),
  ['<Esc>'] = cmp.mapping(function(fallback)
    if cmp.visible() and cmp.get_selected_entry() then
      cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, true, true),
        "n", true)
    else
      fallback()
    end
  end, {"i", "s"}),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<C-y>'] = cmp.mapping(function(_fallback)
    if cmp.visible() and cmp.get_selected_entry() then
      cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
    else
      cmp.complete()
    end
  end, {"i", "s"}),
  ['<C-z>'] = cmp.mapping(function(_fallback)
    -- special: if copilot, restore the original text
    local entry = cmp.get_selected_entry()
    if cmp.visible() and entry then
      if entry.source.name == "copilot" and entry._copilot_old_text ~= nil then
        entry.completion_item.textEdit.newText = entry._copilot_old_text
      end
      cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
    else
      cmp.complete()
    end
  end, {"i", "s"}),

  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item({ behavior = selectBehavior })
    elseif vim.fn["vsnip#available"](1) == 1 then
      feedkey("<Plug>(vsnip-expand-or-jump)", "")
    elseif has_words_before() then
      cmp.complete()
    else
      fallback()
    end
  end, { "i", "s" }),

  ["<S-Tab>"] = cmp.mapping(function()
    if cmp.visible() then
      cmp.select_prev_item({ behavior = selectBehavior })
    elseif vim.fn["vsnip#jumpable"](-1) == 1 then
      feedkey("<Plug>(vsnip-jump-prev)", "")
    end
  end, { "i", "s" }),
}
opts.sources = cmp.config.sources({
  {
    name = 'copilot',
    options = { fix_pairs = false, },
    entry_filter = function(entry, _)
      -- modify label to be first line of textEdit
      -- original text can be restored with <C-z>
      if entry.completion_item.textEdit ~= nil and entry._copilot_old_text == nil then
        local text = entry.completion_item.textEdit.newText
        entry._copilot_old_text = text

        -- get first line only
        local pos = text:find("\n")
        if pos ~= nil then
          text = text:sub(1, pos - 1)
        end
        -- trim leading whitespace
        local label = text:gsub("^%s+", "")

        entry.word = label
        entry.filter_text = label
        -- entry.completion_item.documentation.value = doc
        entry.completion_item.label = label
        entry.completion_item.textEdit.newText = text
      end

      return true
    end,
  },
  { name = 'nvim_lsp' },
  { name = 'buffer', option = {
    get_bufnrs = function() return vim.api.nvim_list_bufs() end,
  } },
  { name = 'calc' },
  { name = 'async_path' },
  { name = 'vsnip' },
  { name = 'buffer' },
  { name = "lazydev" },
  {
    name = 'look',
    keyword_length = 3,
    option = {
      convert_case = true,
      loud = true,
    },
  },
})


local cmp_lsp_rs = require'cmp_lsp_rs'
opts.sorting = {
  priority_weight = 2,
  comparators = {
    cmp.config.compare.exact,
    cmp.config.compare.score,
    cmp.config.compare.offset,

    cmp_lsp_rs.comparators.inscope_inherent_import,
    cmp.config.compare.kind,
    cmp.config.compare.sort_text,
    cmp.config.compare.length,
    cmp.config.compare.order,
  },
}
opts.experimental = { ghost_text = true }

-- disable switch
opts.enabled = function()
  local disabled = false
  disabled = disabled or (vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt')
  disabled = disabled or (vim.fn.reg_recording() ~= '')
  disabled = disabled or (vim.fn.reg_executing() ~= '')
  disabled = disabled or (vim.fn.exists("b:cmp_enabled") == 1 and vim.api.nvim_buf_get_var(0, "cmp_enabled") == 0)
  return not disabled
end

cmp.setup (opts)

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})
