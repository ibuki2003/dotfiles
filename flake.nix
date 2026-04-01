{
  description = "fuwa dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
      system = "x86_64-linux";
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
        inputs.nil.overlays.nil
        (self: super: {
          cargo-binutils = super.rustPlatform.buildRustPackage (
            let old = super.cargo-binutils; in rec {
              inherit (old) pname meta;
              version = "0.4.0";
              src = super.fetchCrate {
                inherit pname version;
                hash = "sha256-AF1MRBH8ULnHNHT2FS/LxMH+b06QMTIZMIR8mmkn17c=";
              };
              cargoHash = "sha256-pK6pFgOxQdEc4hYFj6mLEiIuPhoutpM2h3OLZgYrf6Q=";
            });
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
          niri = super.niri.overrideAttrs (finalAttrs: prevAttrs: {
            src = sources.niri-blur-3483.src;
            cargoDeps = super.rustPlatform.importCargoLock sources.niri-blur-3483.cargoLock."Cargo.lock";
            postPatch = ''
            patchShebangs resources/niri-session
            substituteInPlace resources/niri.service \
              --replace-fail 'ExecStart=niri' "ExecStart=$out/bin/niri"
            '';
            patches = [ (super.writeText "loglevel.patch" ''
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
              '') ];

          });
        })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        allowUnfree = true;
      };
      sources = pkgs.callPackage ./nix/_sources/generated.nix {};
    in
  {

    nixosConfigurations = pkgs.lib.attrsets.mapAttrs (k: v: inputs.nixpkgs.lib.nixosSystem ({
      system = "x86_64-linux";
      modules = [
        (_: { nixpkgs.overlays = overlays; })
      ] ++ v.modules;
      specialArgs = {
        inherit inputs sources;
      };
    })) {
      fuwavermeer-nix = { modules = [ ./nix/nixos/hosts/fuwavermeer.nix ]; };
      fuwathink10-nix = { modules = [ ./nix/nixos/hosts/fuwathink10.nix ]; };
    };

    homeConfigurations = {
      fuwa = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs sources;
        };
        modules = [
          inputs.nix-index-database.homeModules.nix-index
          ./nix/home/desktop.nix
        ];
      };
      headless = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs sources;
        };
        modules = [
          inputs.nix-index-database.homeModules.nix-index
          ./nix/home/base.nix
        ];
      };

      # fuwa@host = headless; # aliases here like this
    };

    apps.${system} = {
      nvfetcher = {
        type = "app";
        program = toString (pkgs.writeShellScript "nvfetcher" ''
          ${pkgs.nvfetcher}/bin/nvfetcher \
            -c ./nix/nvfetcher.toml \
            -o ./nix/_sources \
            "$@"
        '');
      };
    };
  };
}
