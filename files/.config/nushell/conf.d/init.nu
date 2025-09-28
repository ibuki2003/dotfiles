source ./basic.nu
source ./appearance.nu
source ./fzf.nu

# HACK: Load local config if it exists
const path = "~/.config/nushell/conf.d/local.nu"
const file = if ($path | path expand | path exists) { $path }
source $file

use std/dirs

