return function(packer)
  packer.use{
    'vim-jp/vimdoc-ja',
    'vim-denops/denops.vim',
    'sheerun/vim-polyglot',

    {
      'tpope/vim-surround',
    },
    {
      'tpope/vim-commentary',
    },
    {
      'Shougo/context_filetype.vim',
    },
    {
      'osyo-manga/vim-precious',
      after = { 'context_filetype.vim' },
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

        local function dial_incr(mode, direction)
          local cmd = require'dial.command'
          local stairlike = mode == 'vg'
          direction = (direction == 'inc') and 'increment' or 'decrement'
          if mode == 'n' then
            cmd.operator_normal(direction)
          else
            cmd.operator_visual(direction, stairlike)
          end
        end
        local function callback(mode, dir)
          local cmd = require'dial.command'
          return function()
            if mode == 'n' then
              cmd.select_augend_normal()
            else
              cmd.select_augend_visual('visual')
            end
            -- vim.o.operatorfunc = 'v:lua.dial_increment.' .. mode .. '_' .. dir
            _G.dial_increment = function() dial_incr(mode, dir) end
            vim.o.operatorfunc = 'v:lua.dial_increment'
            local retval = 'g@'
            if mode == 'n' then
              retval = retval .. "<Cmd>lua require('dial.command').textobj()<CR>"
            elseif mode == 'v' then
              retval = retval .. "gv"
            end
            return retval
          end
        end

        vim.api.nvim_set_keymap('n',  '<C-a>', '', { expr = true, replace_keycodes = true, callback = callback('n',  'inc') })
        vim.api.nvim_set_keymap('n',  '<C-x>', '', { expr = true, replace_keycodes = true, callback = callback('n',  'dec') })
        vim.api.nvim_set_keymap('x',  '<C-a>', '', { expr = true, replace_keycodes = true, callback = callback('v',  'inc') })
        vim.api.nvim_set_keymap('x',  '<C-x>', '', { expr = true, replace_keycodes = true, callback = callback('v',  'dec') })
        vim.api.nvim_set_keymap('x', 'g<C-a>', '', { expr = true, replace_keycodes = true, callback = callback('vg', 'inc') })
        vim.api.nvim_set_keymap('x', 'g<C-x>', '', { expr = true, replace_keycodes = true, callback = callback('vg', 'dec') })
      end,
    },
    -- {
    --   'kana/vim-textobj-user',
    -- },
    {
      'whatyouhide/vim-textobj-xmlattr',
      requires = { 'kana/vim-textobj-user' },
      after = { 'vim-textobj-user' },
    },
    {
      'subnut/nvim-ghost.nvim',
      run=':call nvim_ghost#installer#install()',
    },
    {
      'ctrlpvim/ctrlp.vim',
      setup = function()
        vim.g.ctrlp_working_path_mode = 'ra'
        vim.g.ctrlp_cmd = 'CtrlP'
        vim.g.ctrlp_extensions = { 'mixed', 'allfile' }
        vim.g.ctrlp_types = { 'mixed', 'allfile' }

        vim.g.ctrlp_user_command = {
          types = {
            {
              '.git',
              (vim.fn.executable('fd')
                and 'fd . %s -t f -HL -E \\.git'
                or  'cd %s && git ls-files -co --exclude-standard')
            },
          },
          fallback = (vim.fn.executable('fd')
            and 'fd . %s -t f -HL -E \\.git'
            or  'find %s -type f -follow'),
        }
      end
    },
    {
      'tpope/vim-fugitive',
      cmd = { 'G', 'Git' },
    },
    {
      'lewis6991/gitsigns.nvim',
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
      cond = 'vim.o.termguicolors',
      run = [[make hexokinase]],
      setup = function()
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
      'cohama/lexima.vim',
      setup = function()
        vim.g.lexima_accept_pum_with_enter = 0
        vim.g.lexima_enable_space_rules = 0
        vim.g.lexima_enable_endwise_rules = 0
      end,
    },
  }
end
