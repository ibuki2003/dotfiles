vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    require("neodev").setup{}
  end,
})

local lspconfig = require('lspconfig')

local servers = {
  efm = require('settings.lsp.efm'),

  vimls = {},
  intelephense = {},
  clangd = { capabilities = { offsetEncoding = 'utf-8' } },
  pylsp = {
    settings = {
      pylsp = {
        plugins = { pycodestyle = { enabled = false } }
      }
    }
  },
  pylyzer = {},
  pyright = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
        },
      },
    },
  },
  eslint = {},
  texlab = {},
  gopls = {},
  arduino_language_server = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        completion = {
          callSnippet = "Replace",
        }
      }
    },
  },
  astro = {},

  tsserver = {
    root_dir = function(fname, buf)
      if fname and vim.endswith(fname, '.vue') then return nil end
      return lspconfig.util.root_pattern("package.json", "node_modules")(fname, buf)
    end,
    single_file_support = false,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      },
    },
  },
  denols = {
    root_dir = function(fname, buf)
      if lspconfig.util.root_pattern("package.json", "node_modules")(fname, buf) ~= nil then
        return nil
      end
      local r = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "tsconfig.json", ".git")(fname, buf)
      if r ~= nil then
        return r
      end
      -- single file support
      return lspconfig.util.path.dirname(fname)
    end,
    single_file_support = false,
  },
  volar = {
    filetypes = { 'vue' },
  },
  emmet_ls = {
    filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue" },
    init_options = {
      html = {
        options = {
          -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
          ["bem.enabled"] = true,
        },
      },
    }
  },
  kotlin_language_server = {
    languages = { "kotlin" },
    -- root_dir = lspconfig.util.root_pattern("build.gradle", "settings.gradle"),
    settings = {
      kotlin = {
        compiler = {
          jvm = {
            target = "1.8";
          }
        }
      }
    },
  },
}

local _cap = nil
local cap = function()
  if _cap == nil then
    _cap = require("cmp_nvim_lsp").default_capabilities()
  end
  return _cap
end

local setup_done = {}
local setup = function(name)
  if setup_done[name] then return end
  setup_done[name] = true

  local opt = vim.tbl_deep_extend('keep',
    servers[name],
    {
      capabilities = cap(),
    }
  )
  local t = vim.uv.hrtime()
  lspconfig[name].setup(opt)
  lspconfig[name].launch()
end

for lsp, _ in pairs(servers) do
  local fts = servers[lsp].filetypes or require('lspconfig.server_configurations.' .. lsp).default_config.filetypes

  if not fts then
    setup(lsp)
  else
    for _, lang in ipairs(fts) do
      vim.api.nvim_create_autocmd('FileType', {
        pattern = lang,
        once = true,
        callback = function() setup(lsp) end,
      })
    end
  end
end
