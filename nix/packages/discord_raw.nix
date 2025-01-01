# Discord client, not patched version
# NOTE: using hacky solution; requires nix-ld to work

{ lib, pkgs, ... }:
let
  # remove specific commands in the build script
  banCommand = cmd: script: lib.strings.concatLines
      (builtins.foldl' (s: l:
        let
          m = s.cont || (lib.strings.hasPrefix (cmd + " ") l);
          c = lib.strings.hasSuffix "\\" l;
        in
          {
            cont = m && c;
            lines = s.lines ++ (if m then [] else [l]);
          })
        { cont = false; lines = []; }
        (lib.splitString "\n" script)
      ).lines;
  version = "0.0.78";
  src = pkgs.fetchzip {
    url = "https://stable.dl2.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-Qlos8S8amL3iDelNK57M00tl3obfEI9tO7q+3ljgbMc=";
  };
in
  pkgs.discord.overrideAttrs (prev: rec {
      inherit src version;
      nativeBuildInputs = [ pkgs.makeShellWrapper ];

      # add missing dependencies
      libPath = prev.libPath + lib.makeLibraryPath (with pkgs; [
        alsa-lib
        libdrm
        libxkbcommon
        xorg.libXdamage
        xorg.libX11
        xorg.libxcb
        xorg.libxshmfence
        mesa
        nss
      ]);

      installPhase = builtins.replaceStrings [prev.libPath] [libPath]
        (banCommand "patchelf" prev.installPhase);
      dontPatchELF = true;
      dontStrip = true;
    })
