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
    -- {
    --   'simplenote-vim/simplenote.vim',
    --   cond = 'exists("g:SimplenoteUsername")',
    --   setup = function()
    --     vim.g.SimplenoteFiletype = 'markdown'
    --     -- let g:SimplenoteFiletype = "markdown"

    --     vim.api.nvim_create_user_command('SL', 'SimplenoteList', true)
    --     vim.api.nvim_create_user_command('SN', 'SimplenoteNew', true)
    --   end

    -- },
    {
      'monaqa/dps-dial.vim',
      setup = function()
        vim.g['dps_dial#augends'] = {
          'decimal',
          'binary',
          'hex',
          'date-hyphen',
          'date-slash',
          'color',
          { kind= 'constant', opts= {
              elements= { 'true', 'false' },
              cyclic= true,
              word= true,
          }},
          { kind= 'constant', opts= {
              elements= { 'True', 'False' },
              cyclic= true,
              word= true,
          }},
        }
        vim.g['dps_dial#augends#register#v'] = vim.tbl_extend('force',
          vim.g['dps_dial#augends'],
          {
            'alpha', 'Alpha',
          }
        )
      -- end,
      -- config = function()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'DenopsPluginPost:dial',
          callback = function()
            -- modify table partially fails in lua
            vim.cmd[[
            let g:dps_dial#aliases.alpha.opts.cyclic = v:true
            let g:dps_dial#aliases.Alpha.opts.cyclic = v:true
            ]]
          end,
        })
        vim.api.nvim_set_keymap('n',  '<C-a>',    '<Plug>(dps-dial-increment)', { noremap = true })
        vim.api.nvim_set_keymap('n',  '<C-x>',    '<Plug>(dps-dial-decrement)', { noremap = true })
        vim.api.nvim_set_keymap('x',  '<C-a>',  '"v<Plug>(dps-dial-increment)gv', { noremap = true })
        vim.api.nvim_set_keymap('x',  '<C-x>',  '"v<Plug>(dps-dial-decrement)gv', { noremap = true })
        vim.api.nvim_set_keymap('x', 'g<C-a>', '"vg<Plug>(dps-dial-increment)', { noremap = true })
        vim.api.nvim_set_keymap('x', 'g<C-x>', '"vg<Plug>(dps-dial-decrement)', { noremap = true })
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
      'airblade/vim-gitgutter',
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
  }
end
