{
  pkgs,
  sources,
  ...
}:
{
  discord = pkgs.callPackage ./discord_raw.nix { };
  poppup = pkgs.callPackage ./poppup.nix { };
  sparks = pkgs.callPackage ./sparks.nix { };
  cargo_pkgs = pkgs.callPackage ./cargo_pkgs.nix { inherit sources; };
}
