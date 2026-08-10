{
  sources,
  ...
}:
(self: super: {
  cargo-binutils = super.rustPlatform.buildRustPackage (
    let
      old = super.cargo-binutils;
    in
    rec {
      inherit (old) pname meta;
      version = "0.4.0";
      src = super.fetchCrate {
        inherit pname version;
        hash = "sha256-AF1MRBH8ULnHNHT2FS/LxMH+b06QMTIZMIR8mmkn17c=";
      };
      cargoHash = "sha256-pK6pFgOxQdEc4hYFj6mLEiIuPhoutpM2h3OLZgYrf6Q=";
    }
  );
  quickshell = super.quickshell.overrideAttrs (oldAttrs: {
    src = sources.quickshell.src;
    buildInputs = oldAttrs.buildInputs ++ [
      super.polkit
      (super.cpptrace.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags ++ [
          (super.lib.cmakeBool "CPPTRACE_UNWIND_WITH_LIBUNWIND" true)
        ];
        buildInputs = old.buildInputs ++ [ super.libunwind ];
      }))
    ];
  });
  niri = super.niri.overrideAttrs (
    finalAttrs: prevAttrs: {
      src = sources.niri.src;
      cargoDeps = super.rustPlatform.importCargoLock sources.niri.cargoLock."Cargo.lock";
      postPatch = ''
        patchShebangs resources/niri-session
        substituteInPlace resources/niri.service \
          --replace-fail 'ExecStart=niri' "ExecStart=$out/bin/niri"
      '';
      patches = [
        (super.writeText "loglevel.patch" ''
          diff --git a/src/utils/spawning.rs b/src/utils/spawning.rs
          index 2c7ae454..4ee422d5 100644
          --- a/src/utils/spawning.rs
          +++ b/src/utils/spawning.rs
          @@ -445,6 +445,7 @@ mod systemd {
                   let properties: &[_] = &[
                       ("PIDs", Value::new(pids)),
                       ("CollectMode", Value::new("inactive-or-failed")),
          +            ("LogLevelMax", Value::new(5i32)), // notice
                   ];
                   let aux: &[(&str, &[(&str, Value)])] = &[];
        '')
      ];

    }
  );
})
