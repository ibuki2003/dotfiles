# management of fcitx5 and fcitx5-skk settings
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption optionalString types;
  inherit (types) listOf either;
  cfg = config.programs.fcitx5;
in {
  options.programs.fcitx5 = {
    dictionaries = mkOption {
      type = listOf (either types.str types.package);
      default = [ ];
      description = "List of dictionaries to use";
    };

  };

  config = {
    xdg.dataFile = {
      "fcitx5/skk/dictionary_list" = mkIf (lib.lists.length cfg.dictionaries > 0) {
        text = let
          dictFiles = cfg.dictionaries
            |> lib.map (dict:
              if lib.isDerivation dict then
                ( let base = "${dict}/share/skk"; in
                  if (builtins.pathExists base) then
                    (
                    builtins.readDir base
                      |> lib.attrsets.mapAttrsToList (k: v: (lib.lists.optional (v=="regular") "${base}/${k}"))
                      |> lib.flatten
                    )
                  else
                    []
                )
              else
                [dict]
            )
            |> lib.flatten
            |> lib.map (file:
              if lib.strings.hasInfix "utf8" file then
                "encoding=UTF-8,file=${file},mode=readonly,type=file"
              else
                "file=${file},mode=readonly,type=file"
              );
          userDict = [ "encoding=UTF-8,file=$FCITX_CONFIG_DIR/skk/user.dict,mode=readwrite,type=file" ];
        in
          lib.concatStringsSep "\n" (
            userDict ++
            dictFiles
          );
      };
    };
  };
}


