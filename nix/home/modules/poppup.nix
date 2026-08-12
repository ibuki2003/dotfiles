{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
  cfg = config.programs.poppup;
in
{
  options.programs.poppup = {
    browser = mkOption {
      type =
        with types;
        nullOr (oneOf [
          str
          package
        ]);
      default = null;
      description = "Browser used to open URLs";
    };
    entries = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Name displayed in the application launcher";
            };

            url = mkOption {
              type = types.str;
              description = "URL opened by Poppup";
            };
          };
        }
      );
      default = { };
      description = "Desktop entries opened by Poppup";
    };
  };

  config.xdg.desktopEntries =
    let
      browser =
        if cfg.browser != null then
          cfg.browser
        else if config.home.sessionVariables ? BROWSER then
          config.home.sessionVariables.BROWSER
        else
          "xdg-open";
    in
    lib.mapAttrs' (
      id: entry:
      lib.nameValuePair "poppup-${id}.desktop" {
        inherit (entry) name;
        exec = toString (pkgs.writeShellScript "poppup-${id}" (
          lib.strings.escapeShellArgs [
            browser
            "ext+poppup:?id=${lib.strings.escapeURL id}&url=${lib.strings.escapeURL entry.url}"
          ]
        ));
      }
    ) cfg.entries;
}
