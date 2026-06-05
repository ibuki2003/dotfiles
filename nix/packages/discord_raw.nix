# Discord client, not patched version
# NOTE: using hacky solution; requires nix-ld to work

{ lib, pkgs, ... }:
  pkgs.discord.overrideAttrs (prev: {
    nativeBuildInputs = [
      pkgs.makeShellWrapper
      pkgs.brotli  # needed at build time: installPhase runs `brotli -d` to extract distro tarball
    ];

    # finalAttrs pattern means overriding libPath here automatically propagates to installPhase
    libPath = prev.libPath + ":" + lib.makeLibraryPath (with pkgs; [
      libxshmfence  # used by Chromium/X11, not in upstream libPath (was patched via autoPatchelfHook)
      mesa          # GPU driver libs (libGL etc.) for hardware acceleration
    ]);

    dontPatchELF = true;
    dontStrip = true;
  })
