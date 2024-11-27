local ccc = require("ccc")
local mapping = require("ccc.mapping")

ccc.setup({
  bar_len = 64,
  highlighter = {
      auto_enable = true,
      lsp = true,
  },
  recognize = {
    input = true,
    output = true,
  },
  inputs = {
    ccc.input.rgb,
    ccc.input.hsl,
    ccc.input.hsv,
    ccc.input.hsluv,
    ccc.input.oklab,
    ccc.input.oklch,
    ccc.input.cmyk,
  },
  outputs = {
    ccc.output.hex,
    ccc.output.hex_short,
    ccc.output.css_rgb,
    ccc.output.css_hsl,
    ccc.output.css_oklab,
    ccc.output.css_oklch,
    ccc.output.float,
  },
  mappings = {
    ["l"] = mapping.increase1,
    ["L"] = mapping.increase10,
    ["h"] = mapping.decrease1,
    ["H"] = mapping.decrease10,
  },
})
