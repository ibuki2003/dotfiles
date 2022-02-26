local function register(register_linter, register_formatter)
  register_formatter(
    'prettier',
    {
      'typescriptreact',
    },
    {
      rootPatterns = {
        'prettierrc',
        '.prettierrc.json', '.prettierrc.yml', '.prettierrc.yaml', '.prettierrc.json5',
        '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.config.js', '.prettierrc.config.cjs',
        '.prettierrc.toml',
        'package.json',
      },
      command = 'prettier',
      args = { '--stdin-filepath=%filename' },
      isStdout = true,
  })
end
return register
