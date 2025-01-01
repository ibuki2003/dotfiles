{
  pkgs,
  sources,
  ...
}:
{
  discord = pkgs.callPackage ./discord_raw.nix {};
  nil = pkgs.callPackage ./nil.nix { inherit sources; };
  sparks = pkgs.callPackage ./sparks.nix {};
}
