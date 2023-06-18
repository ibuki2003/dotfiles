return function(packer)
  packer.use{
    'vim-jp/vimdoc-ja',
    'vim-denops/denops.vim',
    'sheerun/vim-polyglot',

    {
      'machakann/vim-sandwich',
      config = function()
        vim.g.sandwich_no_default_key_mappings = 1
        vim.g['sandwich#input_fallback'] = 0
        vim.fn['operator#sandwich#set']('delete', 'all', 'hi_duration', 50)


        vim.keymap.set('n', 's', '<Plug>(sandwich-add)', { noremap = false })
        vim.keymap.set('n', 'S', '<Plug>(sandwich-add)g_', { noremap = false })
        vim.keymap.set('x', 's', '<Plug>(sandwich-add)', { noremap = false })

        vim.keymap.set('n', 'ds', '<Plug>(sandwich-delete)', { noremap = false })
        vim.keymap.set('n', 'dsb', '<Plug>(sandwich-delete-auto)', { noremap = false })
        vim.keymap.set('n', 'cs', '<Plug>(sandwich-replace)', { noremap = false })
        vim.keymap.set('n', 'csb', '<Plug>(sandwich-replace-auto)', { noremap = false })
        vim.keymap.set('n', 'sr', '<Plug>(sandwich-replace)', { noremap = false })
        vim.keymap.set('n', 'srb', '<Plug>(sandwich-replace-auto)', { noremap = false })

        vim.keymap.set('o', 'ib', '<Plug>(textobj-sandwich-auto-i)', { noremap = false })
        vim.keymap.set('x', 'ib', '<Plug>(textobj-sandwich-auto-i)', { noremap = false })
        vim.keymap.set('o', 'ab', '<Plug>(textobj-sandwich-auto-a)', { noremap = false })
        vim.keymap.set('x', 'ab', '<Plug>(textobj-sandwich-auto-a)', { noremap = false })

        vim.keymap.set('o', 'is', '<Plug>(textobj-sandwich-query-i)', { noremap = false })
        vim.keymap.set('x', 'is', '<Plug>(textobj-sandwich-query-i)', { noremap = false })
        vim.keymap.set('o', 'as', '<Plug>(textobj-sandwich-query-a)', { noremap = false })
        vim.keymap.set('x', 'as', '<Plug>(textobj-sandwich-query-a)', { noremap = false })

        local recipes = {
          { buns = {"(\\s*", "\\s*)"}, nesting = 1, regex = 1, match_syntax = 1, kind = {"delete", "replace", "textobj"}, action = {"delete"}, input = {"("} },
        }

        for _, k in ipairs({ {'{','}'}, {'[',']'} }) do
          local op = k[1]
          local cl = k[2]
          table.insert(recipes, {
              buns = { op .. " ", " " .. cl },
              nesting = 1,
              match_syntax = 1,
              motionwise = { 'char', 'block' }, -- not line
              kind = { "add", "replace" },
              action = { "add" },
              input = { op }
            })
          table.insert(recipes, {
              buns = { op, cl },
              nesting = 1,
              match_syntax = 1,
              motionwise = { 'line' }, -- line
              kind = { "add", "replace" },
              action = { "add" },
              input = { op }
            })
          table.insert(recipes, {
              buns = { op .. "\\s*", "\\s*" .. cl },
              nesting = 1,
              regex = 1,
              match_syntax = 1,
              motionwise = { 'char', 'block' }, -- not line
              kind = { "delete", "replace", "textobj" },
              action = { "delete" },
              input = { op }
              })
        end
        vim.g['sandwich#recipes'] = vim.list_extend(vim.g['sandwich#default_recipes'], recipes)
      end,
    },
    {
      'tpope/vim-commentary',
    },
    {
      'Shougo/context_filetype.vim',
      opt = true,
    },
    {
      'osyo-manga/vim-precious',
      opt = true,
      wants = { 'context_filetype.vim' },
      event = 'CursorMoved',
      cmd = { 'PreciousSwitch', 'PreciousReset' },
      setup = function()
        -- insert mode に入った時に 'filetype' を切り換える。
        -- カーソル移動時の自動切り替えを無効化
        vim.g.precious_enable_switch_CursorMoved = {
          ['*'] = 0,
          help = 1,
        }
        vim.g.precious_enable_switch_CursorMoved_i = {
          ['*'] = 0,
        }

        -- insert に入った時にスイッチし、抜けた時に元に戻す
        vim.cmd[[
        augroup fuwa_precious
        autocmd!
        autocmd InsertEnter * :PreciousSwitch
        " autocmd InsertLeave * :PreciousReset
        augroup END
        ]]
      end
    },
    {
      'editorconfig/editorconfig-vim',
    },
    {
      'tpope/vim-repeat',
    },
    {
      'simeji/winresizer',
      setup = function()
        vim.g.winresizer_vert_resize = 1
        vim.g.winresizer_horiz_resize = 1
      end
    },
    {
      'wakatime/vim-wakatime',
    },
    {
      'machakann/vim-highlightedyank',
      setup = function()
        vim.g.highlightedyank_highlight_duration = 300
      end
    },
    {
      'kana/vim-operator-user',
    },
    {
      'kana/vim-operator-replace',
      keys = { '<Plug>(operator-replace)' },
      setup = function()
        vim.keymap.set("n", "<Leader>r", "<Plug>(operator-replace)")
      end
    },
    {
      'mattn/emmet-vim',
    },
    {
      'junegunn/vim-easy-align',
      setup = function()
        vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
        vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
        vim.g.easy_align_ignore_groups = {'String'}
      end
    },
    {
      'terryma/vim-expand-region',
      keys = { '<Plug>(expand_region_expand)', '<Plug>(expand_region_shrink)' },
      setup = function()
        vim.cmd[[
        vmap v <Plug>(expand_region_expand)
        vmap <C-v> <Plug>(expand_region_shrink)
        ]]
      end
    },
    {
      'fuenor/im_control.vim',
      event = 'InsertEnter',
      opt = 1,
      setup = function()
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
      setup = function()
        vim.g.SimplenoteFiletype = 'markdown'
        vim.api.nvim_create_user_command('SL', 'SimplenoteList', {})
        vim.api.nvim_create_user_command('SN', 'SimplenoteNew', {})
      end
    },
    {
      'monaqa/dial.nvim',
      keys = { '<C-a>', '<C-x>', 'g<C-a>', 'g<C-x>' },
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
      'kana/vim-textobj-user',
    },
    {
      'whatyouhide/vim-textobj-xmlattr',
      -- wants = { 'vim-textobj-user' },
    },
    {
      'subnut/nvim-ghost.nvim',
      run=':call nvim_ghost#installer#install()',
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
      'RRethy/vim-hexokinase',
      event = { 'VimEnter' },
      cond = 'vim.o.termguicolors',
      run = [[make hexokinase]],
      setup = function()
        vim.g.Hexokinase_optInPatterns = {
          'full_hex',
          'triple_hex',
          'rgb',
          'rgba',
          'hsl',
          'hsla',
          -- 'colour_names'
        }
        vim.g.Hexokinase_highlighters = { 'backgroundfull' }
      end,
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
      setup = function()
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
      setup = function()
        vim.cmd("command! -nargs=* -complete=file Rg :call ripgrep#search('-. ' . <q-args>)")
      end
    },
    {
      'tyru/capture.vim',
    },
    {
      'andymass/vim-matchup',
      setup = function()
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
      end,
      config = function()
        require'nvim-treesitter.configs'.setup {
          matchup = {
            enable = true,
          },
        }
      end,
    },
    { 'bennypowers/splitjoin.nvim',
      keys = { '<leader>j', '<leader>,' },
      config = function()
        local splitjoin = require'splitjoin'
        vim.keymap.set('n', '<leader>j', splitjoin.join)
        vim.keymap.set('n', '<leader>,', splitjoin.split)
      end,
    },
    {
      'kawarimidoll/magic.vim',
      config = function()
        vim.keymap.set('c', '<C-x>', function() vim.fn['magic#expr']() end)
      end,
    },
    {
      'nvim-telescope/telescope.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = function()
        require('telescope').setup {
          defaults = {
            mappings = {
              i = {
                ['<C-h>'] = 'which_key',
                ['<Esc>'] = 'close',
                ['<C-u>'] = false,
              },
            },
          },
        }

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>',      builtin.find_files, {})
        vim.keymap.set('n', '<leader>fF', function() builtin.find_files({ no_ignore = true }) end, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      end,
    },
  }
end
