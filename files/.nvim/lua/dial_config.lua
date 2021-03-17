local dial = require("dial")

dial.augends["custom#boolean"] = dial.common.enum_cyclic{
  name = "boolean",
  strlist = {"true", "false"},
}

dial.augends["custom#boolean_python"] = dial.common.enum_cyclic{
  name = "boolean_python",
  strlist = {"True", "False"},
}

dial.config.searchlist.normal = {
  "number#decimal",
  "number#hex",
  "number#binary",
  "custom#boolean",
  "custom#boolean_python",
  "color#hex",
  "char#alph#small#word",
  "char#alph#capital#word",
  "date#[%Y/%m/%d]",
  "date#[%Y-%m-%d]",
  "date#[%H:%M:%S]",
  "date#[%M:%S]",
  "markup#markdown#header",
}

dial.config.searchlist.visual = {
  "number#decimal",
  "number#hex",
  "number#binary",
  "custom#boolean",
  "custom#boolean_python",
  "color#hex",
  "char#alph#small#str",
  "char#alph#capital#str",
  "date#[%Y/%m/%d]",
  "date#[%Y-%m-%d]",
  "date#[%H:%M:%S]",
  "date#[%M:%S]",
  "markup#markdown#header",
}
