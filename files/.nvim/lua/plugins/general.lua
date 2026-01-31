return {
  'vim-jp/vimdoc-ja',
  { 'vim-denops/denops.vim', priority = 1000 },

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
    'kana/vim-operator-replace',
    keys = {
      { '<leader>r', '<Plug>(operator-replace)', mode = { 'n', 'x' } },
    },
    dependencies = { 'kana/vim-operator-user' },
  },
  {
    'fuenor/im_control.vim',
    event = 'InsertEnter',
    init = function()
      if vim.fn.executable('fcitx-remote') == 1 then
        vim.g.IM_CtrlMode = 6
      elseif vim.fn.executable('fcitx5-remote') == 1 then
        _G.IMCtrl = function (cmd)
          local c = ({ On = ' -o', Off = ' -c', Toggle = ' -t', })[cmd] or ''
          vim.fn.system('fcitx5-remote ' .. c  .. ' > /dev/null 2>&1 ' .. vim.g.IM_CtrlAsync)
          return ''
        end
        vim.cmd[[
        silent! function! IMCtrl(cmd)
          return v:lua.IMCtrl(a:cmd)
        endfunction
        ]]
        vim.g.IM_CtrlMode = 1
      end
      vim.g.IM_vi_CooperativeMode = 1
      vim.g.IM_JpFixModeAutoToggle = 0
      vim.g.IM_CtrlBufLocalMode = 1
      vim.api.nvim_set_keymap('i', '<C-k>', '<C-r>=IMState("FixMode")<CR>', { noremap = true, silent = true })
    end
  },
  {
    'tpope/vim-fugitive',
    cmd = { 'G', 'Git' },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufRead', 'BufNewFile' },
    opts = function() return require'settings.gitsigns' end,
  },
  {
    'jasonccox/vim-wayland-clipboard',
  },
  {
    'kyoh86/vim-ripgrep',
    command = { 'Rg' },
    init = function()
      vim.cmd([[command! -nargs=* -complete=file Rg :call ripgrep#search("--glob '!.git' -. " . <q-args>)]])
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
    'uga-rosa/ccc.nvim',
    cond = 'vim.o.termguicolors',
    event = { 'BufRead', 'BufNewFile' },
    config = function() require'settings.ccc' end,
  },
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
    'gamoutatsumi/dps-ghosttext.vim',
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- to use release
    lazy = true,
    event = {
      "BufReadPre /home/fuwa/Notes/**.md",
      "BufNewFile /home/fuwa/Notes/**.md",
    },
    cmd = {
      "ObsidianNew",
      "ObsidianQuickSwitch",
      "ObsidianToday",
      "ObsidianYesterday",
      "ObsidianTomorrow",
      "ObsidianSearch",
    },
    keys = {
      { '<Leader>fn', '<cmd>ObsidianQuickSwitch<CR>', mode = 'n' },
      { '<Leader>fN', '<cmd>ObsidianSearch<CR>', mode = 'n' },
    },
    dependencies = { "nvim-lua/plenary.nvim", },
    opts = {
      ui = {
        enable = false,
      },
      workspaces = {
        {
          name = "main",
          path = "~/Notes/main",
        },
      },
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = nil
      },
      finder = "telescope.nvim",
      note_frontmatter_func = function(note)
        local out = { tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do out[k] = v end
        end
        return out
      end,
      note_id_func = function(title)
        if title ~= nil then
          return title:gsub("%s+", "-"):lower()
        else
          local s = ""
          for _ = 1, 4 do
            s = s .. string.char(math.random(97, 122))
          end
        end
      end,
    },
  },
  {
    'tani/dmacro.nvim',
    event = { 'VimEnter' },
    config = function()
      vim.keymap.set({ 'i', 'n' }, '<C-q>', '<Plug>(dmacro-play-macro)', { noremap = true })
    end,
  },
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle' },
    keys = { {'<leader>u', '<cmd>UndotreeToggle<CR>', mode = 'n'} },
    init = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_DiffCommand = 'diff -u'
    end,
  },
  'rbtnn/vim-ambiwidth',
  'google/vim-searchindex',
  {
    'qpkorr/vim-bufkill',
    init = function()
      vim.g.BufKillCreateMappings = 0
      vim.keymap.set("ca", "bd", function()
        if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "bd" then
          return "BD" -- redirect to custom command
        else
          return "bd"
        end
      end, { expr = true })
    end,
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = { 'qf' },
  },
  {
    'itchyny/vim-qfedit',
    -- TODO: undo not working for now
    ft = { 'qf' },
  },
  {
    'thinca/vim-qfreplace',
    ft = { 'qf' },
  },
  {
    "vim-scripts/MultipleSearch",
  }
}
