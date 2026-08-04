{
  lib,
  pkgs,
  inputs,
  ...
}@args:
let
  trimFirstLine =
    text: if lib.hasPrefix " " text then trimFirstLine (lib.removePrefix " " text) else text;

  localPkgs = pkgs // {
    writeText =
      name: text:
      pkgs.writeText name (
        if lib.hasPrefix "deferred-" name && lib.hasInfix "-wrapper-" name then trimFirstLine text else text
      );
  };
in
(import "${inputs.deferred-apps}/modules/home-manager.nix") (args // { pkgs = localPkgs; })
