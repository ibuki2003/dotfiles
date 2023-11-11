return {
  'vim-jp/vimdoc-ja',
  { 'vim-denops/denops.vim', priority = 1000 },
  'sheerun/vim-polyglot',

  {
    'stevearc/dressing.nvim',
  },
  {
    'machakann/vim-sandwich',
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
    config = function()
      vim.g.sandwich_no_default_key_mappings = 1
      vim.g['sandwich#input_fallback'] = 0
      vim.fn['operator#sandwich#set']('delete', 'all', 'hi_duration', 50)

      local recipes = {
        {
          buns = {"(\\s*", "\\s*)"},
          nesting = 1,
          regex = 1,
          match_syntax = 1,
          kind = {"delete", "replace", "textobj"},
          action = {"delete"},
          input = {"("},
        },
      }

      for _, k in ipairs({ {'{','}'}, {'[',']'} }) do
        local opr = vim.fn.escape(k[1], '[')

        table.insert(recipes, {
            buns = { k[1] .. " ", " " .. k[2] },
            nesting = 1,
            match_syntax = 1,
            motionwise = { 'char', 'block' }, -- only not line
            kind = { "add", "replace" },
            action = { "add" },
            input = { k[1] }
          })

        table.insert(recipes, {
            buns = { opr .. "\\s*", "\\s*" .. k[2] },
            nesting = 1,
            regex = 1,
            match_syntax = 1,
            kind = { "delete", "replace", "textobj" },
            action = { "delete" },
            input = { k[1] }
          })
      end
      vim.g['sandwich#recipes'] = vim.list_extend(vim.g['sandwich#default_recipes'], recipes)
    end,
  },
  {
    'tpope/vim-commentary',
  },
  {
    'tpope/vim-repeat',
  },
  {
    'simeji/winresizer',
    keys = '<C-e>',
    init = function()
      vim.g.winresizer_vert_resize = 1
      vim.g.winresizer_horiz_resize = 1
    end,
  },
  {
    'wakatime/vim-wakatime',
  },
  {
    'machakann/vim-highlightedyank',
    init = function()
      vim.g.highlightedyank_highlight_duration = 300
    end
  },
  {
    'kana/vim-operator-replace',
    dependencies = { 'kana/vim-operator-user' },
    keys = { '<Leader>r', '<Plug>(operator-replace)' }
  },
  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = 'x' },
      { 'ga', '<Plug>(EasyAlign)', mode = 'n' },
    },
    init = function()
      vim.g.easy_align_ignore_groups = {'String'}
    end
  },
  {
    'fuenor/im_control.vim',
    event = 'InsertEnter',
    init = function()
      if vim.fn.executable('fcitx-remote') == 1 then
        vim.g.IM_CtrlMode = 6
      elseif vim.fn.executable('fcitx5-remote') == 1 then
        _G.IMCtrl = function (cmd)
          if cmd == 'On' then
            vim.fn.system('fcitx5-remote -o > /dev/null 2>&1 ' .. vim.g.IM_CtrlAsync)
          elseif cmd == 'Off' then
            vim.fn.system('fcitx5-remote -c > /dev/null 2>&1 ' .. vim.g.IM_CtrlAsync)
          elseif cmd == 'Toggle' then
            vim.fn.system('fcitx5-remote -t > /dev/null 2>&1 ' .. vim.g.IM_CtrlAsync)
          end
          return ''
        end
        vim.cmd[[
        silent! function! IMCtrl(cmd)
          return v:lua.IMCtrl(a:cmd)
        endfunction
        ]]
        vim.g.IM_CtrlMode = 1
        vim.g.IM_vi_CooperativeMode = 1
        vim.g.IM_JpFixModeAutoToggle = 0
      end
      vim.api.nvim_set_keymap('i', '<C-k>', '<C-r>=IMState("FixMode")<CR>', { noremap = true, silent = true })
    end
  },
  {
    'simplenote-vim/simplenote.vim',
    cond = 'vim.fn.exists("g:SimplenoteUsername")',
    init = function()
      vim.g.SimplenoteFiletype = 'markdown'
      vim.api.nvim_create_user_command('SL', 'SimplenoteList', {})
      vim.api.nvim_create_user_command('SN', 'SimplenoteNew', {})
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
    config = function()
      local augend = require("dial.augend")
      augend.constant.alias.alpha.config.cyclic = true
      augend.constant.alias.Alpha.config.cyclic = true

      local augends = require("dial.config").augends
      augends.group.default = {
        augend.integer.alias.decimal,
        augend.integer.alias.binary,
        augend.integer.alias.hex,
        augend.date.alias['%Y-%m-%d'],
        augend.date.alias['%Y/%m/%d'],
        augend.hexcolor.new{ case = "lower", }, -- TODO: preserve case
        augend.constant.new{
          elements = {"true", "false"},
          word = true,
          cyclic = true,
          preserve_case = true,
        },
      }
      augends.group.visual = {}
      vim.list_extend(augends.group.visual, augends.group.default)
      vim.list_extend(augends.group.visual, {
        augend.constant.alias.alpha,
        augend.constant.alias.Alpha,
      })

      local manip = require("dial.map").manipulate
      vim.keymap.set('n',  '<C-a>', function() manip("increment", "normal") end)
      vim.keymap.set('n',  '<C-x>', function() manip("decrement", "normal") end)
      vim.keymap.set('x',  '<C-a>', function() manip("increment", "visual", "visual"); vim.fn.feedkeys('gv', 'n') end)
      vim.keymap.set('x',  '<C-x>', function() manip("decrement", "visual", "visual"); vim.fn.feedkeys('gv', 'n') end)
      vim.keymap.set('n', 'g<C-a>', function() manip("increment", "gnormal") end)
      vim.keymap.set('n', 'g<C-x>', function() manip("decrement", "gnormal") end)
      vim.keymap.set('x', 'g<C-a>', function() manip("increment", "gvisual", "visual") end)
      vim.keymap.set('x', 'g<C-x>', function() manip("decrement", "gvisual", "visual") end)
    end,
  },
  {
    'tpope/vim-fugitive',
    cmd = { 'G', 'Git' },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      local gs = require('gitsigns')
      gs.setup {
        signcolumn = true,
        numhl = false,
        attach_to_untracked = true,
      }

      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, {expr=true})

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {expr=true})

      vim.keymap.set({'n','v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', { silent = true, noremap = true })
      vim.keymap.set({'n','v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', { silent = true, noremap = true })
      vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk)
      vim.keymap.set('n', '<leader>hp', gs.preview_hunk)
      vim.keymap.set('n', '<leader>hb', function() gs.blame_line{full=true} end)
      vim.keymap.set('n', '<leader>hd', gs.diffthis)
      vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end)
      vim.keymap.set('n', '<leader>htd', gs.toggle_deleted)
      -- Text object
      vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { silent = true, noremap = true })
    end
  },
  {
    'dhruvasagar/vim-table-mode',
    config = function()
      vim.g.table_mode_corner = "|"
      vim.api.nvim_create_autocmd('Filetype', {
        pattern = { 'markdown', 'markdown_tablemode', 'mdx' },
        command = 'TableModeEnable',
      })
    end
  },
  {
    'juro106/ftjpn',
    keys = { 'f', 'F', 't', 'T' },
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
    'jasonccox/vim-wayland-clipboard',
  },
  {
    'kyoh86/vim-ripgrep',
    init = function()
      vim.cmd("command! -nargs=* -complete=file Rg :call ripgrep#search('-. ' . <q-args>)")
    end
  },
  {
    'tyru/capture.vim',
    cmd = { 'Capture' },
  },
  {
    'kawarimidoll/magic.vim',
    keys = {
      { '<C-x>', function() vim.fn['magic#expr']() end, mode = 'c' },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    keys = { '<C-p>', '<leader>f' },
    module = 'telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require"settings.telescope"
    end,
  },
  {
    'uga-rosa/ccc.nvim',
    cond = 'vim.o.termguicolors',
    event = { 'BufRead', 'BufNewFile' },
    config = function() require'settings.ccc' end,
  },
  'sharat87/roast.vim',
  'chrisbra/Recover.vim',
  {
    'rhysd/conflict-marker.vim',
    init = function()
      vim.g.conflict_marker_enable_mappings = 0
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          vim.cmd[[
            highlight ConflictMarkerBegin guibg=#2f7366
            highlight ConflictMarkerOurs guibg=#2e5049
            highlight ConflictMarkerTheirs guibg=#344f69
            highlight ConflictMarkerEnd guibg=#2f628e
            highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
          ]]
        end,
      })
    end,
  },
  {
    'bkad/CamelCaseMotion',
    init = function()
      vim.g.camelcasemotion_key = '<Leader>'
    end,
  },
}
