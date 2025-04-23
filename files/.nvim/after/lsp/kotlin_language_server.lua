return {
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
}
