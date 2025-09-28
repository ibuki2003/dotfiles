{
  pkgs,
  sources,
}:
let
  lib = pkgs.lib;

  # Generic Rust package builder using nvfetcher-generated sources
  # Usage example (crate from crates.io):
  #   mytool = mkRust "mytool" sources.mytool { };
  # Usage example (GitHub repo):
  #   other = mkRust "other" sources.other { };
  # Provide cargoHash when you’ve computed it; defaults to lib.fakeHash to allow prefetch.
  mkRust = name: srcDef: {
    cargoHash ? lib.fakeHash,
    buildInputs ? [ ],
    nativeBuildInputs ? [ ],
    doCheck ? false,
    meta ? { },
    # Extra args passthrough if needed
    extraArgs ? { },
  }:
    let
      cargoLockArg = lib.optionalAttrs (srcDef ? cargoLock && srcDef.cargoLock ? "Cargo.lock") {
        cargoLock = srcDef.cargoLock."Cargo.lock";
      };
    in pkgs.rustPlatform.buildRustPackage (
      ({
        pname = name;
        inherit (srcDef) version src;
        inherit cargoHash buildInputs nativeBuildInputs doCheck;
        meta = { mainProgram = name; } // meta;
      }
      // cargoLockArg
      // extraArgs)
    );
in
{
  memvis = mkRust "memvis" sources.memvis { };
  slice = mkRust "slice" sources.slice { };
  cargo-asm = mkRust "cargo-asm" sources.cargo-asm { };
  cargo-call-stack = mkRust "cargo-call-stack" sources.cargo-call-stack { };
  cargo-disasm = mkRust "cargo-disasm" sources.cargo-disasm { };
  cargo-generate = mkRust "cargo-generate" sources.cargo-generate { };
  defmt-print = mkRust "defmt-print" sources.defmt-print {
    extraArgs = {
      cargoBuildFlags = [ "-p" "defmt-print" ];
    };
  };
  ccsum = mkRust "ccsum" sources.ccsum { };

  nu-plugin-bexpand = mkRust "nu-plugin-bexpand" sources.nu-plugin-bexpand { meta = { mainProgram = "nu_plugin_bexpand"; }; };
}
