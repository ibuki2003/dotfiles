register_linter(
  'eslint',
  {
    'javascript',
    'javascript.tsx',
    'javascriptreact',
    'typescript',
    'typescript.tsx',
    'typescriptreact',
  },
  {
    sourceName = 'eslint',
    command = 'eslint_d',
    args = { '--stdin', '--stdin-filename=%filename', '--no-color' },
    rootPatterns = { '.eslintrc', '.eslintrc.js' },
    formatLines = 1,
    formatPattern = {
        '^\\s*(\\d+):(\\d+)\\s+([^ ]+)\\s+(.*?)\\s+([^ ]+)$',
        {
            line     = 1,
            column   = 2,
            message  = {4, ' [', 5, ']' },
            security = 3
        }
    },
    securities = {
        error   = 'error',
        warning = 'warning'
    },
})

register_formatter('eslint',
  {
    'javascript',
    'javascript.tsx',
    'javascriptreact',
    'typescript',
    'typescript.tsx',
    'typescriptreact',
  },
  {
    rootPatterns = { '.eslintrc', '.eslintrc.js' },
    command = 'eslint_d',
    args = { '--fix', '--fix-to-stdout', '--stdin', '--stdin-filename=%filename' },
    isStdout = true,
    isStderr = true,
})
