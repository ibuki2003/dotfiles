# management of xdg autostart
{ config, lib, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.xdg.autostart.files;
in {
  options.xdg.autostart.files = mkOption {
    type = with types; listOf (either str package);
    default = [];
    description = "Desktop files";
  };

  config.xdg.configFile =
    let
      files = map (entry: (
        if lib.isDerivation entry then
          # entry is a package
          builtins.head (lib.filesystem.listFilesRecursive "${entry}/share/applications")
        else
          # assume entry is a path
          entry
        )) cfg;
    in
      builtins.listToAttrs
        (map
          (file: lib.nameValuePair
            (builtins.unsafeDiscardStringContext ("autostart/" + (builtins.baseNameOf file)))
            { source = file; })
          files);
}
