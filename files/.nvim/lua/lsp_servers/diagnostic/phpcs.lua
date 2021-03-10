register_linter(
  'phpcs',
  {
    'php',
  },
  {
    sourceName = 'phpcs',
    command = 'phpcs',
    args = { '-', '--report=csv' },
    rootPatterns = { 'phpcs.xml' },
    formatLines = 1,
    formatPattern = {
        '^"STDIN",(\\d+),(\\d+),(\\w+),"(.+?)",([\\w.]+),\\d+,\\d+$',
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

register_formatter('phpcbf',
  {
    'php',
  },
  {
    rootPatterns = { 'phpcs.xml' },
    command = 'sh',
    args = { '-c', 'phpcbf - -q || true' },
    isStdout = true,
    isStderr = true,
})
