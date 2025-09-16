{
  pkgs,
  sources,
  ...
}:
{
  discord = pkgs.callPackage ./discord_raw.nix {};
  sparks = pkgs.callPackage ./sparks.nix {};
  cargo_pkgs = pkgs.callPackage ./cargo_pkgs.nix { inherit sources; };
}
