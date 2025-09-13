return {
  {
    'machakann/vim-sandwich',
    lazy = true,
    keys = {
      { 's',   '<Plug>(sandwich-add)',             mode = 'n' },
      { 'S',   '<Plug>(sandwich-add)g_',           mode = 'n' },
      { 's',   '<Plug>(sandwich-add)',             mode = 'x' },

      { 'ds',  '<Plug>(sandwich-delete)',          mode = 'n' },
      { 'dsb', '<Plug>(sandwich-delete-auto)',     mode = 'n' },
      { 'cs',  '<Plug>(sandwich-replace)',         mode = 'n' },
      { 'csb', '<Plug>(sandwich-replace-auto)',    mode = 'n' },
      { 'sr',  '<Plug>(sandwich-replace)',         mode = 'n' },
      { 'srb', '<Plug>(sandwich-replace-auto)',    mode = 'n' },

      { 'ib',  '<Plug>(textobj-sandwich-auto-i)',  mode = 'o' },
      { 'ib',  '<Plug>(textobj-sandwich-auto-i)',  mode = 'x' },
      { 'ab',  '<Plug>(textobj-sandwich-auto-a)',  mode = 'o' },
      { 'ab',  '<Plug>(textobj-sandwich-auto-a)',  mode = 'x' },

      { 'is',  '<Plug>(textobj-sandwich-query-i)', mode = 'o' },
      { 'is',  '<Plug>(textobj-sandwich-query-i)', mode = 'x' },
      { 'as',  '<Plug>(textobj-sandwich-query-a)', mode = 'o' },
      { 'as',  '<Plug>(textobj-sandwich-query-a)', mode = 'x' },
    },
    config = function() require"settings.sandwich" end,
  },
  {
    'tpope/vim-commentary',
    keys = {
      { 'gc', '<Plug>Commentary', mode = { 'n', 'x', 'o'} },
      { 'gcc', '<Plug>CommentaryLine' },
      { 'gcu', '<Plug>Commentary<Plug>Commentary' },
    },
    command = { 'Commentary' },
  },
  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = { 'n', 'x' } },
    },
    init = function()
      vim.g.easy_align_ignore_groups = {'String'}
    end
  },
  {
    'monaqa/dial.nvim',
    keys = {
      { '<C-a>', mode = {'n', 'x'} },
      { '<C-x>', mode = {'n', 'x'} },
      { 'g<C-a>', mode = {'n', 'x'} },
      { 'g<C-x>', mode = {'n', 'x'} },
    },
    config = function() require('settings.dial') end,
  },
  {
    'dhruvasagar/vim-table-mode',
    config = function()
      vim.g.table_mode_corner = "|"
    end
  },
  {
    'juro106/ftjpn',
    init = function()
      vim.g.ftjpn_key_list = {
        { '.', '。', '．' },
        { ',', '、', '，' },
        { '/', '・' },
        { '(', '（' },
        { ')', '）' },
        { '{', '｛' },
        { '}', '｝' },
        { '[', '「', '『', '【', '〔' },
        { ']', '」', '』', '】', '〕' },
        { '<', '〈', '《' },
        { '>', '〉', '》' },
        { '!', '！' },
        { '?', '？' },
      }
    end
  },
  {
    'chaoren/vim-wordmotion',
    keys = function()
      local tbl = {}
      for _, t in ipairs({'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE'}) do
        table.insert(tbl, { '<leader>' .. t, '<Plug>WordMotion_' .. t, mode = {'n','x','o'} })
      end
      for _, t in ipairs({ 'w', 'W' }) do
        for _, m in ipairs({ 'i', 'a' }) do
          table.insert(tbl, { '<leader>' .. m .. t, '<Plug>WordMotion_' .. m .. t, mode = {'x','o'} })
          table.insert(tbl, { m .. '<leader>' .. t, '<Plug>WordMotion_' .. m .. t, mode = {'x','o'} })
        end
      end
      return tbl
    end,
    init = function() vim.g.wordmotion_nomap = 1 end,
  },
}
