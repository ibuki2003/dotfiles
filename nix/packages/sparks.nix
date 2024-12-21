# Sparks font
# https://github.com/aftertheflood/sparks
{
  pkgs,
}:
pkgs.stdenv.mkDerivation {
  pname = "sparks";
  version = "v2.0";
  src = pkgs.fetchzip {
    name = "Sparks-font-complete.zip";
    url = "https://github.com/aftertheflood/sparks/releases/download/v2.0/Sparks-font-complete.zip";
    hash = "sha256-xp/rCZpitX2IZO1Tvl3Me1WSPsxy55BDDuoQzQGBlII=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/share/fonts
    cp $src/Sparks/*.otf $out/share/fonts
  '';
}
